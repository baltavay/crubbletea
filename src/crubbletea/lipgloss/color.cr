module Crubbletea::Lipgloss
  alias Color = String | Symbol | Nil

  enum ColorProfile : UInt8
    Ascii
    Ansi
    Ansi256
    TrueColor
  end

  ANSI_COLORS = {
    "black"   => 0, "red" => 1, "green" => 2, "yellow" => 3,
    "blue"    => 4, "magenta" => 5, "cyan" => 6, "white" => 7,
    "default" => 9,
  } of String => Int32

  def self.color_profile : ColorProfile
    colorterm = ENV["COLORTERM"]? || ""
    term = ENV["TERM"]? || ""

    if colorterm.includes?("truecolor") || colorterm.includes?("24bit")
      ColorProfile::TrueColor
    elsif term.includes?("256color") || term.includes?("256")
      ColorProfile::Ansi256
    elsif !term.empty?
      ColorProfile::Ansi
    else
      ColorProfile::Ascii
    end
  end

  def self.ansi_color_code(color) : Int32?
    case color
    when Symbol
      ANSI_COLORS[color.to_s]?
    when String
      ANSI_COLORS[color]?
    else
      nil
    end
  end

  def self.foreground(color : Color) : String
    return "" if color.nil?
    return "\e[39m" if color == :default || color == "default"

    if color.is_a?(Symbol)
      code = ansi_color_code(color)
      return "\e[39m" unless code
      return "\e[#{30 + code}m"
    end

    if color.is_a?(String)
      if color.starts_with?('#') && color.size == 7
        r, g, b = hex_to_rgb(color)
        case color_profile
        when ColorProfile::TrueColor
          "\e[38;2;#{r};#{g};#{b}m"
        when ColorProfile::Ansi256
          idx = rgb_to_ansi256(r, g, b)
          "\e[38;5;#{idx}m"
        else
          "\e[#{nearest_ansi_color(r, g, b)}m"
        end
      elsif color.to_i?
        "\e[38;5;#{color}m"
      else
        code = ansi_color_code(color)
        code ? "\e[#{30 + code}m" : ""
      end
    else
      ""
    end
  end

  def self.background(color : Color) : String
    return "" if color.nil?
    return "\e[49m" if color == :default || color == "default"

    if color.is_a?(Symbol)
      code = ansi_color_code(color)
      return "\e[49m" unless code
      return "\e[#{40 + code}m"
    end

    if color.is_a?(String)
      if color.starts_with?('#') && color.size == 7
        r, g, b = hex_to_rgb(color)
        case color_profile
        when ColorProfile::TrueColor
          "\e[48;2;#{r};#{g};#{b}m"
        when ColorProfile::Ansi256
          idx = rgb_to_ansi256(r, g, b)
          "\e[48;5;#{idx}m"
        else
          "\e[#{40 + nearest_ansi_color(r, g, b)}m"
        end
      elsif color.to_i?
        "\e[48;5;#{color}m"
      else
        code = ansi_color_code(color)
        code ? "\e[#{40 + code}m" : ""
      end
    else
      ""
    end
  end

  def self.hex_to_rgb(hex : String) : {Int32, Int32, Int32}
    r = hex[1..2].to_i(16)
    g = hex[3..4].to_i(16)
    b = hex[5..6].to_i(16)
    {r, g, b}
  end

  def self.rgb_to_ansi256(r : Int32, g : Int32, b : Int32) : Int32
    if r < 8 && g < 8 && b < 8
      return 16
    end
    if r > 248 && g > 248 && b > 248
      return 231
    end
    ir = (r - 8) * 6 // 247
    ig = (g - 8) * 6 // 247
    ib = (b - 8) * 6 // 247
    16 + 36 * ir + 6 * ig + ib
  end

  private def self.nearest_ansi_color(r : Int32, g : Int32, b : Int32) : Int32
    grayscale = (r + g + b) // 3
    if grayscale < 48
      30
    elsif grayscale < 115
      37
    elsif grayscale < 200
      36
    else
      37
    end
  end
end
