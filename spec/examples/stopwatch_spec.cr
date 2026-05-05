require "./example_helper"

describe "stopwatch bubble" do
  it "starts not running" do
    sw = Crubbletea::Bubbles::Stopwatch::Model.new(interval: 1.millisecond)
    sw.running?.should be_false
    sw.elapsed.should eq(Time::Span.zero)
  end

  it "init returns a command" do
    sw = Crubbletea::Bubbles::Stopwatch::Model.new(interval: 1.millisecond)
    cmd = sw.init
    cmd.should_not be_nil
  end

  it "starts running on StartStopMsg(true)" do
    sw = Crubbletea::Bubbles::Stopwatch::Model.new(interval: 10.milliseconds)
    sw, _ = sw.update(Crubbletea::Bubbles::Stopwatch::StartStopMsg.new(sw.id, true))
    sw.running?.should be_true
  end

  it "accumulates time on tick" do
    sw = Crubbletea::Bubbles::Stopwatch::Model.new(interval: 10.milliseconds)
    sw, _ = sw.update(Crubbletea::Bubbles::Stopwatch::StartStopMsg.new(sw.id, true))
    tag = 0
    sw, _ = sw.update(Crubbletea::Bubbles::Stopwatch::TickMsg.new(sw.id, tag))
    sw.elapsed.should eq(10.milliseconds)
    sw, _ = sw.update(Crubbletea::Bubbles::Stopwatch::TickMsg.new(sw.id, tag + 1))
    sw.elapsed.should eq(20.milliseconds)
  end

  it "stops on StartStopMsg(false)" do
    sw = Crubbletea::Bubbles::Stopwatch::Model.new(interval: 10.milliseconds)
    sw, _ = sw.update(Crubbletea::Bubbles::Stopwatch::StartStopMsg.new(sw.id, true))
    sw.running?.should be_true
    sw, _ = sw.update(Crubbletea::Bubbles::Stopwatch::StartStopMsg.new(sw.id, false))
    sw.running?.should be_false
  end

  it "reset clears elapsed" do
    sw = Crubbletea::Bubbles::Stopwatch::Model.new(interval: 10.milliseconds)
    sw, _ = sw.update(Crubbletea::Bubbles::Stopwatch::StartStopMsg.new(sw.id, true))
    sw, _ = sw.update(Crubbletea::Bubbles::Stopwatch::TickMsg.new(sw.id, 0))
    sw.elapsed.should be > Time::Span.zero
    sw, _ = sw.update(Crubbletea::Bubbles::Stopwatch::ResetMsg.new(sw.id))
    sw.elapsed.should eq(Time::Span.zero)
  end

  it "view shows time" do
    sw = Crubbletea::Bubbles::Stopwatch::Model.new(interval: 1.millisecond)
    sw.view.should contain("0")
    sw.view.should contain("s")
  end

  it "rejects ticks from other stopwatches" do
    sw = Crubbletea::Bubbles::Stopwatch::Model.new(interval: 10.milliseconds)
    sw, _ = sw.update(Crubbletea::Bubbles::Stopwatch::StartStopMsg.new(sw.id, true))
    other_id = sw.id + 100
    sw, cmd = sw.update(Crubbletea::Bubbles::Stopwatch::TickMsg.new(other_id, 0))
    ExampleTest.assert_cmd_nil(cmd)
  end

  it "toggle returns start when stopped" do
    sw = Crubbletea::Bubbles::Stopwatch::Model.new(interval: 10.milliseconds)
    sw.running?.should be_false
    cmd = sw.toggle
    cmd.should_not be_nil
  end
end
