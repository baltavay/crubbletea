require "../../src/crubbletea"

TABS = ["Lip Gloss", "Blush", "Eye Shadow", "Mascara", "Foundation"]
TAB_CONTENT = ["Lip Gloss Tab", "Blush Tab", "Eye Shadow Tab", "Mascara Tab", "Foundation Tab"]

HIGHLIGHT_COLOR = "#874BFD"

INACTIVE_BORDER = Crubbletea::Lipgloss::Border.new(
  top: "─", right: "│", bottom: "─", left: "│",
  top_left: "╭", top_right: "╮",
  bottom_left: "┴", bottom_right: "┴"
)

ACTIVE_BORDER = Crubbletea::Lipgloss::Border.new(
  top: "─", right: "│", bottom: " ", left: "│",
  top_left: "╭", top_right: "╮",
  bottom_left: "┘", bottom_right: "└"
)

BASE_TAB_STYLE = Crubbletea::Lipgloss::Style.new
  .border_foreground(HIGHLIGHT_COLOR)
  .padding(0, 1)

WINDOW_STYLE = Crubbletea::Lipgloss::Style.new
  .border_foreground(HIGHLIGHT_COLOR)
  .padding(2, 0)
  .align(Crubbletea::Lipgloss::Style::Pos::Center)
  .border(Crubbletea::Lipgloss::Border.normal)
  .border_top(false)

DOC_STYLE = Crubbletea::Lipgloss::Style.new
  .padding(1, 2)

class TabsModel
  include Crubbletea::Model

  getter active_tab : Int32

  def initialize
    @active_tab = 0
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {TabsModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c", "q"
        return {self, Crubbletea.quit}
      when "right", "l", "n", "tab"
        @active_tab = {@active_tab + 1, TABS.size - 1}.min
        return {self, nil}
      when "left", "h", "p", "shift+tab"
        @active_tab = {@active_tab - 1, 0}.max
        return {self, nil}
      end
    end
    {self, nil}
  end

  def view : Crubbletea::View
    rendered_tabs = TABS.map_with_index do |t, i|
      is_active = i == @active_tab
      is_first = i == 0
      is_last = i == TABS.size - 1

      base = is_active ? ACTIVE_BORDER : INACTIVE_BORDER
      bl = base.bottom_left
      br = base.bottom_right
      b = base.bottom

      if is_first && is_active
        bl = "│"
      elsif is_first && !is_active
        bl = "├"
      end
      if is_last && is_active
        br = "│"
      elsif is_last && !is_active
        br = "┤"
      end

      border = Crubbletea::Lipgloss::Border.new(
        top: base.top, right: base.right, bottom: b, left: base.left,
        top_left: base.top_left, top_right: base.top_right,
        bottom_left: bl, bottom_right: br
      )

      style = BASE_TAB_STYLE.border(border)
      style.render(t)
    end

    row = Crubbletea::Lipgloss.join_horizontal(Crubbletea::Lipgloss::Style::Pos::Top, rendered_tabs)
    content = WINDOW_STYLE.width(Crubbletea::Lipgloss::ANSI.string_width(row)).render(TAB_CONTENT[@active_tab])

    Crubbletea.new_view(DOC_STYLE.render("#{row}\n#{content}"))
  end
end

program = Crubbletea::Program(TabsModel).new(TabsModel.new)
program.run
