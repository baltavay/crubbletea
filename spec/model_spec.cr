require "./spec_helper"

class TestModel
  include Crubbletea::Model

  getter count : Int32

  def initialize(@count : Int32 = 0)
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg)
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "up"
        {TestModel.new(@count + 1), nil}
      when "down"
        {TestModel.new(@count - 1), nil}
      when "q"
        {self, Crubbletea.quit}
      else
        {self, nil}
      end
    else
      {self, nil}
    end
  end

  def view : Crubbletea::View
    Crubbletea.new_view("count: #{@count}")
  end
end

describe Crubbletea::Model do
  it "implements init/update/view" do
    model = TestModel.new
    view = model.view
    view.content.should eq("count: 0")
  end

  it "handles key messages" do
    model = TestModel.new

    up_key = Crubbletea::KeyPressMsg.new(Crubbletea::Key.new(text: "up"))
    model, _ = model.update(up_key)
    model.count.should eq(1)

    down_key = Crubbletea::KeyPressMsg.new(Crubbletea::Key.new(text: "down"))
    model, _ = model.update(down_key)
    model.count.should eq(0)
  end

  it "returns quit command" do
    model = TestModel.new
    q_key = Crubbletea::KeyPressMsg.new(Crubbletea::Key.new(text: "q"))
    _, cmd = model.update(q_key)
    cmd.should_not be_nil
    msg = cmd.not_nil!.call
    msg.should be_a(Crubbletea::QuitMsg)
  end

  it "returns nil init command" do
    model = TestModel.new
    model.init.should be_nil
  end
end
