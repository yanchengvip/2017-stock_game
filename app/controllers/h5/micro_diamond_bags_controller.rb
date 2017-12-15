class H5::MicroDiamondBagsController < ApplicationController
  before_action :set_micro_diamond_bag, only: [:show, :open, :micro_diamond_bag_items]
  skip_before_action :verify_signature

  #红包列表
  def index
    params[:page] ||= 1
    @micro_diamond_bags = $cache.fetch("micro_diamond_bags_index_#{params[:page]}", 60 ){
      MicroDiamondBag.where("published_at < '#{Time.now.to_s}' and status in (0, 1)" ).paginate(:page => params[:page] || 1)
    }
    respond_to do |format|
      format.html {}
      format.json {render json: {data: {micro_diamond_bags: @micro_diamond_bags}, status: 200}}
    end
  end

  #往期红包列表
  def old_bags
    params[:page] ||= 1
    @micro_diamond_bags = $cache.fetch("micro_diamond_bags_old_bags_#{params[:page]}", 60 ){
      MicroDiamondBag.includes(:micro_diamond_bag_items).where(status: 2, "micro_diamond_bag_items.user_id" => current_user.id).paginate(:page => params[:page] || 1)
    }
    respond_to do |format|
      format.html
      format.json {render json: {data: {micro_diamond_bags: @micro_diamond_bags}, status: 200}}
    end
  end

  #红包详情
  def show
    respond_to do |format|
      format.html
      format.json {render json: {data: {micro_diamond_bag: @micro_diamond_bag}, status: 200}}
    end
  end

  #红包开奖明细
  def micro_diamond_bag_items
    micro_diamond_bag_items = @micro_diamond_bag.micro_diamond_bag_items.paginate(:page => params[:page] || 1)
    render json: {status: 200, data: {micro_diamond_bag_items: micro_diamond_bag_items}}
  end

  #开红包
  def open
    @open_result = @micro_diamond_bag.open_result(current_user, request)
    render json: {data: {micro_diamond_bag: @micro_diamond_bag, open_result: @open_result}, status: 200}
  end

  private
  def set_micro_diamond_bag
    @micro_diamond_bag = MicroDiamondBag.find(params[:id])
  end
end
