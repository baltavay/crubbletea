require "./example_helper"
require "../../examples/tabs/main"

describe "tabs example" do
  it "starts at tab 0" do
    m = TabsModel.new
    m.active_tab.should eq(0)
  end

  it "moves right on right" do
    m = TabsModel.new
    m, _ = m.update(ExampleTest.key("right"))
    m.active_tab.should eq(1)
  end

  it "moves right on l" do
    m = TabsModel.new
    m, _ = m.update(ExampleTest.key("l"))
    m.active_tab.should eq(1)
  end

  it "moves right on n" do
    m = TabsModel.new
    m, _ = m.update(ExampleTest.key("n"))
    m.active_tab.should eq(1)
  end

  it "moves right on tab" do
    m = TabsModel.new
    m, _ = m.update(ExampleTest.key("tab"))
    m.active_tab.should eq(1)
  end

  it "moves left on left" do
    m = TabsModel.new
    m, _ = m.update(ExampleTest.key("right"))
    m, _ = m.update(ExampleTest.key("left"))
    m.active_tab.should eq(0)
  end

  it "moves left on h" do
    m = TabsModel.new
    m, _ = m.update(ExampleTest.key("right"))
    m, _ = m.update(ExampleTest.key("h"))
    m.active_tab.should eq(0)
  end

  it "moves left on p" do
    m = TabsModel.new
    m, _ = m.update(ExampleTest.key("right"))
    m, _ = m.update(ExampleTest.key("p"))
    m.active_tab.should eq(0)
  end

  it "moves left on shift+tab" do
    m = TabsModel.new
    m, _ = m.update(ExampleTest.key("right"))
    m, _ = m.update(ExampleTest.key("shift+tab"))
    m.active_tab.should eq(0)
  end

  it "clamps at last tab" do
    m = TabsModel.new
    10.times { m, _ = m.update(ExampleTest.key("right")) }
    m.active_tab.should eq(TABS.size - 1)
  end

  it "clamps at first tab" do
    m = TabsModel.new
    10.times { m, _ = m.update(ExampleTest.key("left")) }
    m.active_tab.should eq(0)
  end

  it "quits on q" do
    m = TabsModel.new
    m, cmd = m.update(ExampleTest.key("q"))
    ExampleTest.assert_quit(cmd)
  end

  it "quits on ctrl+c" do
    m = TabsModel.new
    m, cmd = m.update(ExampleTest.key("ctrl+c"))
    ExampleTest.assert_quit(cmd)
  end

  it "view shows tab names" do
    m = TabsModel.new
    TABS.each do |tab|
      ExampleTest.assert_view_contains(m, tab)
    end
  end

  it "view shows active tab content" do
    m = TabsModel.new
    ExampleTest.assert_view_contains(m, TAB_CONTENT[0])
    m, _ = m.update(ExampleTest.key("right"))
    ExampleTest.assert_view_contains(m, TAB_CONTENT[1])
  end
end
