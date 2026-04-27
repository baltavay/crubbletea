struct Crubbletea::Lipgloss::Border
  getter top : String
  getter right : String
  getter bottom : String
  getter left : String
  getter top_left : String
  getter top_right : String
  getter bottom_left : String
  getter bottom_right : String
  getter middle_left : String
  getter middle_right : String
  getter middle : String
  getter middle_top : String
  getter middle_bottom : String

  def initialize(
    @top = "",
    @right = "",
    @bottom = "",
    @left = "",
    @top_left = "",
    @top_right = "",
    @bottom_left = "",
    @bottom_right = "",
    @middle_left = "",
    @middle_right = "",
    @middle = "",
    @middle_top = "",
    @middle_bottom = ""
  )
  end

  def self.normal : Border
    Border.new(
      top: "─", right: "│", bottom: "─", left: "│",
      top_left: "┌", top_right: "┐", bottom_left: "└", bottom_right: "┘",
      middle_left: "├", middle_right: "┤", middle: "┼",
      middle_top: "┬", middle_bottom: "┴"
    )
  end

  def self.rounded : Border
    Border.new(
      top: "─", right: "│", bottom: "─", left: "│",
      top_left: "╭", top_right: "╮", bottom_left: "╰", bottom_right: "╯",
      middle_left: "├", middle_right: "┤", middle: "┼",
      middle_top: "┬", middle_bottom: "┴"
    )
  end

  def self.block : Border
    Border.new(
      top: "█", right: "█", bottom: "█", left: "█",
      top_left: "█", top_right: "█", bottom_left: "█", bottom_right: "█",
      middle_left: "█", middle_right: "█", middle: "█",
      middle_top: "█", middle_bottom: "█"
    )
  end

  def self.thick : Border
    Border.new(
      top: "━", right: "┃", bottom: "━", left: "┃",
      top_left: "┏", top_right: "┓", bottom_left: "┗", bottom_right: "┛",
      middle_left: "┣", middle_right: "┫", middle: "╋",
      middle_top: "┳", middle_bottom: "┻"
    )
  end

  def self.double : Border
    Border.new(
      top: "═", right: "║", bottom: "═", left: "║",
      top_left: "╔", top_right: "╗", bottom_left: "╚", bottom_right: "╝",
      middle_left: "╠", middle_right: "╣", middle: "╬",
      middle_top: "╦", middle_bottom: "╩"
    )
  end

  def self.hidden : Border
    Border.new
  end

  def self.markdown : Border
    Border.new(
      top: "-", right: "|", bottom: "-", left: "|",
      top_left: "-", top_right: "-", bottom_left: "-", bottom_right: "-",
      middle_left: "|", middle_right: "|", middle: "|",
      middle_top: "-", middle_bottom: "-"
    )
  end

  def self.ascii : Border
    Border.new(
      top: "-", right: "|", bottom: "-", left: "|",
      top_left: "+", top_right: "+", bottom_left: "+", bottom_right: "+",
      middle_left: "+", middle_right: "+", middle: "+",
      middle_top: "+", middle_bottom: "+"
    )
  end
end
