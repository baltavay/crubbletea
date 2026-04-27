struct Crubbletea::Position
  getter x : Int32
  getter y : Int32

  def initialize(@x : Int32 = 0, @y : Int32 = 0)
  end
end

enum Crubbletea::CursorShape
  Block
  Underline
  Bar
end

struct Crubbletea::Cursor
  getter position : Position
  getter shape : CursorShape
  getter blink : Bool

  def initialize(
    @position : Position = Position.new,
    @shape : CursorShape = :block,
    @blink : Bool = true
  )
  end

  def self.new(x : Int32, y : Int32) : Cursor
    new(Position.new(x, y))
  end
end
