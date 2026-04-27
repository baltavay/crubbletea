enum Crubbletea::MouseButton
  None
  Left
  Middle
  Right
  WheelUp
  WheelDown
  WheelLeft
  WheelRight
  Backward
  Forward
end

enum Crubbletea::MouseMode
  None
  CellMotion
  AllMotion
end

struct Crubbletea::Mouse
  getter x : Int32
  getter y : Int32
  getter button : MouseButton
  getter ctrl : Bool
  getter alt : Bool
  getter shift : Bool

  def initialize(
    @x = 0,
    @y = 0,
    @button = MouseButton::None,
    @ctrl = false,
    @alt = false,
    @shift = false
  )
  end

  def to_s : String
    mods = [] of String
    mods << "ctrl" if ctrl
    mods << "alt" if alt
    mods << "shift" if shift
    parts = mods
    parts << button.to_s.downcase
    parts << "(#{x},#{y})"
    parts.join("+")
  end
end

struct Crubbletea::MouseClickMsg
  include Crubbletea::Msg
  getter mouse : Mouse

  def initialize(@mouse : Mouse)
  end

  def to_s : String
    "click: #{@mouse}"
  end
end

struct Crubbletea::MouseReleaseMsg
  include Crubbletea::Msg
  getter mouse : Mouse

  def initialize(@mouse : Mouse)
  end

  def to_s : String
    "release: #{@mouse}"
  end
end

struct Crubbletea::MouseWheelMsg
  include Crubbletea::Msg
  getter mouse : Mouse

  def initialize(@mouse : Mouse)
  end

  def to_s : String
    "wheel: #{@mouse}"
  end
end

struct Crubbletea::MouseMotionMsg
  include Crubbletea::Msg
  getter mouse : Mouse

  def initialize(@mouse : Mouse)
  end

  def to_s : String
    "motion: #{@mouse}"
  end
end
