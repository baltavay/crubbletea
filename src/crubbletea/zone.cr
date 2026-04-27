require "./zone/manager"

module Crubbletea::Zone
  @@default_manager : Manager?

  def self.default_manager : Manager
    @@default_manager ||= Manager.new
  end

  def self.new_global : Nil
    @@default_manager ||= Manager.new
  end

  def self.mark(id : String, value : String) : String
    default_manager.mark(id, value)
  end

  def self.scan(view : String) : String
    default_manager.scan(view)
  end

  def self.get(id : String) : ZoneInfo?
    default_manager.get(id)
  end

  def self.clear(id : String) : Nil
    default_manager.clear(id)
  end

  def self.new_prefix : String
    default_manager.new_prefix
  end

  def self.enabled? : Bool
    default_manager.enabled?
  end

  def self.enabled=(v : Bool)
    default_manager.enabled = v
  end
end
