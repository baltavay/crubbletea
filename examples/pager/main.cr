require "../../src/crubbletea"

TITLE_BORDER = Crubbletea::Lipgloss::Border.new(
  top: "─", right: "├", bottom: "─", left: "│",
  top_left: "╭", top_right: "╮",
  bottom_left: "╰", bottom_right: "╯"
)

TITLE_STYLE = Crubbletea::Lipgloss::Style.new
  .border(TITLE_BORDER)
  .padding(0, 1)

INFO_BORDER = Crubbletea::Lipgloss::Border.new(
  top: "─", right: "│", bottom: "─", left: "┤",
  top_left: "╭", top_right: "╮",
  bottom_left: "╰", bottom_right: "╯"
)

INFO_STYLE = Crubbletea::Lipgloss::Style.new
  .border(INFO_BORDER)
  .padding(0, 1)

class PagerModel
  include Crubbletea::Model

  getter viewport : Crubbletea::Bubbles::Viewport::Model
  getter ready : Bool

  @content : String

  def initialize
    content_path = File.join(File.dirname(__FILE__), "artichoke.md")
    @content = File.exists?(content_path) ? File.read(content_path) : "No content file found."
    @viewport = Crubbletea::Bubbles::Viewport::Model.new(width: 80, height: 20)
    @ready = false
  end

  def init : Crubbletea::Cmd?
    Crubbletea.request_window_size
  end

  def update(msg) : {PagerModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c", "q", "escape"
        return {self, Crubbletea.quit}
      end
    when Crubbletea::WindowSizeMsg
      header_h = Crubbletea::Lipgloss::ANSI.string_width(header_view).clamp(1, 999999) > 0 ? 1 : 0
      footer_h = 1
      vertical_margin = header_h + footer_h

      unless @ready
        @viewport = Crubbletea::Bubbles::Viewport::Model.new(
          width: msg.width,
          height: msg.height - vertical_margin
        )
        @viewport.content = @content
        @ready = true
      else
        @viewport.width = msg.width
        @viewport.height = msg.height - vertical_margin
      end
    end

    @viewport, cmd = @viewport.update(msg)
    {self, cmd}
  end

  def view : Crubbletea::View
    v = Crubbletea.new_view(
      @ready ? "#{header_view}\n#{@viewport.view}\n#{footer_view}" : "\n  Initializing..."
    )
    v.alt_screen = true
    v.mouse_mode = :cell_motion
    v
  end

  private def header_view : String
    title = TITLE_STYLE.render("Mr. Pager")
    line = "─" * {@viewport.width - Crubbletea::Lipgloss::ANSI.string_width(title), 0}.max
    Crubbletea::Lipgloss.join_horizontal(Crubbletea::Lipgloss::Style::Pos::Center, [title, line])
  end

  private def footer_view : String
    if @viewport.max_y_offset > 0
      v_pct = ((@viewport.y_offset.to_f / @viewport.max_y_offset) * 100).round.to_i
    else
      v_pct = 0
    end
    h_pct = 0
    info = INFO_STYLE.render(sprintf("%3d%%:%3d%%", v_pct, h_pct))
    line = "─" * {@viewport.width - Crubbletea::Lipgloss::ANSI.string_width(info), 0}.max
    Crubbletea::Lipgloss.join_horizontal(Crubbletea::Lipgloss::Style::Pos::Center, [line, info])
  end
end

program = Crubbletea::Program(PagerModel).new(PagerModel.new)
program.run
