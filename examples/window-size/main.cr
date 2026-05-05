require "../../src/crubbletea"

class WindowSizeModel
  include Crubbletea::Model

  getter width : Int32
  getter height : Int32

  def initialize
    @width = 0
    @height = 0
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {WindowSizeModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c", "q", "escape"
        return {self, Crubbletea.quit}
      else
        return {self, Crubbletea.request_window_size}
      end
    when Crubbletea::WindowSizeMsg
      @width = msg.width
      @height = msg.height
    end
    {self, nil}
  end

  def view : Crubbletea::View
    if @width > 0 && @height > 0
      Crubbletea.new_view("Window size: #{@width}x#{@height}\n\nPress any key to query the window size.\nPress q to quit.\n")
    else
      Crubbletea.new_view("\nWhen you're done press q to quit.\nPress any other key to query the window-size.\n")
    end
  end
end

program = Crubbletea::Program(WindowSizeModel).new(WindowSizeModel.new)
program.run
