require "../../src/crubbletea"

KEYWORD_STYLE = Crubbletea::Lipgloss::Style.new
  .foreground("204")
  .background("235")
ALTSCREEN_HELP_STYLE = Crubbletea::Lipgloss::Style.new
  .foreground("#626262")

class AltscreenToggleModel
  include Crubbletea::Model

  getter altscreen : Bool
  getter quitting : Bool

  def initialize(@altscreen = false, @quitting = false)
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {AltscreenToggleModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "q", "ctrl+c", "escape"
        @quitting = true
        return {self, Crubbletea.quit}
      when "space"
        @altscreen = !@altscreen
        return {self, nil}
      when "ctrl+z"
        return {self, Crubbletea.suspend}
      end
    end
    {self, nil}
  end

  def view : Crubbletea::View
    if @quitting
      v = Crubbletea.new_view("Bye!\n")
      v.alt_screen = @altscreen
      return v
    end

    mode = @altscreen ? " altscreen mode " : " inline mode "

    v = Crubbletea.new_view(
      "\n\n  You're in #{KEYWORD_STYLE.render(mode)}\n\n\n" +
      ALTSCREEN_HELP_STYLE.render("  space: switch modes • ctrl-z: suspend • q: exit\n")
    )
    v.alt_screen = @altscreen
    v
  end
end

program = Crubbletea::Program(AltscreenToggleModel).new(AltscreenToggleModel.new)
program.run
