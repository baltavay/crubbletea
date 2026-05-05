require "./example_helper"
require "../../examples/views/main"

describe "views example" do
  it "starts unchosen with 10 ticks" do
    m = ViewsModel.new
    m.chosen.should be_false
    m.choice.should eq(0)
    m.ticks.should eq(10)
    m.quitting.should be_false
  end

  it "moves choice down on j" do
    m = ViewsModel.new
    m, _ = m.update(ExampleTest.key("j"))
    m.choice.should eq(1)
  end

  it "moves choice down on down" do
    m = ViewsModel.new
    m, _ = m.update(ExampleTest.key("down"))
    m.choice.should eq(1)
  end

  it "moves choice up on k" do
    m = ViewsModel.new
    m, _ = m.update(ExampleTest.key("j"))
    m, _ = m.update(ExampleTest.key("k"))
    m.choice.should eq(0)
  end

  it "clamps choice at 3 going down" do
    m = ViewsModel.new
    5.times { m, _ = m.update(ExampleTest.key("j")) }
    m.choice.should eq(3)
  end

  it "clamps choice at 0 going up" do
    m = ViewsModel.new
    m, _ = m.update(ExampleTest.key("k"))
    m.choice.should eq(0)
  end

  it "enters chosen state on enter" do
    m = ViewsModel.new
    m, cmd = m.update(ExampleTest.key("enter"))
    m.chosen.should be_true
    cmd.should_not be_nil
  end

  it "preserves choice when entering chosen state" do
    m = ViewsModel.new
    m, _ = m.update(ExampleTest.key("j"))
    m, _ = m.update(ExampleTest.key("j"))
    m, _ = m.update(ExampleTest.key("enter"))
    m.chosen.should be_true
    m.choice.should eq(2)
  end

  it "quits on q" do
    m = ViewsModel.new
    m, cmd = m.update(ExampleTest.key("q"))
    m.quitting.should be_true
    ExampleTest.assert_quit(cmd)
  end

  it "quits on escape" do
    m = ViewsModel.new
    m, cmd = m.update(ExampleTest.key("escape"))
    m.quitting.should be_true
    ExampleTest.assert_quit(cmd)
  end

  it "quits on ctrl+c" do
    m = ViewsModel.new
    m, cmd = m.update(ExampleTest.key("ctrl+c"))
    m.quitting.should be_true
    ExampleTest.assert_quit(cmd)
  end

  it "counts down ticks on TickMsg" do
    m = ViewsModel.new
    m, _ = m.update(TickMsg.new)
    m.ticks.should eq(9)
  end

  it "quits when ticks reach zero" do
    m = ViewsModel.new
    11.times { m, _ = m.update(TickMsg.new) }
    m.quitting.should be_true
  end

  it "progresses animation on FrameMsg in chosen state" do
    m = ViewsModel.new
    m, _ = m.update(ExampleTest.key("enter"))
    m.loaded.should be_false
    m.progress.should eq(0.0)
    m, _ = m.update(FrameMsg.new)
    m.progress.should be > 0.0
  end

  it "reaches loaded state after enough frames" do
    m = ViewsModel.new
    m, _ = m.update(ExampleTest.key("enter"))
    100.times { m, _ = m.update(FrameMsg.new) }
    m.loaded.should be_true
    m.progress.should eq(1.0)
  end

  it "counts down after loaded then quits" do
    m = ViewsModel.new
    m, _ = m.update(ExampleTest.key("enter"))
    100.times { m, _ = m.update(FrameMsg.new) }
    m.loaded.should be_true
    m.ticks.should eq(3)
    4.times { m, _ = m.update(TickMsg.new) }
    m.quitting.should be_true
  end

  it "view shows choice options before choosing" do
    m = ViewsModel.new
    ExampleTest.assert_view_contains(m, "Plant carrots")
    ExampleTest.assert_view_contains(m, "See friends")
  end

  it "view shows countdown" do
    m = ViewsModel.new
    ExampleTest.assert_view_contains(m, "seconds")
  end

  it "view shows progress bar after choosing" do
    m = ViewsModel.new
    m, _ = m.update(ExampleTest.key("enter"))
    ExampleTest.assert_view_contains(m, "Downloading")
  end
end
