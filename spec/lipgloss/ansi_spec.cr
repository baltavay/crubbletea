require "../spec_helper"

describe Crubbletea::Lipgloss::ANSI do
  describe ".string_width" do
    it "returns 0 for empty string" do
      Crubbletea::Lipgloss::ANSI.string_width("").should eq(0)
    end

    it "counts visible characters" do
      Crubbletea::Lipgloss::ANSI.string_width("hello").should eq(5)
    end

    it "excludes CSI sequences" do
      Crubbletea::Lipgloss::ANSI.string_width("\e[1mhello\e[0m").should eq(5)
    end

    it "excludes 256-color sequences" do
      Crubbletea::Lipgloss::ANSI.string_width("\e[38;5;196mtest\e[0m").should eq(4)
    end

    it "excludes true-color sequences" do
      Crubbletea::Lipgloss::ANSI.string_width("\e[38;2;255;0;0mtest\e[0m").should eq(4)
    end

    it "counts CJK characters as width 2" do
      Crubbletea::Lipgloss::ANSI.string_width("你好").should eq(4)
    end

    it "counts Japanese katakana as width 2" do
      Crubbletea::Lipgloss::ANSI.string_width("あ").should eq(2)
    end

    it "counts Korean as width 2" do
      Crubbletea::Lipgloss::ANSI.string_width("한").should eq(2)
    end

    it "counts braille characters as width 1" do
      Crubbletea::Lipgloss::ANSI.string_width("⣾").should eq(1)
    end

    it "counts braille with trailing space correctly" do
      Crubbletea::Lipgloss::ANSI.string_width("⣾ ").should eq(2)
    end

    it "handles mixed ASCII and CJK" do
      Crubbletea::Lipgloss::ANSI.string_width("ab你好cd").should eq(8)
    end

    it "handles mixed styled CJK" do
      Crubbletea::Lipgloss::ANSI.string_width("\e[1m你好\e[0m").should eq(4)
    end

    it "counts box drawing as width 1" do
      Crubbletea::Lipgloss::ANSI.string_width("││").should eq(2)
    end

    it "handles unicode emoji as width 2" do
      Crubbletea::Lipgloss::ANSI.string_width("😀").should eq(2)
    end

    it "handles tabs" do
      width = Crubbletea::Lipgloss::ANSI.string_width("\t")
      width.should be >= 0
    end

    it "string_width returns max line width" do
      Crubbletea::Lipgloss::ANSI.string_width("hi\nhello").should eq(5)
    end
  end

  describe ".strip" do
    it "removes ANSI escape sequences" do
      Crubbletea::Lipgloss::ANSI.strip("\e[1mhello\e[0m").should eq("hello")
    end

    it "returns plain text unchanged" do
      Crubbletea::Lipgloss::ANSI.strip("hello").should eq("hello")
    end

    it "removes true-color sequences" do
      Crubbletea::Lipgloss::ANSI.strip("\e[38;2;95;135;255mtext\e[0m").should eq("text")
    end

    it "removes 256-color sequences" do
      Crubbletea::Lipgloss::ANSI.strip("\e[38;5;196mtext\e[0m").should eq("text")
    end

    it "removes multiple sequences" do
      Crubbletea::Lipgloss::ANSI.strip("\e[1m\e[38;2;255;0;0mhello\e[0m").should eq("hello")
    end
  end

  describe ".truncate" do
    it "returns string unchanged if within width" do
      Crubbletea::Lipgloss::ANSI.truncate("hello", 10).should eq("hello")
    end

    it "truncates to max width" do
      Crubbletea::Lipgloss::ANSI.truncate("hello world", 5).should start_with("hello")
    end

    it "handles empty string" do
      Crubbletea::Lipgloss::ANSI.truncate("", 5).should eq("")
    end

    it "preserves ANSI codes when truncating" do
      result = Crubbletea::Lipgloss::ANSI.truncate("\e[1mhello world\e[0m", 5)
      result.should contain("\e[1m")
      Crubbletea::Lipgloss::ANSI.string_width(result).should be <= 5
    end
  end

  describe ".wrap" do
    it "wraps long lines" do
      result = Crubbletea::Lipgloss::ANSI.wrap("hello world foo bar", 10)
      lines = result.split('\n')
      lines.size.should be > 1
    end

    it "leaves short lines unchanged" do
      Crubbletea::Lipgloss::ANSI.wrap("hello", 10).should eq("hello")
    end

    it "handles multiline input" do
      result = Crubbletea::Lipgloss::ANSI.wrap("hello\nworld", 10)
      lines = result.split('\n')
      lines.size.should eq(2)
    end
  end
end
