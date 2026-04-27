module Crubbletea::Lipgloss::ANSI
  ESC = '\e'

  private def self.terminator?(c : Char) : Bool
    (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || c == '~'
  end

  def self.string_width(s : String) : Int32
    n = 0
    in_esc = false
    s.each_char do |c|
      if c == ESC
        in_esc = true
      elsif in_esc
        in_esc = false if terminator?(c)
      else
        n += 1
      end
    end
    n
  end

  def self.truncate(s : String, max_width : Int32, tail : String = "") : String
    return s if max_width <= 0
    sw = ANSI.string_width(s)
    return s if sw <= max_width
    return tail if max_width <= ANSI.string_width(tail)

    result = String::Builder.new
    w = 0
    in_esc = false
    esc_buf = String::Builder.new

    s.each_char do |c|
      if c == ESC
        if in_esc
          result << esc_buf.to_s
          esc_buf = String::Builder.new
        end
        in_esc = true
        esc_buf << c
        next
      end

      if in_esc
        esc_buf << c
        if terminator?(c)
          in_esc = false
          seq = esc_buf.to_s
          esc_buf = String::Builder.new
          result << seq
        end
        next
      end

      if w >= max_width
        break
      end
      result << c
      w += 1
    end

    result.to_s + "\e[0m"
  end

  def self.wrap(s : String, width : Int32) : String
    return s if width <= 0
    lines = s.split('\n')
    wrapped = lines.map { |line| wrap_line(line, width) }
    wrapped.join('\n')
  end

  def self.strip(s : String) : String
    result = String::Builder.new
    in_esc = false
    s.each_char do |c|
      if c == ESC
        in_esc = true
        next
      end
      if in_esc
        in_esc = false if terminator?(c)
        next
      end
      result << c
    end
    result.to_s
  end

  private def self.wrap_line(line : String, width : Int32) : String
    return line if ANSI.string_width(line) <= width
    words = line.split(' ')
    result = String::Builder.new
    current_w = 0

    words.each_with_index do |word, i|
      word_w = ANSI.string_width(word)
      if i > 0
        if current_w + 1 + word_w > width
          result << '\n'
          current_w = 0
        else
          result << ' '
          current_w += 1
        end
      end
      result << word
      current_w += word_w
    end

    result.to_s
  end
end
