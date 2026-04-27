require "../lipgloss"

module Crubbletea::Lipgloss::Tree
  alias StyleFunc = Proc(Children, Int32, Style)
  alias EnumeratorFn = Proc(Children, Int32, String)
  alias IndenterFn = Proc(Children, Int32, String)

  def self.default_enumerator(children : Children, index : Int32) : String
    if children.length - 1 == index
      "└──"
    else
      "├──"
    end
  end

  def self.rounded_enumerator(children : Children, index : Int32) : String
    if children.length - 1 == index
      "╰──"
    else
      "├──"
    end
  end

  def self.default_indenter(children : Children, index : Int32) : String
    if children.length - 1 == index
      "   "
    else
      "│  "
    end
  end

  abstract class Node
    abstract def value : String
    abstract def children : Children
    abstract def hidden? : Bool
    abstract def hidden=(v : Bool)

    def to_s : String
      value
    end
  end

  class Children
    getter nodes : Array(Node)

    def initialize(@nodes = [] of Node)
    end

    def length : Int32
      @nodes.size
    end

    def at(index : Int32) : Node?
      @nodes[index]?
    end

    def append(node : Node) : Children
      Children.new(@nodes + [node])
    end

    def remove(index : Int32) : Children
      return self if index < 0 || index >= @nodes.size
      Children.new(@nodes[0...index] + @nodes[(index + 1)..])
    end
  end

  class Leaf < Node
    @value : String
    @hidden : Bool

    def initialize(@value = "", @hidden = false)
    end

    def value : String
      @value
    end

    def children : Children
      Children.new
    end

    def hidden? : Bool
      @hidden
    end

    def hidden=(v : Bool)
      @hidden = v
    end
  end

  class TreeNode < Node
    @value : String
    @hidden : Bool
    @children : Children
    @enumerator_style : StyleFunc
    @indenter_style : StyleFunc
    @item_style : StyleFunc
    @root_style : Style
    @enumerator : EnumeratorFn
    @indenter : IndenterFn
    @tree_width : Int32

    def initialize
      @value = ""
      @hidden = false
      @children = Children.new
      @enumerator_style = ->(c : Children, i : Int32) { Style.new.padding_right(1) }
      @indenter_style = ->(c : Children, i : Int32) { Style.new.padding_right(1) }
      @item_style = ->(c : Children, i : Int32) { Style.new }
      @root_style = Style.new
      @enumerator = ->default_enumerator(Children, Int32)
      @indenter = ->default_indenter(Children, Int32)
      @tree_width = 0
    end

    def value : String
      @value
    end

    def children : Children
      @children
    end

    def hidden? : Bool
      @hidden
    end

    def hidden=(v : Bool)
      @hidden = v
    end

    def root(v : String) : TreeNode
      @value = v
      self
    end

    def child(*items : Node | String) : TreeNode
      items.each do |item|
        case item
        when String
          @children = @children.append(Leaf.new(item))
        when Node
          @children = @children.append(item)
        end
      end
      self
    end

    def enumerator_style(s : Style) : TreeNode
      @enumerator_style = ->(c : Children, i : Int32) { s }
      self
    end

    def indenter_style(s : Style) : TreeNode
      @indenter_style = ->(c : Children, i : Int32) { s }
      self
    end

    def item_style(s : Style) : TreeNode
      @item_style = ->(c : Children, i : Int32) { s }
      self
    end

    def root_style(s : Style) : TreeNode
      @root_style = s
      self
    end

    def enumerator(e : EnumeratorFn) : TreeNode
      @enumerator = e
      self
    end

    def indenter(i : IndenterFn) : TreeNode
      @indenter = i
      self
    end

    def width(w : Int32) : TreeNode
      @tree_width = w
      self
    end

    def to_s : String
      render_node(self, true, "")
    end

    private def render_node(node : Node, is_root : Bool, prefix : String) : String
      return "" if node.hidden?

      parts = [] of String
      node_children = node.children

      if (v = node.value) && !v.empty? && is_root
        line = @root_style.render(v)
        if @tree_width > 0
          lw = Lipgloss.width(line)
          if @tree_width > lw
            line = v + " " * (@tree_width - lw)
            line = @root_style.render(line)
          end
        end
        parts << line
      end

      visible = [] of Node
      node_children.length.times do |i|
        n = node_children.at(i)
        visible << n if n && !n.hidden?
      end

      vc = Children.new(visible)
      visible.each_with_index do |child_node, i|
        enum_str = @enumerator.call(vc, i)
        enum_rendered = @enumerator_style.call(vc, i).render(enum_str)

        item_rendered = @item_style.call(vc, i).render(child_node.value)

        child_str = child_node.is_a?(TreeNode) ? render_node(child_node, false, prefix + @indenter_style.call(vc, i).render(@indenter.call(vc, i))) : ""
        parts << prefix + enum_rendered + item_rendered
        parts << child_str unless child_str.empty?
      end

      parts.join('\n')
    end
  end

  def self.new_tree : TreeNode
    TreeNode.new
  end

  def self.root(v : String) : TreeNode
    TreeNode.new.root(v)
  end
end
