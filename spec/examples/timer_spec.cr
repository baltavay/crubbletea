require "./example_helper"

describe "timer bubble" do
  it "starts running by default" do
    t = Crubbletea::Bubbles::Timer::Model.new(timeout: 5.seconds)
    t.running?.should be_true
    t.timedout?.should be_false
  end

  it "init returns tick command" do
    t = Crubbletea::Bubbles::Timer::Model.new(timeout: 5.seconds, interval: 1.second)
    cmd = t.init
    cmd.should_not be_nil
  end

  it "counts down on tick from init" do
    t = Crubbletea::Bubbles::Timer::Model.new(timeout: 5.seconds, interval: 1.second)
    init_cmd = t.init.not_nil!
    tick_msg = init_cmd.call.as(Crubbletea::Bubbles::Timer::TickMsg)
    t, cmd = t.update(tick_msg)
    t.timeout.should be < 5.seconds
    t.running?.should be_true
  end

  it "stops on stop command" do
    t = Crubbletea::Bubbles::Timer::Model.new(timeout: 5.seconds, interval: 1.second)
    t, cmd = t.update(Crubbletea::Bubbles::Timer::StartStopMsg.new(t.id, false))
    t.running?.should be_false
  end

  it "starts on start command" do
    t = Crubbletea::Bubbles::Timer::Model.new(timeout: 5.seconds, interval: 1.second)
    t, _ = t.update(Crubbletea::Bubbles::Timer::StartStopMsg.new(t.id, false))
    t.running?.should be_false
    t, cmd = t.update(Crubbletea::Bubbles::Timer::StartStopMsg.new(t.id, true))
    t.running?.should be_true
  end

  it "toggle stops then starts" do
    t = Crubbletea::Bubbles::Timer::Model.new(timeout: 5.seconds, interval: 1.second)
    t.running?.should be_true
    cmd = t.stop.not_nil!
    t, _ = t.update(cmd.call.as(Crubbletea::Msg))
    t.running?.should be_false
    cmd = t.start.not_nil!
    t, _ = t.update(cmd.call.as(Crubbletea::Msg))
    t.running?.should be_true
  end

  it "reset sets timeout back" do
    t = Crubbletea::Bubbles::Timer::Model.new(timeout: 5.seconds, interval: 1.second)
    init_cmd = t.init.not_nil!
    tick_msg = init_cmd.call.as(Crubbletea::Bubbles::Timer::TickMsg)
    t, _ = t.update(tick_msg)
    t.timeout.should be < 5.seconds
    t.reset(5.seconds)
    t.timeout.should eq(5.seconds)
  end

  it "times out when countdown reaches zero" do
    t = Crubbletea::Bubbles::Timer::Model.new(timeout: 1.second, interval: 1.second)
    init_cmd = t.init.not_nil!
    tick_msg = init_cmd.call.as(Crubbletea::Bubbles::Timer::TickMsg)
    t, cmd = t.update(tick_msg)
    t.timedout?.should be_true
    t.running?.should be_false
  end

  it "view shows time" do
    t = Crubbletea::Bubbles::Timer::Model.new(timeout: 3.5.seconds)
    t.view.should contain("3")
    t.view.should contain("50")
  end

  it "rejects ticks from other timers" do
    t = Crubbletea::Bubbles::Timer::Model.new(timeout: 5.seconds)
    other_id = t.id + 100
    t, cmd = t.update(Crubbletea::Bubbles::Timer::TickMsg.new(other_id, false, 1))
    ExampleTest.assert_cmd_nil(cmd)
  end
end
