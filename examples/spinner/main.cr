require "../../src/crubbletea"

class SpinnerModel
  include Crubbletea::Model

  getter spinner : Crubbletea::Bubbles::Spinner::Model
  getter quitting : Bool
  getter err : Exception?

  def initialize
    @spinner = Crubbletea::Bubbles::Spinner::Model.new(
      spinner: Crubbletea::Bubbles::Spinner::DOT,
      style: Crubbletea::Lipgloss::Style.new.foreground("205")
    )
    @quitting = false
    @err = nil
  end

  def init : Crubbletea::Cmd?
    @spinner.tick
  end

  def update(msg) : {SpinnerModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "q", "escape", "ctrl+c"
        @quitting = true
        return {self, Crubbletea.quit}
      end
    when Crubbletea::Bubbles::Spinner::TickMsg
      @spinner, cmd = @spinner.update(msg)
      return {self, cmd}
    end
    {self, nil}
  end

  def view : Crubbletea::View
    if e = @err
      return Crubbletea.new_view(e.message || "error")
    end
    str = "\n\n   #{@spinner.view} Loading forever...press q to quit\n\n"
    str += "\n" if @quitting
    Crubbletea.new_view(str)
  end
end

program = Crubbletea::Program(SpinnerModel).new(SpinnerModel.new)
program.run
