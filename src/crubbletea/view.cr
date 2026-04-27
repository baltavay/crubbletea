struct Crubbletea::View
  property content : String
  property alt_screen : Bool
  property cursor : Cursor?
  property window_title : String
  property mouse_mode : MouseMode
  property report_focus : Bool

  def initialize(
    @content = "",
    @alt_screen = false,
    @cursor = nil,
    @window_title = "",
    @mouse_mode : MouseMode = :none,
    @report_focus = false
  )
  end
end
