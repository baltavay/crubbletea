require "math"

class Crubbletea::Ntcharts::Linechart
  getter canvas : Canvas
  getter style : Lipgloss::Style
  getter axis_style : Lipgloss::Style
  getter label_style : Lipgloss::Style

  @min_x : Float64
  @max_x : Float64
  @min_y : Float64
  @max_y : Float64
  @x_step : Int32
  @y_step : Int32
  @origin : Point
  @graph_width : Int32
  @graph_height : Int32
  @points : Array(Float64Point)

  def initialize(
    width : Int32 = 60,
    height : Int32 = 15,
    min_x : Float64 = 0.0,
    max_x : Float64 = 100.0,
    min_y : Float64 = 0.0,
    max_y : Float64 = 100.0,
    @style : Lipgloss::Style = Lipgloss::Style.new.foreground("#7571F9"),
    @axis_style : Lipgloss::Style = Lipgloss::Style.new.foreground("#888888"),
    @label_style : Lipgloss::Style = Lipgloss::Style.new.foreground("#666666"),
    @x_step : Int32 = 2,
    @y_step : Int32 = 2
  )
    @canvas = Canvas.new(width, height)
    @min_x = min_x
    @max_x = max_x
    @min_y = min_y
    @max_y = max_y
    @origin = Point.new(0, height - 1)
    @graph_width = width
    @graph_height = height
    @points = [] of Float64Point
    compute_graph_sizes
  end

  def width : Int32
    @canvas.width
  end

  def height : Int32
    @canvas.height
  end

  def push(x : Float64, y : Float64) : Nil
    @points << Float64Point.new(x, y)
  end

  def push_all(pts : Array(Float64Point)) : Nil
    @points.concat(pts)
  end

  def clear : Nil
    @canvas.clear
    @points.clear
  end

  def draw : Nil
    @canvas.clear
    draw_axes
    draw_labels
    draw_data_points
  end

  def view : String
    draw
    @canvas.view
  end

  private def compute_graph_sizes : Nil
    @origin = Point.new(0, @canvas.height - 1)
    @graph_width = @canvas.width
    @graph_height = @canvas.height

    if @x_step > 0
      @origin = Point.new(@origin.x, @origin.y - 1)
      @graph_height -= 2
    end

    if @y_step > 0
      value_len = 4
      @origin = Point.new(@origin.x + value_len, @origin.y)
      @graph_width -= (value_len + 1)
    end
  end

  private def draw_axes : Nil
    if @y_step > 0 && @x_step > 0
      @canvas.set_string(@origin, "┼", @axis_style)
      (@origin.y - 1).downto(0).each do |y|
        @canvas.set_cell(Point.new(@origin.x, y), '│', @axis_style)
      end
      (@origin.x + 1).upto(@canvas.width - 1).each do |x|
        @canvas.set_cell(Point.new(x, @origin.y), '─', @axis_style)
      end
    elsif @y_step > 0
      (@origin.y).downto(0).each do |y|
        @canvas.set_cell(Point.new(@origin.x, y), '│', @axis_style)
      end
    elsif @x_step > 0
      (@origin.x).upto(@canvas.width - 1).each do |x|
        @canvas.set_cell(Point.new(x, @origin.y), '─', @axis_style)
      end
    end
  end

  private def draw_labels : Nil
    if @y_step > 0 && @graph_height > 0
      range = @max_y - @min_y
      incr = range / @graph_height.to_f64
      (0..@graph_height).step(@y_step) do |i|
        v = @min_y + incr * i.to_f64
        s = "%.0f" % v
        y = @origin.y - i
        if y >= 0
          @canvas.set_string(Point.new(@origin.x - s.size, y), s, @label_style)
        end
      end
    end

    if @x_step > 0 && @graph_width > 0
      range = @max_x - @min_x
      incr = range / @graph_width.to_f64
      (0...@graph_width).step(@x_step * 4) do |i|
        v = @min_x + incr * i.to_f64
        s = "%.0f" % v
        x = @origin.x + i
        y = @origin.y + 1
        if x + s.size <= @canvas.width && y < @canvas.height
          @canvas.set_string(Point.new(x, y), s, @label_style)
        end
      end
    end
  end

  private def draw_data_points : Nil
    return if @points.size < 2

    dx = @max_x - @min_x
    dy = @max_y - @min_y
    return if dx <= 0 || dy <= 0

    xs = (@graph_width - 1).to_f64 / dx
    ys = (@graph_height - 1).to_f64 / dy

    screen_points = @points.map do |p|
      sx = @origin.x + ((p.x - @min_x) * xs).round.to_i
      sy = @origin.y - ((p.y - @min_y) * ys).round.to_i
      Point.new(sx, sy)
    end

    (0...screen_points.size - 1).each do |i|
      p1 = screen_points[i]
      p2 = screen_points[i + 1]
      draw_line(p1, p2)
    end

    screen_points.each do |p|
      if p.x >= @origin.x && p.x < @canvas.width && p.y >= 0 && p.y <= @origin.y
        @canvas.set_cell(p, '●', @style)
      end
    end
  end

  private def draw_line(p1 : Point, p2 : Point) : Nil
    dx = (p2.x - p1.x).abs
    dy = (p2.y - p1.y).abs
    sx = p1.x < p2.x ? 1 : -1
    sy = p1.y < p2.y ? 1 : -1
    err = dx - dy

    x, y = p1.x, p1.y

    loop do
      if x >= @origin.x && x < @canvas.width && y >= 0 && y <= @origin.y
        @canvas.set_cell(Point.new(x, y), '·', @style)
      end

      break if x == p2.x && y == p2.y

      e2 = 2 * err
      if e2 > -dy
        err -= dy
        x += sx
      end
      if e2 < dx
        err += dx
        y += sy
      end
    end
  end
end
