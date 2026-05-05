require "../../src/crubbletea"

class ExecModel
  include Crubbletea::Model

  getter alt_screen : Bool
  getter err : String?

  def initialize
    @alt_screen = false
    @err = nil
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {ExecModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c", "q"
        return {self, Crubbletea.quit}
      when "e"
        editor = ENV["EDITOR"]? || "vi"
        return {self, Crubbletea.exec_process(editor)}
      when "a"
        @alt_screen = !@alt_screen
        return {self, nil}
      end
    when Crubbletea::ExecFinishedMsg
      if err = msg.err
        @err = err.message
      end
    end
    {self, nil}
  end

  def view : Crubbletea::View
    v = Crubbletea.new_view(
      "\n  Exec Process Example\n\n" \
      "  Press 'e' to open your $EDITOR\n" \
      "  Press 'a' to toggle alt screen\n" \
      "  Press 'q' to quit\n" \
      "#{"\n  Error: #{@err}" if @err}"
    )
    v.alt_screen = @alt_screen
    v
  end
end

program = Crubbletea::Program(ExecModel).new(ExecModel.new)
program.run
