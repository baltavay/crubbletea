require "../lipgloss"
require "./key"

module Crubbletea::Bubbles::List
  abstract class Item
    abstract def title : String
    abstract def description : String

    def filter_value : String
      title.downcase + " " + description.downcase
    end
  end

  class StringItem < Item
    getter title : String
    getter description : String

    def initialize(@title : String, @description : String = "")
    end
  end

  struct Styles
    getter title : Lipgloss::Style
    getter title_item : Lipgloss::Style
    getter desc : Lipgloss::Style
    getter selected_title : Lipgloss::Style
    getter selected_desc : Lipgloss::Style
    getter cursor : Lipgloss::Style
    getter pagination : Lipgloss::Style
    getter help : Lipgloss::Style
    getter status_bar : Lipgloss::Style
    getter status_bar_filter : Lipgloss::Style
    getter filter_prompt : Lipgloss::Style

    def initialize(
      @title : Lipgloss::Style = Lipgloss::Style.new,
      @title_item : Lipgloss::Style = Lipgloss::Style.new,
      @desc : Lipgloss::Style = Lipgloss::Style.new,
      @selected_title : Lipgloss::Style = Lipgloss::Style.new,
      @selected_desc : Lipgloss::Style = Lipgloss::Style.new,
      @cursor : Lipgloss::Style = Lipgloss::Style.new,
      @pagination : Lipgloss::Style = Lipgloss::Style.new,
      @help : Lipgloss::Style = Lipgloss::Style.new,
      @status_bar : Lipgloss::Style = Lipgloss::Style.new,
      @status_bar_filter : Lipgloss::Style = Lipgloss::Style.new,
      @filter_prompt : Lipgloss::Style = Lipgloss::Style.new
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
    getter filter : Key::Binding
    getter clear_filter : Key::Binding
    getter help : Key::Binding

    def initialize(
      @up : Key::Binding = Key::Binding.new(keys: ["up", "k"]),
      @down : Key::Binding = Key::Binding.new(keys: ["down", "j"]),
      @prev_page : Key::Binding = Key::Binding.new(keys: ["pgup", "left", "h"]),
      @next_page : Key::Binding = Key::Binding.new(keys: ["pgdown", "right", "l"]),
      @enter : Key::Binding = Key::Binding.new(keys: ["enter"]),
      @quit : Key::Binding = Key::Binding.new(keys: ["q", "ctrl+c"]),
      @filter : Key::Binding = Key::Binding.new(keys: ["/"]),
      @clear_filter : Key::Binding = Key::Binding.new(keys: ["escape"]),
      @help : Key::Binding = Key::Binding.new(keys: ["?"])
    )
    end
  end
end

class Crubbletea::Bubbles::List::ListModel
  getter items : Array(Item)
  getter index : Int32
  getter width : Int32
  getter height : Int32
  getter styles : Styles
  getter key_map : KeyMap
  getter cursor : String
  getter infinite : Bool
  getter filter : String
  getter filtering : Bool
  getter title : String

  @visible_items : Array(Item)
  @offset : Int32
  @per_page : Int32

  def initialize(
    @items : Array(Item) = [] of Item,
    @index : Int32 = 0,
    @width : Int32 = 20,
    @height : Int32 = 10,
    @styles : Styles = Styles.new,
    @key_map : KeyMap = KeyMap.new,
    @cursor : String = ">",
    @infinite : Bool = false,
    @filter : String = "",
    @filtering : Bool = false,
    @title : String = ""
  )
    @visible_items = @items
    @offset = 0
    @per_page = {@height, 1}.max
  end

  def selected : Item?
    @visible_items[@index]?
  end

  def items=(items : Array(Item)) : Nil
    @items = items
    apply_filter
  end

  def set_size(w : Int32, h : Int32) : Nil
    @width = w
    @height = h
    @per_page = {@height, 1}.max
  end

  def select(idx : Int32) : Nil
    @index = {0, {idx, @visible_items.size - 1}.min}.max
  end

  def cursor_up : Nil
    if @index > 0
      @index -= 1
    elsif @infinite && @visible_items.size > 0
      @index = @visible_items.size - 1
    end
    adjust_offset
  end

  def cursor_down : Nil
    if @index < @visible_items.size - 1
      @index += 1
    elsif @infinite && @visible_items.size > 0
      @index = 0
    end
    adjust_offset
  end

  def prev_page : Nil
    @index -= @per_page
    @index = 0 if @index < 0
    adjust_offset
  end

  def next_page : Nil
    @index += @per_page
    @index = @visible_items.size - 1 if @index >= @visible_items.size
    adjust_offset
  end

  def toggle_filter : Nil
    @filtering = !@filtering
    @filter = "" unless @filtering
  end

  def update(msg : Crubbletea::Msg) : {ListModel, Item?, Crubbletea::Cmd}
    selected_item = nil
    cmd : Crubbletea::Cmd = nil

    case msg
    when Crubbletea::KeyPressMsg
      key = msg.key
      key_str = key.to_s

      if @filtering
        case
        when key_str == "enter"
          @filtering = false
          apply_filter
        when key_str == "escape"
          @filtering = false
          @filter = ""
          apply_filter
        when key_str == "backspace"
          @filter = @filter[0...-1] if @filter.size > 0
          apply_filter
        when !key.text.empty? && !key.ctrl?
          @filter += key.text
          apply_filter
        end
      else
        case
        when matches?(key, @key_map.up)
          cursor_up
        when matches?(key, @key_map.down)
          cursor_down
        when matches?(key, @key_map.prev_page)
          prev_page
        when matches?(key, @key_map.next_page)
          next_page
        when matches?(key, @key_map.enter)
          selected_item = selected
        when matches?(key, @key_map.filter)
          toggle_filter
        when matches?(key, @key_map.clear_filter)
          @filter = ""
          apply_filter
        end
      end
    end

    {self, selected_item, cmd}
  end

  def view : String
    parts = [] of String

    unless @title.empty?
      parts << @styles.title.render(@title)
    end

    items_view = [] of String
    visible_end = {@offset + @per_page, @visible_items.size}.min

    (@offset...visible_end).each do |i|
      item = @visible_items[i]?
      next unless item

      if i == @index
        cursor_str = @styles.cursor.render(@cursor + " ")
        title_str = @styles.selected_title.render(item.title)
        desc_str = @styles.selected_desc.render(item.description)
      else
        cursor_str = " " * Lipgloss::ANSI.string_width(@cursor + " ")
        title_str = @styles.title_item.render(item.title)
        desc_str = @styles.desc.render(item.description)
      end

      line = cursor_str + title_str
      unless desc_str.empty?
        line += "\n" + (" " * Lipgloss::ANSI.string_width(@cursor + " ")) + desc_str
      end
      items_view << line
    end

    parts << items_view.join('\n') unless items_view.empty?

    if @filtering
      parts << @styles.filter_prompt.render("/" + @filter + "█")
    end

    parts.join('\n')
  end

  private def apply_filter : Nil
    if @filter.empty?
      @visible_items = @items
    else
      @visible_items = @items.select { |item| item.filter_value.includes?(@filter.downcase) }
    end
    @index = 0
    @offset = 0
  end

  private def adjust_offset : Nil
    if @index < @offset
      @offset = @index
    elsif @index >= @offset + @per_page
      @offset = @index - @per_page + 1
    end
  end

  private def matches?(key : Crubbletea::Key, binding : Key::Binding) : Bool
    return false unless binding.enabled?
    key_str = key.to_s
    binding.keys.includes?(key_str)
  end
end
