require "../../src/crubbletea"

struct PrintMsg
  include Crubbletea::Msg
  getter text : String

  def initialize(@text : String)
  end
end

class SequenceModel
  include Crubbletea::Model

  getter output : Array(String)

  def initialize
    @output = [] of String
  end

  def init : Crubbletea::Cmd?
    Crubbletea.sequence([
      Crubbletea.batch([
        Crubbletea.sequence([
          sleep_print("1-1-1", 1000),
          sleep_print("1-1-2", 1000),
        ]),
        Crubbletea.batch([
          sleep_print("1-2-1", 1500),
          sleep_print("1-2-2", 1250),
        ]),
      ]),
      ->{ PrintMsg.new("2").as(Crubbletea::Msg) },
      Crubbletea.sequence([
        Crubbletea.batch([
          sleep_print("3-1-1", 500),
          sleep_print("3-1-2", 1000),
        ]),
        Crubbletea.sequence([
          sleep_print("3-2-1", 750),
          sleep_print("3-2-2", 500),
        ]),
      ]),
      Crubbletea.quit,
    ])
  end

  def update(msg) : {SequenceModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      return {self, Crubbletea.quit}
    when PrintMsg
      @output << msg.text
    end
    {self, nil}
  end

  def view : Crubbletea::View
    Crubbletea.new_view(@output.join("\n"))
  end

  private def sleep_print(s : String, ms : Int32) : Crubbletea::Cmd
    ->{
      sleep ms.milliseconds
      PrintMsg.new(s).as(Crubbletea::Msg)
    }
  end
end

program = Crubbletea::Program(SequenceModel).new(SequenceModel.new)
program.run
