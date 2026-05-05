require "./example_helper"

private FOCUSED_BORDER = Crubbletea::Lipgloss::Style.new
  .border(Crubbletea::Lipgloss::Border.rounded)
  .border_foreground("238")

private BLURRED_BORDER = Crubbletea::Lipgloss::Style.new
  .border(Crubbletea::Lipgloss::Border.hidden)

private def make_ta(width : Int32 = 38, height : Int32 = 17) : Crubbletea::Bubbles::TextArea::Model
  Crubbletea::Bubbles::TextArea::Model.new(
    placeholder: "Type something",
    prompt: "",
    width: width,
    height: height,
    show_line_numbers: true,
    placeholder_style: Crubbletea::Lipgloss::Style.new.faint(true).foreground("238"),
    line_number_style: Crubbletea::Lipgloss::Style.new.foreground("238")
  )
end

private def strip(s : String) : String
  ExampleTest.strip_ansi(s)
end

private class SplitTestModel
  include Crubbletea::Model

  getter inputs : Array(Crubbletea::Bubbles::TextArea::Model)
  getter focus : Int32
  getter width : Int32
  getter height : Int32

  def initialize(terminal_w : Int32 = 80, terminal_h : Int32 = 24)
    @focus = 0
    @width = terminal_w
    @height = terminal_h
    border_w = 2
    border_h = 2
    w = terminal_w // 2 - border_w
    h = terminal_h - 5 - border_h
    @inputs = (0...2).map do
      ta = make_ta(w, h)
      ta.blur
      ta
    end
    @inputs[@focus].focus
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {SplitTestModel, Crubbletea::Cmd?}
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
          ta = make_ta
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

describe "split-editors borders" do
  it "focused border uses rounded corners" do
    ta = make_ta(10, 3)
    ta.focus
    view = FOCUSED_BORDER.render(ta.view)
    lines = strip(view).split('\n')
    lines[0].should start_with("╭"), "top-left should be ╭, got: #{lines[0][0]?}"
    lines[0].should end_with("╮"), "top-right should be ╮"
    lines[-1].should start_with("╰"), "bottom-left should be ╰"
    lines[-1].should end_with("╯"), "bottom-right should be ╯"
  end

  it "blurred border is invisible (spaces)" do
    ta = make_ta(10, 3)
    ta.blur
    view = BLURRED_BORDER.render(ta.view)
    lines = strip(view).split('\n')
    lines[0].should start_with(" "), "blurred top row should start with space"
    lines.each do |line|
      line[0]?.should eq(' '), "blurred left border should be space"
      line[-1]?.should eq(' '), "blurred right border should be space"
    end
  end

  it "focused and blurred borders have same outer dimensions" do
    ta = make_ta(10, 3)
    ta.focus
    focused_view = FOCUSED_BORDER.render(ta.view)
    ta.blur
    blurred_view = BLURRED_BORDER.render(ta.view)

    focused_lines = focused_view.split('\n')
    blurred_lines = blurred_view.split('\n')

    focused_lines.size.should eq(blurred_lines.size), "focused height=#{focused_lines.size} != blurred height=#{blurred_lines.size}"

    focused_lines.each_with_index do |line, i|
      fw = Crubbletea::Lipgloss::ANSI.string_width(line)
      bw = Crubbletea::Lipgloss::ANSI.string_width(blurred_lines[i])
      fw.should eq(bw), "line #{i}: focused width=#{fw} != blurred width=#{bw}"
    end
  end

  it "border horizontal lines span full inner width" do
    ta = make_ta(10, 3)
    ta.focus
    view = FOCUSED_BORDER.render(ta.view)
    lines = strip(view).split('\n')

    top = lines[0]
    top.should start_with("╭")
    top.should end_with("╮")
    top[1..-2].chars.all? { |c| c == '─' }.should be_true, "top border should be all ─, got: #{top[1..-2]}"

    bot = lines[-1]
    bot.should start_with("╰")
    bot.should end_with("╯")
    bot[1..-2].chars.all? { |c| c == '─' }.should be_true, "bottom border should be all ─, got: #{bot[1..-2]}"
  end

  it "border vertical lines on every content row" do
    ta = make_ta(10, 3)
    ta.focus
    view = FOCUSED_BORDER.render(ta.view)
    lines = strip(view).split('\n')

    content = lines[1..-2]
    content.each_with_index do |line, i|
      line.should start_with("│"), "content line #{i} should start with │"
      line.should end_with("│"), "content line #{i} should end with │"
    end
  end
end

describe "split-editors textarea with borders" do
  it "renders multiline text inside borders without breaking them" do
    ta = make_ta(20, 5)
    ta.focus
    ta.value = "line one\nline two\nline three"
    view = FOCUSED_BORDER.render(ta.view)
    lines = strip(view).split('\n')

    lines.size.should be > 3

    lines[0].should start_with("╭"), "top border"
    lines[-1].should start_with("╰"), "bottom border"

    content = lines[1..-2]
    content.each_with_index do |line, i|
      line.should start_with("│"), "content line #{i} left border broken"
      line.should end_with("│"), "content line #{i} right border broken"
    end

    content.any?(&.includes?("line one")).should be_true
    content.any?(&.includes?("line two")).should be_true
    content.any?(&.includes?("line three")).should be_true
  end

  it "renders empty textarea inside borders without breaking them" do
    ta = make_ta(20, 3)
    ta.focus
    view = FOCUSED_BORDER.render(ta.view)
    lines = strip(view).split('\n')

    lines.size.should eq(5)

    lines[0].should start_with("╭")
    lines[-1].should start_with("╰")

    (1..3).each do |i|
      lines[i].should start_with("│")
      lines[i].should end_with("│")
    end
  end

  it "all content lines have equal width within border" do
    ta = make_ta(20, 5)
    ta.focus
    ta.value = "short\nthis is a longer line of text\nhi"
    view = FOCUSED_BORDER.render(ta.view)
    lines = strip(view).split('\n')

    content = lines[1..-2]
    widths = content.map(&.size)
    widths.uniq.size.should eq(1), "content lines have different widths: #{widths}"
  end

  it "typing many lines doesn't break borders" do
    ta = make_ta(20, 5)
    ta.focus
    ta.value = (1..5).join('\n')
    view = FOCUSED_BORDER.render(ta.view)
    lines = strip(view).split('\n')

    lines[0].should start_with("╭")
    lines[-1].should start_with("╰")
    lines[1..-2].each_with_index do |line, i|
      line.should start_with("│"), "line #{i} left border broken"
      line.should end_with("│"), "line #{i} right border broken"
    end
  end
end

describe "split-editors join_horizontal" do
  it "both editors same height after join" do
    left = make_ta(10, 5)
    left.focus
    right = make_ta(10, 5)
    right.blur

    left_view = FOCUSED_BORDER.render(left.view)
    right_view = BLURRED_BORDER.render(right.view)
    left_lines = left_view.split('\n')
    right_lines = right_view.split('\n')
    left_lines.size.should eq(right_lines.size), "left height=#{left_lines.size} != right height=#{right_lines.size}"
  end

  it "joined view has consistent row widths" do
    terminal_w = 80
    ta_w = terminal_w // 2 - 2

    left = make_ta(ta_w, 10)
    left.focus
    left.value = "left content\nwith multiple\nlines"
    right = make_ta(ta_w, 10)
    right.blur
    right.value = "right content\nalso multiline"

    left_rendered = FOCUSED_BORDER.render(left.view)
    right_rendered = BLURRED_BORDER.render(right.view)
    joined = Crubbletea::Lipgloss.join_horizontal(Crubbletea::Lipgloss::Style::Pos::Top, [left_rendered, right_rendered])

    lines = joined.split('\n')
    widths = lines.map { |l| Crubbletea::Lipgloss::ANSI.string_width(l) }
    widths.uniq.size.should eq(1), "joined lines have inconsistent widths: #{widths}"
  end

  it "joined editors fit within terminal width" do
    terminal_w = 80
    ta_w = terminal_w // 2 - 2

    left = make_ta(ta_w, 5)
    left.focus
    right = make_ta(ta_w, 5)
    right.blur

    left_rendered = FOCUSED_BORDER.render(left.view)
    right_rendered = BLURRED_BORDER.render(right.view)
    joined = Crubbletea::Lipgloss.join_horizontal(Crubbletea::Lipgloss::Style::Pos::Top, [left_rendered, right_rendered])

    joined.split('\n').each_with_index do |line, i|
      w = Crubbletea::Lipgloss::ANSI.string_width(line)
      w.should be <= terminal_w, "joined line #{i} width=#{w} exceeds terminal width=#{terminal_w}"
    end
  end
end

describe "split-editors cursor position" do
  it "cursor starts at content area (past border and gutter)" do
    model = SplitTestModel.new(80, 24)
    v = model.view
    c = v.cursor.should_not be_nil
    c = v.cursor.not_nil!

    c.position.x.should be >= 2, "cursor.x=#{c.position.x} should be past border(1) + gutter(1+)"
    c.position.y.should be >= 1, "cursor.y=#{c.position.y} should be past top border"
  end

  it "cursor advances when typing" do
    model = SplitTestModel.new(80, 24)
    initial_x = model.view.cursor.not_nil!.position.x

    "abc".each_char { |ch| model, _ = model.update(ExampleTest.key(ch.to_s)) }

    c = model.view.cursor.not_nil!
    c.position.x.should eq(initial_x + 3), "cursor should advance 3 positions after typing 'abc'"
  end

  it "cursor moves down on enter" do
    model = SplitTestModel.new(80, 24)
    initial_y = model.view.cursor.not_nil!.position.y

    model, _ = model.update(ExampleTest.key("enter"))
    c = model.view.cursor.not_nil!
    c.position.y.should eq(initial_y + 1), "cursor should move down one row after enter"
  end

  it "cursor tracks multiline input correctly" do
    model = SplitTestModel.new(80, 24)

    "hello".each_char { |c| model, _ = model.update(ExampleTest.key(c.to_s)) }
    model, _ = model.update(ExampleTest.key("enter"))
    "world".each_char { |c| model, _ = model.update(ExampleTest.key(c.to_s)) }

    c = model.view.cursor.not_nil!
    c.position.y.should eq(2), "cursor should be on row 2 (top border + 1 newline)"
  end

  it "cursor moves to second editor after tab" do
    model = SplitTestModel.new(80, 24)
    first_cursor_x = model.view.cursor.not_nil!.position.x

    model, _ = model.update(ExampleTest.key("tab"))
    model.focus.should eq(1)

    c = model.view.cursor.not_nil!
    c.position.x.should be > first_cursor_x, "cursor should be in second editor (right of first)"
  end

  it "cursor wraps back to first editor on second tab" do
    model = SplitTestModel.new(80, 24)

    model, _ = model.update(ExampleTest.key("tab"))
    model, _ = model.update(ExampleTest.key("tab"))
    model.focus.should eq(0)
    model.view.cursor.should_not be_nil
  end

  it "cursor stays within focused editor bounds after multiline" do
    model = SplitTestModel.new(80, 24)

    "hello\nworld\nfoo".each_char do |c|
      if c == '\n'
        model, _ = model.update(ExampleTest.key("enter"))
      else
        model, _ = model.update(ExampleTest.key(c.to_s))
      end
    end

    c = model.view.cursor.not_nil!
    view_lines = model.view.content.split('\n')
    first_line_w = Crubbletea::Lipgloss::ANSI.string_width(view_lines[0])
    c.position.x.should be < first_line_w, "cursor.x=#{c.position.x} should be within first editor width=#{first_line_w}"
  end
end

describe "split-editors sizing" do
  it "sized editors fit within terminal width" do
    terminal_w = 80
    model = SplitTestModel.new(terminal_w, 24)

    v = model.view
    lines = v.content.split('\n')
    joined_lines = lines[0..-3]
    joined_lines.each_with_index do |line, i|
      w = Crubbletea::Lipgloss::ANSI.string_width(line)
      w.should be <= terminal_w, "line #{i} width=#{w} exceeds #{terminal_w}"
    end
  end

  it "3 editors fit after ctrl+n" do
    terminal_w = 90
    model = SplitTestModel.new(terminal_w, 24)
    model, _ = model.update(ExampleTest.key("ctrl+n"))
    model.inputs.size.should eq(3)

    v = model.view
    lines = v.content.split('\n')
    joined_lines = lines[0..-3]
    joined_lines.each_with_index do |line, i|
      w = Crubbletea::Lipgloss::ANSI.string_width(line)
      w.should be <= terminal_w, "line #{i} width=#{w} exceeds #{terminal_w}"
    end
  end

  it "removing editor resizes remaining ones" do
    terminal_w = 90
    model = SplitTestModel.new(terminal_w, 24)
    model, _ = model.update(ExampleTest.key("ctrl+n"))
    model.inputs.size.should eq(3)

    model, _ = model.update(ExampleTest.key("ctrl+w"))
    model.inputs.size.should eq(2)

    v = model.view
    lines = v.content.split('\n')
    joined_lines = lines[0..-3]
    joined_lines.each_with_index do |line, i|
      w = Crubbletea::Lipgloss::ANSI.string_width(line)
      w.should be <= terminal_w, "line #{i} width=#{w} exceeds #{terminal_w}"
    end
  end
end
