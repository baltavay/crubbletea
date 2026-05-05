require "../../src/crubbletea"

class CursorStyleModel
  include Crubbletea::Model

  getter shape : Crubbletea::CursorShape
  getter blink : Bool

  def initialize(@shape : Crubbletea::CursorShape = :block, @blink : Bool = true)
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {CursorStyleModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c", "q"
        return {self, Crubbletea.quit}
      when "h", "left"
        shapes = Crubbletea::CursorShape.values
        idx = shapes.index(@shape) || 0
        @shape = shapes[(idx - 1) % shapes.size]
      when "l", "right"
        shapes = Crubbletea::CursorShape.values
        idx = shapes.index(@shape) || 0
        @shape = shapes[(idx + 1) % shapes.size]
      end
    end
    @blink = !@blink
    {self, nil}
  end

  def describe_cursor : String
    adj = @blink ? "blinking" : "steady"
    noun = case @shape
           when .block?      then "block"
           when .underline?  then "underline"
           when .bar?        then "bar"
           else                   "unknown"
           end
    "#{adj} #{noun}"
  end

  def view : Crubbletea::View
    v = Crubbletea.new_view(
      "Press left/right to change the cursor style, q or ctrl+c to quit." +
      "\n\n" +
      "  <- This is the cursor (a #{describe_cursor})"
    )
    v.cursor = Crubbletea::Cursor.new(
      Crubbletea::Position.new(0, 2),
      @shape,
      @blink
    )
    v
  end
end

program = Crubbletea::Program(CursorStyleModel).new(CursorStyleModel.new(blink: true))
program.run
