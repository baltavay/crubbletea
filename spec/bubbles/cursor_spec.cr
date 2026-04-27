require "../spec_helper"

describe Crubbletea::Bubbles::Cursor do
  describe "Model" do
    it "defaults to blink mode, unfocused" do
      c = Crubbletea::Bubbles::Cursor::Model.new
      c.focused?.should be_false
      c.mode.should eq(Crubbletea::Bubbles::Cursor::Model::Mode::Blink)
    end

    it "focuses and blurs" do
      c = Crubbletea::Bubbles::Cursor::Model.new
      c.focus
      c.focused?.should be_true
      c.blur
      c.focused?.should be_false
    end

    it "responds to FocusMsg" do
      c = Crubbletea::Bubbles::Cursor::Model.new
      c, _ = c.update(Crubbletea::FocusMsg.new)
      c.focused?.should be_true
    end

    it "responds to BlurMsg" do
      c = Crubbletea::Bubbles::Cursor::Model.new
      c.focus
      c, _ = c.update(Crubbletea::BlurMsg.new)
      c.focused?.should be_false
    end

    it "sets mode" do
      c = Crubbletea::Bubbles::Cursor::Model.new
      c.set_mode(Crubbletea::Bubbles::Cursor::Model::Mode::Hide)
      c.mode.should eq(Crubbletea::Bubbles::Cursor::Model::Mode::Hide)
    end

    describe "view" do
      it "renders reversed char when visible" do
        c = Crubbletea::Bubbles::Cursor::Model.new
        c.focus
        v = c.view("X")
        v.should contain("X")
      end

      it "renders plain char when blinked" do
        c = Crubbletea::Bubbles::Cursor::Model.new(mode: Crubbletea::Bubbles::Cursor::Model::Mode::Hide)
        c.focus
        v = c.view("X")
        Crubbletea::Lipgloss::ANSI.strip(v).should eq("X")
      end
    end
  end
end
