require "math"

class Crubbletea::Ntcharts::Heatmap
  getter canvas : Canvas
  getter color_scale : Array(Lipgloss::Color)

  @min_value : Float64
  @max_value : Float64
  @points : Array(HeatPoint)

  struct HeatPoint
    getter x : Float64
    getter y : Float64
    getter v : Float64

    def initialize(@x : Float64, @y : Float64, @v : Float64)
    end
  end

  DEFAULT_COLORS = [
    Lipgloss::Color.new("#000000"), Lipgloss::Color.new("#111111"),
    Lipgloss::Color.new("#222222"), Lipgloss::Color.new("#333333"),
    Lipgloss::Color.new("#444444"), Lipgloss::Color.new("#555555"),
    Lipgloss::Color.new("#666666"), Lipgloss::Color.new("#777777"),
    Lipgloss::Color.new("#888888"), Lipgloss::Color.new("#999999"),
    Lipgloss::Color.new("#AAAAAA"), Lipgloss::Color.new("#BBBBBB"),
    Lipgloss::Color.new("#CCCCCC"), Lipgloss::Color.new("#DDDDDD"),
    Lipgloss::Color.new("#EEEEEE"), Lipgloss::Color.new("#FFFFFF"),
  ] of Lipgloss::Color

  def initialize(
    width : Int32 = 20,
    height : Int32 = 10,
    @color_scale : Array(Lipgloss::Color) = DEFAULT_COLORS,
    min_value : Float64 = Float64::MAX,
    max_value : Float64 = -Float64::MAX
  )
    @canvas = Canvas.new(width, height)
    @min_value = min_value
    @max_value = max_value
    @points = [] of HeatPoint
  end

  def push(p : HeatPoint) : Nil
    @min_value = {@min_value, p.v}.min
    @max_value = {@max_value, p.v}.max
    @points << p
  end

  def push_all(pts : Array(HeatPoint)) : Nil
    pts.each { |p| push(p) }
  end

  def clear : Nil
    @canvas.clear
    @points.clear
    @min_value = Float64::MAX
    @max_value = -Float64::MAX
  end

  def draw : Nil
    return if @points.empty? || @color_scale.empty?

    range = @max_value - @min_value
    range = 1.0 if range <= 0

    @points.each do |pt|
      x = pt.x.round.to_i
      y = pt.y.round.to_i
      next unless x >= 0 && x < @canvas.width && y >= 0 && y < @canvas.height

      t = (pt.v - @min_value) / range
      idx = (t * (@color_scale.size - 1).to_f64).round.to_i
      idx = {0, {idx, @color_scale.size - 1}.min}.max
      color = @color_scale[idx]

      style = Lipgloss::Style.new.background(color)
      @canvas.set_cell(Point.new(x, y), ' ', style)
    end
  end

  def view : String
    draw
    @canvas.view
  end
end
