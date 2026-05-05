require "./example_helper"
require "../../examples/result/main"

describe "result example" do
  it "starts with cursor at 0" do
    m = ResultModel.new
    m.cursor.should eq(0)
    m.choice.should be_nil
  end

  it "moves cursor down on down" do
    m = ResultModel.new
    m, _ = m.update(ExampleTest.key("down"))
    m.cursor.should eq(1)
  end

  it "moves cursor down on j" do
    m = ResultModel.new
    m, _ = m.update(ExampleTest.key("j"))
    m.cursor.should eq(1)
  end

  it "moves cursor up on up" do
    m = ResultModel.new
    m, _ = m.update(ExampleTest.key("down"))
    m, _ = m.update(ExampleTest.key("up"))
    m.cursor.should eq(0)
  end

  it "moves cursor up on k" do
    m = ResultModel.new
    m, _ = m.update(ExampleTest.key("j"))
    m, _ = m.update(ExampleTest.key("k"))
    m.cursor.should eq(0)
  end

  it "wraps down past last choice" do
    m = ResultModel.new
    3.times { m, _ = m.update(ExampleTest.key("down")) }
    m.cursor.should eq(0)
  end

  it "wraps up past first choice" do
    m = ResultModel.new
    m, _ = m.update(ExampleTest.key("up"))
    m.cursor.should eq(2)
  end

  it "selects on enter and quits" do
    m = ResultModel.new
    m, cmd = m.update(ExampleTest.key("enter"))
    m.choice.should eq("Taro")
    ExampleTest.assert_quit(cmd)
  end

  it "selects second choice" do
    m = ResultModel.new
    m, _ = m.update(ExampleTest.key("down"))
    m, cmd = m.update(ExampleTest.key("enter"))
    m.choice.should eq("Coffee")
    ExampleTest.assert_quit(cmd)
  end

  it "selects last choice after wrapping" do
    m = ResultModel.new
    m, _ = m.update(ExampleTest.key("up"))
    m, cmd = m.update(ExampleTest.key("enter"))
    m.choice.should eq("Lychee")
    ExampleTest.assert_quit(cmd)
  end

  it "quits on q without choice" do
    m = ResultModel.new
    m, cmd = m.update(ExampleTest.key("q"))
    m.choice.should be_nil
    ExampleTest.assert_quit(cmd)
  end

  it "quits on escape without choice" do
    m = ResultModel.new
    m, cmd = m.update(ExampleTest.key("escape"))
    m.choice.should be_nil
    ExampleTest.assert_quit(cmd)
  end

  it "quits on ctrl+c without choice" do
    m = ResultModel.new
    m, cmd = m.update(ExampleTest.key("ctrl+c"))
    m.choice.should be_nil
    ExampleTest.assert_quit(cmd)
  end

  it "view shows all choices" do
    m = ResultModel.new
    ExampleTest.assert_view_contains(m, "Taro")
    ExampleTest.assert_view_contains(m, "Coffee")
    ExampleTest.assert_view_contains(m, "Lychee")
  end

  it "view marks selected with bullet" do
    m = ResultModel.new
    content = ExampleTest.view_text(m)
    content.should contain("(•) Taro")
    content.should contain("( ) Coffee")
    content.should contain("( ) Lychee")
  end

  it "view bullet follows cursor" do
    m = ResultModel.new
    m, _ = m.update(ExampleTest.key("down"))
    content = ExampleTest.view_text(m)
    content.should contain("( ) Taro")
    content.should contain("(•) Coffee")
    content.should contain("( ) Lychee")
  end
end
