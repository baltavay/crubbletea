require "math"

class Crubbletea::Ntcharts::Barchart
  getter canvas : Canvas
  getter axis_style : Lipgloss::Style
  getter label_style : Lipgloss::Style
  getter auto_max : Bool
  getter bar_width : Int32
  getter bar_gap : Int32
  getter horizontal : Bool
  getter show_axis : Bool

  @max : Float64
  @data : Array(BarData)

  struct BarValue
    getter name : String
    getter value : Float64
    getter style : Lipgloss::Style

    def initialize(@name : String, @value : Float64, @style : Lipgloss::Style = Lipgloss::Style.new)
    end
  end

  struct BarData
    getter label : String
    getter values : Array(BarValue)

    def initialize(@label : String, @values : Array(BarValue) = [] of BarValue)
    end
  end

  def initialize(
    width : Int32 = 40,
    height : Int32 = 10,
    @axis_style : Lipgloss::Style = Lipgloss::Style.new.foreground("#888888"),
    @label_style : Lipgloss::Style = Lipgloss::Style.new.foreground("#666666"),
    @auto_max : Bool = true,
    @bar_width : Int32 = 4,
    @bar_gap : Int32 = 1,
    @horizontal : Bool = false,
    @show_axis : Bool = true
  )
    @canvas = Canvas.new(width, height)
    @max = 1.0
    @data = [] of BarData
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

  def push(bar : BarData) : Nil
    sum = bar.values.map(&.value).sum
    sum = {sum, 0.0}.max
    if @auto_max && sum > @max
      set_max(sum)
    end
    @data << bar
  end

  def push_all(bars : Array(BarData)) : Nil
    bars.each { |b| push(b) }
  end

  def clear : Nil
    @canvas.clear
    @data.clear
    @max = 1.0 if @auto_max
  end

  def resize(w : Int32, h : Int32) : Nil
    @canvas.resize(w, h)
  end

  def draw : Nil
    @canvas.clear
    return if @data.empty?

    graph_height = @canvas.height - (@show_axis ? 2 : 0)
    graph_height = {graph_height, 1}.max

    draw_axis(graph_height) if @show_axis

    effective_bar_width = compute_bar_width

    @data.each_with_index do |bar, idx|
      x_start = idx * (effective_bar_width + @bar_gap)

      sum = 0.0
      bar.values.each do |v|
        scaled = (graph_height.to_f64 * {v.value, 0.0}.max / @max).round.to_i
        scaled = {scaled, graph_height}.min

        start_y = graph_height - sum.round.to_i - scaled
        scaled.times do |i|
          effective_bar_width.times do |bx|
            px = x_start + bx
            py = start_y + i
            if px >= 0 && px < @canvas.width && py >= 0 && py < @canvas.height
              @canvas.set_cell(Point.new(px, py), '█', v.style)
            end
          end
        end
        sum += v.value
      end

      if @show_axis
        label = bar.label
        label = label[0...effective_bar_width] if label.size > effective_bar_width
        @canvas.set_string(Point.new(x_start, graph_height + 1), label, @label_style)
      end
    end
  end

  def view : String
    draw
    @canvas.view
  end

  private def compute_bar_width : Int32
    total_gaps = (@data.size - 1) * @bar_gap
    available = @canvas.width - total_gaps
    if @data.size > 0 && available > 0
      {available / @data.size, 1}.max
    else
      @bar_width
    end
  end

  private def draw_axis(graph_height : Int32) : Nil
    @canvas.width.times do |x|
      @canvas.set_cell(Point.new(x, graph_height), '─', @axis_style)
    end
  end
end
