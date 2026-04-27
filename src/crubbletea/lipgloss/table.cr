require "../lipgloss"

class Crubbletea::Lipgloss::TableRenderer
  HEADER_ROW = -1

  alias StyleFunc = Proc(Int32, Int32, Style)

  class StringData
    getter rows : Array(Array(String))
    @columns : Int32

    def initialize(rows : Array(Array(String)) = [] of Array(String))
      @rows = rows
      @columns = rows.empty? ? 0 : rows.map(&.size).max
    end

    def append(row : Array(String)) : Nil
      @columns = {@columns, row.size}.max
      @rows << row
    end

    def at(row : Int32, col : Int32) : String
      return "" if row >= @rows.size || col >= @rows[row].size
      @rows[row][col]
    end

    def columns : Int32
      @columns
    end

    def rows_count : Int32
      @rows.size
    end
  end

  @base_style : Style
  @style_func : StyleFunc
  @border : Border
  @border_top : Bool
  @border_bottom : Bool
  @border_left : Bool
  @border_right : Bool
  @border_header : Bool
  @border_column : Bool
  @border_row : Bool
  @border_style : Style
  @headers : Array(String)
  @data : StringData
  @width : Int32
  @height : Int32
  @use_manual_height : Bool
  @y_offset : Int32
  @wrap : Bool
  @widths : Array(Int32)
  @heights : Array(Int32)

  def initialize
    @base_style = Style.new
    @style_func = ->(row : Int32, col : Int32) { Style.new }
    @border = Border.normal
    @border_top = true
    @border_bottom = true
    @border_left = true
    @border_right = true
    @border_header = true
    @border_column = true
    @border_row = false
    @border_style = Style.new
    @headers = [] of String
    @data = StringData.new
    @width = 0
    @height = 0
    @use_manual_height = false
    @y_offset = 0
    @wrap = true
    @widths = [] of Int32
    @heights = [] of Int32
  end

  def base_style(s : Style) : TableRenderer
    @base_style = s
    @border_style = @border_style.inherit(s)
    self
  end

  def style_func(fn : StyleFunc) : TableRenderer
    @style_func = fn
    self
  end

  def headers(*h : String) : TableRenderer
    @headers = h.to_a
    self
  end

  def row(*cells : String) : TableRenderer
    @data.append(cells.to_a)
    self
  end

  def rows(rs : Array(Array(String))) : TableRenderer
    rs.each { |r| @data.append(r) }
    self
  end

  def border(b : Border) : TableRenderer
    @border = b
    self
  end

  def border_top(v : Bool) : TableRenderer
    @border_top = v
    self
  end

  def border_bottom(v : Bool) : TableRenderer
    @border_bottom = v
    self
  end

  def border_left(v : Bool) : TableRenderer
    @border_left = v
    self
  end

  def border_right(v : Bool) : TableRenderer
    @border_right = v
    self
  end

  def border_header(v : Bool) : TableRenderer
    @border_header = v
    self
  end

  def border_column(v : Bool) : TableRenderer
    @border_column = v
    self
  end

  def border_row(v : Bool) : TableRenderer
    @border_row = v
    self
  end

  def border_style(s : Style) : TableRenderer
    @border_style = s.inherit(@base_style)
    self
  end

  def width(w : Int32) : TableRenderer
    @width = w
    self
  end

  def height(h : Int32) : TableRenderer
    @height = h
    @use_manual_height = true
    self
  end

  def wrap(v : Bool) : TableRenderer
    @wrap = v
    self
  end

  def render : String
    has_headers = !@headers.empty?
    has_rows = @data.rows_count > 0

    return "" unless has_headers || has_rows

    if has_headers
      while @headers.size < @data.columns
        @headers << ""
      end
    end

    compute_sizes

    buf = String::Builder.new

    if @border_top
      buf << construct_top_border << '\n'
    end

    if has_headers
      buf << construct_headers
    end

    if has_rows
      @data.rows_count.times do |r|
        buf << construct_row(r)
      end
    end

    if @border_bottom
      buf << construct_bottom_border
    end

    result = buf.to_s
    if result.ends_with?('\n')
      result = result[0...-1]
    end
    result
  end

  def to_s : String
    render
  end

  private def style(row : Int32, col : Int32) : Style
    @style_func.call(row, col).inherit(@base_style)
  end

  private def compute_sizes : Nil
    all_rows = [] of Array(String)
    if !@headers.empty?
      all_rows << @headers
    end
    @data.rows_count.times do |i|
      r = (0...@data.columns).map { |j| @data.at(i, j) }
      all_rows << r
    end

    num_cols = @data.columns
    @widths = Array.new(num_cols, 0)
    @heights = Array.new(all_rows.size, 1)

    all_rows.each_with_index do |row, _ri|
      row.each_with_index do |cell, ci|
        cw = Lipgloss.width(cell)
        @widths[ci] = {@widths[ci], cw}.max if ci < num_cols
      end
    end

    if @width > 0
      total_border = (@border_left ? 1 : 0) + (@border_right ? 1 : 0)
      total_sep = (@border_column ? {num_cols - 1, 0}.max : 0)
      available = @width - total_border - total_sep
      available = {available, 0}.max

      current_total = @widths.sum
      if current_total > available
        diff = current_total - available
        while diff > 0
          max_idx = @widths.each_with_index.max_by { |w, _| w }[1]
          @widths[max_idx] -= 1
          diff -= 1
        end
      elsif current_total < available
        diff = available - current_total
        while diff > 0
          @widths.each_with_index do |_, i|
            break if diff <= 0
            @widths[i] += 1
            diff -= 1
          end
        end
      end
    end
  end

  private def construct_top_border : String
    buf = String::Builder.new
    buf << @border_style.render(@border.top_left) if @border_left
    @widths.each_with_index do |w, i|
      buf << @border_style.render(@border.top * w)
      if i < @widths.size - 1 && @border_column
        buf << @border_style.render(@border.middle_top)
      end
    end
    buf << @border_style.render(@border.top_right) if @border_right
    buf.to_s
  end

  private def construct_bottom_border : String
    buf = String::Builder.new
    buf << @border_style.render(@border.bottom_left) if @border_left
    @widths.each_with_index do |w, i|
      buf << @border_style.render(@border.bottom * w)
      if i < @widths.size - 1 && @border_column
        buf << @border_style.render(@border.middle_bottom)
      end
    end
    buf << @border_style.render(@border.bottom_right) if @border_right
    buf.to_s
  end

  private def construct_headers : String
    buf = String::Builder.new
    cells = [] of String
    h = @heights[0]? || 1

    left = @border_style.render(@border.left)
    if @border_left
      h.times { cells << left }
    end

    @headers.each_with_index do |header, j|
      cell_style = style(HEADER_ROW, j)
      truncated = Lipgloss::ANSI.truncate(header, @widths[j]? || 0)
      rendered = cell_style.width(@widths[j]? || 0).height(h).render(truncated)
      cells << rendered

      if j < @headers.size - 1 && @border_column
        h.times { cells << left }
      end
    end

    if @border_right
      right = @border_style.render(@border.right)
      h.times { cells << right }
    end

    buf << Lipgloss.join_horizontal(Style::Pos::Top, cells) << '\n'

    if @border_header
      buf << @border_style.render(@border.middle_left) if @border_left
      @widths.each_with_index do |w, i|
        buf << @border_style.render(@border.top * w)
        if i < @widths.size - 1 && @border_column
          buf << @border_style.render(@border.middle)
        end
      end
      buf << @border_style.render(@border.middle_right) if @border_right
      buf << '\n'
    end

    buf.to_s
  end

  private def construct_row(index : Int32) : String
    buf = String::Builder.new
    has_headers = !@headers.empty?
    h_idx = index + (has_headers ? 1 : 0)
    h = @heights[h_idx]? || 1

    cells = [] of String
    left = @border_style.render(@border.left)
    if @border_left
      h.times { cells << left }
    end

    @data.columns.times do |c|
      cell = @data.at(index, c)
      cell_style = style(index, c)
      unless @wrap
        cell = Lipgloss::ANSI.truncate(cell, @widths[c]? || 0)
      end
      cells << cell_style.width(@widths[c]? || 0).height(h).render(cell)

      if c < @data.columns - 1 && @border_column
        h.times { cells << left }
      end
    end

    if @border_right
      right = @border_style.render(@border.right)
      h.times { cells << right }
    end

    buf << Lipgloss.join_horizontal(Style::Pos::Top, cells) << '\n'

    if @border_row && index < @data.rows_count - 1
      buf << @border_style.render(@border.middle_left) if @border_left
      @widths.each_with_index do |w, i|
        buf << @border_style.render(@border.bottom * w)
        if i < @widths.size - 1 && @border_column
          buf << @border_style.render(@border.middle)
        end
      end
      buf << @border_style.render(@border.middle_right) if @border_right
      buf << '\n'
    end

    buf.to_s
  end
end
