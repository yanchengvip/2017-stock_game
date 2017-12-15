module Admins::ProductsHelper


  #判断商品对应的夺宝是否已经开始
  def product_is_lottery product
    if product.lotteries.pluck(:status).include?(1) || product.lotteries.pluck(:status).include?(2)
      return true
    end

    product.lotteries.each do |lottery|
      if lottery.published_at.to_i <= Time.now.to_i
        return true
      end
    end

    return false

  end


  #赠送钻币的夺宝商品
  def product_type_send_diamond_num product
      return product.diamond_num.to_i if product.present?
      return 500 if !product.present?
  end

  def is_product_type_send_diamond product
      if product.present? && product.product_second_type == 1
        return 'checked'
      end
    return ''
  end
end