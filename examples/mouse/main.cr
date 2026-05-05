require "../../src/crubbletea"

class MouseModel
  include Crubbletea::Model

  getter last_mouse : String

  def initialize
    @last_mouse = ""
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {MouseModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c", "q", "escape"
        return {self, Crubbletea.quit}
      end
    when Crubbletea::MouseClickMsg, Crubbletea::MouseReleaseMsg,
         Crubbletea::MouseWheelMsg, Crubbletea::MouseMotionMsg
      mouse = msg.mouse
      @last_mouse = "(X: #{mouse.x}, Y: #{mouse.y}) #{msg.to_s}"
    end
    {self, nil}
  end

  def view : Crubbletea::View
    s = "Do mouse stuff. When you're done press q to quit.\n"
    s += "\n#{@last_mouse}\n" unless @last_mouse.empty?
    v = Crubbletea.new_view(s)
    v.mouse_mode = Crubbletea::MouseMode::AllMotion
    v
  end
end

program = Crubbletea::Program(MouseModel).new(MouseModel.new)
program.run
