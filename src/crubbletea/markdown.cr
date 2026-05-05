module Crubbletea::Markdown
  def self.render(text : String, width : Int32 = 80) : String
    lines = text.split('\n')
    result = [] of String

    in_code_block = false
    code_lines = [] of String

    lines.each do |line|
      if line.starts_with?("```")
        if in_code_block
          code_lines.each do |cl|
            result << "  #{cl}"
          end
          code_lines.clear
          in_code_block = false
        else
          in_code_block = true
        end
        next
      end

      if in_code_block
        code_lines << line
        next
      end

      if line.starts_with?("# ")
        result << Crubbletea::Lipgloss::Style.new.bold(true).foreground("#5f87ff").render(line.lchop("# "))
      elsif line.starts_with?("## ")
        result << Crubbletea::Lipgloss::Style.new.bold(true).foreground("#87afff").render(line.lchop("## "))
      elsif line.starts_with?("### ")
        result << Crubbletea::Lipgloss::Style.new.bold(true).foreground("#afafff").render(line.lchop("### "))
      elsif line.starts_with?("- ")
        result << "  #{Crubbletea::Lipgloss::Style.new.foreground("#87ff87").render("•")} #{line.lchop("- ")}"
      elsif line.starts_with?("> ")
        result << Crubbletea::Lipgloss::Style.new.foreground("#878787").render("  #{line.lchop("> ")}")
      elsif line.match(/^\d+\.\s/)
        result << "  #{line}"
      elsif line.starts_with?("---") || line.starts_with?("___") || line.starts_with?("***")
        result << Crubbletea::Lipgloss::Style.new.foreground("#585858").render("─" * width)
      elsif line.empty?
        result << ""
      else
        result << render_inline(line)
      end
    end

    result.join('\n')
  end

  private def self.render_inline(line : String) : String
    line = line.gsub(/\*\*(.+?)\*\*/) do
      Crubbletea::Lipgloss::Style.new.bold(true).render($1)
    end
    line = line.gsub(/\*(.+?)\*/) do
      Crubbletea::Lipgloss::Style.new.italic(true).render($1)
    end
    line = line.gsub(/`(.+?)`/) do
      Crubbletea::Lipgloss::Style.new.foreground("#ff8700").render($1)
    end
    line = line.gsub(/\[(.+?)\]\((.+?)\)/) do
      Crubbletea::Lipgloss::Style.new.foreground("#5f87ff").underline(true).render($1)
    end
    line
  end
end
