require "./ansi"
require "./color"
require "./border"

struct Crubbletea::Lipgloss::Style
  enum Pos
    Top
    Bottom
    Center
    Left
    Right
  end

  @bold : Bool?
  @italic : Bool?
  @underline : Bool?
  @strikethrough : Bool?
  @reverse : Bool?
  @blink : Bool?
  @faint : Bool?

  @foreground : Color
  @background : Color

  @padding_top : Int32?
  @padding_right : Int32?
  @padding_bottom : Int32?
  @padding_left : Int32?

  @margin_top : Int32?
  @margin_right : Int32?
  @margin_bottom : Int32?
  @margin_left : Int32?

  @border : Border?
  @border_top : Bool
  @border_right : Bool
  @border_bottom : Bool
  @border_left : Bool
  @border_foreground : Color
  @border_background : Color

  @width : Int32?
  @height : Int32?
  @max_width : Int32?
  @max_height : Int32?
  @min_width : Int32?
  @min_height : Int32?

  @horizontal_align : Pos?
  @vertical_align : Pos?

  @inline : Bool
  @max_width_per_line : Bool

  def initialize(
    @bold = nil,
    @italic = nil,
    @underline = nil,
    @strikethrough = nil,
    @reverse = nil,
    @blink = nil,
    @faint = nil,
    @foreground : Color = nil,
    @background : Color = nil,
    @padding_top = nil,
    @padding_right = nil,
    @padding_bottom = nil,
    @padding_left = nil,
    @margin_top = nil,
    @margin_right = nil,
    @margin_bottom = nil,
    @margin_left = nil,
    @border = nil,
    @border_top = false,
    @border_right = false,
    @border_bottom = false,
    @border_left = false,
    @border_foreground : Color = nil,
    @border_background : Color = nil,
    @width = nil,
    @height = nil,
    @max_width = nil,
    @max_height = nil,
    @min_width = nil,
    @min_height = nil,
    @horizontal_align : Pos? = nil,
    @vertical_align : Pos? = nil,
    @inline = false,
    @max_width_per_line = false
  )
  end

  private COPY_UNSET_COLOR = :__copy_unset__

  private def color_or_current(new_val, current)
    new_val == COPY_UNSET_COLOR ? current : (new_val == nil ? nil : new_val)
  end

  def copy_with(
    bold : Bool? = nil,
    italic : Bool? = nil,
    underline : Bool? = nil,
    strikethrough : Bool? = nil,
    reverse : Bool? = nil,
    blink : Bool? = nil,
    faint : Bool? = nil,
    foreground : Color = COPY_UNSET_COLOR,
    background : Color = COPY_UNSET_COLOR,
    padding_top : Int32? = nil,
    padding_right : Int32? = nil,
    padding_bottom : Int32? = nil,
    padding_left : Int32? = nil,
    margin_top : Int32? = nil,
    margin_right : Int32? = nil,
    margin_bottom : Int32? = nil,
    margin_left : Int32? = nil,
    border : Border? = nil,
    border_top : Bool? = nil,
    border_right : Bool? = nil,
    border_bottom : Bool? = nil,
    border_left : Bool? = nil,
    border_foreground : Color = COPY_UNSET_COLOR,
    border_background : Color = COPY_UNSET_COLOR,
    width : Int32? = nil,
    height : Int32? = nil,
    max_width : Int32? = nil,
    max_height : Int32? = nil,
    min_width : Int32? = nil,
    min_height : Int32? = nil,
    horizontal_align : Pos? = nil,
    vertical_align : Pos? = nil,
    inline : Bool? = nil,
    max_width_per_line : Bool? = nil
  ) : Style
    Style.new(
      bold: bold.nil? ? @bold : bold,
      italic: italic.nil? ? @italic : italic,
      underline: underline.nil? ? @underline : underline,
      strikethrough: strikethrough.nil? ? @strikethrough : strikethrough,
      reverse: reverse.nil? ? @reverse : reverse,
      blink: blink.nil? ? @blink : blink,
      faint: faint.nil? ? @faint : faint,
      foreground: color_or_current(foreground, @foreground),
      background: color_or_current(background, @background),
      padding_top: padding_top.nil? ? @padding_top : padding_top,
      padding_right: padding_right.nil? ? @padding_right : padding_right,
      padding_bottom: padding_bottom.nil? ? @padding_bottom : padding_bottom,
      padding_left: padding_left.nil? ? @padding_left : padding_left,
      margin_top: margin_top.nil? ? @margin_top : margin_top,
      margin_right: margin_right.nil? ? @margin_right : margin_right,
      margin_bottom: margin_bottom.nil? ? @margin_bottom : margin_bottom,
      margin_left: margin_left.nil? ? @margin_left : margin_left,
      border: border.nil? ? @border : border,
      border_top: border_top.nil? ? @border_top : border_top,
      border_right: border_right.nil? ? @border_right : border_right,
      border_bottom: border_bottom.nil? ? @border_bottom : border_bottom,
      border_left: border_left.nil? ? @border_left : border_left,
      border_foreground: color_or_current(border_foreground, @border_foreground),
      border_background: color_or_current(border_background, @border_background),
      width: width.nil? ? @width : width,
      height: height.nil? ? @height : height,
      max_width: max_width.nil? ? @max_width : max_width,
      max_height: max_height.nil? ? @max_height : max_height,
      min_width: min_width.nil? ? @min_width : min_width,
      min_height: min_height.nil? ? @min_height : min_height,
      horizontal_align: horizontal_align.nil? ? @horizontal_align : horizontal_align,
      vertical_align: vertical_align.nil? ? @vertical_align : vertical_align,
      inline: inline.nil? ? @inline : inline,
      max_width_per_line: max_width_per_line.nil? ? @max_width_per_line : max_width_per_line
    )
  end

  macro chain_bool(name)
    def {{name.id}}(v : Bool = true) : Style
      copy_with({{name.id}}: v)
    end
  end

  chain_bool bold
  chain_bool italic
  chain_bool underline
  chain_bool strikethrough
  chain_bool reverse
  chain_bool blink
  chain_bool faint
  chain_bool inline

  def foreground(color : Color) : Style
    copy_with(foreground: color)
  end

  def background(color : Color) : Style
    copy_with(background: color)
  end

  def padding(v : Int32) : Style
    copy_with(padding_top: v, padding_right: v, padding_bottom: v, padding_left: v)
  end

  def padding(vertical : Int32, horizontal : Int32) : Style
    copy_with(padding_top: vertical, padding_right: horizontal, padding_bottom: vertical, padding_left: horizontal)
  end

  def padding(top : Int32, right : Int32, bottom : Int32, left : Int32) : Style
    copy_with(padding_top: top, padding_right: right, padding_bottom: bottom, padding_left: left)
  end

  def padding_horizontal(v : Int32) : Style
    copy_with(padding_left: v, padding_right: v)
  end

  def padding_vertical(v : Int32) : Style
    copy_with(padding_top: v, padding_bottom: v)
  end

  def margin(v : Int32) : Style
    copy_with(margin_top: v, margin_right: v, margin_bottom: v, margin_left: v)
  end

  def margin(top : Int32, right : Int32, bottom : Int32, left : Int32) : Style
    copy_with(margin_top: top, margin_right: right, margin_bottom: bottom, margin_left: left)
  end

  def margin_horizontal(v : Int32) : Style
    copy_with(margin_left: v, margin_right: v)
  end

  def margin_vertical(v : Int32) : Style
    copy_with(margin_top: v, margin_bottom: v)
  end

  def border(b : Border, sides : Array(Bool)? = nil) : Style
    s = copy_with(border: b)
    if sides && sides.size == 4
      s = s.copy_with(border_top: sides[0], border_right: sides[1], border_bottom: sides[2], border_left: sides[3])
    else
      s = s.copy_with(border_top: true, border_right: true, border_bottom: true, border_left: true)
    end
    s
  end

  def border_top(v : Bool = true) : Style
    copy_with(border_top: v)
  end

  def border_right(v : Bool = true) : Style
    copy_with(border_right: v)
  end

  def border_bottom(v : Bool = true) : Style
    copy_with(border_bottom: v)
  end

  def border_left(v : Bool = true) : Style
    copy_with(border_left: v)
  end

  def border_foreground(color : Color) : Style
    copy_with(border_foreground: color)
  end

  def border_background(color : Color) : Style
    copy_with(border_background: color)
  end

  def width(w : Int32) : Style
    copy_with(width: w)
  end

  def height(h : Int32) : Style
    copy_with(height: h)
  end

  def max_width(w : Int32) : Style
    copy_with(max_width: w)
  end

  def max_height(h : Int32) : Style
    copy_with(max_height: h)
  end

  def min_width(w : Int32) : Style
    copy_with(min_width: w)
  end

  def min_height(h : Int32) : Style
    copy_with(min_height: h)
  end

  def align_horizontal(pos : Pos) : Style
    copy_with(horizontal_align: pos)
  end

  def align_vertical(pos : Pos) : Style
    copy_with(vertical_align: pos)
  end

  def align(p : Pos) : Style
    copy_with(horizontal_align: p)
  end

  def get_foreground : Color
    @foreground
  end

  def get_background : Color
    @background
  end

  def get_padding_top : Int32
    @padding_top || 0
  end

  def get_padding_right : Int32
    @padding_right || 0
  end

  def get_padding_bottom : Int32
    @padding_bottom || 0
  end

  def get_padding_left : Int32
    @padding_left || 0
  end

  def get_horizontal_padding : Int32
    get_padding_left + get_padding_right
  end

  def get_vertical_padding : Int32
    get_padding_top + get_padding_bottom
  end

  def get_margin_top : Int32
    @margin_top || 0
  end

  def get_margin_right : Int32
    @margin_right || 0
  end

  def get_margin_bottom : Int32
    @margin_bottom || 0
  end

  def get_margin_left : Int32
    @margin_left || 0
  end

  def get_horizontal_margin : Int32
    get_margin_left + get_margin_right
  end

  def get_vertical_margin : Int32
    get_margin_top + get_margin_bottom
  end

  def get_horizontal_frame_size : Int32
    border_w = (@border_left ? 1 : 0) + (@border_right ? 1 : 0)
    get_horizontal_padding + border_w
  end

  def get_vertical_frame_size : Int32
    border_h = (@border_top ? 1 : 0) + (@border_bottom ? 1 : 0)
    get_vertical_padding + border_h
  end

  def get_width : Int32
    @width || 0
  end

  def get_height : Int32
    @height || 0
  end

  def has_border_top? : Bool
    @border_top
  end

  def has_border_bottom? : Bool
    @border_bottom
  end

  def has_border_left? : Bool
    @border_left
  end

  def has_border_right? : Bool
    @border_right
  end

  def inherit(other : Style) : Style
    s = self
    s = s.bold(other.@bold.not_nil!) if @bold.nil? && !other.@bold.nil?
    s = s.italic(other.@italic.not_nil!) if @italic.nil? && !other.@italic.nil?
    s = s.underline(other.@underline.not_nil!) if @underline.nil? && !other.@underline.nil?
    s = s.strikethrough(other.@strikethrough.not_nil!) if @strikethrough.nil? && !other.@strikethrough.nil?
    s = s.reverse(other.@reverse.not_nil!) if @reverse.nil? && !other.@reverse.nil?
    s = s.blink(other.@blink.not_nil!) if @blink.nil? && !other.@blink.nil?
    s = s.faint(other.@faint.not_nil!) if @faint.nil? && !other.@faint.nil?
    s = s.foreground(other.@foreground) if @foreground.nil? && !other.@foreground.nil?
    s = s.background(other.@background) if @background.nil? && !other.@background.nil?
    s
  end

  def render(s : String) : String
    return "" if s.empty? && @width.nil? && @height.nil?

    content = s
    lines = content.split('\n')

    content_w = lines.map { |l| ANSI.string_width(l) }.max
    content_h = lines.size

    pt = get_padding_top
    pr = get_padding_right
    pb = get_padding_bottom
    pl = get_padding_left

    mt = get_margin_top
    mr = get_margin_right
    mb = get_margin_bottom
    ml = get_margin_left

    border_w = (@border && @border_left ? 1 : 0) + (@border && @border_right ? 1 : 0)
    border_h = (@border && @border_top ? 1 : 0) + (@border && @border_bottom ? 1 : 0)

    target_w = content_w
    if w = @width
      target_w = {w - pl - pr - border_w, 0}.max
    end
    if mw = @max_width
      tw = mw - pl - pr - border_w
      target_w = {target_w, tw}.min if tw < target_w
    end
    if minw = @min_width
      tw = minw - pl - pr - border_w
      target_w = {target_w, tw}.max if tw > target_w
    end

    target_h = content_h
    if h = @height
      target_h = {h - pt - pb - border_h, 0}.max
    end
    if mh = @max_height
      th = mh - pt - pb - border_h
      target_h = {target_h, th}.min if th < target_h
    end
    if minh = @min_height
      th = minh - pt - pb - border_h
      target_h = {target_h, th}.max if th > target_h
    end

    aligned = lines.map do |line|
      lw = ANSI.string_width(line)
      if lw < target_w
        case @horizontal_align
        when Pos::Right
          " " * (target_w - lw) + line
        when Pos::Center
          left_pad = (target_w - lw) // 2
          right_pad = target_w - lw - left_pad
          " " * left_pad + line + " " * right_pad
        else
          line + " " * (target_w - lw)
        end
      elsif lw > target_w
        ANSI.truncate(line, target_w)
      else
        line
      end
    end

    while aligned.size < target_h
      aligned << " " * target_w
    end
    if aligned.size > target_h
      aligned = aligned[0...target_h]
    end

    padded = aligned.map do |line|
      (" " * pl) + line + (" " * pr)
    end

    pt.times { padded.insert(0, " " * (pl + target_w + pr)) }
    pb.times { padded << " " * (pl + target_w + pr) }

    inner_w = pl + target_w + pr

    border_fg = ""
    border_bg = ""
    if @border_foreground
      border_fg = Lipgloss.foreground(@border_foreground)
    end
    if @border_background
      border_bg = Lipgloss.background(@border_background)
    end
    border_style_prefix = (border_fg.empty? && border_bg.empty?) ? "" : border_fg + border_bg
    border_style_reset = border_style_prefix.empty? ? "" : "\e[0m"

    styled = padded.map do |line|
      apply_ansi(line)
    end

    if b = @border
      border_lines = [] of String
      if @border_top
        tl = @border_top && @border_left ? b.top_left : (@border_top ? b.top : "")
        tr = @border_top && @border_right ? b.top_right : (@border_top ? b.top : "")
        top_line = tl + b.top * inner_w + tr
        top_line = border_style_prefix + top_line + border_style_reset unless border_style_prefix.empty?
        border_lines << top_line
      end

      styled.each_with_index do |line, _i|
        left = @border_left ? b.left : ""
        right = @border_right ? b.right : ""
        if border_style_prefix.empty?
          border_lines << left + line + right
        else
          border_lines << border_style_prefix + left + border_style_reset + line + border_style_prefix + right + border_style_reset
        end
      end

      if @border_bottom
        bl = @border_bottom && @border_left ? b.bottom_left : (@border_bottom ? b.bottom : "")
        br = @border_bottom && @border_right ? b.bottom_right : (@border_bottom ? b.bottom : "")
        bot_line = bl + b.bottom * inner_w + br
        bot_line = border_style_prefix + bot_line + border_style_reset unless border_style_prefix.empty?
        border_lines << bot_line
      end

      styled = border_lines
    end

    if !@inline
      full_w = styled.map { |l| ANSI.string_width(l) }.max

      if mt > 0 || mb > 0
        margin_top_lines = mt.times.map { " " * (ml + full_w + mr) }.to_a
        margin_bottom_lines = mb.times.map { " " * (ml + full_w + mr) }.to_a
        styled = margin_top_lines + styled + margin_bottom_lines
      end

      if ml > 0 || mr > 0
        styled = styled.map do |line|
          (" " * ml) + line + (" " * mr)
        end
      end
    else
      if ml > 0
        styled[0] = " " * ml + styled[0]
      end
      if mr > 0
        styled[-1] = styled[-1] + " " * mr
      end
    end

    styled.join('\n')
  end

  private def apply_ansi(s : String) : String
    codes = [] of String

    if @bold == true
      codes << "\e[1m"
    end
    if @faint == true
      codes << "\e[2m"
    end
    if @italic == true
      codes << "\e[3m"
    end
    if @underline == true
      codes << "\e[4m"
    end
    if @blink == true
      codes << "\e[5m"
    end
    if @reverse == true
      codes << "\e[7m"
    end
    if @strikethrough == true
      codes << "\e[9m"
    end

    if @foreground
      codes << Lipgloss.foreground(@foreground)
    end
    if @background
      codes << Lipgloss.background(@background)
    end

    return s if codes.empty?

    reset = "\e[0m"
    code_str = codes.join

    if @inline
      code_str + s + reset
    else
      s.split('\n').map do |line|
        if line.includes?(reset)
          styled_line = line.gsub(reset, reset + code_str)
          code_str + styled_line + reset
        else
          code_str + line + reset
        end
      end.join('\n')
    end
  end
end
