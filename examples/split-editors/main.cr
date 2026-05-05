require "../../src/crubbletea"

FOCUSED_BORDER = Crubbletea::Lipgloss::Style.new
  .border(Crubbletea::Lipgloss::Border.rounded)
  .border_foreground("238")

BLURRED_BORDER = Crubbletea::Lipgloss::Style.new
  .border(Crubbletea::Lipgloss::Border.hidden)

class SplitEditorsModel
  include Crubbletea::Model

  getter inputs : Array(Crubbletea::Bubbles::TextArea::Model)
  getter focus : Int32
  getter width : Int32
  getter height : Int32

  def initialize
    @focus = 0
    @width = 80
    @height = 24

    @inputs = (0...2).map do
      ta = Crubbletea::Bubbles::TextArea::Model.new(
        placeholder: "Type something",
        prompt: "",
        width: 40,
        height: 18,
        show_line_numbers: true,
        placeholder_style: Crubbletea::Lipgloss::Style.new.faint(true).foreground("238"),
        line_number_style: Crubbletea::Lipgloss::Style.new.foreground("238")
      )
      ta.blur
      ta
    end
    @inputs[@focus].focus
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {SplitEditorsModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::WindowSizeMsg
      @width = msg.width
      @height = msg.height
      size_inputs
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c", "escape"
        @inputs.each(&.blur)
        return {self, Crubbletea.quit}
      when "tab"
        @inputs[@focus].blur
        @focus = (@focus + 1) % @inputs.size
        @inputs[@focus].focus
      when "shift+tab"
        @inputs[@focus].blur
        @focus = (@focus - 1) % @inputs.size
        @inputs[@focus].focus
      when "ctrl+n"
        if @inputs.size < 6
          ta = Crubbletea::Bubbles::TextArea::Model.new(
            placeholder: "Type something",
            prompt: "",
            width: @width // (@inputs.size + 1),
            height: @height - 5,
            show_line_numbers: true,
            placeholder_style: Crubbletea::Lipgloss::Style.new.faint(true).foreground("238"),
            line_number_style: Crubbletea::Lipgloss::Style.new.foreground("238")
          )
          ta.blur
          @inputs << ta
          size_inputs
        end
      when "ctrl+w"
        if @inputs.size > 1
          @inputs.pop
          @focus = {@focus, @inputs.size - 1}.min
          @inputs[@focus].focus
          size_inputs
        end
      end
    end

    cmds = [] of Crubbletea::Cmd
    @inputs.each { |inp| inp, cmd = inp.update(msg); cmds << cmd if cmd }
    {self, cmds.empty? ? nil : Crubbletea.batch(cmds)}
  end

  def view : Crubbletea::View
    views = @inputs.map_with_index do |inp, i|
      raw = inp.view
      if i == @focus
        FOCUSED_BORDER.render(raw)
      else
        BLURRED_BORDER.render(raw)
      end
    end

    joined = Crubbletea::Lipgloss.join_horizontal(Crubbletea::Lipgloss::Style::Pos::Top, views)
    help_text = "tab: next • shift+tab: prev • ctrl+n: add • ctrl+w: remove • esc: quit"

    v = Crubbletea.new_view("#{joined}\n\n#{help_text}")
    v.alt_screen = true

    focused = @inputs[@focus]?
    if focused && focused.focused?
      x_offset = 0
      views.each_with_index do |rendered, i|
        break if i == @focus
        x_offset += Crubbletea::Lipgloss::ANSI.string_width(rendered.split('\n').first? || "")
      end
      col = x_offset + 1 + focused.visible_cursor_col
      row = 1 + focused.visible_cursor_row
      v.cursor = Crubbletea::Cursor.new(col, row)
    end
    v
  end

  private def size_inputs : Nil
    border_w = 2
    border_h = 2
    w = @width // @inputs.size - border_w
    h = @height - 5 - border_h
    @inputs.each do |inp|
      inp.width = w
      inp.height = h
    end
  end
end

program = Crubbletea::Program(SplitEditorsModel).new(SplitEditorsModel.new)
program.run
