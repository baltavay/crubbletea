require "spec"
require "../spec_helper"

{% for name in [
  "altscreen-toggle", "autocomplete", "canvas", "capability", "cellbuffer",
  "chat", "clickable", "colorprofile", "composable-views", "cursor-style",
  "debounce", "doom-fire", "dynamic-textarea", "exec", "eyes",
  "file-picker", "focus-blur", "fullscreen", "glamour", "help",
  "http", "isbn-form", "keyboard-enhancements", "list-default",
  "list-fancy", "list-simple", "mouse", "package-manager", "pager",
  "paginator", "pipe", "prevent-quit", "print-key", "progress-animated",
  "progress-bar", "progress-download", "progress-static", "query-term",
  "realtime", "result", "send-msg", "sequence", "set-terminal-color",
  "set-window-title", "simple", "space", "spinner", "spinners",
  "splash", "split-editors", "stopwatch", "suspend", "table-resize",
  "table", "tabs", "textarea", "textinput", "textinputs", "timer",
  "tui-daemon-combo", "vanish", "views", "window-size"
] %}
  require "../../examples/{{name.id}}/main.cr"
{% end %}

describe "example compilation" do
  {% for name in [
    "altscreen-toggle", "autocomplete", "canvas", "capability", "cellbuffer",
    "chat", "clickable", "colorprofile", "composable-views", "cursor-style",
    "debounce", "doom-fire", "dynamic-textarea", "exec", "eyes",
    "file-picker", "focus-blur", "fullscreen", "glamour", "help",
    "http", "isbn-form", "keyboard-enhancements", "list-default",
    "list-fancy", "list-simple", "mouse", "package-manager", "pager",
    "paginator", "pipe", "prevent-quit", "print-key", "progress-animated",
    "progress-bar", "progress-download", "progress-static", "query-term",
    "realtime", "result", "send-msg", "sequence", "set-terminal-color",
    "set-window-title", "simple", "space", "spinner", "spinners",
    "splash", "split-editors", "stopwatch", "suspend", "table-resize",
    "table", "tabs", "textarea", "textinput", "textinputs", "timer",
    "tui-daemon-combo", "vanish", "views", "window-size"
  ] %}
    it "{{name.id}} compiles" do
      true.should be_true
    end
  {% end %}
end
