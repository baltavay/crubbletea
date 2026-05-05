require "../../src/crubbletea"

PROGRESS_WIDTH = 71

struct TickMsg
  include Crubbletea::Msg
  getter time : Time

  def initialize(@time : Time = Time.utc)
  end
end

struct FrameMsg
  include Crubbletea::Msg
end

RAMP = begin
  ca_r, ca_g, ca_b = 0xB1, 0x4F, 0xFF
  cb_r, cb_g, cb_b = 0x00, 0xFF, 0xA3
  (0...PROGRESS_WIDTH).map do |i|
    t = i.to_f / PROGRESS_WIDTH
    r = ((ca_r * (1 - t) + cb_r * t).round.to_i)
    g = ((ca_g * (1 - t) + cb_g * t).round.to_i)
    b = ((ca_b * (1 - t) + cb_b * t).round.to_i)
    Crubbletea::Lipgloss::Style.new.foreground("#%02X%02X%02X" % [r, g, b])
  end
end

class ViewsModel
  include Crubbletea::Model

  getter choice : Int32
  getter chosen : Bool
  getter ticks : Int32
  getter frames : Int32
  getter progress : Float64
  getter loaded : Bool
  getter quitting : Bool

  def initialize
    @choice = 0
    @chosen = false
    @ticks = 10
    @frames = 0
    @progress = 0.0
    @loaded = false
    @quitting = false
  end

  def init : Crubbletea::Cmd?
    Crubbletea.tick(1.second) { |t| TickMsg.new(t).as(Crubbletea::Msg) }
  end

  def update(msg) : {ViewsModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "q", "escape", "ctrl+c"
        @quitting = true
        return {self, Crubbletea.quit}
      end
    end

    if @quitting
      return {self, nil}
    end

    unless @chosen
      return update_choices(msg)
    end
    update_chosen(msg)
  end

  def view : Crubbletea::View
    main_style = Crubbletea::Lipgloss::Style.new.margin(0, 0, 0, 2)

    if @quitting
      return Crubbletea.new_view("\n  See you later!\n\n")
    end

    unless @chosen
      s = choices_view
    else
      s = chosen_view
    end
    Crubbletea.new_view(main_style.render("\n" + s + "\n"))
  end

  private def update_choices(msg) : {ViewsModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "j", "down"
        @choice = {@choice + 1, 3}.min
      when "k", "up"
        @choice = {@choice - 1, 0}.max
      when "enter"
        @chosen = true
        return {self, Crubbletea.tick((1000 / 60).milliseconds) { |t| FrameMsg.new.as(Crubbletea::Msg) }}
      end
    when TickMsg
      if @ticks == 0
        @quitting = true
        return {self, Crubbletea.quit}
      end
      @ticks -= 1
      return {self, Crubbletea.tick(1.second) { |t| TickMsg.new(t).as(Crubbletea::Msg) }}
    end
    {self, nil}
  end

  private def bounce_out(t : Float64) : Float64
    return 1.0 if t >= 1.0
    t = t * 1.0
    if t < (1.0 / 2.75)
      7.5625 * t * t
    elsif t < (2.0 / 2.75)
      t -= (1.5 / 2.75)
      7.5625 * t * t + 0.75
    elsif t < (2.5 / 2.75)
      t -= (2.25 / 2.75)
      7.5625 * t * t + 0.9375
    else
      t -= (2.625 / 2.75)
      7.5625 * t * t + 0.984375
    end
  end

  private def update_chosen(msg) : {ViewsModel, Crubbletea::Cmd?}
    case msg
    when FrameMsg
      unless @loaded
        @frames += 1
        @progress = bounce_out(@frames.to_f / 100.0)
        if @progress >= 1.0
          @progress = 1.0
          @loaded = true
          @ticks = 3
          return {self, Crubbletea.tick(1.second) { |t| TickMsg.new(t).as(Crubbletea::Msg) }}
        end
        return {self, Crubbletea.tick((1000 / 60).milliseconds) { |t| FrameMsg.new.as(Crubbletea::Msg) }}
      end
    when TickMsg
      if @loaded
        if @ticks == 0
          @quitting = true
          return {self, Crubbletea.quit}
        end
        @ticks -= 1
        return {self, Crubbletea.tick(1.second) { |t| TickMsg.new(t).as(Crubbletea::Msg) }}
      end
    end
    {self, nil}
  end

  private def choices_view : String
    subtle = Crubbletea::Lipgloss::Style.new.foreground("241")
    ticks_style = Crubbletea::Lipgloss::Style.new.foreground("79")
    checkbox_style = Crubbletea::Lipgloss::Style.new.foreground("212")
    dot_style = Crubbletea::Lipgloss::Style.new.foreground("236").render(" • ")

    options = ["Plant carrots", "Go to the market", "Read something", "See friends"]

    choices = options.each_with_index.map do |opt, i|
      if @choice == i
        checkbox_style.render("[x] #{opt}")
      else
        "[ ] #{opt}"
      end
    end.join("\n")

    "What to do today?\n\n#{choices}\n\nProgram quits in #{ticks_style.render(@ticks.to_s)} seconds\n\n" +
      subtle.render("j/k, up/down: select") + dot_style +
      subtle.render("enter: choose") + dot_style +
      subtle.render("q, esc: quit")
  end

  private def chosen_view : String
    keyword = Crubbletea::Lipgloss::Style.new.foreground("211")
    ticks_style = Crubbletea::Lipgloss::Style.new.foreground("79")
    empty_style = Crubbletea::Lipgloss::Style.new.foreground("241")

    msg = case @choice
          when 0
            "Carrot planting?\n\nCool, we'll need #{keyword.render("libgarden")} and #{keyword.render("vegeutils")}..."
          when 1
            "A trip to the market?\n\nOkay, then we should install #{keyword.render("marketkit")} and #{keyword.render("libshopping")}..."
          when 2
            "Reading time?\n\nOkay, cool, then we'll need a library. Yes, an #{keyword.render("actual library")}."
          else
            "It's always good to see friends.\n\nFetching #{keyword.render("social-skills")} and #{keyword.render("conversationutils")}..."
          end

    label = if @loaded
              "Downloaded. Exiting in #{ticks_style.render(@ticks.to_s)} seconds..."
            else
              "Downloading..."
            end

    bar_full = (@progress * PROGRESS_WIDTH).round.to_i
    bar_full = {bar_full, PROGRESS_WIDTH}.min
    full_cells = (0...bar_full).map { |i| RAMP[i].render("█") }.join
    empty_cells = empty_style.render("░" * (PROGRESS_WIDTH - bar_full))
    pct = " %3.0f" % (@progress * 100)

    "#{msg}\n\n#{label}\n#{full_cells}#{empty_cells}#{pct}"
  end
end

program = Crubbletea::Program(ViewsModel).new(ViewsModel.new)
program.run
