class Public::PressItemsController < Public::BaseController
  def index
    @press_items_by_year = PressItem.visible.by_year
  end
end
