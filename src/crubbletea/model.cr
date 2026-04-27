module Crubbletea::Model
  abstract def init
  abstract def update(msg)
  abstract def view : View
end
