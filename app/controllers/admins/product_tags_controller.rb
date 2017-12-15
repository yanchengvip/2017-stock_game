class Admins::ProductTagsController < Admins::ApplicationController
  before_action :set_product_menu_active
  before_action :product_side_menus
  before_action :set_product_tag, only: [:tag_delete,:tag_update]


  def index
    @product_tags = ProductTag.order('sort desc').paginate(:page => params[:page], :per_page => 30)
  end

  def new

  end

  def create
    tag = ProductTag.where(name: params[:name])
    redirect_to '/admins/product_tags', notice: '标签已存在！' and return  if tag.present?
    @pt = ProductTag.new(product_tag_params)
    @pt.save
    redirect_to '/admins/product_tags', notice: '添加成功！'
  end

  def tag_update
    @set_product_tag.update_attributes(product_tag_params)
    redirect_to '/admins/product_tags', notice: '添加成功！'
  end
  def tag_delete
    @set_product_tag.destroy
    redirect_to '/admins/product_tags', notice: '删除成功！'
  end

  private

  def product_tag_params
    params.permit(:name,:sort)
  end

  def set_product_menu_active
    @menu_active = '商品标签'
  end

  def set_product_tag
    @set_product_tag = ProductTag.find(params[:id])
  end


end