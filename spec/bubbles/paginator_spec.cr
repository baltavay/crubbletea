require "../spec_helper"

describe Crubbletea::Bubbles::Paginator do
  describe "Model" do
    it "defaults to page 0" do
      p = Crubbletea::Bubbles::Paginator::Model.new
      p.page.should eq(0)
      p.on_first_page?.should be_true
    end

    describe "set_total_pages" do
      it "calculates total pages from items" do
        p = Crubbletea::Bubbles::Paginator::Model.new(per_page: 5)
        p.set_total_pages(12)
        p.total_pages.should eq(3)
      end

      it "handles exact division" do
        p = Crubbletea::Bubbles::Paginator::Model.new(per_page: 5)
        p.set_total_pages(10)
        p.total_pages.should eq(2)
      end

      it "handles less than one page" do
        p = Crubbletea::Bubbles::Paginator::Model.new(per_page: 5)
        p.set_total_pages(3)
        p.total_pages.should eq(1)
      end
    end

    describe "navigation" do
      it "goes to next page" do
        p = Crubbletea::Bubbles::Paginator::Model.new(per_page: 5, total_pages: 3)
        p.next_page
        p.page.should eq(1)
        p.on_first_page?.should be_false
      end

      it "goes to previous page" do
        p = Crubbletea::Bubbles::Paginator::Model.new(per_page: 5, total_pages: 3)
        p.next_page
        p.prev_page
        p.page.should eq(0)
      end

      it "does not go before first page" do
        p = Crubbletea::Bubbles::Paginator::Model.new(per_page: 5, total_pages: 3)
        p.prev_page
        p.page.should eq(0)
      end

      it "does not go past last page" do
        p = Crubbletea::Bubbles::Paginator::Model.new(per_page: 5, total_pages: 3)
        p.next_page
        p.next_page
        p.on_last_page?.should be_true
        p.next_page
        p.page.should eq(2)
      end
    end

    describe "items_on_page" do
      it "returns items on current page" do
        p = Crubbletea::Bubbles::Paginator::Model.new(per_page: 5, total_pages: 3)
        p.set_total_pages(12)
        p.items_on_page(12).should eq(5)
        p.next_page
        p.items_on_page(12).should eq(5)
        p.next_page
        p.items_on_page(12).should eq(2)
      end
    end

    describe "slice_bounds" do
      it "returns correct bounds" do
        p = Crubbletea::Bubbles::Paginator::Model.new(per_page: 5, total_pages: 3)
        p.set_total_pages(12)
        s, e = p.slice_bounds(12)
        s.should eq(0)
        e.should eq(5)

        p.next_page
        s, e = p.slice_bounds(12)
        s.should eq(5)
        e.should eq(10)
      end
    end

    describe "view" do
      it "renders arabic pagination" do
        p = Crubbletea::Bubbles::Paginator::Model.new(per_page: 5, total_pages: 3)
        p.set_total_pages(12)
        p.view.should eq("1/3")
      end

      it "renders dots pagination" do
        p = Crubbletea::Bubbles::Paginator::Model.new(
          type: Crubbletea::Bubbles::Paginator::Model::Type::Dots,
          per_page: 5,
          total_pages: 3
        )
        p.set_total_pages(12)
        p.view.should eq("•○○")

        p.next_page
        p.view.should eq("○•○")
      end
    end

    describe "update" do
      it "navigates with arrow keys" do
        p = Crubbletea::Bubbles::Paginator::Model.new(per_page: 5, total_pages: 3)
        p.set_total_pages(12)

        p, _ = p.update(Crubbletea::KeyPressMsg.new(Crubbletea::Key.new(code: Crubbletea::Key::Code::Right)))
        p.page.should eq(1)

        p, _ = p.update(Crubbletea::KeyPressMsg.new(Crubbletea::Key.new(code: Crubbletea::Key::Code::Left)))
        p.page.should eq(0)
      end
    end
  end
end
