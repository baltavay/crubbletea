require "./example_helper"
require "../../examples/composable-views/main"

describe "composable-views example" do
  it "starts on timer view" do
    m = ComposableViewsModel.new
    m.state.should eq(ViewState::TimerView)
  end

  it "toggles to spinner on tab" do
    m = ComposableViewsModel.new
    m, _ = m.update(ExampleTest.key("tab"))
    m.state.should eq(ViewState::SpinnerView)
  end

  it "toggles back to timer on second tab" do
    m = ComposableViewsModel.new
    m, _ = m.update(ExampleTest.key("tab"))
    m, _ = m.update(ExampleTest.key("tab"))
    m.state.should eq(ViewState::TimerView)
  end

  it "cycles spinner style on n in spinner view" do
    m = ComposableViewsModel.new
    m, _ = m.update(ExampleTest.key("tab"))
    m.spinner_index.should eq(0)
    m, _ = m.update(ExampleTest.key("n"))
    m.spinner_index.should eq(1)
    m, _ = m.update(ExampleTest.key("n"))
    m.spinner_index.should eq(2)
  end

  it "wraps spinner index" do
    m = ComposableViewsModel.new
    m, _ = m.update(ExampleTest.key("tab"))
    (ComposableViewsModel::SPINNERS.size).times { m, _ = m.update(ExampleTest.key("n")) }
    m.spinner_index.should eq(0)
  end

  it "resets timer on n in timer view" do
    m = ComposableViewsModel.new
    old_timeout = m.timer.timeout
    m, _ = m.update(ExampleTest.key("n"))
    m.timer.timeout.should eq(1.minute)
  end

  it "quits on q" do
    m = ComposableViewsModel.new
    m, cmd = m.update(ExampleTest.key("q"))
    ExampleTest.assert_quit(cmd)
  end

  it "quits on ctrl+c" do
    m = ComposableViewsModel.new
    m, cmd = m.update(ExampleTest.key("ctrl+c"))
    ExampleTest.assert_quit(cmd)
  end

  it "view shows help text" do
    m = ComposableViewsModel.new
    ExampleTest.assert_view_contains(m, "tab: focus next")
    ExampleTest.assert_view_contains(m, "q: exit")
  end

  it "view shows timer label in timer mode" do
    m = ComposableViewsModel.new
    ExampleTest.assert_view_contains(m, "timer")
  end

  it "view shows spinner label in spinner mode" do
    m = ComposableViewsModel.new
    m, _ = m.update(ExampleTest.key("tab"))
    ExampleTest.assert_view_contains(m, "spinner")
  end

  it "init returns batched commands" do
    m = ComposableViewsModel.new
    cmd = m.init
    cmd.should_not be_nil
  end
end
