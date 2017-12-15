class Admins::SessionsController < Admins::ApplicationController
  skip_before_action :authenticate_user

   def index
    #登录

   end

  def logout
      session[:admin_id] = ''
      redirect_to '/admins/login'
  end

  #登录
  def create

    if  params["phone"]  && params["password"]

      if admin = Admin.login(params["phone"], params["password"])

        if admin.status.to_i != 1
          redirect_to '/admins/login', notice: '管理员被禁用，没有登录权限！' and return
        end
        if admin.role.to_i == 2
          #管理员
          session[:admin_id] = admin.id
          admin.update_attributes(request_ip: request.remote_ip)
          redirect_to SYSTEMCONFIG[:host] + '/admins/products' and return

        end
        redirect_to '/admins/login', notice: '用户不是管理员，没有登录权限！' and return
      end

    end

    redirect_to '/admins/login', notice: '用户名或密码错误！'

  end



end
