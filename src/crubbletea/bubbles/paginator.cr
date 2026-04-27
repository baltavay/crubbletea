require "../lipgloss"

struct Crubbletea::Bubbles::Paginator::Model
  enum Type
    Arabic
    Dots
  end

  getter type : Type
  getter page : Int32
  getter per_page : Int32
  getter total_pages : Int32
  getter active_dot : String
  getter inactive_dot : String
  getter arabic_format : String

  def initialize(
    @type : Type = Type::Arabic,
    @page : Int32 = 0,
    @per_page : Int32 = 1,
    @total_pages : Int32 = 1,
    @active_dot : String = "•",
    @inactive_dot : String = "○",
    @arabic_format : String = "%d/%d"
  )
  end

  def set_total_pages(items : Int32) : Int32
    return @total_pages if items < 1
    n = items // @per_page
    n += 1 if items % @per_page > 0
    @total_pages = n
    n
  end

  def items_on_page(total_items : Int32) : Int32
    return 0 if total_items < 1
    s, e = slice_bounds(total_items)
    e - s
  end

  def slice_bounds(length : Int32) : {Int32, Int32}
    start_pos = @page * @per_page
    end_pos = {@page * @per_page + @per_page, length}.min
    {start_pos, end_pos}
  end

  def prev_page : Nil
    @page -= 1 if @page > 0
  end

  def next_page : Nil
    @page += 1 unless on_last_page?
  end

  def on_last_page? : Bool
    @page == @total_pages - 1
  end

  def on_first_page? : Bool
    @page == 0
  end

  def update(msg : Crubbletea::Msg) : {Model, Crubbletea::Cmd}
    case msg
    when Crubbletea::KeyPressMsg
      key = msg.key
      if key.to_s == "pgup" || key.to_s == "left" || key.to_s == "h"
        prev_page
      elsif key.to_s == "pgdown" || key.to_s == "right" || key.to_s == "l"
        next_page
      end
    end
    {self, nil}
  end

  def view : String
    case @type
    in Type::Dots
      dots_view
    in Type::Arabic
      arabic_view
    end
  end

  private def dots_view : String
    @total_pages.times.map do |i|
      i == @page ? @active_dot : @inactive_dot
    end.join
  end

  private def arabic_view : String
    @arabic_format % {@page + 1, @total_pages}
  end
end
