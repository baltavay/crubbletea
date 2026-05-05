struct Crubbletea::View
  property content : String
  property alt_screen : Bool
  property cursor : Cursor?
  property window_title : String
  property mouse_mode : MouseMode
  property report_focus : Bool
  property progress_bar : ProgressBar?
  property foreground_color : String
  property background_color : String
  property keyboard_enhancements : KeyboardEnhancements?

  def initialize(
    @content = "",
    @alt_screen = false,
    @cursor = nil,
    @window_title = "",
    @mouse_mode : MouseMode = :none,
    @report_focus = false,
    @progress_bar : ProgressBar? = nil,
    @foreground_color = "",
    @background_color = "",
    @keyboard_enhancements : KeyboardEnhancements? = nil
  )
  end
end

struct Crubbletea::ProgressBar
  getter state : Int32
  getter value : Int32

  def initialize(@state : Int32 = 0, @value : Int32 = 0)
  end
end

struct Crubbletea::KeyboardEnhancements
  getter report_event_types : Bool

  def initialize(@report_event_types : Bool = false)
  end
end
