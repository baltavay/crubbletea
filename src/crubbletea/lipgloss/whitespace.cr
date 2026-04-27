require "./style"
require "./layout"

struct Crubbletea::Lipgloss::Whitespace
  @style : Style

  def initialize(@style = Style.new)
  end

  def render(width : Int32 = 0, height : Int32 = 0) : String
    s = @style
    s = s.width(width) if width > 0
    s = s.height(height) if height > 0
    s.render("")
  end
end
