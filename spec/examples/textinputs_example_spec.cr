require "./example_helper"
require "../../examples/textinputs/main"

describe "textinputs example app" do
  it "starts with first input focused" do
    app = TextinputsModel.new
    app.focus_index.should eq(0)
    app.inputs[0].focused?.should be_true
    app.inputs[1].focused?.should be_false
    app.inputs[2].focused?.should be_false
  end

  it "shows placeholders" do
    app = TextinputsModel.new
    view = app.inputs[0].view
    view.should contain("Nickname")
    app.inputs[1].view.should contain("Email")
  end

  it "password placeholder is masked" do
    app = TextinputsModel.new
    view = app.inputs[2].view
    view.should contain("*")
  end

  it "has cursor on first input line" do
    app = TextinputsModel.new
    v = app.view
    c = v.cursor.not_nil!
    c.position.y.should eq(0), "cursor should be on line 0, got #{c.position.y}"
  end

  it "cursor x starts at prompt width on first input" do
    app = TextinputsModel.new
    v = app.view
    c = v.cursor.not_nil!
    prompt_w = Crubbletea::Lipgloss::ANSI.string_width(app.inputs[0].prompt)
    c.position.x.should eq(prompt_w), "cursor.x should be at prompt width #{prompt_w}, got #{c.position.x}"
  end

  it "types into focused input only" do
    app = TextinputsModel.new
    app, _ = app.update(ExampleTest.key("a"))
    app.inputs[0].value.should eq("a")
    app.inputs[1].value.should eq("")
    app.inputs[2].value.should eq("")
  end

  it "tab advances focus to next input" do
    app = TextinputsModel.new
    app, _ = app.update(ExampleTest.key("tab"))
    app.focus_index.should eq(1)
    app.inputs[0].focused?.should be_false
    app.inputs[1].focused?.should be_true
    app.inputs[2].focused?.should be_false
  end

  it "tab cycles through all inputs and submit button" do
    app = TextinputsModel.new
    app, _ = app.update(ExampleTest.key("tab"))
    app.focus_index.should eq(1)
    app, _ = app.update(ExampleTest.key("tab"))
    app.focus_index.should eq(2)
    app, _ = app.update(ExampleTest.key("tab"))
    app.focus_index.should eq(3)
    app, _ = app.update(ExampleTest.key("tab"))
    app.focus_index.should eq(0)
  end

  it "enter advances focus like tab" do
    app = TextinputsModel.new
    app, _ = app.update(ExampleTest.key("enter"))
    app.focus_index.should eq(1)
  end

  it "enter on submit button quits" do
    app = TextinputsModel.new
    app, _ = app.update(ExampleTest.key("enter"))
    app, _ = app.update(ExampleTest.key("tab"))
    app, _ = app.update(ExampleTest.key("tab"))
    app.focus_index.should eq(3)
    app, cmd = app.update(ExampleTest.key("enter"))
    ExampleTest.assert_quit(cmd)
  end

  it "down advances focus" do
    app = TextinputsModel.new
    app, _ = app.update(ExampleTest.key("down"))
    app.focus_index.should eq(1)
  end

  it "up moves focus backward" do
    app = TextinputsModel.new
    app, _ = app.update(ExampleTest.key("tab"))
    app.focus_index.should eq(1)
    app, _ = app.update(ExampleTest.key("up"))
    app.focus_index.should eq(0)
  end

  it "escape quits" do
    app = TextinputsModel.new
    app, cmd = app.update(ExampleTest.key("escape"))
    app.quitting.should be_true
    ExampleTest.assert_quit(cmd)
  end

  it "ctrl+c quits" do
    app = TextinputsModel.new
    app, cmd = app.update(ExampleTest.key("ctrl+c"))
    app.quitting.should be_true
    ExampleTest.assert_quit(cmd)
  end

  it "cursor moves to correct input on tab" do
    app = TextinputsModel.new
    app, _ = app.update(ExampleTest.key("tab"))
    v = app.view
    c = v.cursor.not_nil!
    c.position.y.should eq(1), "cursor should be on line 1 after tab, got #{c.position.y}"
  end

  it "cursor tracks typing on first input" do
    app = TextinputsModel.new
    prompt_w = Crubbletea::Lipgloss::ANSI.string_width(app.inputs[0].prompt)
    "hi".each_char { |c| app, _ = app.update(ExampleTest.key(c.to_s)) }
    v = app.view
    c = v.cursor.not_nil!
    c.position.x.should eq(prompt_w + 2), "cursor.x should be #{prompt_w + 2} after 'hi', got #{c.position.x}"
    c.position.y.should eq(0)
  end

  it "cursor tracks typing on second input after tab" do
    app = TextinputsModel.new
    app, _ = app.update(ExampleTest.key("tab"))
    prompt_w = Crubbletea::Lipgloss::ANSI.string_width(app.inputs[1].prompt)
    "ab".each_char { |c| app, _ = app.update(ExampleTest.key(c.to_s)) }
    v = app.view
    c = v.cursor.not_nil!
    c.position.x.should eq(prompt_w + 2), "cursor.x should be #{prompt_w + 2} after 'ab', got #{c.position.x}"
    c.position.y.should eq(1), "cursor should be on input 1 (line 1), got #{c.position.y}"
  end

  it "no cursor when focused on submit button" do
    app = TextinputsModel.new
    app, _ = app.update(ExampleTest.key("tab"))
    app, _ = app.update(ExampleTest.key("tab"))
    app, _ = app.update(ExampleTest.key("tab"))
    app.focus_index.should eq(3)
    v = app.view
    v.cursor.should be_nil
  end

  it "password input uses echo_mode password" do
    app = TextinputsModel.new
    app, _ = app.update(ExampleTest.key("tab"))
    app, _ = app.update(ExampleTest.key("tab"))
    app.inputs[2].echo_mode.should eq(:password)
    "sec".each_char { |c| app, _ = app.update(ExampleTest.key(c.to_s)) }
    app.inputs[2].value.should eq("sec")
    view = app.inputs[2].view
    view.should contain("*")
    view.should_not contain("sec")
  end

  it "nickname input has char_limit 32" do
    app = TextinputsModel.new
    app.inputs[0].char_limit.should eq(32)
  end

  it "email input has char_limit 64" do
    app = TextinputsModel.new
    app.inputs[1].char_limit.should eq(64)
  end

  it "password input has char_limit 32" do
    app = TextinputsModel.new
    app.inputs[2].char_limit.should eq(32)
  end

  it "tab does not insert text into inputs" do
    app = TextinputsModel.new
    app, _ = app.update(ExampleTest.key("tab"))
    app.inputs[0].value.should eq("")
    app.inputs[1].value.should eq("")
  end

  it "ctrl+r cycles cursor mode" do
    app = TextinputsModel.new
    app.inputs[0].cursor.mode.should eq(Crubbletea::Bubbles::Cursor::Model::Mode::Blink)
    app, _ = app.update(ExampleTest.key("ctrl+r"))
    app.inputs[0].cursor.mode.should eq(Crubbletea::Bubbles::Cursor::Model::Mode::Static)
    app, _ = app.update(ExampleTest.key("ctrl+r"))
    app.inputs[0].cursor.mode.should eq(Crubbletea::Bubbles::Cursor::Model::Mode::Hide)
    app, _ = app.update(ExampleTest.key("ctrl+r"))
    app.inputs[0].cursor.mode.should eq(Crubbletea::Bubbles::Cursor::Model::Mode::Blink)
  end

  it "ctrl+r changes cursor mode on all inputs" do
    app = TextinputsModel.new
    app, _ = app.update(ExampleTest.key("ctrl+r"))
    app.inputs.each do |inp|
      inp.cursor.mode.should eq(Crubbletea::Bubbles::Cursor::Model::Mode::Static)
    end
  end

  it "view shows cursor mode help" do
    app = TextinputsModel.new
    content = ExampleTest.view_text(app)
    stripped = ExampleTest.strip_ansi(content)
    stripped.should contain("cursor mode is")
    stripped.should contain("Blink Block")
    stripped.should contain("ctrl+r to change style")
  end

  it "view updates cursor mode help after ctrl+r" do
    app = TextinputsModel.new
    app, _ = app.update(ExampleTest.key("ctrl+r"))
    content = ExampleTest.view_text(app)
    stripped = ExampleTest.strip_ansi(content)
    stripped.should contain("Steady Block")
  end

  it "view shows submit button" do
    app = TextinputsModel.new
    content = ExampleTest.strip_ansi(ExampleTest.view_text(app))
    content.should contain("Submit")
  end

  it "view has focused submit button when on submit" do
    app = TextinputsModel.new
    app, _ = app.update(ExampleTest.key("tab"))
    app, _ = app.update(ExampleTest.key("tab"))
    app, _ = app.update(ExampleTest.key("tab"))
    content = ExampleTest.view_text(app)
    content.should contain("Submit")
  end

  it "typing across multiple inputs works independently" do
    app = TextinputsModel.new
    "nick".each_char { |c| app, _ = app.update(ExampleTest.key(c.to_s)) }
    app, _ = app.update(ExampleTest.key("tab"))
    "test@test.com".each_char { |c| app, _ = app.update(ExampleTest.key(c.to_s)) }
    app.inputs[0].value.should eq("nick")
    app.inputs[1].value.should eq("test@test.com")
    app.inputs[2].value.should eq("")
  end

  it "up wraps to submit button from first input" do
    app = TextinputsModel.new
    app, _ = app.update(ExampleTest.key("up"))
    app.focus_index.should eq(3)
  end

  it "view line count is stable" do
    app = TextinputsModel.new
    initial = ExampleTest.view_text(app).split('\n').size
    "hello".each_char { |c| app, _ = app.update(ExampleTest.key(c.to_s)) }
    current = ExampleTest.view_text(app).split('\n').size
    current.should eq(initial)
  end

  it "cursor has blink=true by default" do
    app = TextinputsModel.new
    v = app.view
    c = v.cursor.not_nil!
    c.blink.should be_true
  end

  it "cursor has blink=false after ctrl+r (static mode)" do
    app = TextinputsModel.new
    app, _ = app.update(ExampleTest.key("ctrl+r"))
    v = app.view
    c = v.cursor.not_nil!
    c.blink.should be_false
  end

  it "no cursor when cursor mode is Hide" do
    app = TextinputsModel.new
    app, _ = app.update(ExampleTest.key("ctrl+r"))
    app, _ = app.update(ExampleTest.key("ctrl+r"))
    v = app.view
    v.cursor.should be_nil
  end

  it "quitting adds extra blank line" do
    app = TextinputsModel.new
    content_before = ExampleTest.view_text(app).split('\n').size
    app, _ = app.update(ExampleTest.key("escape"))
    content_after = ExampleTest.view_text(app).split('\n').size
    content_after.should eq(content_before + 1)
  end
end
