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
  @without_renderer : Bool
  @last_render : Time::Instant = Time.instant
  @dirty : Bool = false
  @pending_flush : Bool = false
  @tty_file : File?
  FRAME_NS = 16_666_667_i64

  def initialize(
    @model : M,
    @filter : (Msg -> Msg)? = nil,
    @without_renderer : Bool = false
  )
    @msgs = Channel(Msg).new(256)
    @errs = Channel(Exception).new(1)
    @input_parser = InputParser.new
    @stdout_fd = 1

    @stdin_fd = 0
    unless STDIN.tty?
      begin
        tty_file = File.open("/dev/tty", "r")
        @tty_file = tty_file
        @stdin_fd = tty_file.fd
      rescue
      end
    end
  end

  def run : Nil
    return if Crubbletea.test_mode?
    @running = true
    @last_render = Time.instant

    @width, @height = Termios.window_size(@stdout_fd)

    old_termios = Termios.enter_raw(@stdin_fd)
    @old_termios = old_termios

    unless @without_renderer
      @renderer = Renderer.new(STDOUT, @width, @height)
    end

    Signal::INT.trap { @msgs.send(InterruptMsg.new.as(Msg)) }
    Signal::TERM.trap { @msgs.send(QuitMsg.new.as(Msg)) }
    Signal::WINCH.trap do
      w, h = Termios.window_size(@stdout_fd)
      @width = w
      @height = h
      @renderer.try(&.resize(w, h))
      @msgs.send(WindowSizeMsg.new(w, h).as(Msg))
    end

    @msgs.send(WindowSizeMsg.new(@width, @height).as(Msg))

    init_cmd = @model.init
    if init_cmd
      spawn { @msgs.send(init_cmd.call) }
    end

    spawn read_input_loop

    event_loop

    flush_render

    if r = @renderer
      r.force_render(@model.view)
      r.close
    end
  ensure
    restore_terminal
  end

  def send(msg : Msg) : Nil
    @msgs.send(msg) if @running
  end

  def kill : Nil
    @running = false
  end

  @pending_flush : Bool = false

  private def flush_render : Nil
    return unless @dirty
    @dirty = false
    @pending_flush = false
    if r = @renderer
      r.render(@model.view)
    end
    @last_render = Time.instant
  end

  private def try_render(immediate : Bool) : Nil
    @dirty = true
    if immediate
      flush_render
    else
      elapsed = (Time.instant - @last_render).total_nanoseconds.to_i64
      if elapsed >= FRAME_NS
        flush_render
      elsif !@pending_flush
        @pending_flush = true
        remaining = FRAME_NS - elapsed
        spawn do
          sleep remaining.nanoseconds
          @msgs.send(FlushRenderMsg.new.as(Msg))
        end
      end
    end
  end

  private def event_loop : Nil
    while @running
      raw = @msgs.receive?
      break unless raw

      if raw.is_a?(BatchMsg)
        exec_batch(raw.as(BatchMsg))
        next
      end

      if raw.is_a?(SequenceMsg)
        spawn { exec_sequence(raw.as(SequenceMsg)) }
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

      if raw.is_a?(FlushRenderMsg)
        flush_render
        next
      end

      if raw.is_a?(ClearScreenMsg)
        @renderer.try(&.clear_screen)
      end

      if raw.is_a?(PrintLineMsg)
        @renderer.try(&.insert_above(raw.as(PrintLineMsg).body))
      end

      if raw.is_a?(WindowSizeMsg)
        wmsg = raw.as(WindowSizeMsg)
        @width = wmsg.width
        @height = wmsg.height
        @renderer.try(&.resize(@width, @height))
      end

      if raw.is_a?(SuspendMsg)
        restore_terminal
        LibC.kill(LibC.getpid, LibC::SIGTSTP)
        old_termios = Termios.enter_raw(@stdin_fd)
        @old_termios = old_termios
        if r = @renderer
          r.render(@model.view)
        end
        resume_msg : Msg = ResumeMsg.new
        if f = @filter
          filtered = f.call(resume_msg)
          unless filtered.nil?
            resume_msg = filtered
            @model, cmd = @model.update(resume_msg)
            if cmd
              c = cmd.as(Proc(Msg))
              spawn { @msgs.send(c.call) }
            end
          end
        else
          @model, cmd = @model.update(resume_msg)
          if cmd
            c = cmd.as(Proc(Msg))
            spawn { @msgs.send(c.call) }
          end
        end
        try_render(true)
        next
      end

      msg : Msg = raw.as(Msg)

      if raw.is_a?(QuitMsg) || raw.is_a?(InterruptMsg)
        if f = @filter
          filtered = f.call(msg)
          break if filtered.is_a?(QuitMsg) || filtered.is_a?(InterruptMsg)
          next if filtered.nil?
          msg = filtered
        else
          break
        end
      elsif f = @filter
        filtered = f.call(msg)
        next if filtered.nil?
        msg = filtered
      end

      @model, cmd = @model.update(msg)

      if cmd
        c = cmd.as(Proc(Msg))
        spawn { @msgs.send(c.call) }
      end

      immediate = raw.is_a?(KeyPressMsg) || raw.is_a?(WindowSizeMsg) || raw.is_a?(QuitMsg) || raw.is_a?(InterruptMsg)
      try_render(immediate)
    end

    @running = false
  end

  private def read_input_loop : Nil
    buf = Bytes.new(4096)
    input_io = @tty_file || STDIN
    loop do
      break unless @running
      begin
        n = input_io.read(buf)
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

  private def exec_batch(msg : BatchMsg) : Nil
    msg.cmds.each do |cmd|
      spawn do
        result = cmd.call
        case result
        when BatchMsg
          exec_batch(result)
        when SequenceMsg
          exec_sequence(result)
        else
          @msgs.send(result)
        end
      end
    end
  end

  private def exec_sequence(msg : SequenceMsg) : Nil
    msg.cmds.each do |cmd|
      result = cmd.call
      case result
      when BatchMsg
        exec_batch(result)
      when SequenceMsg
        exec_sequence(result)
      else
        @msgs.send(result)
      end
    end
  end

  private def restore_terminal : Nil
    if t = @old_termios
      Termios.restore(@stdin_fd, t)
      @old_termios = nil
    end
    @tty_file.try(&.close)
  end
end
