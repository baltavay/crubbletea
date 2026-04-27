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
  end

  describe ".strip" do
    it "removes ANSI escape sequences" do
      Crubbletea::Lipgloss::ANSI.strip("\e[1mhello\e[0m").should eq("hello")
    end

    it "returns plain text unchanged" do
      Crubbletea::Lipgloss::ANSI.strip("hello").should eq("hello")
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
  end
end
