require "./spec_helper"

describe Crubbletea do
  describe "QuitMsg" do
    it "includes Msg" do
      msg = Crubbletea::QuitMsg.new
      msg.is_a?(Crubbletea::Msg).should be_true
    end
  end

  describe "InterruptMsg" do
    it "includes Msg" do
      msg = Crubbletea::InterruptMsg.new
      msg.is_a?(Crubbletea::Msg).should be_true
    end
  end

  describe "SuspendMsg" do
    it "includes Msg" do
      msg = Crubbletea::SuspendMsg.new
      msg.is_a?(Crubbletea::Msg).should be_true
    end
  end

  describe "ResumeMsg" do
    it "includes Msg" do
      msg = Crubbletea::ResumeMsg.new
      msg.is_a?(Crubbletea::Msg).should be_true
    end
  end

  describe "WindowSizeMsg" do
    it "stores width and height" do
      msg = Crubbletea::WindowSizeMsg.new(120, 40)
      msg.width.should eq(120)
      msg.height.should eq(40)
    end
  end

  describe "ClearScreenMsg" do
    it "includes Msg" do
      msg = Crubbletea::ClearScreenMsg.new
      msg.is_a?(Crubbletea::Msg).should be_true
    end
  end

  describe "FocusMsg" do
    it "includes Msg" do
      msg = Crubbletea::FocusMsg.new
      msg.is_a?(Crubbletea::Msg).should be_true
    end
  end

  describe "BlurMsg" do
    it "includes Msg" do
      msg = Crubbletea::BlurMsg.new
      msg.is_a?(Crubbletea::Msg).should be_true
    end
  end

  describe "PasteMsg" do
    it "stores content" do
      msg = Crubbletea::PasteMsg.new("hello world")
      msg.content.should eq("hello world")
      msg.to_s.should eq("hello world")
    end
  end

  describe "CursorPositionMsg" do
    it "stores x and y" do
      msg = Crubbletea::CursorPositionMsg.new(10, 20)
      msg.x.should eq(10)
      msg.y.should eq(20)
    end
  end

  describe "BatchMsg" do
    it "stores cmds" do
      cmds = [Crubbletea.quit.not_nil!, Crubbletea.quit.not_nil!]
      msg = Crubbletea::BatchMsg.new(cmds)
      msg.cmds.size.should eq(2)
    end
  end

  describe "SequenceMsg" do
    it "stores cmds" do
      cmds = [Crubbletea.quit.not_nil!, Crubbletea.quit.not_nil!]
      msg = Crubbletea::SequenceMsg.new(cmds)
      msg.cmds.size.should eq(2)
    end
  end

  describe "EnvMsg" do
    it "stores env array" do
      msg = Crubbletea::EnvMsg.new(["TERM=xterm", "SHELL=/bin/bash"])
      msg.env.size.should eq(2)
    end
  end
end
