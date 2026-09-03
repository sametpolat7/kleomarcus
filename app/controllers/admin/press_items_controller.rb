class Admin::PressItemsController < Admin::BaseController
  before_action :set_press_item, only: %i[edit update destroy]

  def index
    @pagy, @press_items = pagy(PressItem.ordered)
  end

  def new
    @press_item = PressItem.new
  end

  def create
    @press_item = PressItem.new(press_item_params)

    if @press_item.save
      redirect_to admin_press_items_path, notice: "Basın kaydı oluşturuldu."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    if @press_item.update(press_item_params)
      redirect_to admin_press_items_path, notice: "Basın kaydı güncellendi."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @press_item.destroy
    redirect_to admin_press_items_path, notice: "Basın kaydı silindi.", status: :see_other
  end

  private

  def set_press_item
    @press_item = PressItem.find(params[:id])
  end

  def press_item_params
    params.expect(press_item: [ :publisher, :publisher_kind, :headline, :url, :archive_url, :published_on, :byline, :quote, :published ])
  end
end
