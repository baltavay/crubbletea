require "../../src/crubbletea"

class PaginatorModel
  include Crubbletea::Model

  getter items : Array(String)
  getter paginator : Crubbletea::Bubbles::Paginator::Model

  def initialize
    @items = (1..100).map { |i| "Item #{i}" }
    active_dot = Crubbletea::Lipgloss::Style.new
      .foreground("252")
      .render("•")
    inactive_dot = Crubbletea::Lipgloss::Style.new
      .foreground("238")
      .render("•")
    @paginator = Crubbletea::Bubbles::Paginator::Model.new(
      type: Crubbletea::Bubbles::Paginator::Model::Type::Dots,
      per_page: 10,
      total_pages: (@items.size / 10.0).ceil.to_i,
      active_dot: active_dot,
      inactive_dot: inactive_dot
    )
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {PaginatorModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "q", "escape", "ctrl+c"
        return {self, Crubbletea.quit}
      end
    end

    @paginator, cmd = @paginator.update(msg)
    {self, cmd}
  end

  def view : Crubbletea::View
    s = String::Builder.new
    s << "\n  Paginator Example\n\n"

    start_idx, end_idx = @paginator.slice_bounds(@items.size)
    @items[start_idx...end_idx].each do |item|
      s << "  • #{item}\n\n"
    end

    s << "  " << @paginator.view
    s << "\n\n  h/l ←/→ page • q: quit\n"

    Crubbletea.new_view(s.to_s)
  end
end

program = Crubbletea::Program(PaginatorModel).new(PaginatorModel.new)
program.run
