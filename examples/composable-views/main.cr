require "../../src/crubbletea"

enum ViewState
  TimerView
  SpinnerView
end

class ComposableViewsModel
  include Crubbletea::Model

  getter state : ViewState
  getter timer : Crubbletea::Bubbles::Timer::Model
  getter spinner : Crubbletea::Bubbles::Spinner::Model
  getter spinner_index : Int32

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

  def initialize
    @state = ViewState::TimerView
    @timer = Crubbletea::Bubbles::Timer::Model.new(timeout: 1.minute, interval: 10.milliseconds)
    @spinner = Crubbletea::Bubbles::Spinner::Model.new(
      style: Crubbletea::Lipgloss::Style.new.foreground("#5F87FF")
    )
    @spinner_index = 0
  end

  def init : Crubbletea::Cmd?
    Crubbletea.batch([@timer.init, @spinner.tick].compact)
  end

  def update(msg) : {ComposableViewsModel, Crubbletea::Cmd?}
    cmds = [] of Crubbletea::Cmd
    cmd : Crubbletea::Cmd = nil

    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c", "q"
        return {self, Crubbletea.quit}
      when "tab"
        @state = @state.timer_view? ? ViewState::SpinnerView : ViewState::TimerView
      when "n"
        if @state.timer_view?
          @timer = Crubbletea::Bubbles::Timer::Model.new(timeout: 1.minute, interval: 10.milliseconds)
          cmds << @timer.init
        else
          @spinner_index = (@spinner_index + 1) % SPINNERS.size
          @spinner = Crubbletea::Bubbles::Spinner::Model.new(
            spinner: SPINNERS[@spinner_index],
            style: Crubbletea::Lipgloss::Style.new.foreground("#5F87FF")
          )
          cmds << @spinner.tick
        end
      end
      case @state
      when ViewState::SpinnerView
        @spinner, cmd = @spinner.update(msg)
        cmds << cmd
      else
        @timer, cmd = @timer.update(msg)
        cmds << cmd
      end
    when Crubbletea::Bubbles::Spinner::TickMsg
      @spinner, cmd = @spinner.update(msg)
      cmds << cmd
    when Crubbletea::Bubbles::Timer::TickMsg
      @timer, cmd = @timer.update(msg)
      cmds << cmd
    when Crubbletea::Bubbles::Timer::TimeoutMsg
      return {self, Crubbletea.quit}
    when Crubbletea::Bubbles::Timer::StartStopMsg
      @timer, cmd = @timer.update(msg)
      cmds << cmd
    end

    {self, Crubbletea.batch(cmds.compact)}
  end

  def view : Crubbletea::View
    focused_style = Crubbletea::Lipgloss::Style.new
      .width(15)
      .height(5)
      .align_horizontal(Crubbletea::Lipgloss::Style::Pos::Center)
      .align_vertical(Crubbletea::Lipgloss::Style::Pos::Center)
      .border(Crubbletea::Lipgloss::Border.normal)
      .border_foreground("#5F87FF")
    model_style = Crubbletea::Lipgloss::Style.new
      .width(15)
      .height(5)
      .align_horizontal(Crubbletea::Lipgloss::Style::Pos::Center)
      .align_vertical(Crubbletea::Lipgloss::Style::Pos::Center)
      .border(Crubbletea::Lipgloss::Border.hidden)
    help_style = Crubbletea::Lipgloss::Style.new.foreground("241")

    timer_view = "%4s" % @timer.view
    spinner_view = @spinner.view

    if @state.timer_view?
      top = Crubbletea::Lipgloss.join_horizontal(
        Crubbletea::Lipgloss::Style::Pos::Top,
        [focused_style.render(timer_view), model_style.render(spinner_view)]
      )
    else
      top = Crubbletea::Lipgloss.join_horizontal(
        Crubbletea::Lipgloss::Style::Pos::Top,
        [model_style.render(timer_view), focused_style.render(spinner_view)]
      )
    end

    model_name = @state.timer_view? ? "timer" : "spinner"
    s = top + "\n" + help_style.render("tab: focus next • n: new #{model_name} • q: exit\n")
    Crubbletea.new_view(s)
  end
end

program = Crubbletea::Program(ComposableViewsModel).new(ComposableViewsModel.new)
program.run
