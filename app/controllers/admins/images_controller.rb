class Admins::ImagesController < Admins::ApplicationController
  before_action :set_image, only: [:show, :edit, :update, :destroy]
  #skip_before_action :verify_authenticity_token


  def index
    @images = Image.all
  end

  def new
    @image = Image.new
  end

  def create
    uploader = ImageUploader.new
    uploader.store!(params[:file])
    url = uploader.url

    image = Image.new(url: url)
    image.save!
    render json: {image_id: image.id, image_url: image.url}
  end


  def pro_thumb_upload
    uploader = ImageUploader.new
    uploader.store!(params[:file])
    url = uploader.url
    render json: {image_url: url}
  end


  def update_img
    #flag 1=缩略图修改，2=修改展示图，3=添加展示图
    flag = params[:flag].to_i
    id = params[:id]
    uploader = ImageUploader.new
    uploader.store!(params[:file])

    url = uploader.url
    if flag == 1
      @product = Product.find(id)
      @product.update_attributes({head_image: url})
    elsif flag == 2
      @image = Image.find(id)
      @image.update_attributes({url: url})

    elsif flag == 3
      @product = Product.find(id)
      @product.images.create(url: url)
    end

    render json: {status: 'ok'}
  end


  #添加商品时调用
  def add_img
    uploader = ImageUploader.new
    uploader.store!(params[:file])
    render json: {url: uploader.url}
  end

  def destroy
    @image.destroy
    respond_to do |format|
      format.html { redirect_to images_url, notice: 'Image was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_image
    @image = Image.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def image_params
    params.require(:image).permit(:url, :name, :content_size, :table_id, :table_type)
  end

  def image_upload_params
    params.permit(:url, :name, :content_size, :table_id, :table_type)
  end
end
