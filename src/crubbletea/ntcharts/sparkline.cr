require "math"

class Crubbletea::Ntcharts::Sparkline
  getter canvas : Canvas
  getter style : Lipgloss::Style
  getter auto_max : Bool

  @max : Float64
  @data : Array(Float64)

  def initialize(
    width : Int32 = 40,
    height : Int32 = 8,
    @style : Lipgloss::Style = Lipgloss::Style.new,
    @auto_max : Bool = true,
    max_value : Float64 = 1.0
  )
    @canvas = Canvas.new(width, height)
    @max = max_value
    @data = [] of Float64
  end

  def width : Int32
    @canvas.width
  end

  def height : Int32
    @canvas.height
  end

  def max_value : Float64
    @max
  end

  def set_max(v : Float64) : Nil
    @max = v
  end

  def push(v : Float64) : Nil
    v = {v, 0.0}.max
    if @auto_max && v > @max
      set_max(v)
    end
    @data << v
    if @data.size > @canvas.width
      @data.shift
    end
  end

  def push_all(values : Array(Float64)) : Nil
    values.each { |v| push(v) }
  end

  def resize(w : Int32, h : Int32) : Nil
    @canvas.resize(w, h)
    while @data.size > w
      @data.shift
    end
  end

  def clear : Nil
    @canvas.clear
    @data.clear
  end

  def draw : Nil
    @canvas.clear
    return if @data.empty?

    @data.each_with_index do |val, col|
      scaled = (@canvas.height.to_f64 * val / @max).round.to_i
      scaled = {scaled, @canvas.height}.min
      start_y = @canvas.height - scaled
      scaled.times do |i|
        @canvas.set_cell(Point.new(col, start_y + i), '█', @style)
      end
    end
    @canvas.set_style(@style)
  end

  def view : String
    draw
    @canvas.view
  end
end
