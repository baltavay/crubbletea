require "../../src/crubbletea"

SPINNERS = [
  Crubbletea::Bubbles::Spinner::LINE,
  Crubbletea::Bubbles::Spinner::DOT,
  Crubbletea::Bubbles::Spinner::MINI_DOT,
  Crubbletea::Bubbles::Spinner::JUMP,
  Crubbletea::Bubbles::Spinner::PULSE,
  Crubbletea::Bubbles::Spinner::POINTS,
  Crubbletea::Bubbles::Spinner::GLOBE,
  Crubbletea::Bubbles::Spinner::MOON,
  Crubbletea::Bubbles::Spinner::MONKEY,
]

class SpinnersModel
  include Crubbletea::Model

  getter index : Int32
  getter spinner : Crubbletea::Bubbles::Spinner::Model

  def initialize
    @index = 0
    @spinner = Crubbletea::Bubbles::Spinner::Model.new(
      spinner: SPINNERS[0],
      style: Crubbletea::Lipgloss::Style.new.foreground("#5F87FF")
    )
  end

  def init : Crubbletea::Cmd?
    @spinner.tick
  end

  def update(msg) : {SpinnersModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c", "q", "escape"
        return {self, Crubbletea.quit}
      when "h", "left"
        @index = (@index - 1) % SPINNERS.size
        reset_spinner
        return {self, @spinner.tick}
      when "l", "right"
        @index = (@index + 1) % SPINNERS.size
        reset_spinner
        return {self, @spinner.tick}
      end
    when Crubbletea::Bubbles::Spinner::TickMsg
      @spinner, cmd = @spinner.update(msg)
      return {self, cmd}
    end
    {self, nil}
  end

  def view : Crubbletea::View
    gap = @index == 1 ? "" : " "
    text_style = Crubbletea::Lipgloss::Style.new.foreground("#D0D0D0")
    help_style = Crubbletea::Lipgloss::Style.new.foreground("#606060")

    s = "\n #{@spinner.view}#{gap}#{text_style.render("Spinning...")}\n\n"
    s += help_style.render("h/l, ←/→: change spinner • q: exit\n")
    Crubbletea.new_view(s)
  end

  private def reset_spinner
    @spinner = Crubbletea::Bubbles::Spinner::Model.new(
      spinner: SPINNERS[@index],
      style: Crubbletea::Lipgloss::Style.new.foreground("#5F87FF")
    )
  end
end

program = Crubbletea::Program(SpinnersModel).new(SpinnersModel.new)
program.run
