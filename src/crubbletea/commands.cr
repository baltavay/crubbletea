module Crubbletea
  def self.batch(cmds : Array(Cmd)) : Cmd
    valid = cmds.reject(&.nil?).map(&.not_nil!)
    case valid.size
    when 0 then nil
    when 1 then valid[0]
    else
      ->{ BatchMsg.new(valid).as(Msg) }
    end
  end

  def self.sequence(cmds : Array(Cmd)) : Cmd
    valid = cmds.reject(&.nil?).map(&.not_nil!)
    case valid.size
    when 0 then nil
    when 1 then valid[0]
    else
      ->{ SequenceMsg.new(valid).as(Msg) }
    end
  end

  def self.tick(duration : Time::Span, &fn : Time -> Msg) : Cmd
    -> do
      sleep duration
      fn.call(Time.utc).as(Msg)
    end
  end

  def self.every(duration : Time::Span, &fn : Time -> Msg) : Cmd
    -> do
      now = Time.utc
      next_tick = now + duration
      delay = next_tick - now
      sleep delay if delay > Time::Span.zero
      fn.call(Time.utc).as(Msg)
    end
  end

  def self.clear_screen : Cmd
    ->{ ClearScreenMsg.new.as(Msg) }
  end

  def self.request_window_size : Cmd
    ->{
      w, h = Termios.window_size(1)
      WindowSizeMsg.new(w, h).as(Msg)
    }
  end

  def self.request_background_color : Cmd
    ->{
      STDOUT << "\e]11;?\e\\"
      STDOUT.flush
      nil.as(Msg?)
    }
  end

  def self.request_capability(names : Array(String)) : Cmd
    ->{
      STDOUT << ANSI.request_capability(names)
      STDOUT.flush
      CapabilityMsg.new("", "").as(Msg)
    }
  end

  def self.exec_process(cmd : String, args : Array(String) = [] of String) : Cmd
    ->{
      begin
        Process.run(cmd, args, input: STDIN, output: STDOUT, error: STDERR)
        ExecFinishedMsg.new.as(Msg)
      rescue e
        ExecFinishedMsg.new(e).as(Msg)
      end
    }
  end

  def self.printf(format : String, *args) : Cmd
    text = sprintf(format, *args)
    ->{ PrintLineMsg.new(text).as(Msg) }
  end

  def self.new_compositor(width : Int32, height : Int32) : Compositor
    Compositor.new(width, height)
  end
end
