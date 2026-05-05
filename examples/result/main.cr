require "../../src/crubbletea"

CHOICES = ["Taro", "Coffee", "Lychee"]

class ResultModel
  include Crubbletea::Model

  getter cursor : Int32
  getter choice : String?

  def initialize
    @cursor = 0
    @choice = nil
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {ResultModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c", "q", "escape"
        return {self, Crubbletea.quit}
      when "enter"
        @choice = CHOICES[@cursor]
        return {self, Crubbletea.quit}
      when "down", "j"
        @cursor = (@cursor + 1) % CHOICES.size
      when "up", "k"
        @cursor = (@cursor - 1) % CHOICES.size
      end
    end
    {self, nil}
  end

  def view : Crubbletea::View
    s = "What kind of Bubble Tea would you like to order?\n\n"

    CHOICES.each_with_index do |choice, i|
      if @cursor == i
        s += "(•) #{choice}\n"
      else
        s += "( ) #{choice}\n"
      end
    end
    s += "\n(press q to quit)\n"

    Crubbletea.new_view(s)
  end
end

m = ResultModel.new
program = Crubbletea::Program(ResultModel).new(m)
program.run

if c = m.choice
  puts "\n---\nYou chose #{c}!"
end
