require "../spec_helper"

describe Crubbletea::Bubbles::Progress do
  describe "Model" do
    it "defaults to 0 percent" do
      p = Crubbletea::Bubbles::Progress::Model.new
      p.percent.should eq(0.0)
    end

    it "sets percent" do
      p = Crubbletea::Bubbles::Progress::Model.new
      p.set_percent(0.5)
      p.percent.should eq(0.5)
    end

    it "clamps percent to 0..1" do
      p = Crubbletea::Bubbles::Progress::Model.new
      p.set_percent(1.5)
      p.percent.should eq(1.0)
      p.set_percent(-0.5)
      p.percent.should eq(0.0)
    end

    it "increments percent" do
      p = Crubbletea::Bubbles::Progress::Model.new
      p.set_percent(0.3)
      p.incr_percent(0.2)
      p.percent.should be_close(0.5, 0.001)
    end

    it "decrements percent" do
      p = Crubbletea::Bubbles::Progress::Model.new
      p.set_percent(0.5)
      p.decr_percent(0.2)
      p.percent.should be_close(0.3, 0.001)
    end

    it "has default width" do
      p = Crubbletea::Bubbles::Progress::Model.new
      p.width.should eq(40)
    end

    it "set_percent returns a cmd" do
      p = Crubbletea::Bubbles::Progress::Model.new
      cmd = p.set_percent(0.5)
      cmd.should_not be_nil
    end

    describe "update" do
      it "updates with FrameMsg" do
        p = Crubbletea::Bubbles::Progress::Model.new
        cmd = p.set_percent(1.0)
        p.animating?.should be_true

        msg = cmd.not_nil!.call
        p, next_cmd = p.update(msg)
        next_cmd.should_not be_nil
      end

      it "ignores FrameMsg with wrong id" do
        p = Crubbletea::Bubbles::Progress::Model.new
        wrong_msg = Crubbletea::Bubbles::Progress::FrameMsg.new(p.id + 999, 0)
        p, cmd = p.update(wrong_msg)
        cmd.should be_nil
      end
    end

    describe "view" do
      it "renders at 0%" do
        p = Crubbletea::Bubbles::Progress::Model.new(show_percentage: false, width: 10)
        v = p.view_as(0.0)
        v.should_not be_empty
      end

      it "renders at 100%" do
        p = Crubbletea::Bubbles::Progress::Model.new(show_percentage: false, width: 10)
        v = p.view_as(1.0)
        v.should_not be_empty
      end

      it "shows percentage" do
        p = Crubbletea::Bubbles::Progress::Model.new(show_percentage: true)
        v = p.view_as(0.5)
        v.should contain("50")
      end
    end
  end
end
