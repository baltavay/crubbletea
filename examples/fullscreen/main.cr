require "../../src/crubbletea"

struct TickMsg
  include Crubbletea::Msg
  getter time : Time

  def initialize(@time : Time = Time.utc)
  end
end

class FullscreenModel
  include Crubbletea::Model

  getter count : Int32

  def initialize(@count : Int32 = 5)
  end

  def init : Crubbletea::Cmd?
    Crubbletea.tick(1.second) { |t| TickMsg.new(t).as(Crubbletea::Msg) }
  end

  def update(msg) : {FullscreenModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "q", "escape", "ctrl+c"
        return {self, Crubbletea.quit}
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
    v = Crubbletea.new_view("\n\n     Hi. This program will exit in #{@count} seconds...")
    v.alt_screen = true
    v
  end
end

program = Crubbletea::Program(FullscreenModel).new(FullscreenModel.new(5))
program.run
