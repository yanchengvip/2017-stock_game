#resource_type 0:无，1：前端H5权限资源，2：后台权限资源
class Resource < ApplicationRecord
  after_save :clear_cache

  #获取权限资源
  def self.get_resources resource_type
    $cache.fetch('user_permission_resources', 2*60*60) {
      Resource.select(:model_n, :controller_n, :action_n).where(status: 1, resource_type: resource_type).as_json
    }

  end

  #获取项目所有controller名称转换为类似model,例如Admins::LotteryOrdersController->LotteryOrder
  def self.controller_transfer_model
    all_controller = all_controller_names
    h5_arr,h5_cons_hash = model_arr all_controller[:h5],'h5'
    admin_arr,admin_cons_hash = model_arr all_controller[:admin],'admin'
    cons_hash = h5_cons_hash.merge(admin_cons_hash)
    {h5_model_arr: h5_arr, admin_modle_arr: admin_arr,controller_hash: cons_hash}
  end


  #Admins::LotteryOrdersController -> admins/lottery_orders
  def self.get_all_controllers
    all_controller = all_controller_names
    h5_arr = controller_to_route (all_controller[:h5])
    admin_arr = controller_to_route (all_controller[:admin])
    {h5: h5_arr, admin: admin_arr}
  end

  def self.get_all_actions
    all_controller = all_controller_names
    h5_action = controller_key_action_value all_controller[:h5]
    admin_action = controller_key_action_value all_controller[:admin]
    h5_action.merge(admin_action)
  end

  def self.transfer_controller_to_string
    all_controller = all_controller_names
  end

  def self.all_controller_names
    Rails.application.eager_load!
    h5_controllers = ApplicationController.descendants
    admin_controllers = Admins::ApplicationController.descendants
    {h5: h5_controllers, admin: admin_controllers}
  end

  #清除缓存
  def clear_cache
    $cache.delete("user_permission_resources")
  end

  private

  def self.model_arr controller_arr,type
    m_arr = []
    cons_hash = {}
    controller_arr.each do |con|
      c = con.to_s.split("::")
      if c.size >= 2
        c = c[1].underscore.split('_')
      else
        c = c[0].underscore.split('_')
      end
      c.pop
      c = c.join('_').singularize.camelize
      con_temp = controller_to_route "#{type+'_'+c}",con
      cons_hash = cons_hash.merge con_temp
      m_arr << c
    end
    return m_arr,cons_hash
  end

  def self.controller_to_route key=nil,controller
    a_hash = {}

    con_arr = controller.to_s.split("::")
    if con_arr.size >= 2
      c = con_arr[1].underscore.split('_')
      c.pop
      perfix = con_arr[0].underscore
      c = perfix + '/' +c.join('_')
    else
      c = con_arr[0].underscore.split('_')
      c.pop
      c = c.join('_')
    end
    a_hash["#{key}"] = c

    return a_hash
  end

  def self.controller_key_action_value controller_arr
    a_hash = {}
    controller_arr.each do |con|
      con_arr = con.to_s.split("::")
      if con_arr.size >= 2
        c = con_arr[1].underscore.split('_')
        c.pop
        perfix = con_arr[0].underscore
        c = perfix + '/' +c.join('_')
      else
        c = con_arr[0].underscore.split('_')
        c.pop
        c = c.join('_')
      end
      actions_names = con.action_methods.to_a
      a_hash["#{c}"] = actions_names
    end
    return a_hash
  end
end