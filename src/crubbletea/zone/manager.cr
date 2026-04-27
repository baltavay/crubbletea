struct Crubbletea::Zone::ZoneInfo
  getter id : String
  getter iteration : Int32
  getter start_x : Int32
  getter start_y : Int32
  getter end_x : Int32
  getter end_y : Int32

  def initialize(@id = "", @iteration = 0, @start_x = 0, @start_y = 0, @end_x = 0, @end_y = 0)
  end

  def zero? : Bool
    @id.empty?
  end

  def in_bounds?(mouse : Mouse) : Bool
    return false if zero?
    return false if @start_x > @end_x || @start_y > @end_y
    mouse.x >= @start_x && mouse.y >= @start_y && mouse.x <= @end_x && mouse.y <= @end_y
  end

  def pos(mouse : Mouse) : {Int32, Int32}
    return {-1, -1} if zero? || !in_bounds?(mouse)
    {mouse.x - @start_x, mouse.y - @start_y}
  end
end

struct Crubbletea::ZoneMsg
  include Crubbletea::Msg
  getter zone : Zone::ZoneInfo
  getter mouse : Mouse

  def initialize(@zone : Zone::ZoneInfo, @mouse : Mouse)
  end
end

class Crubbletea::Zone::Manager
  @enabled : Bool
  @zones : Hash(String, ZoneInfo)
  @ids : Hash(String, String)
  @rids : Hash(String, String)
  @marker_counter : Int32
  @prefix_counter : Int32

  def initialize
    @enabled = true
    @zones = {} of String => ZoneInfo
    @ids = {} of String => String
    @rids = {} of String => String
    @marker_counter = 1000
    @prefix_counter = 0
  end

  def enabled? : Bool
    @enabled
  end

  def enabled=(v : Bool)
    @enabled = v
  end

  def new_prefix : String
    @prefix_counter += 1
    "zone_#{@prefix_counter}__"
  end

  def mark(id : String, value : String) : String
    return value unless @enabled
    return value if id.empty? || value.empty?

    gid = @ids[id]?
    unless gid
      @marker_counter += 1
      gid = "\e[#{@marker_counter}z"
      @ids[id] = gid
      @rids[gid] = id
    end

    gid + value + gid
  end

  def clear(id : String) : Nil
    @zones.delete(id)
  end

  def get(id : String) : ZoneInfo?
    @zones[id]?
  end

  def scan(view : String) : String
    iteration = Time.utc.to_unix_ms.to_i32
    result, zones = strip_markers(view, iteration)

    zones.each do |zone|
      @zones[@rids[zone.id]? || zone.id] = zone
    end

    @zones.reject! { |_, v| v.iteration != iteration && iteration != 0 }

    result
  end

  private def strip_markers(input : String, iteration : Int32) : {String, Array(ZoneInfo)}
    result = String::Builder.new(input.size)
    tracked = {} of String => ZoneInfo
    zones = [] of ZoneInfo
    pos = 0
    newlines = 0
    last_newline = 0
    bytes = input.to_slice

    while pos < bytes.size
      if bytes[pos] == 0x1b_u8 && pos + 1 < bytes.size && bytes[pos + 1] == '['.ord
        start_pos = pos
        pos += 2

        num_start = pos
        while pos < bytes.size && bytes[pos] >= '0'.ord && bytes[pos] <= '9'.ord
          pos += 1
        end

        if pos < bytes.size && bytes[pos] == 'z'.ord
          rid = input[start_pos..pos]
          pos += 1

          if existing = tracked[rid]?
            existing_end_x = printable_width(input[last_newline...start_pos]) - 1
            existing_end_y = newlines
            zones << ZoneInfo.new(id: rid, iteration: iteration, start_x: existing.start_x, start_y: existing.start_y, end_x: existing_end_x, end_y: existing_end_y)
            tracked.delete(rid)
          else
            tracked[rid] = ZoneInfo.new(
              id: rid,
              iteration: iteration,
              start_x: printable_width(input[last_newline...start_pos]),
              start_y: newlines
            )
          end
          next
        end
        result << input[start_pos...pos]
        next
      elsif bytes[pos] == '\n'.ord
        newlines += 1
        last_newline = pos + 1
        result << '\n'
      else
        result << input[pos].chr
      end
      pos += 1
    end

    {result.to_s, zones}
  end

  private def printable_width(s : String) : Int32
    n = 0
    in_esc = false
    s.each_char do |c|
      if c == '\e'
        in_esc = true
      elsif in_esc
        in_esc = false if (c >= '@' && c <= 'z') || c == '~'
      else
        n += 1 unless c == '\n'
      end
    end
    n
  end

  def any_in_bounds(mouse : Mouse) : Array(ZoneInfo)
    result = [] of ZoneInfo
    @zones.values.sort_by(&.id).each do |zone|
      result << zone if zone.in_bounds?(mouse)
    end
    result
  end
end
