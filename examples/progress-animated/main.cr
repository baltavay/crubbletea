require "../../src/crubbletea"

ANIMATED_PADDING  = 2
ANIMATED_MAX_WIDTH = 80

struct TickMsg
  include Crubbletea::Msg
  getter time : Time

  def initialize(@time : Time = Time.utc)
  end
end

class ProgressAnimatedModel
  include Crubbletea::Model

  getter progress : Crubbletea::Bubbles::Progress::Model

  def initialize
    @progress = Crubbletea::Bubbles::Progress::Model.new
  end

  def init : Crubbletea::Cmd?
    Crubbletea.tick(1.second) { |t| TickMsg.new(t).as(Crubbletea::Msg) }
  end

  def update(msg) : {ProgressAnimatedModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      return {self, Crubbletea.quit}
    when Crubbletea::WindowSizeMsg
      @progress.width = msg.width - ANIMATED_PADDING * 2 - 4
      @progress.width = {@progress.width, ANIMATED_MAX_WIDTH}.min
      return {self, nil}
    when TickMsg
      if @progress.percent >= 1.0
        return {self, Crubbletea.quit}
      end
      cmd = @progress.incr_percent(0.25)
      return {self, Crubbletea.batch([Crubbletea.tick(1.second) { |t| TickMsg.new(t).as(Crubbletea::Msg) }, cmd].compact)}
    when Crubbletea::Bubbles::Progress::FrameMsg
      @progress, cmd = @progress.update(msg)
      return {self, cmd}
    end
    {self, nil}
  end

  def view : Crubbletea::View
    pad = " " * ANIMATED_PADDING
    help_style = Crubbletea::Lipgloss::Style.new.foreground("#626262")
    Crubbletea.new_view("\n#{pad}#{@progress.view}\n\n#{pad}#{help_style.render("Press any key to quit")}")
  end
end

program = Crubbletea::Program(ProgressAnimatedModel).new(ProgressAnimatedModel.new)
program.run
