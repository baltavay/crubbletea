require "../lipgloss"

class Crubbletea::Bubbles::TableModel
  getter columns : Array(String)
  getter rows : Array(Array(String))
  getter style : Lipgloss::Style
  getter header_style : Lipgloss::Style
  getter cell_style : Lipgloss::Style
  getter selected_row : Int32
  getter height : Int32
  getter width : Int32

  @focused : Bool

  def initialize(
    @columns : Array(String) = [] of String,
    @rows : Array(Array(String)) = [] of Array(String),
    @style : Lipgloss::Style = Lipgloss::Style.new,
    @header_style : Lipgloss::Style = Lipgloss::Style.new.bold(true),
    @cell_style : Lipgloss::Style = Lipgloss::Style.new,
    @selected_row : Int32 = 0,
    @height : Int32 = 0,
    @width : Int32 = 0,
    @focused : Bool = false
  )
  end

  def focused? : Bool
    @focused
  end

  def focus : Nil
    @focused = true
  end

  def blur : Nil
    @focused = false
  end

  def set_rows(rs : Array(Array(String))) : Nil
    @rows = rs
    @selected_row = 0
  end

  def set_columns(cols : Array(String)) : Nil
    @columns = cols
  end

  def row_count : Int32
    @rows.size
  end

  def move_up : Nil
    @selected_row -= 1 if @selected_row > 0
  end

  def move_down : Nil
    @selected_row += 1 if @selected_row < @rows.size - 1
  end

  def move_top : Nil
    @selected_row = 0
  end

  def move_bottom : Nil
    @selected_row = {@rows.size - 1, 0}.max
  end

  def selected_row_data : Array(String)?
    @rows[@selected_row]?
  end

  def update(msg : Crubbletea::Msg) : {TableModel, Crubbletea::Cmd}
    case msg
    when Crubbletea::KeyPressMsg
      key = msg.key
      case key.to_s
      when "up", "k"
        move_up
      when "down", "j"
        move_down
      when "home", "g"
        move_top
      when "end", "G"
        move_bottom
      end
    end
    {self, nil}
  end

  def view : String
    return "" if @columns.empty?

    col_widths = compute_column_widths

    header_cells = @columns.each_with_index.map do |col, i|
      @header_style.width(col_widths[i]).render(col)
    end.to_a

    result = Lipgloss.join_horizontal(Lipgloss::Style::Pos::Left, header_cells) + "\n"

    @rows.each_with_index do |row, ri|
      cells = row.each_with_index.map do |cell, ci|
        s = ri == @selected_row ? @cell_style.reverse(true) : @cell_style
        s.width(col_widths[ci]).render(cell)
      end.to_a

      result += Lipgloss.join_horizontal(Lipgloss::Style::Pos::Left, cells) + "\n"
    end

    result
  end

  private def compute_column_widths : Array(Int32)
    @columns.each_with_index.map do |col, i|
      max_w = Lipgloss::ANSI.string_width(col)
      @rows.each do |row|
        if cell = row[i]?
          max_w = {max_w, Lipgloss::ANSI.string_width(cell)}.max
        end
      end
      max_w
    end.to_a
  end
end
