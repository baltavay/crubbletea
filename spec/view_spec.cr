require "./spec_helper"

describe Crubbletea::View do
  describe ".new" do
    it "defaults to empty content" do
      view = Crubbletea::View.new
      view.content.should eq("")
      view.alt_screen.should be_false
      view.cursor.should be_nil
      view.window_title.should eq("")
      view.mouse_mode.should eq(Crubbletea::MouseMode::None)
      view.report_focus.should be_false
    end

    it "accepts all options" do
      cursor = Crubbletea::Cursor.new(x: 5, y: 3)
      view = Crubbletea::View.new(
        content: "hello",
        alt_screen: true,
        cursor: cursor,
        window_title: "Test",
        mouse_mode: Crubbletea::MouseMode::CellMotion,
        report_focus: true
      )
      view.content.should eq("hello")
      view.alt_screen.should be_true
      view.cursor.should eq(cursor)
      view.window_title.should eq("Test")
      view.mouse_mode.should eq(Crubbletea::MouseMode::CellMotion)
      view.report_focus.should be_true
    end
  end

  describe "content property" do
    it "is mutable" do
      view = Crubbletea::View.new
      view.content = "updated"
      view.content.should eq("updated")
    end
  end
end
