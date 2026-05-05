require "./example_helper"
require "../../examples/textinput/main"

describe "textinput example app" do
  it "shows header text" do
    app = TextinputModel.new
    ExampleTest.assert_view_contains(app, "What's your favorite Pokémon?")
  end

  it "shows footer text" do
    app = TextinputModel.new
    ExampleTest.assert_view_contains(app, "(esc to quit)")
  end

  it "shows prompt" do
    app = TextinputModel.new
    ExampleTest.assert_view_contains(app, "> ")
  end

  it "has cursor on second line" do
    app = TextinputModel.new
    v = app.view
    c = v.cursor.not_nil!
    c.position.y.should eq(1), "cursor should be on line 1 (second line), got #{c.position.y}"
  end

  it "cursor x starts at prompt width" do
    app = TextinputModel.new
    v = app.view
    c = v.cursor.not_nil!
    prompt_w = Crubbletea::Lipgloss::ANSI.string_width("> ")
    c.position.x.should eq(prompt_w), "cursor.x should be #{prompt_w}, got #{c.position.x}"
  end

  it "cursor x advances with typing" do
    app = TextinputModel.new
    prompt_w = Crubbletea::Lipgloss::ANSI.string_width("> ")
    app, _ = app.update(ExampleTest.key("a"))
    v = app.view
    c = v.cursor.not_nil!
    c.position.x.should eq(prompt_w + 1), "after 'a': cursor.x should be #{prompt_w + 1}, got #{c.position.x}"

    app, _ = app.update(ExampleTest.key("b"))
    v = app.view
    c = v.cursor.not_nil!
    c.position.x.should eq(prompt_w + 2), "after 'ab': cursor.x should be #{prompt_w + 2}, got #{c.position.x}"
  end

  it "cursor tracks across multiple characters" do
    app = TextinputModel.new
    prompt_w = Crubbletea::Lipgloss::ANSI.string_width("> ")
    "hello".each_char do |ch|
      app, _ = app.update(ExampleTest.key(ch.to_s))
    end
    v = app.view
    c = v.cursor.not_nil!
    c.position.x.should eq(prompt_w + 5), "after 'hello': cursor.x should be #{prompt_w + 5}, got #{c.position.x}"
  end

  it "quit on enter" do
    app = TextinputModel.new
    app, cmd = app.update(ExampleTest.key("enter"))
    app.quitting.should be_true
    ExampleTest.assert_quit(cmd)
  end

  it "quit on escape" do
    app = TextinputModel.new
    app, cmd = app.update(ExampleTest.key("escape"))
    app.quitting.should be_true
    ExampleTest.assert_quit(cmd)
  end

  it "quit on ctrl+c" do
    app = TextinputModel.new
    app, cmd = app.update(ExampleTest.key("ctrl+c"))
    app.quitting.should be_true
    ExampleTest.assert_quit(cmd)
  end

  it "adds newline suffix when quitting" do
    app = TextinputModel.new
    content_before = ExampleTest.view_text(app)
    app, _ = app.update(ExampleTest.key("enter"))
    content_after = ExampleTest.view_text(app)
    content_after.size.should be > content_before.size, "quitting should add newline suffix"
    content_after.should match(/\n$/)
  end

  it "no quit suffix while typing" do
    app = TextinputModel.new
    app, _ = app.update(ExampleTest.key("a"))
    content = ExampleTest.view_text(app)
    content.should_not match(/\n\n$/)
  end

  it "typed text appears in view" do
    app = TextinputModel.new
    "Charizard".each_char { |c| app, _ = app.update(ExampleTest.key(c.to_s)) }
    ExampleTest.assert_view_contains(app, "Charizard")
  end

  it "left/right arrow moves cursor" do
    app = TextinputModel.new
    prompt_w = Crubbletea::Lipgloss::ANSI.string_width("> ")
    "abc".each_char { |c| app, _ = app.update(ExampleTest.key(c.to_s)) }

    app, _ = app.update(ExampleTest.key("left"))
    v = app.view
    c = v.cursor.not_nil!
    c.position.x.should eq(prompt_w + 2), "after left: cursor.x should be #{prompt_w + 2}, got #{c.position.x}"

    app, _ = app.update(ExampleTest.key("left"))
    v = app.view
    c = v.cursor.not_nil!
    c.position.x.should eq(prompt_w + 1), "after 2x left: cursor.x should be #{prompt_w + 1}, got #{c.position.x}"

    app, _ = app.update(ExampleTest.key("right"))
    v = app.view
    c = v.cursor.not_nil!
    c.position.x.should eq(prompt_w + 2), "after right: cursor.x should be #{prompt_w + 2}, got #{c.position.x}"
  end

  it "home/end moves cursor to extremes" do
    app = TextinputModel.new
    prompt_w = Crubbletea::Lipgloss::ANSI.string_width("> ")
    "abc".each_char { |c| app, _ = app.update(ExampleTest.key(c.to_s)) }

    app, _ = app.update(ExampleTest.key("home"))
    v = app.view
    c = v.cursor.not_nil!
    c.position.x.should eq(prompt_w), "after home: cursor.x should be #{prompt_w}, got #{c.position.x}"

    app, _ = app.update(ExampleTest.key("end"))
    v = app.view
    c = v.cursor.not_nil!
    c.position.x.should eq(prompt_w + 3), "after end: cursor.x should be #{prompt_w + 3}, got #{c.position.x}"
  end

  it "ctrl+a/e works as home/end" do
    app = TextinputModel.new
    prompt_w = Crubbletea::Lipgloss::ANSI.string_width("> ")
    "abc".each_char { |c| app, _ = app.update(ExampleTest.key(c.to_s)) }

    app, _ = app.update(ExampleTest.key("ctrl+a"))
    v = app.view
    c = v.cursor.not_nil!
    c.position.x.should eq(prompt_w), "after ctrl+a: cursor.x should be #{prompt_w}, got #{c.position.x}"

    app, _ = app.update(ExampleTest.key("ctrl+e"))
    v = app.view
    c = v.cursor.not_nil!
    c.position.x.should eq(prompt_w + 3), "after ctrl+e: cursor.x should be #{prompt_w + 3}, got #{c.position.x}"
  end

  it "view line count stays stable while typing" do
    app = TextinputModel.new
    initial_lines = ExampleTest.view_text(app).split('\n').size
    initial_lines.should be > 0

    "hello world".each_char do |c|
      app, _ = app.update(ExampleTest.key(c.to_s))
      current_lines = ExampleTest.view_text(app).split('\n').size
      current_lines.should eq(initial_lines), "line count changed after '#{c}'"
    end
  end

  it "view line count stays stable with backspace" do
    app = TextinputModel.new
    initial_lines = ExampleTest.view_text(app).split('\n').size

    "abc".each_char { |c| app, _ = app.update(ExampleTest.key(c.to_s)) }
    3.times do
      app, _ = app.update(ExampleTest.key("backspace"))
      current_lines = ExampleTest.view_text(app).split('\n').size
      current_lines.should eq(initial_lines), "line count changed after backspace"
    end
  end

  it "ctrl+k kills to end of line" do
    app = TextinputModel.new
    "abc".each_char { |c| app, _ = app.update(ExampleTest.key(c.to_s)) }
    app, _ = app.update(ExampleTest.key("home"))
    app, _ = app.update(ExampleTest.key("right"))
    app, _ = app.update(ExampleTest.key("ctrl+k"))
    app.text_input.value.should eq("a")
  end

  it "ctrl+u kills to start of line" do
    app = TextinputModel.new
    "abc".each_char { |c| app, _ = app.update(ExampleTest.key(c.to_s)) }
    app, _ = app.update(ExampleTest.key("home"))
    app, _ = app.update(ExampleTest.key("right"))
    app, _ = app.update(ExampleTest.key("ctrl+u"))
    app.text_input.value.should eq("bc")
    app.text_input.cursor_pos.should eq(0)
  end

  it "insertion in middle updates cursor correctly" do
    app = TextinputModel.new
    prompt_w = Crubbletea::Lipgloss::ANSI.string_width("> ")
    "abc".each_char { |c| app, _ = app.update(ExampleTest.key(c.to_s)) }
    app, _ = app.update(ExampleTest.key("home"))
    app, _ = app.update(ExampleTest.key("right"))
    app, _ = app.update(ExampleTest.key("X"))
    app.text_input.value.should eq("aXbc")

    v = app.view
    c = v.cursor.not_nil!
    c.position.x.should eq(prompt_w + 2), "after insert in middle: cursor.x should be #{prompt_w + 2}, got #{c.position.x}"
  end

  it "suggestions view shows matched suggestions" do
    app = TextinputModel.new
    app.text_input.show_suggestions = true
    app.text_input.set_suggestions(["Pikachu", "Pidgey", "Charizard"])
    app, _ = app.update(ExampleTest.key("P"))
    suggestions = app.text_input.suggestions_view
    suggestions.should contain("Pikachu")
    suggestions.should contain("Pidgey")
    suggestions.should_not contain("Charizard")
  end
end
