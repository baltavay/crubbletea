
struct Crubbletea::Bubbles::Stopwatch::StartStopMsg
  include Crubbletea::Msg
  getter id : Int32
  getter running : Bool

  def initialize(@id : Int32, @running : Bool)
  end
end

struct Crubbletea::Bubbles::Stopwatch::TickMsg
  include Crubbletea::Msg
  getter id : Int32
  getter tag : Int32

  def initialize(@id : Int32, @tag : Int32)
  end
end

struct Crubbletea::Bubbles::Stopwatch::ResetMsg
  include Crubbletea::Msg
  getter id : Int32

  def initialize(@id : Int32)
  end
end

class Crubbletea::Bubbles::Stopwatch::Model
  getter interval : Time::Span
  getter id : Int32

  @@last_id = 0

  @duration : Time::Span
  @running : Bool
  @tag : Int32

  def initialize(@interval : Time::Span = 1.second)
    @@last_id += 1
    @id = @@last_id
    @duration = Time::Span.zero
    @running = false
    @tag = 0
  end

  def running? : Bool
    @running
  end

  def elapsed : Time::Span
    @duration
  end

  def init : Crubbletea::Cmd
    start
  end

  def start : Crubbletea::Cmd
    Crubbletea.sequence([
      ->{ StartStopMsg.new(@id, true).as(Crubbletea::Msg) },
      tick_cmd,
    ])
  end

  def stop : Crubbletea::Cmd
    ->{ StartStopMsg.new(@id, false).as(Crubbletea::Msg) }
  end

  def toggle : Crubbletea::Cmd
    @running ? stop : start
  end

  def reset : Crubbletea::Cmd
    ->{ ResetMsg.new(@id).as(Crubbletea::Msg) }
  end

  def update(msg : Crubbletea::Msg) : {Model, Crubbletea::Cmd}
    case msg
    when StartStopMsg
      return {self, nil} if msg.id != @id
      @running = msg.running
      {self, nil}
    when ResetMsg
      return {self, nil} if msg.id != @id
      @duration = Time::Span.zero
      {self, nil}
    when TickMsg
      if !@running || msg.id != @id
        return {self, nil}
      end
      if msg.tag > 0 && msg.tag != @tag
        return {self, nil}
      end

      @duration += @interval
      @tag += 1
      {self, tick_cmd}
    else
      {self, nil}
    end
  end

  def view : String
    t = @duration
    if t.total_hours >= 1
      "#{t.hours}h#{t.minutes}m#{t.seconds}.#{t.milliseconds.to_s.rjust(3, '0')}s"
    elsif t.total_minutes >= 1
      "#{t.minutes}m#{t.seconds}.#{t.milliseconds.to_s.rjust(3, '0')}s"
    elsif t.total_seconds >= 1
      "#{t.seconds}.#{t.milliseconds.to_s.rjust(3, '0')}s"
    else
      "#{"%.3f" % t.total_seconds}s"
    end
  end

  private def tick_cmd : Crubbletea::Cmd
    tag = @tag
    id = @id
    interval = @interval
    ->{
      sleep interval
      TickMsg.new(id, tag).as(Crubbletea::Msg)
    }
  end
end
