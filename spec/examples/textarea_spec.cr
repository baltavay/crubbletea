require "./example_helper"

describe "textarea bubble" do
  it "starts unfocused" do
    ta = Crubbletea::Bubbles::TextArea::Model.new
    ta.focused?.should be_false
  end

  it "can focus" do
    ta = Crubbletea::Bubbles::TextArea::Model.new
    ta.focus
    ta.focused?.should be_true
  end

  it "can blur" do
    ta = Crubbletea::Bubbles::TextArea::Model.new
    ta.focus
    ta.blur
    ta.focused?.should be_false
  end

  it "starts with one empty line" do
    ta = Crubbletea::Bubbles::TextArea::Model.new
    ta.line_count.should eq(1)
    ta.value.should eq("")
  end

  it "types characters" do
    ta = Crubbletea::Bubbles::TextArea::Model.new
    ta.focus
    ta, _ = ta.update(ExampleTest.key("h"))
    ta, _ = ta.update(ExampleTest.key("e"))
    ta, _ = ta.update(ExampleTest.key("l"))
    ta, _ = ta.update(ExampleTest.key("l"))
    ta, _ = ta.update(ExampleTest.key("o"))
    ta.value.should eq("hello")
  end

  it "inserts newline on enter" do
    ta = Crubbletea::Bubbles::TextArea::Model.new
    ta.focus
    ta, _ = ta.update(ExampleTest.key("a"))
    ta, _ = ta.update(ExampleTest.key("b"))
    ta, _ = ta.update(ExampleTest.key("enter"))
    ta.value.should eq("ab\n")
    ta.cursor_row.should eq(1)
    ta.cursor_col.should eq(0)
  end

  it "inserts newline in middle of line" do
    ta = Crubbletea::Bubbles::TextArea::Model.new
    ta.focus
    ta, _ = ta.update(ExampleTest.key("a"))
    ta, _ = ta.update(ExampleTest.key("b"))
    ta, _ = ta.update(ExampleTest.key("c"))
    ta, _ = ta.update(ExampleTest.key("left"))
    ta, _ = ta.update(ExampleTest.key("enter"))
    ta.value.should eq("ab\nc")
    ta.cursor_row.should eq(1)
    ta.cursor_col.should eq(0)
  end

  it "backspace deletes char" do
    ta = Crubbletea::Bubbles::TextArea::Model.new
    ta.focus
    ta, _ = ta.update(ExampleTest.key("a"))
    ta, _ = ta.update(ExampleTest.key("b"))
    ta, _ = ta.update(ExampleTest.key("backspace"))
    ta.value.should eq("a")
  end

  it "backspace at line start merges lines" do
    ta = Crubbletea::Bubbles::TextArea::Model.new
    ta.focus
    ta, _ = ta.update(ExampleTest.key("a"))
    ta, _ = ta.update(ExampleTest.key("b"))
    ta, _ = ta.update(ExampleTest.key("enter"))
    ta, _ = ta.update(ExampleTest.key("c"))
    ta, _ = ta.update(ExampleTest.key("home"))
    ta.cursor_col.should eq(0)
    ta.cursor_row.should eq(1)
    ta, _ = ta.update(ExampleTest.key("backspace"))
    ta.value.should eq("abc")
    ta.cursor_row.should eq(0)
    ta.cursor_col.should eq(2)
  end

  it "delete key removes char forward" do
    ta = Crubbletea::Bubbles::TextArea::Model.new
    ta.focus
    ta, _ = ta.update(ExampleTest.key("a"))
    ta, _ = ta.update(ExampleTest.key("b"))
    ta, _ = ta.update(ExampleTest.key("c"))
    ta, _ = ta.update(ExampleTest.key("left"))
    ta, _ = ta.update(ExampleTest.key("delete"))
    ta.value.should eq("ab")
  end

  it "delete at end of line merges with next" do
    ta = Crubbletea::Bubbles::TextArea::Model.new
    ta.focus
    ta, _ = ta.update(ExampleTest.key("a"))
    ta, _ = ta.update(ExampleTest.key("enter"))
    ta, _ = ta.update(ExampleTest.key("b"))
    ta, _ = ta.update(ExampleTest.key("home"))
    ta, _ = ta.update(ExampleTest.key("up"))
    ta, _ = ta.update(ExampleTest.key("end"))
    ta.cursor_col.should eq(1)
    ta, _ = ta.update(ExampleTest.key("delete"))
    ta.value.should eq("ab")
  end

  it "left/right arrow moves cursor" do
    ta = Crubbletea::Bubbles::TextArea::Model.new
    ta.focus
    ta, _ = ta.update(ExampleTest.key("a"))
    ta, _ = ta.update(ExampleTest.key("b"))
    ta, _ = ta.update(ExampleTest.key("c"))
    ta.cursor_col.should eq(3)
    ta, _ = ta.update(ExampleTest.key("left"))
    ta.cursor_col.should eq(2)
    ta, _ = ta.update(ExampleTest.key("right"))
    ta.cursor_col.should eq(3)
  end

  it "left at col 0 goes to previous line end" do
    ta = Crubbletea::Bubbles::TextArea::Model.new
    ta.focus
    ta, _ = ta.update(ExampleTest.key("a"))
    ta, _ = ta.update(ExampleTest.key("b"))
    ta, _ = ta.update(ExampleTest.key("enter"))
    ta, _ = ta.update(ExampleTest.key("c"))
    ta.cursor_row.should eq(1)
    ta.cursor_col.should eq(1)
    ta, _ = ta.update(ExampleTest.key("home"))
    ta.cursor_col.should eq(0)
    ta, _ = ta.update(ExampleTest.key("left"))
    ta.cursor_row.should eq(0)
    ta.cursor_col.should eq(2)
  end

  it "right at end of line goes to next line start" do
    ta = Crubbletea::Bubbles::TextArea::Model.new
    ta.focus
    ta, _ = ta.update(ExampleTest.key("a"))
    ta, _ = ta.update(ExampleTest.key("enter"))
    ta, _ = ta.update(ExampleTest.key("b"))
    ta, _ = ta.update(ExampleTest.key("home"))
    ta, _ = ta.update(ExampleTest.key("up"))
    ta, _ = ta.update(ExampleTest.key("end"))
    ta.cursor_col.should eq(1)
    ta, _ = ta.update(ExampleTest.key("right"))
    ta.cursor_row.should eq(1)
    ta.cursor_col.should eq(0)
  end

  it "up/down moves between lines" do
    ta = Crubbletea::Bubbles::TextArea::Model.new
    ta.focus
    ta, _ = ta.update(ExampleTest.key("a"))
    ta, _ = ta.update(ExampleTest.key("b"))
    ta, _ = ta.update(ExampleTest.key("enter"))
    ta, _ = ta.update(ExampleTest.key("c"))
    ta, _ = ta.update(ExampleTest.key("d"))
    ta.cursor_row.should eq(1)
    ta, _ = ta.update(ExampleTest.key("up"))
    ta.cursor_row.should eq(0)
    ta, _ = ta.update(ExampleTest.key("down"))
    ta.cursor_row.should eq(1)
  end

  it "up clamps col to shorter line" do
    ta = Crubbletea::Bubbles::TextArea::Model.new
    ta.focus
    ta, _ = ta.update(ExampleTest.key("a"))
    ta, _ = ta.update(ExampleTest.key("b"))
    ta, _ = ta.update(ExampleTest.key("c"))
    ta, _ = ta.update(ExampleTest.key("enter"))
    ta, _ = ta.update(ExampleTest.key("x"))
    ta.cursor_row.should eq(1)
    ta.cursor_col.should eq(1)
    ta, _ = ta.update(ExampleTest.key("up"))
    ta.cursor_row.should eq(0)
    ta.cursor_col.should eq(1)
  end

  it "home/end moves to line start/end" do
    ta = Crubbletea::Bubbles::TextArea::Model.new
    ta.focus
    ta, _ = ta.update(ExampleTest.key("a"))
    ta, _ = ta.update(ExampleTest.key("b"))
    ta, _ = ta.update(ExampleTest.key("c"))
    ta, _ = ta.update(ExampleTest.key("home"))
    ta.cursor_col.should eq(0)
    ta, _ = ta.update(ExampleTest.key("end"))
    ta.cursor_col.should eq(3)
  end

  it "ctrl+a/e works as home/end" do
    ta = Crubbletea::Bubbles::TextArea::Model.new
    ta.focus
    ta, _ = ta.update(ExampleTest.key("a"))
    ta, _ = ta.update(ExampleTest.key("b"))
    ta, _ = ta.update(ExampleTest.key("ctrl+a"))
    ta.cursor_col.should eq(0)
    ta, _ = ta.update(ExampleTest.key("ctrl+e"))
    ta.cursor_col.should eq(2)
  end

  it "ctrl+k kills to end of line" do
    ta = Crubbletea::Bubbles::TextArea::Model.new
    ta.focus
    ta, _ = ta.update(ExampleTest.key("a"))
    ta, _ = ta.update(ExampleTest.key("b"))
    ta, _ = ta.update(ExampleTest.key("c"))
    ta, _ = ta.update(ExampleTest.key("home"))
    ta, _ = ta.update(ExampleTest.key("right"))
    ta.cursor_col.should eq(1)
    ta, _ = ta.update(ExampleTest.key("ctrl+k"))
    ta.value.should eq("a")
    ta.cursor_col.should eq(1)
  end

  it "ctrl+u kills to start of line" do
    ta = Crubbletea::Bubbles::TextArea::Model.new
    ta.focus
    ta, _ = ta.update(ExampleTest.key("a"))
    ta, _ = ta.update(ExampleTest.key("b"))
    ta, _ = ta.update(ExampleTest.key("c"))
    ta, _ = ta.update(ExampleTest.key("home"))
    ta, _ = ta.update(ExampleTest.key("right"))
    ta, _ = ta.update(ExampleTest.key("ctrl+u"))
    ta.value.should eq("bc")
    ta.cursor_col.should eq(0)
  end

  it "respects char_limit" do
    ta = Crubbletea::Bubbles::TextArea::Model.new(char_limit: 5)
    ta.focus
    "abcde".each_char { |c| ta, _ = ta.update(ExampleTest.key(c.to_s)) }
    ta.value.should eq("abcde")
    ta, _ = ta.update(ExampleTest.key("f"))
    ta.value.should eq("abcde")
  end

  it "ignores keys when unfocused" do
    ta = Crubbletea::Bubbles::TextArea::Model.new
    ta, _ = ta.update(ExampleTest.key("a"))
    ta.value.should eq("")
  end

  it "shows placeholder when empty" do
    ta = Crubbletea::Bubbles::TextArea::Model.new(placeholder: "type here...")
    ta.focus
    ta.view.should contain("type here...")
  end

  it "hides placeholder after typing" do
    ta = Crubbletea::Bubbles::TextArea::Model.new(placeholder: "type here...")
    ta.focus
    ta, _ = ta.update(ExampleTest.key("x"))
    ta.view.should_not contain("type here...")
  end

  it "set_cursor positions cursor" do
    ta = Crubbletea::Bubbles::TextArea::Model.new
    ta.focus
    ta, _ = ta.update(ExampleTest.key("a"))
    ta, _ = ta.update(ExampleTest.key("enter"))
    ta, _ = ta.update(ExampleTest.key("b"))
    ta, _ = ta.update(ExampleTest.key("c"))
    ta.set_cursor(0, 1)
    ta.cursor_row.should eq(0)
    ta.cursor_col.should eq(1)
  end

  it "set_cursor clamps to valid range" do
    ta = Crubbletea::Bubbles::TextArea::Model.new
    ta.focus
    ta, _ = ta.update(ExampleTest.key("a"))
    ta.set_cursor(100, 100)
    ta.cursor_row.should eq(0)
    ta.cursor_col.should eq(1)
  end

  it "value= sets content and moves cursor to end" do
    ta = Crubbletea::Bubbles::TextArea::Model.new
    ta.focus
    ta.value = "hello\nworld"
    ta.line_count.should eq(2)
    ta.cursor_row.should eq(1)
    ta.cursor_col.should eq(5)
  end

  it "line() returns line content" do
    ta = Crubbletea::Bubbles::TextArea::Model.new
    ta.focus
    ta.value = "hello\nworld"
    ta.line(0).should eq("hello")
    ta.line(1).should eq("world")
  end

  it "line(idx) returns empty for out of bounds" do
    ta = Crubbletea::Bubbles::TextArea::Model.new
    ta.line(5).should eq("")
  end
end

private class TextareaApp
  include Crubbletea::Model

  getter textarea : Crubbletea::Bubbles::TextArea::Model

  def initialize(
    width : Int32 = 40,
    height : Int32 = 6,
    prompt : String = "┃ ",
    show_line_numbers : Bool = true,
    line_number_style : Crubbletea::Lipgloss::Style = Crubbletea::Lipgloss::Style.new.foreground("7"),
    placeholder : String = "Once upon a time..."
  )
    @textarea = Crubbletea::Bubbles::TextArea::Model.new(
      placeholder: placeholder,
      width: width,
      height: height,
      prompt: prompt,
      show_line_numbers: show_line_numbers,
      line_number_style: line_number_style
    )
    @textarea.focus
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {TextareaApp, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c"
        return {self, Crubbletea.quit}
      end
    end
    @textarea, cmd = @textarea.update(msg)
    {self, cmd}
  end

  def view : Crubbletea::View
    header = "Tell me a story.\n"
    footer = "\n(ctrl+c to quit)\n"
    content = "#{header}\n#{@textarea.view}\n#{footer}"
    v = Crubbletea.new_view(content)
    if @textarea.focused?
      v.cursor = Crubbletea::Cursor.new(@textarea.visible_cursor_col, 2 + @textarea.visible_cursor_row)
    end
    v
  end
end

private class TextareaAppNoLineNumbers
  include Crubbletea::Model

  getter textarea : Crubbletea::Bubbles::TextArea::Model

  def initialize(
    width : Int32 = 40,
    height : Int32 = 6,
    prompt : String = "┃ "
  )
    @textarea = Crubbletea::Bubbles::TextArea::Model.new(
      width: width,
      height: height,
      prompt: prompt,
      show_line_numbers: false
    )
    @textarea.focus
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {TextareaAppNoLineNumbers, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c"
        return {self, Crubbletea.quit}
      end
    end
    @textarea, cmd = @textarea.update(msg)
    {self, cmd}
  end

  def view : Crubbletea::View
    header = "Tell me a story.\n"
    footer = "\n(ctrl+c to quit)\n"
    content = "#{header}\n#{@textarea.view}\n#{footer}"
    v = Crubbletea.new_view(content)
    if @textarea.focused?
      v.cursor = Crubbletea::Cursor.new(@textarea.visible_cursor_col, 2 + @textarea.visible_cursor_row)
    end
    v
  end
end

describe "textarea cursor position" do
  it "visible_cursor_col includes prompt width" do
    ta = Crubbletea::Bubbles::TextArea::Model.new(prompt: "┃ ", show_line_numbers: false)
    ta.focus
    prompt_w = Crubbletea::Lipgloss::ANSI.string_width("┃ ")
    ta.visible_cursor_col.should eq(prompt_w)
  end

  it "visible_cursor_col includes line numbers width" do
    ta = Crubbletea::Bubbles::TextArea::Model.new(prompt: "┃ ", show_line_numbers: true)
    ta.focus
    prompt_w = Crubbletea::Lipgloss::ANSI.string_width("┃ ")
    gutter_w = 2
    ta.visible_cursor_col.should eq(prompt_w + gutter_w)
  end

  it "visible_cursor_col advances with typing" do
    ta = Crubbletea::Bubbles::TextArea::Model.new(prompt: "┃ ", show_line_numbers: true)
    ta.focus
    prompt_w = Crubbletea::Lipgloss::ANSI.string_width("┃ ")
    gutter_w = 2
    initial_col = ta.visible_cursor_col
    initial_col.should eq(prompt_w + gutter_w)
    ta, _ = ta.update(ExampleTest.key("a"))
    ta.visible_cursor_col.should eq(prompt_w + gutter_w + 1)
    ta, _ = ta.update(ExampleTest.key("b"))
    ta.visible_cursor_col.should eq(prompt_w + gutter_w + 2)
  end

  it "visible_cursor_row starts at 0" do
    ta = Crubbletea::Bubbles::TextArea::Model.new
    ta.focus
    ta.visible_cursor_row.should eq(0)
  end

  it "visible_cursor_row advances with newlines" do
    ta = Crubbletea::Bubbles::TextArea::Model.new(height: 10)
    ta.focus
    ta, _ = ta.update(ExampleTest.key("enter"))
    ta.visible_cursor_row.should eq(1)
    ta, _ = ta.update(ExampleTest.key("enter"))
    ta.visible_cursor_row.should eq(2)
  end

  it "cursor at correct position in app view — no line numbers" do
    app = TextareaAppNoLineNumbers.new(prompt: "┃ ")
    ta = app.textarea
    prompt_w = Crubbletea::Lipgloss::ANSI.string_width("┃ ")
    v = app.view
    c = v.cursor.not_nil!
    c.position.x.should eq(prompt_w), "cursor.x should be at prompt width #{prompt_w}, got #{c.position.x}"
  end

  it "cursor at correct position in app view — with line numbers" do
    app = TextareaApp.new
    ta = app.textarea
    prompt_w = Crubbletea::Lipgloss::ANSI.string_width("┃ ")
    gutter_w = 2
    v = app.view
    c = v.cursor.not_nil!
    c.position.x.should eq(prompt_w + gutter_w), "cursor.x should be at prompt(#{prompt_w}) + gutter(#{gutter_w}) = #{prompt_w + gutter_w}, got #{c.position.x}"
  end

  it "cursor advances correctly after typing — with line numbers" do
    app = TextareaApp.new
    ta = app.textarea
    prompt_w = Crubbletea::Lipgloss::ANSI.string_width("┃ ")
    gutter_w = 2
    base_x = prompt_w + gutter_w

    app, _ = app.update(ExampleTest.key("a"))
    v = app.view
    c = v.cursor.not_nil!
    c.position.x.should eq(base_x + 1), "after 'a': cursor.x should be #{base_x + 1}, got #{c.position.x}"

    app, _ = app.update(ExampleTest.key("b"))
    v = app.view
    c = v.cursor.not_nil!
    c.position.x.should eq(base_x + 2), "after 'ab': cursor.x should be #{base_x + 2}, got #{c.position.x}"
  end

  it "cursor Y advances after newline in app view" do
    app = TextareaApp.new
    app, _ = app.update(ExampleTest.key("enter"))
    v = app.view
    c = v.cursor.not_nil!
    c.position.y.should eq(3), "after enter: cursor.y should be 3 (header + 1 newline), got #{c.position.y}"
  end

  it "cursor Y is correct on second line after typing" do
    app = TextareaApp.new
    app, _ = app.update(ExampleTest.key("enter"))
    app, _ = app.update(ExampleTest.key("a"))
    v = app.view
    c = v.cursor.not_nil!
    prompt_w = Crubbletea::Lipgloss::ANSI.string_width("┃ ")
    gutter_w = 2
    base_x = prompt_w + gutter_w
    c.position.y.should eq(3), "cursor.y on second line should be 3, got #{c.position.y}"
    c.position.x.should eq(base_x + 1), "cursor.x after 'a' on line 2 should be #{base_x + 1}, got #{c.position.x}"
  end
end

describe "textarea view rendering" do
  it "shows placeholder when empty" do
    ta = Crubbletea::Bubbles::TextArea::Model.new(
      placeholder: "type here",
      width: 20,
      height: 3,
      show_line_numbers: false
    )
    ta.focus
    view = ta.view
    view.should contain("type here")
  end

  it "renders typed text" do
    ta = Crubbletea::Bubbles::TextArea::Model.new(width: 20, height: 3, show_line_numbers: false)
    ta.focus
    ta, _ = ta.update(ExampleTest.key("h"))
    ta, _ = ta.update(ExampleTest.key("i"))
    view = ta.view
    view.should contain("hi")
  end

  it "renders multiple lines" do
    ta = Crubbletea::Bubbles::TextArea::Model.new(width: 40, height: 5, show_line_numbers: false)
    ta.focus
    ta, _ = ta.update(ExampleTest.key("a"))
    ta, _ = ta.update(ExampleTest.key("enter"))
    ta, _ = ta.update(ExampleTest.key("b"))
    view = ta.view
    lines = view.split('\n')
    lines.size.should be >= 2
  end

  it "view height matches textarea height" do
    ta = Crubbletea::Bubbles::TextArea::Model.new(width: 40, height: 4, show_line_numbers: false)
    ta.focus
    view = ta.view
    view.split('\n').size.should eq(4)
  end

  it "shows line numbers when enabled" do
    ta = Crubbletea::Bubbles::TextArea::Model.new(
      width: 40,
      height: 3,
      show_line_numbers: true,
      line_number_style: Crubbletea::Lipgloss::Style.new.foreground("7")
    )
    ta.focus
    ta, _ = ta.update(ExampleTest.key("a"))
    view = ta.view
    stripped = ExampleTest.strip_ansi(view)
    stripped.should match(/^1 /)
  end

  it "shows line numbers for multiple lines" do
    ta = Crubbletea::Bubbles::TextArea::Model.new(
      width: 40,
      height: 5,
      show_line_numbers: true,
      line_number_style: Crubbletea::Lipgloss::Style.new.foreground("7")
    )
    ta.focus
    ta, _ = ta.update(ExampleTest.key("a"))
    ta, _ = ta.update(ExampleTest.key("enter"))
    ta, _ = ta.update(ExampleTest.key("b"))
    view = ta.view
    stripped = ExampleTest.strip_ansi(view)
    lines = stripped.split('\n')
    lines[0].should start_with("1")
    lines[1].should start_with("2")
  end

  it "shows prompt on each line" do
    ta = Crubbletea::Bubbles::TextArea::Model.new(
      prompt: "┃ ",
      width: 40,
      height: 3,
      show_line_numbers: false
    )
    ta.focus
    ta, _ = ta.update(ExampleTest.key("a"))
    ta, _ = ta.update(ExampleTest.key("enter"))
    ta, _ = ta.update(ExampleTest.key("b"))
    view = ta.view
    lines = view.split('\n')
    lines.each do |line|
      line.should start_with("┃ ")
    end
  end

  it "empty lines are padded" do
    ta = Crubbletea::Bubbles::TextArea::Model.new(width: 20, height: 3, show_line_numbers: false)
    ta.focus
    view = ta.view
    lines = view.split('\n')
    lines.size.should eq(3)
  end

  it "scrolls viewport down when cursor moves below visible area" do
    ta = Crubbletea::Bubbles::TextArea::Model.new(width: 40, height: 3, show_line_numbers: false)
    ta.focus
    5.times do |i|
      ta, _ = ta.update(ExampleTest.key("line#{i}"))
      ta, _ = ta.update(ExampleTest.key("enter"))
    end
    ta.cursor_row.should be >= 3
    ta.visible_cursor_row.should be < 3
  end
end

describe "textarea app view" do
  it "line numbers are NOT under the cursor position" do
    app = TextareaApp.new
    ta = app.textarea
    prompt_w = Crubbletea::Lipgloss::ANSI.string_width("┃ ")
    gutter_w = 2
    base_x = prompt_w + gutter_w

    v = app.view
    c = v.cursor.not_nil!
    c.position.x.should be >= (prompt_w + gutter_w), "cursor x=#{c.position.x} is over line numbers (gutter ends at #{prompt_w + gutter_w})"
  end

  it "cursor is NOT one char behind after typing" do
    app = TextareaApp.new
    ta = app.textarea
    prompt_w = Crubbletea::Lipgloss::ANSI.string_width("┃ ")
    gutter_w = 2
    base_x = prompt_w + gutter_w

    "hello".each_char do |ch|
      app, _ = app.update(ExampleTest.key(ch.to_s))
    end
    v = app.view
    c = v.cursor.not_nil!
    c.position.x.should eq(base_x + 5), "after 'hello': cursor.x should be #{base_x + 5}, got #{c.position.x}"
  end

  it "cursor tracks correctly across line navigation" do
    app = TextareaApp.new
    ta = app.textarea

    "hello".each_char { |c| app, _ = app.update(ExampleTest.key(c.to_s)) }
    app, _ = app.update(ExampleTest.key("enter"))
    "world".each_char { |c| app, _ = app.update(ExampleTest.key(c.to_s)) }

    v = app.view
    c = v.cursor.not_nil!
    c.position.y.should eq(3), "on line 2: cursor.y should be 3, got #{c.position.y}"

    app, _ = app.update(ExampleTest.key("up"))
    v = app.view
    c = v.cursor.not_nil!
    c.position.y.should eq(2), "after up: cursor.y should be 2, got #{c.position.y}"
    c.position.x.should be > 0, "cursor should be on content, not at x=0"
  end
end
