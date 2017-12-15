class Admins::ProductsController < Admins::ApplicationController
  #authorize_resource
  #authorize_resource :class => false #如果controller不存在model
  before_action :set_product, only: [:edit, :update_product, :destroy_product]
  before_action :set_product_menu_active
  before_action :product_side_menus
  #skip_before_filter :verify_authenticity_token,only: [:destroy_product]

  def index

    @products = Product.includes(:lotteries, :ranking_config_items,:product_tag)
                    .where(product_type: 1)
                    .order('created_at desc')
                    .paginate(:page => params[:page], :per_page => 30)
  end

  def new
    @product_tags = ProductTag.all
    @admin_product = Product.new
  end


  def search
    @products = Product.where(product_type: 1)
                    .order('created_at desc')
                    .ransack(name_cont: params[:name]).result.page(params[:page])

    render template: '/admins/products/index'
  end


  def show

  end

  def edit
    @product_tags = ProductTag.all
    @is_show_admin_product_layout = true
    @images = @product.images
  end

  def update_product
    params[:lottery_percent] = params[:lottery_percent].to_f / 100
    if !params[:is_type3]
      #不赠送钻币
      params[:diamond_num] = 0
      params[:product_second_type] = 0
    end
    @product.update_attributes(product_not_img_params)
    redirect_to :back, notice: '修改成功！'
  end

  def create
    image_url_array = params[:pro_image_urls].split(',')
    params[:lottery_percent] = params[:lottery_percent].to_f / 100
    if !params[:is_type3]
      #不赠送钻币
      params.delete('diamond_num')
      params.delete('product_second_type')
    end
    @product = Product.new(product_params.merge(product_type: 1))
    @product.save
    image_url_array.each do |img|
      @product.images.create(url: img)
    end
    redirect_to '/admins/products'
  end


  def destroy_product
    @product.destroy
    redirect_to :back
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.includes(:lotteries, :ranking_config_items).find(params[:id])
  end

  def set_product_menu_active
    @menu_active = '商品列表'
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def product_params
    params.permit(:name, :desc, :price, :inventory_count, :detail_url, :head_image, :is_published,
                  :user_id, :postage, :interval, :lottery_percent,:diamond_num,:product_second_type,:product_tag_id)
  end

  def product_not_img_params
    params.permit(:name, :desc, :price, :inventory_count, :detail_url, :is_published, :user_id,
                  :postage, :interval, :lottery_percent,:diamond_num,:product_second_type,:product_tag_id)
  end

end
