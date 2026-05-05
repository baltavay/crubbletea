require "./example_helper"

describe "textinput bubble" do
  it "starts unfocused" do
    ti = Crubbletea::Bubbles::TextInput::Model.new(width: 20)
    ti.focused?.should be_false
  end

  it "can focus" do
    ti = Crubbletea::Bubbles::TextInput::Model.new(width: 20)
    ti.focus
    ti.focused?.should be_true
  end

  it "types characters" do
    ti = Crubbletea::Bubbles::TextInput::Model.new(width: 20)
    ti.focus
    ti, cmd = ti.update(ExampleTest.key("h"))
    ti, cmd = ti.update(ExampleTest.key("e"))
    ti, cmd = ti.update(ExampleTest.key("l"))
    ti, cmd = ti.update(ExampleTest.key("l"))
    ti, cmd = ti.update(ExampleTest.key("o"))
    ti.value.should eq("hello")
  end

  it "backspace deletes last char" do
    ti = Crubbletea::Bubbles::TextInput::Model.new(width: 20)
    ti.focus
    ti, _ = ti.update(ExampleTest.key("a"))
    ti, _ = ti.update(ExampleTest.key("b"))
    ti, _ = ti.update(ExampleTest.key("c"))
    ti.value.should eq("abc")
    ti, _ = ti.update(ExampleTest.key("backspace"))
    ti.value.should eq("ab")
  end

  it "shows placeholder when empty" do
    ti = Crubbletea::Bubbles::TextInput::Model.new(width: 20, placeholder: "type here...")
    ti.focus
    ti.view.should contain("type here...")
  end

  it "hides placeholder after typing" do
    ti = Crubbletea::Bubbles::TextInput::Model.new(width: 20, placeholder: "type here...")
    ti.focus
    ti, _ = ti.update(ExampleTest.key("x"))
    ti.view.should_not contain("type here...")
    ti.value.should eq("x")
  end

  it "respects char_limit" do
    ti = Crubbletea::Bubbles::TextInput::Model.new(width: 20, char_limit: 3)
    ti.focus
    ti, _ = ti.update(ExampleTest.key("a"))
    ti, _ = ti.update(ExampleTest.key("b"))
    ti, _ = ti.update(ExampleTest.key("c"))
    ti, _ = ti.update(ExampleTest.key("d"))
    ti.value.should eq("abc")
  end

  it "visible_cursor_pos starts at prompt width" do
    ti = Crubbletea::Bubbles::TextInput::Model.new(width: 20)
    ti.focus
    pw = Crubbletea::Lipgloss::ANSI.string_width(ti.prompt)
    ti.visible_cursor_pos.should eq(pw)
  end

  it "visible_cursor_pos advances with typing" do
    ti = Crubbletea::Bubbles::TextInput::Model.new(width: 20)
    ti.focus
    pw = Crubbletea::Lipgloss::ANSI.string_width(ti.prompt)
    ti, _ = ti.update(ExampleTest.key("a"))
    ti.visible_cursor_pos.should eq(pw + 1)
    ti, _ = ti.update(ExampleTest.key("b"))
    ti.visible_cursor_pos.should eq(pw + 2)
  end

  it "shows prompt" do
    ti = Crubbletea::Bubbles::TextInput::Model.new(prompt: "> ", width: 20)
    ti.focus
    ti.view.should contain("> ")
  end

  it "cursor position in view" do
    ti = Crubbletea::Bubbles::TextInput::Model.new(prompt: "> ", width: 20)
    ti.focus
    ti, _ = ti.update(ExampleTest.key("a"))
    ti, _ = ti.update(ExampleTest.key("b"))
    ti.visible_cursor_pos.should eq(4)
  end

  it "echo mode password hides chars" do
    ti = Crubbletea::Bubbles::TextInput::Model.new(width: 20, echo_mode: :password)
    ti.focus
    ti, _ = ti.update(ExampleTest.key("s"))
    ti, _ = ti.update(ExampleTest.key("e"))
    ti, _ = ti.update(ExampleTest.key("c"))
    ti.value.should eq("sec")
    view = ti.view
    view.should_not contain("sec")
  end

  it "left/right arrow moves cursor" do
    ti = Crubbletea::Bubbles::TextInput::Model.new(width: 20)
    ti.focus
    ti, _ = ti.update(ExampleTest.key("a"))
    ti, _ = ti.update(ExampleTest.key("b"))
    ti, _ = ti.update(ExampleTest.key("c"))
    ti.value.should eq("abc")
    ti, _ = ti.update(ExampleTest.key("left"))
    ti, _ = ti.update(ExampleTest.key("left"))
    ti, _ = ti.update(ExampleTest.key("x"))
    ti.value.should eq("axbc")
  end

  it "delete key removes char at cursor" do
    ti = Crubbletea::Bubbles::TextInput::Model.new(width: 20)
    ti.focus
    ti, _ = ti.update(ExampleTest.key("a"))
    ti, _ = ti.update(ExampleTest.key("b"))
    ti, _ = ti.update(ExampleTest.key("c"))
    ti, _ = ti.update(ExampleTest.key("left"))
    ti, _ = ti.update(ExampleTest.key("delete"))
    ti.value.should eq("ab")
  end

  it "home/end keys" do
    ti = Crubbletea::Bubbles::TextInput::Model.new(width: 20)
    ti.focus
    ti, _ = ti.update(ExampleTest.key("a"))
    ti, _ = ti.update(ExampleTest.key("b"))
    ti, _ = ti.update(ExampleTest.key("c"))
    ti, _ = ti.update(ExampleTest.key("home"))
    ti, _ = ti.update(ExampleTest.key("x"))
    ti.value.should eq("xabc")
    ti, _ = ti.update(ExampleTest.key("end"))
    ti, _ = ti.update(ExampleTest.key("y"))
    ti.value.should eq("xabcy")
  end
end

private class TextinputApp
  include Crubbletea::Model

  getter input : Crubbletea::Bubbles::TextInput::Model

  def initialize
    @input = Crubbletea::Bubbles::TextInput::Model.new(prompt: "> ", width: 20)
    @input.focus
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {TextinputApp, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c", "escape"
        return {self, Crubbletea.quit}
      end
    end
    @input, cmd = @input.update(msg)
    {self, cmd}
  end

  def view : Crubbletea::View
    v = Crubbletea.new_view("\n#{@input.view}\n\nPress ctrl+c to quit\n")
    if @input.focused?
      pw = Crubbletea::Lipgloss::ANSI.string_width(@input.prompt)
       v.cursor = Crubbletea::Cursor.new(@input.visible_cursor_pos, 1)
    end
    v
  end
end

private def count_cursor_up(output : String) : Int32
  output.scan(/\e\[(\d+)A/).map { |m| m[1].to_i }.sum
end

private def count_cursor_down(output : String) : Int32
  output.scan(/\e\[(\d+)B/).map { |m| m[1].to_i }.sum
end

private def count_newlines(output : String) : Int32
  output.count('\n')
end

describe "textinput rendering" do
  it "renderer inline_height tracks correctly across renders" do
    io = IO::Memory.new
    renderer = Crubbletea::Renderer.new(io)
    app = TextinputApp.new
    renderer.render(app.view)
    height1 = renderer.@inline_height
    height1.should be > 0

    "hello".each_char do |c|
      app, _ = app.update(ExampleTest.key(c.to_s))
      renderer.render(app.view)
      renderer.@inline_height.should eq(height1), "inline_height drifted after typing '#{c}'"
    end
  end

  it "renderer output has no trailing newline on last content line" do
    io = IO::Memory.new
    renderer = Crubbletea::Renderer.new(io)
    app = TextinputApp.new
    renderer.render(app.view)
    output = io.to_s
    output.should_not match(/\n\n$/)
  end

  it "renderer cursor_up on re-render matches cursor row" do
    io = IO::Memory.new
    renderer = Crubbletea::Renderer.new(io)
    app = TextinputApp.new

    renderer.render(app.view)
    cursor_y = app.view.cursor.not_nil!.position.y

    io.clear
    app, _ = app.update(ExampleTest.key("a"))
    renderer.render(app.view)

    output = io.to_s
    output.should contain(Crubbletea::ANSI.cursor_up(cursor_y))
  end

  it "cursor position tracks typing correctly" do
    app = TextinputApp.new
    pw = Crubbletea::Lipgloss::ANSI.string_width(app.input.prompt)

    app, _ = app.update(ExampleTest.key("a"))
    ExampleTest.assert_cursor_at(app, pw + 1, 1)

    app, _ = app.update(ExampleTest.key("b"))
    ExampleTest.assert_cursor_at(app, pw + 2, 1)

    app, _ = app.update(ExampleTest.key("c"))
    ExampleTest.assert_cursor_at(app, pw + 3, 1)
  end
end

describe "renderer inline stability" do
  it "cursor_up on re-render moves back to content top" do
    io = IO::Memory.new
    renderer = Crubbletea::Renderer.new(io)
    app = TextinputApp.new

    renderer.render(app.view)
    cursor_y = app.view.cursor.not_nil!.position.y
    height = renderer.@inline_height
    height.should be > 0

    io.clear
    app, _ = app.update(ExampleTest.key("a"))
    renderer.render(app.view)

    output = io.to_s
    up_count = count_cursor_up(output)
    down_count = count_cursor_down(output)
    nl_count = count_newlines(output)
    net_up = up_count - down_count - nl_count
    net_up.should eq(0), "net vertical movement should be 0, got up=#{up_count} down=#{down_count} nl=#{nl_count} = #{net_up}"
  end

  it "typing many characters does not drift inline_height" do
    io = IO::Memory.new
    renderer = Crubbletea::Renderer.new(io)
    app = TextinputApp.new

    renderer.render(app.view)
    expected_height = renderer.@inline_height

    "hello world".each_char do |c|
      app, _ = app.update(ExampleTest.key(c.to_s))
      io.clear
      renderer.render(app.view)
      renderer.@inline_height.should eq(expected_height), "height drifted after '#{c}'"
    end
  end

  it "each re-render produces same cursor_up count as first re-render" do
    io = IO::Memory.new
    renderer = Crubbletea::Renderer.new(io)
    app = TextinputApp.new

    renderer.render(app.view)

    cursor_up_counts = [] of Int32
    "abcde".each_char do |c|
      app, _ = app.update(ExampleTest.key(c.to_s))
      io.clear
      renderer.render(app.view)
      cursor_up_counts << count_cursor_up(io.to_s)
    end

    cursor_up_counts.each_with_index do |count, i|
      count.should eq(cursor_up_counts[0]), "cursor_up count changed at char #{i}: #{count} != #{cursor_up_counts[0]}"
    end
  end

  it "net vertical movement is zero across consecutive renders" do
    io = IO::Memory.new
    renderer = Crubbletea::Renderer.new(io)
    app = TextinputApp.new

    renderer.render(app.view)

    "abc".each_char do |c|
      app, _ = app.update(ExampleTest.key(c.to_s))
      io.clear
      renderer.render(app.view)
      output = io.to_s

      up = count_cursor_up(output)
      nl = count_newlines(output)
      down = count_cursor_down(output)

      net = up - down - nl
      net.should eq(0), "net vertical movement after '#{c}': up=#{up} - down=#{down} - newlines=#{nl} = #{net}, should be 0"
    end
  end

  it "cursor row is consistent across renders" do
    io = IO::Memory.new
    renderer = Crubbletea::Renderer.new(io)
    app = TextinputApp.new

    renderer.render(app.view)
    cursor_y = app.view.cursor.not_nil!.position.y

    "xyz".each_char do |c|
      app, _ = app.update(ExampleTest.key(c.to_s))
      io.clear
      renderer.render(app.view)

      renderer.@cursor_row.should eq(cursor_y), "cursor_row drifted after '#{c}'"
    end
  end

  it "backspace then retype does not drift" do
    io = IO::Memory.new
    renderer = Crubbletea::Renderer.new(io)
    app = TextinputApp.new

    renderer.render(app.view)
    expected_height = renderer.@inline_height

    "abc".each_char { |c| app, _ = app.update(ExampleTest.key(c.to_s)) }
    3.times { app, _ = app.update(ExampleTest.key("backspace")) }
    "xyz".each_char { |c| app, _ = app.update(ExampleTest.key(c.to_s)) }

    io.clear
    renderer.render(app.view)
    renderer.@inline_height.should eq(expected_height)
  end
end

private class CursorStyleApp
  include Crubbletea::Model

  @blink : Bool
  @shape : Crubbletea::CursorShape

  def initialize(@blink : Bool = true, @shape : Crubbletea::CursorShape = :block)
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {CursorStyleApp, Crubbletea::Cmd?}
    {self, nil}
  end

  def view : Crubbletea::View
    v = Crubbletea.new_view("hello\n")
    v.cursor = Crubbletea::Cursor.new(0, 0, @shape, @blink)
    v
  end
end

describe "renderer cursor style transitions" do
  it "sends steady style immediately after hide when switching from blink" do
    io = IO::Memory.new
    renderer = Crubbletea::Renderer.new(io)

    blink_app = CursorStyleApp.new(blink: true)
    renderer.render(blink_app.view)
    output1 = io.to_s
    output1.should contain("\e[1 q"), "first render should set blink block"
    output1.should contain("\e[?25l"), "first render should hide cursor"
    output1.should contain("\e[?25h"), "first render should show cursor"

    io.clear
    steady_app = CursorStyleApp.new(blink: false)
    renderer.render(steady_app.view)
    output2 = io.to_s
    hide_idx = output2.index("\e[?25l").not_nil!
    steady_idx = output2.index("\e[2 q").not_nil!
    show_idx = output2.index("\e[?25h").not_nil!
    hide_idx.should be < steady_idx, "hide should come before steady style"
    steady_idx.should be < show_idx, "steady style should come before show"
  end

  it "steady style appears twice: after hide and before show" do
    io = IO::Memory.new
    renderer = Crubbletea::Renderer.new(io)

    blink_app = CursorStyleApp.new(blink: true)
    renderer.render(blink_app.view)
    io.clear

    steady_app = CursorStyleApp.new(blink: false)
    renderer.render(steady_app.view)
    output = io.to_s
    count = output.scan(/\e\[2 q/).size
    count.should be >= 1, "steady style should be sent at least once"
  end

  it "does not resend same style on re-render" do
    io = IO::Memory.new
    renderer = Crubbletea::Renderer.new(io)

    app = CursorStyleApp.new(blink: false)
    renderer.render(app.view)
    io.clear

    renderer.render(app.view)
    io.to_s.size.should eq(0), "same view should produce no output"
  end

  it "sends blink style when switching from steady" do
    io = IO::Memory.new
    renderer = Crubbletea::Renderer.new(io)

    steady_app = CursorStyleApp.new(blink: false)
    renderer.render(steady_app.view)
    io.clear

    blink_app = CursorStyleApp.new(blink: true)
    renderer.render(blink_app.view)
    output = io.to_s
    hide_idx = output.index("\e[?25l").not_nil!
    blink_idx = output.index("\e[1 q").not_nil!
    show_idx = output.index("\e[?25h").not_nil!
    hide_idx.should be < blink_idx, "hide should come before blink style"
    blink_idx.should be < show_idx, "blink style should come before show"
  end

  it "cursor style change triggers render even when content is same" do
    io = IO::Memory.new
    renderer = Crubbletea::Renderer.new(io)

    blink_app = CursorStyleApp.new(blink: true)
    renderer.render(blink_app.view)
    io.clear

    steady_app = CursorStyleApp.new(blink: false)
    renderer.render(steady_app.view)
    io.to_s.size.should be > 0, "style change alone should produce output"
  end

  it "force_render sends cursor style after hide" do
    io = IO::Memory.new
    renderer = Crubbletea::Renderer.new(io)

    steady_app = CursorStyleApp.new(blink: false)
    renderer.force_render(steady_app.view)
    output = io.to_s
    hide_idx = output.index("\e[?25l").not_nil!
    steady_idx = output.index("\e[2 q").not_nil!
    show_idx = output.index("\e[?25h").not_nil!
    hide_idx.should be < steady_idx, "hide should come before steady style in force_render"
    steady_idx.should be < show_idx, "steady style should come before show in force_render"
  end
end
