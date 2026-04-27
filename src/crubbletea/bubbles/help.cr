require "../lipgloss"
require "./key"

module Crubbletea::Bubbles::Help
  struct Styles
    getter short_key : Lipgloss::Style
    getter short_desc : Lipgloss::Style
    getter short_separator : Lipgloss::Style
    getter full_key : Lipgloss::Style
    getter full_desc : Lipgloss::Style
    getter full_separator : Lipgloss::Style
    getter ellipsis : Lipgloss::Style

    def initialize(
      @short_key : Lipgloss::Style = Lipgloss::Style.new,
      @short_desc : Lipgloss::Style = Lipgloss::Style.new,
      @short_separator : Lipgloss::Style = Lipgloss::Style.new,
      @full_key : Lipgloss::Style = Lipgloss::Style.new,
      @full_desc : Lipgloss::Style = Lipgloss::Style.new,
      @full_separator : Lipgloss::Style = Lipgloss::Style.new,
      @ellipsis : Lipgloss::Style = Lipgloss::Style.new
    )
    end
  end

  module KeyMap
    abstract def short_help : Array(Key::Binding)
    abstract def full_help : Array(Array(Key::Binding))
  end

  struct HelpModel
    getter show_all : Bool
    getter short_separator : String
    getter full_separator : String
    getter ellipsis : String
    getter styles : Styles
    getter width : Int32

    def initialize(
      @show_all : Bool = false,
      @short_separator : String = " • ",
      @full_separator : String = "    ",
      @ellipsis : String = "…",
      @styles : Styles = Styles.new,
      @width : Int32 = 0
    )
    end

    def update(msg : Crubbletea::Msg) : {HelpModel, Crubbletea::Cmd}
      {self, nil}
    end

    def view(km : KeyMap) : String
      if @show_all
        full_help_view(km.full_help)
      else
        short_help_view(km.short_help)
      end
    end

    def short_help_view(bindings : Array(Key::Binding)) : String
      return "" if bindings.empty?

      parts = [] of String
      total_width = 0

      bindings.each_with_index do |b, i|
        next unless b.enabled?

        sep = ""
        if total_width > 0 && i < bindings.size
          sep = @styles.short_separator.inline(true).render(@short_separator)
        end

        str = sep +
          @styles.short_key.inline(true).render(b.help_key) + " " +
          @styles.short_desc.inline(true).render(b.help_desc)

        w = Lipgloss::ANSI.string_width(str)

        if @width > 0 && total_width + w > @width
          tail = " " + @styles.ellipsis.inline(true).render(@ellipsis)
          if total_width + Lipgloss::ANSI.string_width(tail) < @width
            parts << tail
          end
          break
        end

        total_width += w
        parts << str
      end

      parts.join
    end

    def full_help_view(groups : Array(Array(Key::Binding))) : String
      return "" if groups.empty?

      cols = [] of String
      total_width = 0

      groups.each_with_index do |group, i|
        next if group.empty?

        keys = [] of String
        descs = [] of String
        group.each do |b|
          next unless b.enabled?
          keys << b.help_key
          descs << b.help_desc
        end
        next if keys.empty?

        sep = ""
        if total_width > 0 && i < groups.size
          sep = @styles.full_separator.inline(true).render(@full_separator)
        end

        col = Lipgloss.join_horizontal(Lipgloss::Style::Pos::Top, [
          sep,
          @styles.full_key.render(keys.join('\n')),
          "   ",
          @styles.full_desc.inline(true).render(descs.join('\n')),
        ])

        w = Lipgloss.width(col)

        if @width > 0 && total_width + w > @width
          tail = " " + @styles.ellipsis.inline(true).render(@ellipsis)
          if total_width + Lipgloss::ANSI.string_width(tail) < @width
            cols << tail
          end
          break
        end

        total_width += w
        cols << col
      end

      Lipgloss.join_horizontal(Lipgloss::Style::Pos::Top, cols)
    end
  end
end
