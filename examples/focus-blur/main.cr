require "../../src/crubbletea"

class FocusBlurModel
  include Crubbletea::Model

  getter focused : Bool
  getter reporting : Bool

  def initialize
    @focused = true
    @reporting = true
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {FocusBlurModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::FocusMsg
      @focused = true
    when Crubbletea::BlurMsg
      @focused = false
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "t"
        @reporting = !@reporting
      when "ctrl+c", "q"
        return {self, Crubbletea.quit}
      end
    end
    {self, nil}
  end

  def view : Crubbletea::View
    s = "Hi. Focus report is currently "
    s += @reporting ? "enabled" : "disabled"
    s += ".\n\n"

    if @reporting
      if @focused
        s += "This program is currently focused!"
      else
        s += "This program is currently blurred!"
      end
    end

    s += "\n\nTo quit sooner press ctrl-c, or t to toggle focus reporting...\n"
    v = Crubbletea.new_view(s)
    v.report_focus = @reporting
    v
  end
end

program = Crubbletea::Program(FocusBlurModel).new(FocusBlurModel.new)
program.run
