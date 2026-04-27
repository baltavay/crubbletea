require "../spec_helper"

describe Crubbletea::Bubbles::Spinner do
  describe "spinner constants" do
    it "LINE has correct frames" do
      Crubbletea::Bubbles::Spinner::LINE.frames.should eq(["|", "/", "-", "\\"])
      Crubbletea::Bubbles::Spinner::LINE.fps.should eq(100.milliseconds)
    end

    it "DOT has 8 frames" do
      Crubbletea::Bubbles::Spinner::DOT.frames.size.should eq(8)
    end

    it "MINI_DOT has 10 frames" do
      Crubbletea::Bubbles::Spinner::MINI_DOT.frames.size.should eq(10)
    end

    it "PULSE has 4 frames" do
      Crubbletea::Bubbles::Spinner::PULSE.frames.size.should eq(4)
    end

    it "GLOBE has 3 frames" do
      Crubbletea::Bubbles::Spinner::GLOBE.frames.size.should eq(3)
    end

    it "MOON has 8 frames" do
      Crubbletea::Bubbles::Spinner::MOON.frames.size.should eq(8)
    end

    it "MONKEY has 3 frames" do
      Crubbletea::Bubbles::Spinner::MONKEY.frames.size.should eq(3)
    end
  end

  describe "Model" do
    it "defaults to LINE spinner" do
      model = Crubbletea::Bubbles::Spinner::Model.new
      model.spinner.should eq(Crubbletea::Bubbles::Spinner::LINE)
      model.frame.should eq(0)
    end

    it "accepts custom spinner" do
      custom = Crubbletea::Bubbles::Spinner::SpinnerFrames.new(["a", "b", "c"], 50.milliseconds)
      model = Crubbletea::Bubbles::Spinner::Model.new(custom)
      model.spinner.should eq(custom)
    end

    it "advances frame on tick" do
      model = Crubbletea::Bubbles::Spinner::Model.new
      model.frame.should eq(0)

      tick_msg = Crubbletea::Bubbles::Spinner::TickMsg.new(Time.utc, model.id, 0)
      model, cmd = model.update(tick_msg)
      model.frame.should eq(1)
      cmd.should_not be_nil

      tick_cmd = cmd.not_nil!
      next_tick = tick_cmd.call.as(Crubbletea::Bubbles::Spinner::TickMsg)
      model, _ = model.update(next_tick)
      model.frame.should eq(2)
    end

    it "wraps frame around" do
      spinner = Crubbletea::Bubbles::Spinner::SpinnerFrames.new(["a", "b"], 100.milliseconds)
      model = Crubbletea::Bubbles::Spinner::Model.new(spinner)

      tick = Crubbletea::Bubbles::Spinner::TickMsg.new(Time.utc, model.id, 0)
      model, cmd = model.update(tick)
      model.frame.should eq(1)

      next_tick = cmd.not_nil!.call.as(Crubbletea::Bubbles::Spinner::TickMsg)
      model, _ = model.update(next_tick)
      model.frame.should eq(0)
    end

    it "ignores tick for wrong id" do
      model = Crubbletea::Bubbles::Spinner::Model.new
      wrong_id_tick = Crubbletea::Bubbles::Spinner::TickMsg.new(Time.utc, model.id + 100, 1)
      model, _ = model.update(wrong_id_tick)
      model.frame.should eq(0)
    end

    it "renders current frame" do
      model = Crubbletea::Bubbles::Spinner::Model.new
      model.view.should eq("|")
    end

    it "renders styled frame" do
      style = Crubbletea::Lipgloss::Style.new.bold(true)
      model = Crubbletea::Bubbles::Spinner::Model.new(style: style)
      model.view.should contain("\e[1m")
    end

    it "tick returns a cmd" do
      model = Crubbletea::Bubbles::Spinner::Model.new
      cmd = model.tick
      cmd.should_not be_nil
      msg = cmd.not_nil!.call
      msg.should be_a(Crubbletea::Bubbles::Spinner::TickMsg)
    end
  end
end
