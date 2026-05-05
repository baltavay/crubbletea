require "./example_helper"
require "../../examples/focus-blur/main"

describe "focus-blur example" do
  it "starts focused with reporting on" do
    m = FocusBlurModel.new
    m.focused.should be_true
    m.reporting.should be_true
  end

  it "unfocuses on BlurMsg" do
    m = FocusBlurModel.new
    m, _ = m.update(Crubbletea::BlurMsg.new)
    m.focused.should be_false
  end

  it "refocuses on FocusMsg" do
    m = FocusBlurModel.new
    m, _ = m.update(Crubbletea::BlurMsg.new)
    m.focused.should be_false
    m, _ = m.update(Crubbletea::FocusMsg.new)
    m.focused.should be_true
  end

  it "toggles reporting on t" do
    m = FocusBlurModel.new
    m.reporting.should be_true
    m, _ = m.update(ExampleTest.key("t"))
    m.reporting.should be_false
    m, _ = m.update(ExampleTest.key("t"))
    m.reporting.should be_true
  end

  it "quits on q" do
    m = FocusBlurModel.new
    m, cmd = m.update(ExampleTest.key("q"))
    ExampleTest.assert_quit(cmd)
  end

  it "quits on ctrl+c" do
    m = FocusBlurModel.new
    m, cmd = m.update(ExampleTest.key("ctrl+c"))
    ExampleTest.assert_quit(cmd)
  end

  it "view shows focused when focused" do
    m = FocusBlurModel.new
    ExampleTest.assert_view_contains(m, "focused!")
    ExampleTest.assert_view_not_contains(m, "blurred!")
  end

  it "view shows blurred when blurred" do
    m = FocusBlurModel.new
    m, _ = m.update(Crubbletea::BlurMsg.new)
    ExampleTest.assert_view_contains(m, "blurred!")
    ExampleTest.assert_view_not_contains(m, "focused!")
  end

  it "view hides focus state when reporting disabled" do
    m = FocusBlurModel.new
    m, _ = m.update(ExampleTest.key("t"))
    ExampleTest.assert_view_not_contains(m, "focused!")
    ExampleTest.assert_view_not_contains(m, "blurred!")
  end

  it "view shows enabled when reporting on" do
    m = FocusBlurModel.new
    ExampleTest.assert_view_contains(m, "enabled")
  end

  it "view shows disabled when reporting off" do
    m = FocusBlurModel.new
    m, _ = m.update(ExampleTest.key("t"))
    ExampleTest.assert_view_contains(m, "disabled")
  end

  it "view sets report_focus when reporting on" do
    m = FocusBlurModel.new
    m.view.report_focus.should be_true
  end

  it "view unsets report_focus when reporting off" do
    m = FocusBlurModel.new
    m, _ = m.update(ExampleTest.key("t"))
    m.view.report_focus.should be_false
  end
end
