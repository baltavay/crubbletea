
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
    ->{ StartStopMsg.new(@id, true).as(Crubbletea::Msg) }
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
      {self, @running ? tick_cmd : nil}
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
    @duration.to_s
  end

  private def tick_cmd : Crubbletea::Cmd
    ->{ TickMsg.new(@id, @tag).as(Crubbletea::Msg) }
  end
end
