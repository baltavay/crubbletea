struct Crubbletea::Key
  enum Code
    Unknown
    Up
    Down
    Left
    Right
    Enter
    Backspace
    Tab
    Escape
    Space
    Home
    End
    Insert
    Delete
    PgUp
    PgDown
    F1
    F2
    F3
    F4
    F5
    F6
    F7
    F8
    F9
    F10
    F11
    F12
  end

  getter text : String
  getter code : Code
  getter ctrl : Bool
  getter alt : Bool
  getter shift : Bool

  def initialize(
    @text = "",
    @code = Code::Unknown,
    @ctrl = false,
    @alt = false,
    @shift = false
  )
  end

  def to_s : String
    parts = [] of String
    parts << "ctrl" if ctrl
    parts << "alt" if alt
    parts << "shift" if shift
    key_str = code.unknown? ? text : code_name
    parts << key_str
    parts.join("+")
  end

  private def code_name : String
    case code
    in Code::Unknown    then text
    in Code::Up         then "up"
    in Code::Down       then "down"
    in Code::Left       then "left"
    in Code::Right      then "right"
    in Code::Enter      then "enter"
    in Code::Backspace  then "backspace"
    in Code::Tab        then "tab"
    in Code::Escape     then "escape"
    in Code::Space      then "space"
    in Code::Home       then "home"
    in Code::End        then "end"
    in Code::Insert     then "insert"
    in Code::Delete     then "delete"
    in Code::PgUp       then "pgup"
    in Code::PgDown     then "pgdown"
    in Code::F1         then "f1"
    in Code::F2         then "f2"
    in Code::F3         then "f3"
    in Code::F4         then "f4"
    in Code::F5         then "f5"
    in Code::F6         then "f6"
    in Code::F7         then "f7"
    in Code::F8         then "f8"
    in Code::F9         then "f9"
    in Code::F10        then "f10"
    in Code::F11        then "f11"
    in Code::F12        then "f12"
    end
  end
end

struct Crubbletea::KeyPressMsg
  include Crubbletea::Msg
  getter key : Key

  def initialize(@key : Key)
  end

  def to_s : String
    @key.to_s
  end
end

struct Crubbletea::KeyReleaseMsg
  include Crubbletea::Msg
  getter key : Key

  def initialize(@key : Key)
  end

  def to_s : String
    @key.to_s
  end
end
