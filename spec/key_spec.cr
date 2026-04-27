require "./spec_helper"

describe Crubbletea::Key do
  describe ".new" do
    it "defaults to unknown code with empty text" do
      key = Crubbletea::Key.new
      key.code.should eq(Crubbletea::Key::Code::Unknown)
      key.text.should eq("")
      key.ctrl.should be_false
      key.alt.should be_false
      key.shift.should be_false
    end

    it "stores text, code, and modifiers" do
      key = Crubbletea::Key.new(text: "a", code: Crubbletea::Key::Code::Unknown, ctrl: true)
      key.text.should eq("a")
      key.ctrl.should be_true
      key.alt.should be_false
    end
  end

  describe "#to_s" do
    it "returns text for unknown keys" do
      Crubbletea::Key.new(text: "a").to_s.should eq("a")
    end

    it "returns code name for known keys" do
      Crubbletea::Key.new(code: Crubbletea::Key::Code::Enter).to_s.should eq("enter")
      Crubbletea::Key.new(code: Crubbletea::Key::Code::Up).to_s.should eq("up")
      Crubbletea::Key.new(code: Crubbletea::Key::Code::F1).to_s.should eq("f1")
    end

    it "includes modifiers" do
      Crubbletea::Key.new(code: Crubbletea::Key::Code::Unknown, text: "c", ctrl: true).to_s.should eq("ctrl+c")
      Crubbletea::Key.new(code: Crubbletea::Key::Code::Unknown, text: "x", alt: true).to_s.should eq("alt+x")
      Crubbletea::Key.new(code: Crubbletea::Key::Code::Unknown, text: "a", ctrl: true, alt: true).to_s.should eq("ctrl+alt+a")
    end
  end

  describe "Code enum" do
    it "has all expected key codes" do
      codes = Crubbletea::Key::Code.values
      codes.should contain(Crubbletea::Key::Code::Up)
      codes.should contain(Crubbletea::Key::Code::Down)
      codes.should contain(Crubbletea::Key::Code::Left)
      codes.should contain(Crubbletea::Key::Code::Right)
      codes.should contain(Crubbletea::Key::Code::Enter)
      codes.should contain(Crubbletea::Key::Code::Backspace)
      codes.should contain(Crubbletea::Key::Code::Tab)
      codes.should contain(Crubbletea::Key::Code::Escape)
      codes.should contain(Crubbletea::Key::Code::Space)
      codes.should contain(Crubbletea::Key::Code::Home)
      codes.should contain(Crubbletea::Key::Code::End)
      codes.should contain(Crubbletea::Key::Code::Insert)
      codes.should contain(Crubbletea::Key::Code::Delete)
      codes.should contain(Crubbletea::Key::Code::PgUp)
      codes.should contain(Crubbletea::Key::Code::PgDown)
      codes.should contain(Crubbletea::Key::Code::F1)
      codes.should contain(Crubbletea::Key::Code::F12)
    end
  end
end

describe Crubbletea::KeyPressMsg do
  it "includes Msg and stores key" do
    key = Crubbletea::Key.new(text: "q")
    msg = Crubbletea::KeyPressMsg.new(key)
    msg.is_a?(Crubbletea::Msg).should be_true
    msg.key.should eq(key)
    msg.to_s.should eq("q")
  end
end

describe Crubbletea::KeyReleaseMsg do
  it "includes Msg and stores key" do
    key = Crubbletea::Key.new(code: Crubbletea::Key::Code::Enter)
    msg = Crubbletea::KeyReleaseMsg.new(key)
    msg.is_a?(Crubbletea::Msg).should be_true
    msg.key.should eq(key)
  end
end
