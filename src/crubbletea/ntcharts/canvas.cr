class Crubbletea::Ntcharts::Canvas
  getter width : Int32
  getter height : Int32

  @cells : Array(Array(Char))
  @styles : Array(Array(Lipgloss::Style?))

  def initialize(@width : Int32 = 80, @height : Int32 = 24)
    @cells = Array.new(@height) { Array.new(@width, ' ') }
    @styles = Array.new(@height) { Array.new(@width, nil.as(Lipgloss::Style?)) }
  end

  def resize(w : Int32, h : Int32) : Nil
    @width = w
    @height = h
    new_cells = Array.new(h) { Array.new(w, ' ') }
    new_styles = Array.new(h) { Array.new(w, nil.as(Lipgloss::Style?)) }
    h.times do |y|
      w.times do |x|
        if y < @cells.size && x < @cells[y].size
          new_cells[y][x] = @cells[y][x]
          new_styles[y][x] = @styles[y][x]
        end
      end
    end
    @cells = new_cells
    @styles = new_styles
  end

  def clear : Nil
    @cells = Array.new(@height) { Array.new(@width, ' ') }
    @styles = Array.new(@height) { Array.new(@width, nil.as(Lipgloss::Style?)) }
  end

  def set_cell(p : Point, c : Char, style : Lipgloss::Style? = nil) : Nil
    return unless p.x >= 0 && p.x < @width && p.y >= 0 && p.y < @height
    @cells[p.y][p.x] = c
    @styles[p.y][p.x] = style
  end

  def set_string(p : Point, s : String, style : Lipgloss::Style? = nil) : Nil
    s.each_char_with_index do |c, i|
      set_cell(Point.new(p.x + i, p.y), c, style)
    end
  end

  def cell(p : Point) : Char
    return ' ' unless p.x >= 0 && p.x < @width && p.y >= 0 && p.y < @height
    @cells[p.y][p.x]
  end

  def set_style(p : Point, style : Lipgloss::Style) : Nil
    return unless p.x >= 0 && p.x < @width && p.y >= 0 && p.y < @height
    @styles[p.y][p.x] = style
  end

  def get_style(p : Point) : Lipgloss::Style?
    return nil unless p.x >= 0 && p.x < @width && p.y >= 0 && p.y < @height
    @styles[p.y][p.x]
  end

  def set_cell_style(p : Point, style : Lipgloss::Style) : Nil
    set_style(p, style)
  end

  def get_cell_style(p : Point) : Lipgloss::Style?
    get_style(p)
  end

  def view : String
    lines = @height.times.map do |y|
      row = String::Builder.new
      @width.times do |x|
        c = @cells[y][x]
        s = @styles[y][x]
        if s
          row << s.inline(true).render(c.to_s)
        else
          row << c
        end
      end
      row.to_s
    end.to_a
    lines.join('\n')
  end

  def update(msg : Crubbletea::Msg) : Crubbletea::Cmd
    nil
  end
end
