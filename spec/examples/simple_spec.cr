require "./example_helper"
require "../../examples/simple/main"

describe "simple" do
  it "shows initial countdown" do
    m = SimpleModel.new(10)
    ExampleTest.assert_view_contains(m, "exit in 10 seconds")
  end

  it "quits on q" do
    m = SimpleModel.new(10)
    m, cmd = m.update(ExampleTest.key("q"))
    ExampleTest.assert_quit(cmd)
  end

  it "quits on ctrl+c" do
    m = SimpleModel.new(10)
    m, cmd = m.update(ExampleTest.key("ctrl+c"))
    ExampleTest.assert_quit(cmd)
  end

  it "ignores other keys" do
    m = SimpleModel.new(10)
    m, cmd = m.update(ExampleTest.key("a"))
    ExampleTest.assert_cmd_nil(cmd)
    m.count.should eq(10)
  end

  it "counts down on tick" do
    m = SimpleModel.new(5)
    m, cmd = m.update(TickMsg.new)
    m.count.should eq(4)
    ExampleTest.assert_view_contains(m, "exit in 4 seconds")
  end

  it "quits when count reaches 0" do
    m = SimpleModel.new(1)
    m, cmd = m.update(TickMsg.new)
    m.count.should eq(0)
    ExampleTest.assert_quit(cmd)
  end

  it "cursor not set" do
    m = SimpleModel.new(10)
    ExampleTest.assert_no_cursor(m)
  end
end
