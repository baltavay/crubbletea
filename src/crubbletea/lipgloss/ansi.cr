module Crubbletea::Lipgloss::ANSI
  ESC = '\e'

  private def self.terminator?(c : Char) : Bool
    (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || c == '~'
  end

  private def self.wide?(c : Char) : Bool
    cp = c.ord
    (0x1100 <= cp <= 0x115F) ||
      (0x231A <= cp <= 0x231B) ||
      (0x2329 <= cp <= 0x232A) ||
      (0x23E9 <= cp <= 0x23EC) ||
      (0x23F0 <= cp <= 0x23F3) ||
      (0x25FD <= cp <= 0x25FE) ||
      (0x2614 <= cp <= 0x2615) ||
      (0x2648 <= cp <= 0x2653) ||
      (0x267F <= cp <= 0x2693) ||
      (0x26A1 <= cp <= 0x26A1) ||
      (0x26AA <= cp <= 0x26AB) ||
      (0x26BD <= cp <= 0x26BF) ||
      (0x26C4 <= cp <= 0x26CD) ||
      (0x26D3 <= cp <= 0x26E1) ||
      (0x26F2 <= cp <= 0x26F3) ||
      (0x26F5 <= cp <= 0x26FA) ||
      (0x26FD <= cp <= 0x26FD) ||
      (0x2702 <= cp <= 0x2702) ||
      (0x2705 <= cp <= 0x2705) ||
      (0x2708 <= cp <= 0x270D) ||
      (0x270F <= cp <= 0x270F) ||
      (0x2712 <= cp <= 0x2712) ||
      (0x2714 <= cp <= 0x2714) ||
      (0x2716 <= cp <= 0x2716) ||
      (0x271D <= cp <= 0x271D) ||
      (0x2721 <= cp <= 0x2721) ||
      (0x2728 <= cp <= 0x2728) ||
      (0x2733 <= cp <= 0x2734) ||
      (0x2744 <= cp <= 0x2744) ||
      (0x2747 <= cp <= 0x2747) ||
      (0x274C <= cp <= 0x274C) ||
      (0x274E <= cp <= 0x274E) ||
      (0x2753 <= cp <= 0x2755) ||
      (0x2757 <= cp <= 0x2757) ||
      (0x2763 <= cp <= 0x2767) ||
      (0x2795 <= cp <= 0x2797) ||
      (0x27A1 <= cp <= 0x27A1) ||
      (0x27B0 <= cp <= 0x27B0) ||
      (0x27BF <= cp <= 0x27BF) ||
      (0x2B1B <= cp <= 0x2B1C) ||
      (0x2B50 <= cp <= 0x2B50) ||
      (0x2B55 <= cp <= 0x2B55) ||
      (0x2FF0 <= cp <= 0x4DBF && !(0x2800 <= cp <= 0x28FF)) ||
      (0x4E00 <= cp <= 0x9FFF) ||
      (0xA000 <= cp <= 0xA4CF) ||
      (0xAC00 <= cp <= 0xD7A3) ||
      (0xF900 <= cp <= 0xFAFF) ||
      (0xFE10 <= cp <= 0xFE19) ||
      (0xFE30 <= cp <= 0xFE6F) ||
      (0xFF01 <= cp <= 0xFF60) ||
      (0xFFE0 <= cp <= 0xFFE6) ||
      (0x1F000 <= cp <= 0x1F9FF) ||
      (0x20000 <= cp <= 0x2FFFD) ||
      (0x30000 <= cp <= 0x3FFFD)
  end

  def self.char_width(c : Char) : Int32
    wide?(c) ? 2 : 1
  end

  def self.string_width(s : String) : Int32
    max_w = 0
    n = 0
    in_esc = false
    s.each_char do |c|
      if c == ESC
        in_esc = true
      elsif in_esc
        in_esc = false if terminator?(c)
      elsif c == '\n'
        max_w = n if n > max_w
        n = 0
      else
        n += char_width(c)
      end
    end
    n > max_w ? n : max_w
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
      cw = char_width(c)
      w += cw
      if w >= max_width
        break
      end
    end

    tail_w = string_width(tail)
    r = result.to_s
    if tail_w > 0 && !tail.empty?
      r + "\e[0m" + tail
    else
      r + "\e[0m"
    end
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
        if current_w + 1 + {word_w, width}.min > width
          result << '\n'
          current_w = 0
        else
          result << ' '
          current_w += 1
        end
      end

      if word_w <= width
        result << word
        current_w += word_w
      else
        word.each_char do |c|
          cw = char_width(c)
          if current_w + cw > width
            result << '\n'
            current_w = 0
          end
          result << c
          current_w += cw
        end
      end
    end

    result.to_s
  end
end
