require "../spec_helper"

describe Crubbletea::Bubbles::Key do
  describe "Binding" do
    it "stores keys and help info" do
      b = Crubbletea::Bubbles::Key::Binding.new(
        keys: ["up", "k"],
        help_key: "↑/k",
        help_desc: "move up"
      )
      b.keys.should eq(["up", "k"])
      b.help_key.should eq("↑/k")
      b.help_desc.should eq("move up")
    end

    it "is enabled when has keys and not disabled" do
      b = Crubbletea::Bubbles::Key::Binding.new(keys: ["q"], help_key: "q", help_desc: "quit")
      b.enabled?.should be_true
    end

    it "is disabled when no keys" do
      b = Crubbletea::Bubbles::Key::Binding.new(help_key: "q", help_desc: "quit")
      b.enabled?.should be_false
    end

    it "can be disabled" do
      b = Crubbletea::Bubbles::Key::Binding.new(keys: ["q"], help_key: "q", help_desc: "quit")
      b.enabled = false
      b.enabled?.should be_false
    end
  end

  describe ".new_binding" do
    it "creates a binding with keys" do
      b = Crubbletea::Bubbles::Key.new_binding("up", "k", help_key: "↑/k", help_desc: "up")
      b.keys.should eq(["up", "k"])
      b.help_key.should eq("↑/k")
    end
  end

  describe ".matches" do
    it "matches key to binding" do
      bindings = [
        Crubbletea::Bubbles::Key::Binding.new(keys: ["q"], help_key: "q", help_desc: "quit"),
        Crubbletea::Bubbles::Key::Binding.new(keys: ["up", "k"], help_key: "↑/k", help_desc: "up"),
      ]
      key_q = Crubbletea::Key.new(text: "q")
      Crubbletea::Bubbles::Key.matches(key_q, bindings).should be_true

      key_k = Crubbletea::Key.new(code: Crubbletea::Key::Code::Unknown, text: "k")
      Crubbletea::Bubbles::Key.matches(key_k, bindings).should be_true

      key_x = Crubbletea::Key.new(text: "x")
      Crubbletea::Bubbles::Key.matches(key_x, bindings).should be_false
    end

    it "skips disabled bindings" do
      b = Crubbletea::Bubbles::Key::Binding.new(keys: ["q"], help_key: "q", help_desc: "quit")
      b.enabled = false
      key_q = Crubbletea::Key.new(text: "q")
      Crubbletea::Bubbles::Key.matches(key_q, [b]).should be_false
    end
  end
end
