require "./spec_helper"

describe Crubbletea::Mouse do
  describe ".new" do
    it "defaults to no button at origin" do
      mouse = Crubbletea::Mouse.new
      mouse.x.should eq(0)
      mouse.y.should eq(0)
      mouse.button.should eq(Crubbletea::MouseButton::None)
      mouse.ctrl.should be_false
      mouse.alt.should be_false
      mouse.shift.should be_false
    end

    it "stores position, button, and modifiers" do
      mouse = Crubbletea::Mouse.new(x: 10, y: 20, button: Crubbletea::MouseButton::Left, ctrl: true)
      mouse.x.should eq(10)
      mouse.y.should eq(20)
      mouse.button.should eq(Crubbletea::MouseButton::Left)
      mouse.ctrl.should be_true
    end
  end

  describe "#to_s" do
    it "includes button and position" do
      mouse = Crubbletea::Mouse.new(x: 5, y: 3, button: Crubbletea::MouseButton::Left)
      s = mouse.to_s
      s.should contain("left")
      s.should contain("(5,3)")
    end

    it "includes modifiers" do
      mouse = Crubbletea::Mouse.new(x: 0, y: 0, button: Crubbletea::MouseButton::Right, ctrl: true)
      s = mouse.to_s
      s.should contain("ctrl")
      s.should contain("right")
    end
  end
end

describe Crubbletea::MouseButton do
  it "has expected values" do
    Crubbletea::MouseButton::None.should_not be_nil
    Crubbletea::MouseButton::Left.should_not be_nil
    Crubbletea::MouseButton::Middle.should_not be_nil
    Crubbletea::MouseButton::Right.should_not be_nil
    Crubbletea::MouseButton::WheelUp.should_not be_nil
    Crubbletea::MouseButton::WheelDown.should_not be_nil
    Crubbletea::MouseButton::WheelLeft.should_not be_nil
    Crubbletea::MouseButton::WheelRight.should_not be_nil
    Crubbletea::MouseButton::Backward.should_not be_nil
    Crubbletea::MouseButton::Forward.should_not be_nil
  end
end

describe Crubbletea::MouseMode do
  it "has expected values" do
    Crubbletea::MouseMode::None.should_not be_nil
    Crubbletea::MouseMode::CellMotion.should_not be_nil
    Crubbletea::MouseMode::AllMotion.should_not be_nil
  end
end

describe Crubbletea::MouseClickMsg do
  it "includes Msg" do
    mouse = Crubbletea::Mouse.new(button: Crubbletea::MouseButton::Left)
    msg = Crubbletea::MouseClickMsg.new(mouse)
    msg.is_a?(Crubbletea::Msg).should be_true
    msg.mouse.button.should eq(Crubbletea::MouseButton::Left)
  end
end

describe Crubbletea::MouseReleaseMsg do
  it "includes Msg" do
    msg = Crubbletea::MouseReleaseMsg.new(Crubbletea::Mouse.new)
    msg.is_a?(Crubbletea::Msg).should be_true
  end
end

describe Crubbletea::MouseWheelMsg do
  it "includes Msg" do
    msg = Crubbletea::MouseWheelMsg.new(Crubbletea::Mouse.new(button: Crubbletea::MouseButton::WheelUp))
    msg.is_a?(Crubbletea::Msg).should be_true
    msg.mouse.button.should eq(Crubbletea::MouseButton::WheelUp)
  end
end

describe Crubbletea::MouseMotionMsg do
  it "includes Msg" do
    msg = Crubbletea::MouseMotionMsg.new(Crubbletea::Mouse.new)
    msg.is_a?(Crubbletea::Msg).should be_true
  end
end
