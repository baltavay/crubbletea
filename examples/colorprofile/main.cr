require "../../src/crubbletea"

COLORPROFILE_COLORS = ["#FF0000", "#FF8800", "#FFFF00", "#00FF00", "#0088FF", "#8800FF"]

class ColorprofileModel
  include Crubbletea::Model

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {ColorprofileModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      return {self, Crubbletea.quit}
    end
    {self, nil}
  end

  def view : Crubbletea::View
    s = "\n  Color Profile Example\n\n"
    COLORPROFILE_COLORS.each do |c|
      bar = Crubbletea::Lipgloss::Style.new.foreground(c).render("████████")
      s += "  #{bar} #{c}\n"
    end
    s += "\n  TrueColor is assumed. Press any key to quit.\n"

    Crubbletea.new_view(s)
  end
end

program = Crubbletea::Program(ColorprofileModel).new(ColorprofileModel.new)
program.run
