struct Crubbletea::Bubbles::Key::Binding
  getter keys : Array(String)
  getter help_key : String
  getter help_desc : String
  @disabled : Bool

  def initialize(@keys = [] of String, @help_key = "", @help_desc = "", @disabled = false)
  end

  def enabled? : Bool
    !@disabled && !@keys.empty?
  end

  def enabled=(v : Bool)
    @disabled = !v
  end

  def enabled_help : {String, String}?
    return nil unless enabled?
    k = @help_key.empty? ? @keys.first? || "" : @help_key
    d = @help_desc.empty? ? "" : @help_desc
    {k, d}
  end
end

struct Crubbletea::Bubbles::Key::Help
  getter key : String
  getter desc : String

  def initialize(@key = "", @desc = "")
  end
end

module Crubbletea::Bubbles::Key
  def self.new_binding(*keys : String, help_key : String = "", help_desc : String = "") : Binding
    Binding.new(keys.to_a, help_key, help_desc)
  end

  def self.matches(key : Crubbletea::Key, *bindings : Binding) : Bool
    key_str = key.to_s
    bindings.each do |b|
      next unless b.enabled?
      b.keys.each do |k|
        return true if key_str == k
      end
    end
    false
  end

  def self.matches(key : Crubbletea::Key, bindings : Array(Binding)) : Bool
    key_str = key.to_s
    bindings.each do |b|
      next unless b.enabled?
      b.keys.each do |k|
        return true if key_str == k
      end
    end
    false
  end
end
