require "../../src/crubbletea"

WINDOW_TITLE = "Hello, Bubble Tea"

class SetWindowTitleModel
  include Crubbletea::Model

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {SetWindowTitleModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      return {self, Crubbletea.quit}
    end
    {self, nil}
  end

  def view : Crubbletea::View
    wrap = Crubbletea::Lipgloss::Style.new.width(78).render(
      "The window title has been set to '#{WINDOW_TITLE}'. It will be cleared on exit."
    )
    v = Crubbletea.new_view("#{wrap}\n\nPress any key to quit.")
    v.window_title = WINDOW_TITLE
    v
  end
end

program = Crubbletea::Program(SetWindowTitleModel).new(SetWindowTitleModel.new)
program.run
