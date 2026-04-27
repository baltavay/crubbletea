require "../spec_helper"

describe Crubbletea::Bubbles::Viewport do
  describe "Model" do
    it "defaults to 80x24" do
      vp = Crubbletea::Bubbles::Viewport::Model.new
      vp.width.should eq(80)
      vp.height.should eq(24)
      vp.y_offset.should eq(0)
      vp.x_offset.should eq(0)
    end

    it "starts at top" do
      vp = Crubbletea::Bubbles::Viewport::Model.new
      vp.at_top?.should be_true
    end

    describe "content" do
      it "sets and gets content" do
        vp = Crubbletea::Bubbles::Viewport::Model.new
        vp.content = "hello\nworld"
        vp.content.should eq("hello\nworld")
      end

      it "counts total lines" do
        vp = Crubbletea::Bubbles::Viewport::Model.new
        vp.content = "a\nb\nc\nd\ne"
        vp.total_lines.should eq(5)
      end

      it "gets line by index" do
        vp = Crubbletea::Bubbles::Viewport::Model.new
        vp.content = "first\nsecond\nthird"
        vp.line(0).should eq("first")
        vp.line(1).should eq("second")
        vp.line(2).should eq("third")
      end

      it "returns empty string for out-of-bounds" do
        vp = Crubbletea::Bubbles::Viewport::Model.new
        vp.content = "hello"
        vp.line(5).should eq("")
      end
    end

    describe "scrolling" do
      it "scrolls down" do
        vp = Crubbletea::Bubbles::Viewport::Model.new(height: 3)
        vp.content = (1..10).map(&.to_s).join('\n')
        vp.at_top?.should be_true
        vp.view_down
        vp.y_offset.should eq(1)
      end

      it "scrolls up" do
        vp = Crubbletea::Bubbles::Viewport::Model.new(height: 3)
        vp.content = (1..10).map(&.to_s).join('\n')
        vp.view_down(3)
        vp.view_up
        vp.y_offset.should eq(2)
      end

      it "does not scroll past top" do
        vp = Crubbletea::Bubbles::Viewport::Model.new(height: 3)
        vp.content = "hello"
        vp.view_up
        vp.y_offset.should eq(0)
      end

      it "does not scroll past bottom" do
        vp = Crubbletea::Bubbles::Viewport::Model.new(height: 5)
        vp.content = "a\nb\nc"
        vp.view_down(100)
        vp.y_offset.should eq(0)
        vp.at_bottom?.should be_true
      end

      it "scrolls by page with pgup/pgdown" do
        vp = Crubbletea::Bubbles::Viewport::Model.new(height: 3)
        vp.content = (1..20).map(&.to_s).join('\n')

        vp, _ = vp.update(Crubbletea::KeyPressMsg.new(Crubbletea::Key.new(code: Crubbletea::Key::Code::PgDown)))
        vp.y_offset.should eq(3)

        vp, _ = vp.update(Crubbletea::KeyPressMsg.new(Crubbletea::Key.new(code: Crubbletea::Key::Code::PgUp)))
        vp.y_offset.should eq(0)
      end

      it "goes to top with home" do
        vp = Crubbletea::Bubbles::Viewport::Model.new(height: 3)
        vp.content = (1..20).map(&.to_s).join('\n')
        vp.view_down(5)
        vp, _ = vp.update(Crubbletea::KeyPressMsg.new(Crubbletea::Key.new(code: Crubbletea::Key::Code::Home)))
        vp.y_offset.should eq(0)
        vp.at_top?.should be_true
      end

      it "goes to bottom with end" do
        vp = Crubbletea::Bubbles::Viewport::Model.new(height: 3)
        vp.content = (1..20).map(&.to_s).join('\n')
        vp, _ = vp.update(Crubbletea::KeyPressMsg.new(Crubbletea::Key.new(code: Crubbletea::Key::Code::End)))
        vp.at_bottom?.should be_true
      end
    end

    describe "set_size" do
      it "updates dimensions" do
        vp = Crubbletea::Bubbles::Viewport::Model.new
        vp.set_size(40, 10)
        vp.width.should eq(40)
        vp.height.should eq(10)
      end
    end

    describe "set_y_offset" do
      it "clamps to valid range" do
        vp = Crubbletea::Bubbles::Viewport::Model.new(height: 3)
        vp.content = (1..10).map(&.to_s).join('\n')
        vp.set_y_offset(-5)
        vp.y_offset.should eq(0)
        vp.set_y_offset(100)
        vp.y_offset.should eq(7)
      end
    end

    describe "view" do
      it "renders visible lines" do
        vp = Crubbletea::Bubbles::Viewport::Model.new(width: 20, height: 2)
        vp.content = "first\nsecond\nthird"
        view = vp.view
        lines = view.split('\n')
        lines.size.should eq(2)
        lines[0].should contain("first")
        lines[1].should contain("second")
      end

      it "shows empty lines past content" do
        vp = Crubbletea::Bubbles::Viewport::Model.new(width: 10, height: 5)
        vp.content = "only one line"
        view = vp.view
        view.split('\n').size.should eq(5)
      end
    end

    describe "over? and past_bottom?" do
      it "over? returns true past total lines" do
        vp = Crubbletea::Bubbles::Viewport::Model.new
        vp.content = "a\nb\nc"
        vp.over?(3).should be_true
        vp.over?(2).should be_false
      end

      it "past_bottom? checks past visible area" do
        vp = Crubbletea::Bubbles::Viewport::Model.new(height: 3)
        vp.content = (1..10).map(&.to_s).join('\n')
        vp.past_bottom?(5).should be_true
        vp.past_bottom?(3).should be_false
      end
    end

    describe "soft wrap" do
      it "wraps long lines when soft_wrap is true" do
        vp = Crubbletea::Bubbles::Viewport::Model.new(width: 10, height: 10, soft_wrap: true)
        vp.content = "this is a really long line that should wrap"
        vp.total_lines.should be > 1
      end

      it "does not wrap when soft_wrap is false" do
        vp = Crubbletea::Bubbles::Viewport::Model.new(width: 10, height: 10, soft_wrap: false)
        vp.content = "this is a really long line that should not wrap"
        vp.total_lines.should eq(1)
      end
    end
  end
end
