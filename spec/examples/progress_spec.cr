require "./example_helper"

describe "progress bubble" do
  it "starts at 0" do
    p = Crubbletea::Bubbles::Progress::Model.new
    p.percent.should eq(0.0)
  end

  it "set_percent sets target" do
    p = Crubbletea::Bubbles::Progress::Model.new
    cmd = p.set_percent(0.5)
    p.percent.should eq(0.5)
  end

  it "incr_percent increases" do
    p = Crubbletea::Bubbles::Progress::Model.new
    p.set_percent(0.0)
    p.incr_percent(0.25)
    p.percent.should eq(0.25)
  end

  it "decr_percent decreases" do
    p = Crubbletea::Bubbles::Progress::Model.new
    p.set_percent(0.5)
    p.decr_percent(0.25)
    p.percent.should eq(0.25)
  end

  it "clamps to 0 and 1" do
    p = Crubbletea::Bubbles::Progress::Model.new
    p.set_percent(-0.5)
    p.percent.should eq(0.0)
    p.set_percent(1.5)
    p.percent.should eq(1.0)
  end

  it "view shows filled char" do
    p = Crubbletea::Bubbles::Progress::Model.new
    p.set_percent(0.5)
    view = p.view_as(0.5)
    view.should contain("▌")
  end

  it "view_as at 0 shows empty char" do
    p = Crubbletea::Bubbles::Progress::Model.new
    view = p.view_as(0.0)
    view.should contain("░")
  end

  it "view_as shows percentage" do
    p = Crubbletea::Bubbles::Progress::Model.new
    view = p.view_as(0.5)
    view.should contain("50%")
  end

  it "animates on frame msg" do
    p = Crubbletea::Bubbles::Progress::Model.new
    cmd = p.set_percent(1.0)
    frame_result = cmd.not_nil!.call
    p, cmd2 = p.update(frame_result)
    cmd2.should_not be_nil
  end
end
