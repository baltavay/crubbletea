require "../lipgloss"
require "../harmonica"

struct Crubbletea::Bubbles::Progress::FrameMsg
  include Crubbletea::Msg
  getter id : Int32
  getter tag : Int32

  def initialize(@id : Int32, @tag : Int32)
  end
end

class Crubbletea::Bubbles::Progress::Model
  DEFAULT_FULL_CHAR  = '▌'
  DEFAULT_EMPTY_CHAR = '░'
  FPS                = 60
  DEFAULT_WIDTH      = 40
  DEFAULT_FREQUENCY  = 18.0
  DEFAULT_DAMPING    = 1.0

  getter full : Char
  getter full_color : Lipgloss::Color
  getter empty : Char
  getter empty_color : Lipgloss::Color
  getter show_percentage : Bool
  getter percent_format : String
  getter percentage_style : Lipgloss::Style
  getter width : Int32
  getter id : Int32

  @@last_id = 0

  @spring : Harmonica::Spring
  @spring_customized : Bool
  @percent_shown : Float64
  @target_percent : Float64
  @velocity : Float64
  @tag : Int32

  def initialize(
    @full : Char = DEFAULT_FULL_CHAR,
    @full_color : Lipgloss::Color = "#7571F9",
    @empty : Char = DEFAULT_EMPTY_CHAR,
    @empty_color : Lipgloss::Color = "#606060",
    @show_percentage : Bool = true,
    @percent_format : String = " %3.0f%%",
    @percentage_style : Lipgloss::Style = Lipgloss::Style.new,
    @width : Int32 = DEFAULT_WIDTH
  )
    @@last_id += 1
    @id = @@last_id
    @spring = Harmonica::Spring.new(Harmonica.fps(FPS), DEFAULT_FREQUENCY, DEFAULT_DAMPING)
    @spring_customized = false
    @percent_shown = 0.0
    @target_percent = 0.0
    @velocity = 0.0
    @tag = 0
  end

  def set_spring_options(frequency : Float64, damping : Float64) : Nil
    @spring = Harmonica::Spring.new(Harmonica.fps(FPS), frequency, damping)
  end

  def percent : Float64
    @target_percent
  end

  def set_percent(p : Float64) : Crubbletea::Cmd
    @target_percent = {0.0, {p, 1.0}.min}.max
    @tag += 1
    next_frame_cmd
  end

  def incr_percent(v : Float64) : Crubbletea::Cmd
    set_percent(percent + v)
  end

  def decr_percent(v : Float64) : Crubbletea::Cmd
    set_percent(percent - v)
  end

  def update(msg : Crubbletea::Msg) : {Model, Crubbletea::Cmd}
    case msg
    when FrameMsg
      if msg.id != @id || msg.tag != @tag
        return {self, nil}
      end
      unless animating?
        return {self, nil}
      end
      @percent_shown, @velocity = @spring.update(@percent_shown, @velocity, @target_percent)
      {self, next_frame_cmd}
    else
      {self, nil}
    end
  end

  def view : String
    view_as(@percent_shown)
  end

  def view_as(pct : Float64) : String
    pct_view = percentage_view(pct)
    bar = bar_view(pct, Lipgloss::ANSI.string_width(pct_view))
    bar + pct_view
  end

  def animating? : Bool
    dist = (@percent_shown - @target_percent).abs
    !(dist < 0.001 && @velocity < 0.01)
  end

  private def next_frame_cmd : Crubbletea::Cmd
    ->{ FrameMsg.new(@id, @tag).as(Crubbletea::Msg) }
  end

  private def bar_view(percent : Float64, text_width : Int32) : String
    tw = {@width - text_width, 0}.max
    fw = {(tw.to_f64 * percent).round.to_i, tw}.min
    fw = {fw, 0}.max

    buf = String::Builder.new
    fw.times { buf << Lipgloss::Style.new.foreground(@full_color).render(@full.to_s) }
    (tw - fw).times { buf << Lipgloss::Style.new.foreground(@empty_color).render(@empty.to_s) }
    buf.to_s
  end

  private def percentage_view(percent : Float64) : String
    return "" unless @show_percentage
    pct = {0.0, {percent, 1.0}.min}.max
    text = @percent_format % (pct * 100)
    @percentage_style.inline(true).render(text)
  end
end
