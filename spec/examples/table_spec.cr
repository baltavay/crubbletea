require "./example_helper"
require "../../examples/table/main"

describe "table example" do
  it "starts with row 0 selected and focused" do
    m = TableModel.new
    m.selected_row.should eq(0)
    m.focused.should be_true
    m.selected_city.should be_nil
  end

  it "moves down on down" do
    m = TableModel.new
    m, _ = m.update(ExampleTest.key("down"))
    m.selected_row.should eq(1)
  end

  it "moves down on j" do
    m = TableModel.new
    m, _ = m.update(ExampleTest.key("j"))
    m.selected_row.should eq(1)
  end

  it "moves up on up" do
    m = TableModel.new
    m, _ = m.update(ExampleTest.key("down"))
    m, _ = m.update(ExampleTest.key("up"))
    m.selected_row.should eq(0)
  end

  it "moves up on k" do
    m = TableModel.new
    m, _ = m.update(ExampleTest.key("j"))
    m, _ = m.update(ExampleTest.key("k"))
    m.selected_row.should eq(0)
  end

  it "does not go above first row" do
    m = TableModel.new
    m, _ = m.update(ExampleTest.key("up"))
    m.selected_row.should eq(0)
  end

  it "does not go below last row" do
    m = TableModel.new
    20.times { m, _ = m.update(ExampleTest.key("down")) }
    m.selected_row.should eq(TABLE_ROWS.size - 1)
  end

  it "toggles focus on escape" do
    m = TableModel.new
    m.focused.should be_true
    m, _ = m.update(ExampleTest.key("escape"))
    m.focused.should be_false
    m, _ = m.update(ExampleTest.key("escape"))
    m.focused.should be_true
  end

  it "selects city on enter and quits" do
    m = TableModel.new
    m, cmd = m.update(ExampleTest.key("enter"))
    m.selected_city.should eq("Tokyo")
    ExampleTest.assert_quit(cmd)
  end

  it "selects correct city after navigating" do
    m = TableModel.new
    m, _ = m.update(ExampleTest.key("down"))
    m, _ = m.update(ExampleTest.key("down"))
    m, cmd = m.update(ExampleTest.key("enter"))
    m.selected_city.should eq("Shanghai")
    ExampleTest.assert_quit(cmd)
  end

  it "quits on q" do
    m = TableModel.new
    m, cmd = m.update(ExampleTest.key("q"))
    ExampleTest.assert_quit(cmd)
  end

  it "quits on ctrl+c" do
    m = TableModel.new
    m, cmd = m.update(ExampleTest.key("ctrl+c"))
    ExampleTest.assert_quit(cmd)
  end

  it "view contains city names" do
    m = TableModel.new
    ExampleTest.assert_view_contains(m, "Tokyo")
    ExampleTest.assert_view_contains(m, "Delhi")
  end

  it "view contains help text" do
    m = TableModel.new
    ExampleTest.assert_view_contains(m, "navigate")
    ExampleTest.assert_view_contains(m, "select")
  end
end
