require "../../src/crubbletea"

class PrintKeyModel
  include Crubbletea::Model

  getter last_key : String

  def initialize
    @last_key = ""
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {PrintKeyModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c"
        return {self, Crubbletea.quit}
      end
      key = msg.key
      @last_key = key.to_s
      if key.text.empty?
        @last_key = "You pressed: #{key.to_s}"
      else
        @last_key = "You pressed: #{key.to_s} (text: #{key.text.inspect})"
      end
    end
    {self, nil}
  end

  def view : Crubbletea::View
    s = "Press any key to see its details. Press 'ctrl+c' to quit.\n"
    s += "\n#{@last_key}\n" unless @last_key.empty?
    Crubbletea.new_view(s)
  end
end

program = Crubbletea::Program(PrintKeyModel).new(PrintKeyModel.new)
program.run
