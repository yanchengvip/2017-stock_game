class H5::ProductsController < ::ApplicationController
  before_action :set_product, only: [:show]
  skip_before_action :verify_signature
  skip_before_filter :verify_authenticity_token
  #skip_before_filter :verify_authenticity_token,only: [:destroy_product]

  def show
    @lottery = Lottery.first
  end

  private
  def set_product
    @product = Product.find(params[:id])
  end
end
