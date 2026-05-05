require "../../src/crubbletea"

struct TickMsg
  include Crubbletea::Msg
  getter time : Time

  def initialize(@time : Time = Time.utc)
  end
end

class SimpleModel
  include Crubbletea::Model

  getter count : Int32

  def initialize(@count : Int32 = 5)
  end

  def init : Crubbletea::Cmd?
    Crubbletea.tick(1.second) { |t| TickMsg.new(t).as(Crubbletea::Msg) }
  end

  def update(msg) : {SimpleModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c", "q"
        return {self, Crubbletea.quit}
      when "ctrl+z"
        return {self, Crubbletea.suspend}
      end
    when TickMsg
      @count -= 1
      if @count <= 0
        return {self, Crubbletea.quit}
      end
      return {self, Crubbletea.tick(1.second) { |t| TickMsg.new(t).as(Crubbletea::Msg) }}
    end
    {self, nil}
  end

  def view : Crubbletea::View
    Crubbletea.new_view("Hi. This program will exit in #{@count} seconds.\n\nTo quit sooner press ctrl-c, or press ctrl-z to suspend...\n")
  end
end

program = Crubbletea::Program(SimpleModel).new(SimpleModel.new(5))
program.run
