require "./spec_helper"

describe Crubbletea do
  describe ".quit" do
    it "returns a Cmd that produces QuitMsg" do
      cmd = Crubbletea.quit
      cmd.should_not be_nil
      msg = cmd.not_nil!.call
      msg.should be_a(Crubbletea::QuitMsg)
    end
  end

  describe ".interrupt" do
    it "returns a Cmd that produces InterruptMsg" do
      cmd = Crubbletea.interrupt
      msg = cmd.not_nil!.call
      msg.should be_a(Crubbletea::InterruptMsg)
    end
  end

  describe ".suspend" do
    it "returns a Cmd that produces SuspendMsg" do
      cmd = Crubbletea.suspend
      msg = cmd.not_nil!.call
      msg.should be_a(Crubbletea::SuspendMsg)
    end
  end

  describe ".clear_screen" do
    it "returns a Cmd that produces ClearScreenMsg" do
      cmd = Crubbletea.clear_screen
      msg = cmd.not_nil!.call
      msg.should be_a(Crubbletea::ClearScreenMsg)
    end
  end

  describe ".batch" do
    it "returns nil for nil input" do
      Crubbletea.batch([nil.as(Crubbletea::Cmd)] * 0).should be_nil
    end

    it "returns nil for empty array" do
      Crubbletea.batch([] of Crubbletea::Cmd).should be_nil
    end

    it "returns single cmd unwrapped for single-element array" do
      cmd = Crubbletea.quit
      result = Crubbletea.batch([cmd])
      result.should_not be_nil
      msg = result.not_nil!.call
      msg.should be_a(Crubbletea::QuitMsg)
    end

    it "returns BatchMsg for multiple cmds" do
      cmds = [Crubbletea.quit, Crubbletea.quit].map(&.as(Crubbletea::Cmd))
      result = Crubbletea.batch(cmds)
      result.should_not be_nil
      msg = result.not_nil!.call
      msg.should be_a(Crubbletea::BatchMsg)
      batch = msg.as(Crubbletea::BatchMsg)
      batch.cmds.size.should eq(2)
    end

    it "filters nil cmds" do
      cmds = [nil.as(Crubbletea::Cmd), Crubbletea.quit, nil, Crubbletea.quit, nil].as(Array(Crubbletea::Cmd))
      result = Crubbletea.batch(cmds)
      msg = result.not_nil!.call
      batch = msg.as(Crubbletea::BatchMsg)
      batch.cmds.size.should eq(2)
    end
  end

  describe ".sequence" do
    it "returns nil for empty array" do
      Crubbletea.sequence([] of Crubbletea::Cmd).should be_nil
    end

    it "returns single cmd unwrapped for single-element array" do
      cmd = Crubbletea.quit
      result = Crubbletea.sequence([cmd])
      result.should_not be_nil
      msg = result.not_nil!.call
      msg.should be_a(Crubbletea::QuitMsg)
    end

    it "returns SequenceMsg for multiple cmds" do
      cmds = [Crubbletea.quit, Crubbletea.quit].map(&.as(Crubbletea::Cmd))
      result = Crubbletea.sequence(cmds)
      msg = result.not_nil!.call
      msg.should be_a(Crubbletea::SequenceMsg)
      seq = msg.as(Crubbletea::SequenceMsg)
      seq.cmds.size.should eq(2)
    end

    it "filters nil cmds" do
      cmds = [nil.as(Crubbletea::Cmd), Crubbletea.quit, nil].as(Array(Crubbletea::Cmd))
      result = Crubbletea.sequence(cmds)
      msg = result.not_nil!.call
      msg.should be_a(Crubbletea::QuitMsg)
    end
  end

  describe ".tick" do
    it "produces a message after duration" do
      produced = false
      cmd = Crubbletea.tick(1.millisecond) { |t| produced = true; Crubbletea::QuitMsg.new.as(Crubbletea::Msg) }
      msg = cmd.not_nil!.call
      msg.should be_a(Crubbletea::QuitMsg)
      produced.should be_true
    end
  end

  describe ".every" do
    it "produces a message" do
      cmd = Crubbletea.every(1.millisecond) { |t| Crubbletea::QuitMsg.new.as(Crubbletea::Msg) }
      msg = cmd.not_nil!.call
      msg.should be_a(Crubbletea::QuitMsg)
    end
  end

  describe ".new_view" do
    it "creates a View with given content" do
      view = Crubbletea.new_view("hello")
      view.should be_a(Crubbletea::View)
      view.content.should eq("hello")
    end
  end
end
