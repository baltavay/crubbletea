
struct Crubbletea::Bubbles::Timer::StartStopMsg
  include Crubbletea::Msg
  getter id : Int32
  getter running : Bool

  def initialize(@id : Int32, @running : Bool)
  end
end

struct Crubbletea::Bubbles::Timer::TickMsg
  include Crubbletea::Msg
  getter id : Int32
  getter timeout : Bool
  getter tag : Int32

  def initialize(@id : Int32, @timeout : Bool, @tag : Int32)
  end
end

struct Crubbletea::Bubbles::Timer::TimeoutMsg
  include Crubbletea::Msg
  getter id : Int32

  def initialize(@id : Int32)
  end
end

class Crubbletea::Bubbles::Timer::Model
  getter timeout : Time::Span
  getter interval : Time::Span
  getter id : Int32

  @@last_id = 0

  @running : Bool
  @tag : Int32

  def initialize(@timeout : Time::Span = 10.seconds, @interval : Time::Span = 1.second)
    @@last_id += 1
    @id = @@last_id
    @running = true
    @tag = 0
  end

  def running? : Bool
    !timedout? && @running
  end

  def timedout? : Bool
    @timeout <= Time::Span.zero
  end

  def init : Crubbletea::Cmd
    tick_cmd
  end

  def update(msg : Crubbletea::Msg) : {Model, Crubbletea::Cmd}
    case msg
    when StartStopMsg
      return {self, nil} if msg.id != 0 && msg.id != @id
      @running = msg.running
      {self, tick_cmd}
    when TickMsg
      unless running? && (msg.id == 0 || msg.id == @id)
        return {self, nil}
      end
      if msg.tag > 0 && msg.tag != @tag
        return {self, nil}
      end

      @timeout -= @interval
      cmds = [tick_cmd]
      if timedout?
        cmds << ->{ TimeoutMsg.new(@id).as(Crubbletea::Msg) }
      end
      {self, Crubbletea.batch(cmds)}
    else
      {self, nil}
    end
  end

  def view : String
    @timeout.to_s
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

  private def tick_cmd : Crubbletea::Cmd
    @tag += 1
    ->{ TickMsg.new(@id, timedout?, @tag).as(Crubbletea::Msg) }
  end
end
