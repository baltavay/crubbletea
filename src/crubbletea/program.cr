require "signal"

class Crubbletea::Program(M)
  @model : M
  @msgs : Channel(Msg)
  @errs : Channel(Exception)
  @running : Bool = false
  @input_parser : InputParser
  @renderer : Renderer?
  @width : Int32 = 80
  @height : Int32 = 24
  @old_termios : LibC::Termios?
  @stdin_fd : Int32
  @stdout_fd : Int32
  @filter : (Msg -> Msg)?
  @escape_timer_active : Bool = false

  def initialize(
    @model : M,
    @filter : (Msg -> Msg)? = nil
  )
    @msgs = Channel(Msg).new(256)
    @errs = Channel(Exception).new(1)
    @input_parser = InputParser.new
    @stdin_fd = 0
    @stdout_fd = 1
  end

  def run : Nil
    @running = true

    old_termios = Termios.enter_raw(@stdin_fd)
    @old_termios = old_termios

    @width, @height = Termios.window_size(@stdout_fd)
    renderer = Renderer.new(STDOUT, @width, @height)
    @renderer = renderer

    Signal::INT.trap { @msgs.send(InterruptMsg.new.as(Msg)) }
    Signal::TERM.trap { @msgs.send(QuitMsg.new.as(Msg)) }
    Signal::WINCH.trap do
      w, h = Termios.window_size(@stdout_fd)
      @width = w
      @height = h
      renderer.resize(w, h)
      @msgs.send(WindowSizeMsg.new(w, h).as(Msg))
    end

    @msgs.send(WindowSizeMsg.new(@width, @height).as(Msg))

    init_cmd = @model.init
    if init_cmd
      spawn { @msgs.send(init_cmd.call) }
    end

    spawn read_input_loop

    renderer.render(@model.view)

    event_loop

    renderer.render(@model.view)
    renderer.close
  ensure
    restore_terminal
  end

  def send(msg : Msg) : Nil
    @msgs.send(msg) if @running
  end

  def kill : Nil
    @running = false
  end

  private def event_loop : Nil
    while @running
      raw = @msgs.receive?
      break if raw.nil?

      if raw.is_a?(QuitMsg) || raw.is_a?(InterruptMsg)
        break
      end

      if raw.is_a?(BatchMsg)
        raw.cmds.each do |cmd|
          spawn { @msgs.send(cmd.call) }
        end
        next
      end

      if raw.is_a?(SequenceMsg)
        cmds = raw.cmds
        spawn do
          cmds.each do |cmd|
            @msgs.send(cmd.call)
          end
        end
        next
      end

      if raw.is_a?(EscapePendingMsg)
        unless @escape_timer_active
          @escape_timer_active = true
          spawn do
            sleep 50.milliseconds
            @msgs.send(FlushEscapeMsg.new.as(Msg))
          end
        end
        next
      end

      if raw.is_a?(FlushEscapeMsg)
        @escape_timer_active = false
        if @input_parser.in_escape_state?
          esc_msg = @input_parser.flush_escape
          @msgs.send(esc_msg) if esc_msg
        end
        next
      end

      if raw.is_a?(ClearScreenMsg)
        @renderer.try(&.clear_screen)
      end

      if raw.is_a?(WindowSizeMsg)
        @width = raw.width
        @height = raw.height
        @renderer.try(&.resize(@width, @height))
      end

      msg : Msg = raw
      if f = @filter
        filtered = f.call(msg)
        next if filtered.nil?
        msg = filtered
      end

      @model, cmd = @model.update(msg)

      if cmd
        c = cmd.as(Proc(Msg))
        spawn { @msgs.send(c.call) }
      end

      if r = @renderer
        view = @model.view
        r.resize(@width, @height)
        r.render(view)
      end
    end
  end

  private def read_input_loop : Nil
    buf = Bytes.new(4096)
    loop do
      break unless @running
      begin
        n = STDIN.read(buf)
        break if n <= 0
        i = 0
        while i < n
          msg = @input_parser.parse(buf[i])
          if msg
            @msgs.send(msg)
          elsif @input_parser.in_escape_state?
            @msgs.send(EscapePendingMsg.new.as(Msg))
          end
          i += 1
        end
      rescue ex
        @errs.send(ex)
        break
      end
    end
  rescue Channel::ClosedError
  end

  private def restore_terminal : Nil
    if t = @old_termios
      Termios.restore(@stdin_fd, t)
      @old_termios = nil
    end
  end
end
