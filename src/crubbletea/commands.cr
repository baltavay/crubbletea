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
    ->{ WindowSizeMsg.new(0, 0).as(Msg) }
  end
end
