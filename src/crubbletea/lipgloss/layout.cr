require "./ansi"
require "./style"

module Crubbletea::Lipgloss
  def self.new_style : Style
    Style.new
  end

  def self.width(s : String) : Int32
    return 0 if s.empty?
    s.split('\n').map { |l| ANSI.string_width(l) }.max
  end

  def self.height(s : String) : Int32
    return 0 if s.empty?
    s.split('\n').size
  end

  def self.size(s : String) : {Int32, Int32}
    {width(s), height(s)}
  end

  def self.join_horizontal(position : Style::Pos, strs : Array(String)) : String
    return "" if strs.empty?
    return strs[0] if strs.size == 1

    str_heights = strs.map { |s| height(s) }
    max_h = str_heights.max

    padded = strs.map_with_index do |s, idx|
      h = str_heights[idx]
      lines = s.split('\n')
      s_w = lines.map { |l| ANSI.string_width(l) }.max
      while lines.size < max_h
        case position
        when Style::Pos::Top, Style::Pos::Left
          lines << " " * s_w
        when Style::Pos::Bottom, Style::Pos::Right
          lines.insert(0, " " * s_w)
        when Style::Pos::Center
          lines.insert(0, " " * s_w)
        end
      end
      lines
    end

    result = Array(String).new(max_h, "")
    max_h.times do |row|
      row_parts = padded.map do |col_lines|
        col_lines[row]? || ""
      end
      result[row] = row_parts.join
    end

    result.join('\n')
  end

  def self.join_vertical(position : Style::Pos, strs : Array(String)) : String
    return "" if strs.empty?
    return strs[0] if strs.size == 1

    widths = strs.map { |s| width(s) }
    max_w = widths.max

    aligned = strs.map_with_index do |s, idx|
      w = widths[idx]
      next s if w >= max_w

      lines = s.split('\n')
      lines.map do |line|
        lw = ANSI.string_width(line)
        pad = max_w - lw
        case position
        when Style::Pos::Right
          " " * pad + line
        when Style::Pos::Center
          left_pad = pad // 2
          right_pad = pad - left_pad
          " " * left_pad + line + " " * right_pad
        else
          line + " " * pad
        end
      end.join('\n')
    end

    aligned.join('\n')
  end

  def self.place(box_w : Int32, box_h : Int32, h_pos : Style::Pos, v_pos : Style::Pos, content : String, bg_char : Char? = nil) : String
    place_horizontal(box_w, h_pos, place_vertical(box_h, v_pos, content, bg_char))
  end

  def self.place_horizontal(box_w : Int32, pos : Style::Pos, content : String) : String
    lines = content.split('\n')
    lines.map do |line|
      lw = ANSI.string_width(line)
      pad = box_w - lw
      if pad <= 0
        line
      else
        case pos
        when Style::Pos::Right
          " " * pad + line
        when Style::Pos::Center
          left_pad = pad // 2
          right_pad = pad - left_pad
          " " * left_pad + line + " " * right_pad
        else
          line + " " * pad
        end
      end
    end.join('\n')
  end

  def self.place_vertical(box_h : Int32, pos : Style::Pos, content : String, bg_char : Char? = nil) : String
    lines = content.split('\n')
    pad = box_h - lines.size
    if pad <= 0
      return content
    end

    case pos
    when Style::Pos::Bottom, Style::Pos::Right
      pad.times { lines.insert(0, "") }
    when Style::Pos::Center
      top_pad = pad // 2
      bottom_pad = pad - top_pad
      top_pad.times { lines.insert(0, "") }
      bottom_pad.times { lines << "" }
    else
      pad.times { lines << "" }
    end

    lines.join('\n')
  end

  def self.wrap(s : String, width : Int32) : String
    ANSI.wrap(s, width)
  end
end
