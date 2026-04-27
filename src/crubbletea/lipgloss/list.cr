require "../lipgloss"

module Crubbletea::Lipgloss::List
  def self.alphabet : Array(String)
    ("A".."Z").to_a
  end

  def self.arabic : Array(String)
    (1..26).map(&.to_s)
  end

  def self.roman : Array(String)
    ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X",
     "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX",
     "XXI", "XXII", "XXIII", "XXIV", "XXV", "XXVI"]
  end

  def self.bullet : Array(String)
    Array.new(26, "•")
  end

  def self.asterisk : Array(String)
    Array.new(26, "*")
  end

  def self.dash : Array(String)
    Array.new(26, "-")
  end

  def self.numbered(items : Array(String), enumerator : Array(String) = arabic) : String
    items.map_with_index do |item, i|
      enum_str = enumerator[i % enumerator.size]? || "#{i + 1}"
      "#{enum_str}. #{item}"
    end.join('\n')
  end

  def self.bulleted(items : Array(String), bullet : String = "•") : String
    items.map { |item| "#{bullet} #{item}" }.join('\n')
  end
end
