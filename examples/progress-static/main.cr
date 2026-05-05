require "../../src/crubbletea"

STATIC_PADDING  = 2
STATIC_MAX_WIDTH = 80

struct TickMsg
  include Crubbletea::Msg
  getter time : Time

  def initialize(@time : Time = Time.utc)
  end
end

class ProgressStaticModel
  include Crubbletea::Model

  getter percent : Float64
  getter progress : Crubbletea::Bubbles::Progress::Model

  def initialize
    @percent = 0.0
    @progress = Crubbletea::Bubbles::Progress::Model.new(
      full_color: "#FF7CCB",
      empty_color: "#FDFF8C"
    )
  end

  def init : Crubbletea::Cmd?
    Crubbletea.tick(1.second) { |t| TickMsg.new(t).as(Crubbletea::Msg) }
  end

  def update(msg) : {ProgressStaticModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      return {self, Crubbletea.quit}
    when Crubbletea::WindowSizeMsg
      w = {msg.width - STATIC_PADDING * 2 - 4, STATIC_MAX_WIDTH}.min
      @progress.width = w
      return {self, nil}
    when TickMsg
      @percent += 0.25
      if @percent > 1.0
        @percent = 1.0
        return {self, Crubbletea.quit}
      end
      return {self, Crubbletea.tick(1.second) { |t| TickMsg.new(t).as(Crubbletea::Msg) }}
    end
    {self, nil}
  end

  def view : Crubbletea::View
    pad = " " * STATIC_PADDING
    help_style = Crubbletea::Lipgloss::Style.new.foreground("#626262")
    Crubbletea.new_view("\n#{pad}#{@progress.view_as(@percent)}\n\n#{pad}#{help_style.render("Press any key to quit")}")
  end
end

program = Crubbletea::Program(ProgressStaticModel).new(ProgressStaticModel.new)
program.run
