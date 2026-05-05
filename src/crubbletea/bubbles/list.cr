require "../lipgloss"
require "./key"
require "./help"
require "./textinput"

module Crubbletea::Bubbles::List
  enum FilterState
    Unfiltered
    Filtering
    FilterApplied
  end

  abstract class Item
    abstract def title : String
    abstract def description : String

    def filter_value : String
      title.downcase
    end
  end

  class StringItem < Item
    getter title : String
    getter description : String

    def initialize(@title : String, @description : String = "")
    end
  end

  struct Styles
    getter title_bar : Lipgloss::Style
    getter title : Lipgloss::Style
    getter status_bar : Lipgloss::Style
    getter status_empty : Lipgloss::Style
    getter status_bar_filter_count : Lipgloss::Style
    getter divider_dot : Lipgloss::Style
    getter pagination : Lipgloss::Style
    getter help : Lipgloss::Style
    getter normal_title : Lipgloss::Style
    getter normal_desc : Lipgloss::Style
    getter selected_title : Lipgloss::Style
    getter selected_desc : Lipgloss::Style
    getter dimmed_title : Lipgloss::Style
    getter dimmed_desc : Lipgloss::Style
    getter filter_match : Lipgloss::Style
    getter active_pagination_dot : Lipgloss::Style
    getter inactive_pagination_dot : Lipgloss::Style
    getter filter_prompt : Lipgloss::Style
    getter help_key : Lipgloss::Style
    getter help_desc : Lipgloss::Style
    getter help_separator : Lipgloss::Style

    def initialize(
      @title_bar : Lipgloss::Style = Lipgloss::Style.new.padding(0, 0, 1, 2),
      @title : Lipgloss::Style = Lipgloss::Style.new.background("62").foreground("230").padding(0, 1),
      @status_bar : Lipgloss::Style = Lipgloss::Style.new.foreground("#777777").padding(0, 0, 1, 2),
      @status_empty : Lipgloss::Style = Lipgloss::Style.new.foreground("#5C5C5C"),
      @status_bar_filter_count : Lipgloss::Style = Lipgloss::Style.new.foreground("#3C3C3C"),
      @divider_dot : Lipgloss::Style = Lipgloss::Style.new.foreground("#3C3C3C"),
      @pagination : Lipgloss::Style = Lipgloss::Style.new.padding(0, 0, 0, 2),
      @help : Lipgloss::Style = Lipgloss::Style.new.padding(1, 0, 0, 2),
      @normal_title : Lipgloss::Style = Lipgloss::Style.new.foreground("#dddddd").padding(0, 0, 0, 2),
      @normal_desc : Lipgloss::Style = Lipgloss::Style.new.foreground("#777777").padding(0, 0, 0, 2),
      @selected_title : Lipgloss::Style = Lipgloss::Style.new
        .border(Lipgloss::Border.normal, [false, false, false, true])
        .border_foreground("#AD58B4")
        .foreground("#EE6FF8")
        .padding(0, 0, 0, 1),
      @selected_desc : Lipgloss::Style = Lipgloss::Style.new
        .border(Lipgloss::Border.normal, [false, false, false, true])
        .border_foreground("#AD58B4")
        .foreground("#AD58B4")
        .padding(0, 0, 0, 1),
      @dimmed_title : Lipgloss::Style = Lipgloss::Style.new.foreground("#777777").padding(0, 0, 0, 2),
      @dimmed_desc : Lipgloss::Style = Lipgloss::Style.new.foreground("#4D4D4D").padding(0, 0, 0, 2),
      @filter_match : Lipgloss::Style = Lipgloss::Style.new.underline(true),
      @active_pagination_dot : Lipgloss::Style = Lipgloss::Style.new.foreground("#979797"),
      @inactive_pagination_dot : Lipgloss::Style = Lipgloss::Style.new.foreground("#3C3C3C"),
      @filter_prompt : Lipgloss::Style = Lipgloss::Style.new.foreground("#ECFD65"),
      @help_key : Lipgloss::Style = Lipgloss::Style.new.foreground("#626262"),
      @help_desc : Lipgloss::Style = Lipgloss::Style.new.foreground("#4A4A4A"),
      @help_separator : Lipgloss::Style = Lipgloss::Style.new.foreground("#3C3C3C")
    )
    end
  end

  struct KeyMap
    getter up : Key::Binding
    getter down : Key::Binding
    getter prev_page : Key::Binding
    getter next_page : Key::Binding
    getter enter : Key::Binding
    getter quit : Key::Binding
    getter go_to_start : Key::Binding
    getter go_to_end : Key::Binding
    getter filter : Key::Binding
    getter clear_filter : Key::Binding
    getter cancel_while_filtering : Key::Binding
    getter accept_while_filtering : Key::Binding
    getter show_full_help : Key::Binding
    getter close_full_help : Key::Binding

    def initialize(
      @up : Key::Binding = Key::Binding.new(keys: ["up", "k"], help_key: "↑/k", help_desc: "up"),
      @down : Key::Binding = Key::Binding.new(keys: ["down", "j"], help_key: "↓/j", help_desc: "down"),
      @prev_page : Key::Binding = Key::Binding.new(keys: ["left", "h", "pgup", "b", "u"], help_key: "←/h/pgup", help_desc: "prev page"),
      @next_page : Key::Binding = Key::Binding.new(keys: ["right", "l", "pgdown", "f", "d"], help_key: "→/l/pgdn", help_desc: "next page"),
      @enter : Key::Binding = Key::Binding.new(keys: ["enter"], help_key: "enter", help_desc: "select"),
      @quit : Key::Binding = Key::Binding.new(keys: ["q", "escape"], help_key: "q", help_desc: "quit"),
      @go_to_start : Key::Binding = Key::Binding.new(keys: ["home", "g"], help_key: "g/home", help_desc: "go to start"),
      @go_to_end : Key::Binding = Key::Binding.new(keys: ["end", "G"], help_key: "G/end", help_desc: "go to end"),
      @filter : Key::Binding = Key::Binding.new(keys: ["/"], help_key: "/", help_desc: "filter"),
      @clear_filter : Key::Binding = Key::Binding.new(keys: ["escape"], help_key: "esc", help_desc: "clear filter"),
      @cancel_while_filtering : Key::Binding = Key::Binding.new(keys: ["escape"], help_key: "esc", help_desc: "cancel"),
      @accept_while_filtering : Key::Binding = Key::Binding.new(keys: ["enter", "tab"], help_key: "enter", help_desc: "apply filter"),
      @show_full_help : Key::Binding = Key::Binding.new(keys: ["?"], help_key: "?", help_desc: "more"),
      @close_full_help : Key::Binding = Key::Binding.new(keys: ["?"], help_key: "?", help_desc: "close help")
    )
    end
  end
end

class Crubbletea::Bubbles::List::ListModel
  include Crubbletea::Bubbles::Help::KeyMap

  getter items : Array(Item)
  getter width : Int32
  getter height : Int32
  getter styles : Styles
  getter key_map : KeyMap
  getter infinite : Bool
  getter title : String
  getter show_status_bar : Bool
  getter show_pagination : Bool
  getter show_help : Bool
  getter help_show_all : Bool
  getter item_height : Int32
  getter item_spacing : Int32
  getter selected_prefix : String
  getter normal_prefix : String
  getter additional_short_help_keys : Array(Key::Binding)
  getter additional_full_help_keys : Array(Array(Key::Binding))
  getter filter_input : Crubbletea::Bubbles::TextInput::Model
  getter filter_state : FilterState
  getter filtering_enabled : Bool

  @visible_items : Array(Item)
  @filter_matched_indices : Array(Array(Int32))
  @status_message : String
  @cursor : Int32
  @page : Int32
  @per_page : Int32
  @total_pages : Int32

  def initialize(
    @items : Array(Item) = [] of Item,
    initial_index : Int32 = 0,
    @width : Int32 = 20,
    @height : Int32 = 10,
    @styles : Styles = Styles.new,
    @key_map : KeyMap = KeyMap.new,
    @infinite : Bool = false,
    @title : String = "",
    @show_status_bar : Bool = true,
    @show_pagination : Bool = true,
    @show_help : Bool = true,
    @help_show_all : Bool = false,
    @filtering_enabled : Bool = true,
    @item_height : Int32 = 2,
    @item_spacing : Int32 = 1,
    @selected_prefix : String = "",
    @normal_prefix : String = "",
    @additional_short_help_keys : Array(Key::Binding) = [] of Key::Binding,
    @additional_full_help_keys : Array(Array(Key::Binding)) = [] of Array(Key::Binding)
  )
    @visible_items = @items
    @filter_matched_indices = [] of Array(Int32)
    @status_message = ""
    @cursor = 0
    @page = 0
    @per_page = 1
    @total_pages = 1
    @filter_state = FilterState::Unfiltered
    @filter_input = Crubbletea::Bubbles::TextInput::Model.new(
      prompt: "Filter: ",
      prompt_style: @styles.filter_prompt,
      char_limit: 64
    )
    update_pagination
    update_keybindings
    do_select(initial_index)
  end

  def filter : String
    @filter_input.value
  end

  def filtering? : Bool
    @filter_state == FilterState::Filtering
  end

  def filter_applied? : Bool
    @filter_state == FilterState::FilterApplied
  end

  def status_message=(msg : String) : Nil
    @status_message = msg
  end

  def status_message : String
    @status_message
  end

  def index : Int32
    @page * @per_page + @cursor
  end

  private def max_cursor_index : Int32
    start = @page * @per_page
    items_on_page = {@per_page, @visible_items.size - start}.min
    {items_on_page, 1}.max - 1
  end

  private def measured_height(s : String) : Int32
    Lipgloss::ANSI.string_width(s) == 0 ? 0 : s.count('\n') + 1
  end

  def selected : Item?
    idx = index
    return nil if idx >= @visible_items.size
    @visible_items[idx]?
  end

  def items=(items : Array(Item)) : Nil
    @items = items
    apply_filter
  end

  def set_size(w : Int32, h : Int32) : Nil
    @width = w
    @height = h
    update_pagination
    update_keybindings
  end

  def select(idx : Int32) : Nil
    do_select(idx)
  end

  private def do_select(idx : Int32) : Nil
    return if @visible_items.empty?
    idx = {0, {idx, @visible_items.size - 1}.min}.max
    @page = @per_page > 0 ? idx // @per_page : 0
    @cursor = @per_page > 0 ? idx % @per_page : 0
    clamp_page
  end

  def cursor_up : Nil
    @cursor -= 1
    if @cursor < 0 && @page == 0
      if @infinite && @visible_items.size > 0
        cursor_end
        return
      end
      @cursor = 0
      return
    end
    return if @cursor >= 0
    @page -= 1
    @cursor = max_cursor_index
  end

  def cursor_down : Nil
    mci = max_cursor_index
    @cursor += 1
    return if @cursor <= mci
    if @page < @total_pages - 1
      @page += 1
      @cursor = 0
      return
    end
    @cursor = {mci, 0}.max
    if @infinite && @visible_items.size > 0
      cursor_start
    end
  end

  def prev_page : Nil
    return if @page <= 0
    @page -= 1
    @cursor = {@cursor, max_cursor_index}.min
  end

  def next_page : Nil
    return if @page >= @total_pages - 1
    @page += 1
    @cursor = {@cursor, max_cursor_index}.min
  end

  def cursor_start : Nil
    @page = 0
    @cursor = 0
  end

  def cursor_end : Nil
    @page = {0, @total_pages - 1}.max
    @cursor = max_cursor_index
  end

  private def update_keybindings : Nil
    case @filter_state
    when FilterState::Filtering
      @key_map.up.enabled = false
      @key_map.down.enabled = false
      @key_map.next_page.enabled = false
      @key_map.prev_page.enabled = false
      @key_map.go_to_start.enabled = false
      @key_map.go_to_end.enabled = false
      @key_map.filter.enabled = false
      @key_map.clear_filter.enabled = false
      @key_map.cancel_while_filtering.enabled = true
      @key_map.accept_while_filtering.enabled = !@filter_input.value.empty?
      @key_map.quit.enabled = false
      @key_map.show_full_help.enabled = false
      @key_map.close_full_help.enabled = false
    else
      has_items = !@items.empty?
      @key_map.up.enabled = has_items
      @key_map.down.enabled = has_items
      has_pages = @total_pages > 1
      @key_map.next_page.enabled = has_pages
      @key_map.prev_page.enabled = has_pages
      @key_map.go_to_start.enabled = has_items
      @key_map.go_to_end.enabled = has_items
      @key_map.filter.enabled = @filtering_enabled && has_items
      @key_map.clear_filter.enabled = filter_applied?
      @key_map.cancel_while_filtering.enabled = false
      @key_map.accept_while_filtering.enabled = false
      @key_map.quit.enabled = true
      @key_map.show_full_help.enabled = true
      @key_map.close_full_help.enabled = true
    end
  end

  def short_help : Array(Key::Binding)
    bindings = [
      @key_map.up,
      @key_map.down,
    ] of Key::Binding
    bindings.concat(@additional_short_help_keys) unless filtering?
    bindings << @key_map.filter
    bindings << @key_map.clear_filter
    bindings << @key_map.accept_while_filtering
    bindings << @key_map.cancel_while_filtering
    bindings << @key_map.quit
    bindings << @key_map.show_full_help
    bindings
  end

  def full_help : Array(Array(Key::Binding))
    groups = [
      [
        @key_map.up,
        @key_map.down,
        @key_map.next_page,
        @key_map.prev_page,
        @key_map.go_to_start,
        @key_map.go_to_end,
      ] of Key::Binding,
    ] of Array(Key::Binding)
    groups.concat(@additional_full_help_keys) unless filtering?
    list_bindings = [
      @key_map.filter,
      @key_map.clear_filter,
      @key_map.accept_while_filtering,
      @key_map.cancel_while_filtering,
    ] of Key::Binding
    groups << list_bindings
    groups << [
      @key_map.quit,
      @key_map.close_full_help,
    ] of Key::Binding
    groups
  end

  def update(msg : Crubbletea::Msg) : {ListModel, Item?, Crubbletea::Cmd}
    selected_item = nil
    cmd : Crubbletea::Cmd = nil

    case msg
    when Crubbletea::KeyPressMsg
      key = msg.key

      if @filter_state == FilterState::Filtering
        cmd = handle_filtering(msg)
      else
        cmd = handle_browsing(msg)
        if matches?(key, @key_map.enter)
          selected_item = selected
        end
      end
    end

    {self, selected_item, cmd}
  end

  private def handle_browsing(msg : Crubbletea::Msg) : Crubbletea::Cmd
    case msg
    when Crubbletea::KeyPressMsg
      key = msg.key
      case
      when matches?(key, @key_map.clear_filter)
        reset_filtering
      when matches?(key, @key_map.quit)
        return Crubbletea.quit
      when matches?(key, @key_map.up)
        cursor_up
      when matches?(key, @key_map.down)
        cursor_down
      when matches?(key, @key_map.prev_page)
        prev_page
      when matches?(key, @key_map.next_page)
        next_page
      when matches?(key, @key_map.go_to_start)
        cursor_start
      when matches?(key, @key_map.go_to_end)
        cursor_end
      when matches?(key, @key_map.filter)
        enter_filter
        return nil
      when matches?(key, @key_map.show_full_help)
        @help_show_all = !@help_show_all
        update_pagination
      when matches?(key, @key_map.close_full_help)
        @help_show_all = !@help_show_all
        update_pagination
      end
    end
    nil
  end

  private def handle_filtering(msg : Crubbletea::Msg) : Crubbletea::Cmd
    case msg
    when Crubbletea::KeyPressMsg
      key = msg.key
      case
      when matches?(key, @key_map.cancel_while_filtering)
        reset_filtering
        update_keybindings
        return nil
      when matches?(key, @key_map.accept_while_filtering)
        if @items.empty?
          return nil
        end
        if @visible_items.empty?
          reset_filtering
          update_keybindings
          return nil
        end
        @filter_input.blur
        @filter_state = FilterState::FilterApplied
        if @filter_input.value.empty?
          reset_filtering
          update_keybindings
          return nil
        end
        update_pagination
        update_keybindings
        return nil
      end
    end

    old_val = @filter_input.value
    @filter_input, input_cmd = @filter_input.update(msg)

    if @filter_input.value != old_val
      apply_filter
      @key_map.accept_while_filtering.enabled = !@filter_input.value.empty?
    end
    input_cmd
  end

  private def enter_filter : Nil
    return unless @filtering_enabled
    @status_message = ""
    cursor_start
    @filter_state = FilterState::Filtering
    @filter_input.focus
    @filter_input.cursor_end
    @filter_matched_indices = @items.map { |_| [] of Int32 }
    @visible_items = @items
    update_keybindings
  end

  private def reset_filtering : Nil
    return if @filter_state == FilterState::Unfiltered
    @filter_input = Crubbletea::Bubbles::TextInput::Model.new(
      prompt: "Filter: ",
      prompt_style: @styles.filter_prompt,
      char_limit: 64
    )
    @filter_state = FilterState::Unfiltered
    @filter_matched_indices = [] of Array(Int32)
    @visible_items = @items
    @cursor = 0
    @page = 0
    update_pagination
    update_keybindings
  end

  private def highlight_matches(text : String, matched_indices : Array(Int32)) : String
    return text if matched_indices.empty?

    chars = text.chars
    parts = [] of String
    i = 0
    while i < chars.size
      if matched_indices.includes?(i)
        start = i
        while i < chars.size && matched_indices.includes?(i)
          i += 1
        end
        parts << @styles.filter_match.inline(true).render(chars[start...i].join)
      else
        start = i
        while i < chars.size && !matched_indices.includes?(i)
          i += 1
        end
        parts << chars[start...i].join
      end
    end
    parts.join
  end

  def view : String
    sections = [] of String
    avail_height = @height

    title_view = build_title_view
    unless title_view.empty?
      sections << title_view
      avail_height -= measured_height(title_view)
    end

    status_view = build_status_view
    unless status_view.empty?
      sections << status_view
      avail_height -= measured_height(status_view)
    end

    pagination_view = ""
    if @show_pagination
      pagination_view = build_pagination_view
      unless pagination_view.empty?
        avail_height -= measured_height(pagination_view)
      end
    end

    help_view = ""
    if @show_help
      help_model = Help::HelpModel.new(
        show_all: @help_show_all,
        width: @width,
        styles: Help::Styles.new(
          short_key: @styles.help_key,
          short_desc: @styles.help_desc,
          short_separator: @styles.help_separator,
          full_key: @styles.help_key,
          full_desc: @styles.help_desc,
          full_separator: @styles.help_separator
        )
      )
      help_view = @styles.help.render(help_model.view(self))
      avail_height -= measured_height(help_view)
    end

    content = populated_view(avail_height)
    if avail_height > 0
      sections << content
    end

    sections << pagination_view unless pagination_view.empty?
    sections << help_view unless help_view.empty?

    Lipgloss.join_vertical(Lipgloss::Style::Pos::Left, sections)
  end

  private def populated_view(avail_height : Int32) : String
    items = @visible_items

    if items.empty?
      if @filter_state == FilterState::Filtering
        return ""
      end
      return @styles.status_empty.render("No items.")
    end

    start_idx = @page * @per_page
    end_idx = {start_idx + @per_page, items.size}.min
    global_idx = index
    is_filtering = @filter_state == FilterState::Filtering
    is_filtered = @filter_state == FilterState::Filtering || @filter_state == FilterState::FilterApplied
    empty_filter = is_filtering && @filter_input.value.empty?

    lines = [] of String

    (start_idx...end_idx).each do |i|
      item = items[i]?
      next unless item

      title_text = item.title
      desc_text = item.description

      matched_indices = [] of Int32
      if is_filtered && i < @filter_matched_indices.size
        matched_indices = @filter_matched_indices[i]
      end

      title_str = if empty_filter
        @styles.dimmed_title.render(title_text)
      elsif i == global_idx && !is_filtering
        if is_filtered && !matched_indices.empty?
          @styles.selected_title.render(highlight_matches(title_text, matched_indices))
        else
          raw = @selected_prefix + title_text
          @styles.selected_title.render(raw)
        end
      else
        if is_filtered && !matched_indices.empty?
          @styles.normal_title.render(highlight_matches(title_text, matched_indices))
        else
          raw = @normal_prefix + title_text
          @styles.normal_title.render(raw)
        end
      end

      if @item_height > 1 && !desc_text.empty?
        desc_str = if empty_filter
          @styles.dimmed_desc.render(desc_text)
        elsif i == global_idx && !is_filtering
          @styles.selected_desc.render(desc_text)
        else
          @styles.normal_desc.render(desc_text)
        end
        lines << "#{title_str}\n#{desc_str}"
      else
        lines << title_str
      end
    end

    content = lines.join("\n" * (@item_spacing + 1))

    items_count = end_idx - start_idx
    if items_count < @per_page
      trailing = @per_page - items_count
      content += "\n" * (trailing * (@item_height + @item_spacing))
    end

    content
  end

  private def build_title_view : String
    return "" if @title.empty? && @filter_state != FilterState::Filtering

    if @filtering_enabled && @filter_state == FilterState::Filtering
      return @styles.title_bar.render(@filter_input.view)
    end

    return "" if @title.empty?

    view = @styles.title.render(@title)
    if !@status_message.empty? && @filter_state != FilterState::Filtering
      view += "  " + @status_message
    end
    @styles.title_bar.render(view)
  end

  private def build_status_view : String
    return "" unless @show_status_bar

    visible = @visible_items.size
    total = @items.size
    word = visible == 1 ? "item" : "items"

    status = if @filter_state == FilterState::Filtering
      if visible == 0
        @styles.status_empty.render("Nothing matched")
      else
        "#{visible} #{word}"
      end
    elsif total == 0
      @styles.status_empty.render("No items")
    elsif filter_applied?
      f = @filter_input.value
      f = f[0...10] + "…" if f.size > 10
      "\"#{f}\" #{visible} #{word}"
    else
      "#{visible} #{word}"
    end

    num_filtered = total - visible
    if num_filtered > 0
      status += @styles.divider_dot.render(" • ")
      status += @styles.status_bar_filter_count.render("#{num_filtered} filtered")
    end

    @styles.status_bar.render(status)
  end

  private def build_pagination_view : String
    return "" if @total_pages < 2

    dots = @total_pages.times.map do |i|
      dot = "•"
      if i == @page
        @styles.active_pagination_dot.render(dot)
      else
        @styles.inactive_pagination_dot.render(dot)
      end
    end.join

    style = @styles.pagination
    if @item_spacing == 0
      style = style.margin(1, 0, 0, 0)
    end

    style.render(dots)
  end

  private def update_pagination : Nil
    saved_idx = index

    fixed_overhead = 0
    unless @title.empty?
      fixed_overhead += measured_height(@styles.title_bar.render(@styles.title.render(@title)))
    end
    if @show_status_bar
      count = @visible_items.size
      word = count == 1 ? "item" : "items"
      fixed_overhead += measured_height(@styles.status_bar.render("#{count} #{word}"))
    end
    help_overhead = 0
    if @show_help
      help_overhead = measured_height(@styles.help.render("help"))
    end

    prev_total = 0
    5.times do
      avail = @height - fixed_overhead - help_overhead
      if @show_pagination && @total_pages > 1
        pag_style = @styles.pagination
        pag_style = pag_style.margin(1, 0, 0, 0) if @item_spacing == 0
        dots = {@total_pages, 1}.max.times.map { "•" }.join
        avail -= measured_height(pag_style.render(dots))
      end
      @per_page = {avail // {@item_height + @item_spacing, 1}.max, 1}.max
      set_total_pages
      break if @total_pages == prev_total
      prev_total = @total_pages
    end

    clamp_page
    saved_idx = {saved_idx, {@visible_items.size - 1, 0}.max}.min
    @page = @per_page > 0 ? saved_idx // @per_page : 0
    @cursor = @per_page > 0 ? saved_idx % @per_page : 0
    clamp_page
  end

  private def set_total_pages : Nil
    n = @visible_items.size
    if n < 1
      @total_pages = 1
    else
      pages = n // @per_page
      pages += 1 if n % @per_page > 0
      @total_pages = pages
    end
  end

  private def clamp_page : Nil
    if @page >= @total_pages
      @page = {0, @total_pages - 1}.max
    end
    mci = max_cursor_index
    if @cursor > mci
      @cursor = mci
    end
  end

  private def apply_filter : Nil
    val = @filter_input.value
    if val.empty?
      @visible_items = @items
      @filter_matched_indices = @items.map { |_| [] of Int32 }
    else
      lower_val = val.downcase
      @visible_items = [] of Item
      @filter_matched_indices = [] of Array(Int32)
      @items.each do |item|
        fv = item.filter_value
        indices = [] of Int32
        fv.chars.each_with_index do |c, i|
          indices << i if lower_val.includes?(c.downcase)
        end
        if fv.downcase.includes?(lower_val)
          title_lower = item.title.downcase
          match_positions = [] of Int32
          search_start = 0
          lower_val.chars.each do |fc|
            pos = title_lower.index(fc, search_start)
            if pos
              match_positions << pos
              search_start = pos + 1
            end
          end
          @visible_items << item
          @filter_matched_indices << match_positions
        end
      end
    end
    @cursor = 0
    @page = 0
    update_pagination
  end

  private def matches?(key : Crubbletea::Key, binding : Key::Binding) : Bool
    return false unless binding.enabled?
    key_str = key.to_s
    binding.keys.includes?(key_str)
  end
end

module Crubbletea::Bubbles::List
  alias Model = ListModel
end
