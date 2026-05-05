require "../../src/crubbletea"

struct ExitMsg
  include Crubbletea::Msg
  getter tag : Int32

  def initialize(@tag : Int32)
  end
end

DEBOUNCE = 1.second

class DebounceModel
  include Crubbletea::Model

  getter tag : Int32

  def initialize
    @tag = 0
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {DebounceModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      @tag += 1
      current_tag = @tag
      return {self, Crubbletea.tick(DEBOUNCE) { ExitMsg.new(current_tag) }}
    when ExitMsg
      if msg.tag == @tag
        return {self, Crubbletea.quit}
      end
    end
    {self, nil}
  end

  def view : Crubbletea::View
    Crubbletea.new_view("Key presses: #{@tag}\nTo exit press any key, then wait for one second without pressing anything.")
  end
end

program = Crubbletea::Program(DebounceModel).new(DebounceModel.new)
program.run
