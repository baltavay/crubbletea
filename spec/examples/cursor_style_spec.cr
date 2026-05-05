require "./example_helper"
require "../../examples/cursor-style/main"

describe "cursor-style example" do
  it "starts with block shape and blink on" do
    m = CursorStyleModel.new
    m.shape.should eq(Crubbletea::CursorShape::Block)
    m.blink.should be_true
  end

  it "cycles shape forward on right" do
    m = CursorStyleModel.new
    m, _ = m.update(ExampleTest.key("right"))
    m.shape.should eq(Crubbletea::CursorShape::Underline)
  end

  it "cycles shape backward on left" do
    m = CursorStyleModel.new
    m, _ = m.update(ExampleTest.key("left"))
    m.shape.should eq(Crubbletea::CursorShape::Bar)
  end

  it "cycles shape forward with l" do
    m = CursorStyleModel.new
    m, _ = m.update(ExampleTest.key("l"))
    m.shape.should eq(Crubbletea::CursorShape::Underline)
  end

  it "cycles shape backward with h" do
    m = CursorStyleModel.new
    m, _ = m.update(ExampleTest.key("h"))
    m.shape.should eq(Crubbletea::CursorShape::Bar)
  end

  it "wraps forward through all shapes" do
    m = CursorStyleModel.new
    shapes = Crubbletea::CursorShape.values
    shapes.each do |expected|
      m.shape.should eq(expected)
      m, _ = m.update(ExampleTest.key("right"))
    end
    m.shape.should eq(shapes.first)
  end

  it "wraps backward through all shapes" do
    m = CursorStyleModel.new
    shapes = Crubbletea::CursorShape.values
    m, _ = m.update(ExampleTest.key("left"))
    m.shape.should eq(shapes.last)
  end

  it "toggles blink on every update" do
    m = CursorStyleModel.new
    m.blink.should be_true
    m, _ = m.update(ExampleTest.key("right"))
    m.blink.should be_false
    m, _ = m.update(ExampleTest.key("right"))
    m.blink.should be_true
  end

  it "quits on q" do
    m = CursorStyleModel.new
    m, cmd = m.update(ExampleTest.key("q"))
    ExampleTest.assert_quit(cmd)
  end

  it "quits on ctrl+c" do
    m = CursorStyleModel.new
    m, cmd = m.update(ExampleTest.key("ctrl+c"))
    ExampleTest.assert_quit(cmd)
  end

  it "describe_cursor returns correct string" do
    m = CursorStyleModel.new(shape: Crubbletea::CursorShape::Block, blink: true)
    m.describe_cursor.should eq("blinking block")

    m = CursorStyleModel.new(shape: Crubbletea::CursorShape::Underline, blink: false)
    m.describe_cursor.should eq("steady underline")

    m = CursorStyleModel.new(shape: Crubbletea::CursorShape::Bar, blink: true)
    m.describe_cursor.should eq("blinking bar")
  end

  it "view contains cursor description" do
    m = CursorStyleModel.new
    ExampleTest.assert_view_contains(m, "blinking block")
  end

  it "view has cursor set" do
    m = CursorStyleModel.new
    v = m.view
    v.cursor.should_not be_nil
    c = v.cursor.not_nil!
    c.position.should eq(Crubbletea::Position.new(0, 2))
    c.shape.should eq(Crubbletea::CursorShape::Block)
    c.blink.should be_true
  end
end
