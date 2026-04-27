require "./spec_helper"

describe Crubbletea::Position do
  it "defaults to origin" do
    pos = Crubbletea::Position.new
    pos.x.should eq(0)
    pos.y.should eq(0)
  end

  it "stores x and y" do
    pos = Crubbletea::Position.new(10, 20)
    pos.x.should eq(10)
    pos.y.should eq(20)
  end
end

describe Crubbletea::CursorShape do
  it "has expected values" do
    Crubbletea::CursorShape::Block.should_not be_nil
    Crubbletea::CursorShape::Underline.should_not be_nil
    Crubbletea::CursorShape::Bar.should_not be_nil
  end
end

describe Crubbletea::Cursor do
  describe ".new" do
    it "defaults to block cursor at origin with blink" do
      cursor = Crubbletea::Cursor.new
      cursor.position.x.should eq(0)
      cursor.position.y.should eq(0)
      cursor.shape.should eq(Crubbletea::CursorShape::Block)
      cursor.blink.should be_true
    end
  end

  describe ".new(x, y)" do
    it "creates cursor at given position" do
      cursor = Crubbletea::Cursor.new(5, 10)
      cursor.position.x.should eq(5)
      cursor.position.y.should eq(10)
    end
  end

  describe ".new(position)" do
    it "creates cursor with given position and shape" do
      pos = Crubbletea::Position.new(3, 7)
      cursor = Crubbletea::Cursor.new(pos, Crubbletea::CursorShape::Underline, blink: false)
      cursor.position.should eq(pos)
      cursor.shape.should eq(Crubbletea::CursorShape::Underline)
      cursor.blink.should be_false
    end
  end
end
