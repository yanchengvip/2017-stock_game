class Admins::UsersController < Admins::ApplicationController
  before_action :user_side_menus
  before_action :set_user, only: [:add_roles_for_user, :forget_password_update]
  before_action :set_admin, only: [:edit, :admin_update]

  def index

  end

  def new

  end

  def edit

  end

  def admin_update
    s = @admin.update_attributes(admin_params)
    if s == false
      flag = '修改失败'
    else
      flag = '修改成功'
    end
    redirect_to '/admins/users/admins_list', notice: flag
  end

  def create
    @menu_active= '账户管理'
    Admin.create(admin_params)
    redirect_to '/admins/users/admins_list', notice: '创建成功'
  end

  def my_info

  end

  def update_password
    if params[:password] != params[:confirm_password] || !params[:password].present? || !params[:confirm_password].present?
      redirect_to '/admins/users/my_info', notice: '两次密码输入不一致' and return
    end
    flag = current_user.valid_current_password params[:old_password]
    redirect_to '/admins/users/my_info', notice: '当前密码输入错误' and return if !flag
    current_user.update_attributes(encrypted_password: params[:password])
    redirect_to '/admins/users/my_info', notice: '密码修改成功！'
  end

  def forget_password_update
    if params[:password] != params[:confirm_password] || !params[:password].present? || !params[:confirm_password].present?
      redirect_to '/admins/users/users_list', notice: '两次密码输入不一致' and return
    end

    @user.update_attributes({encrypted_password: 'zs123456'})
    redirect_to '/admins/users/users_list', notice: '密码修改成功！'
  end

  def admins_list
    @menu_active= '管理员管理'
    @admins = Admin.paginate(:page => params[:page], :per_page => 20)
  end


  def users_list
    @menu_active= '用户管理'
    conditions = []
    values = []
    if params[:nickname].present?
      conditions << 'phone like ? or nickname like ? '
      values << "%#{params[:nickname]}%"
      values << "%#{params[:nickname]}%"
    end

    if params[:role].present? && params[:role].to_i != 0
      conditions << 'role = ?'
      values << "#{params[:role]}"
    end
    @users = User.includes(:roles).where(conditions.join(' and '), *values)
                 .paginate(:page => params[:page], :per_page => 20)
  end

  def add_roles_for_user
    @user.update_attributes(role: params[:role])
    redirect_to '/admins/users/users_list', notice: '添加角色成功！'
  end


  #生成二维码记录
  def qrcodes
    @menu_active= '二维码管理'
    @qrcodes = Qrcode.where(qrcode_status: 1).includes(:qrcode_scan_records).order('created_at desc').paginate(:page => params[:page], :per_page => 10)
  end

  #永久字符串二维码
  def generate_qrcode
    @menu_active= '二维码管理'
    scene_id = Utils.generate_uuid
    result = Wechat.api.qrcode_create_limit_scene(scene_id)
    @qrcode_url = "https://mp.weixin.qq.com/cgi-bin/showqrcode?ticket=" + result['ticket']
    Qrcode.create(user_name: params[:user_name], qrcode_url: @qrcode_url, ticket: result['ticket'], scene_id: scene_id, qrcode_type: 2)
  end

  def qrcodes_destroy
    Qrcode.find(params[:qrcode_id]).update_attributes(qrcode_status: -1)
    redirect_to '/admins/users/qrcodes'
  end

  private

  def admin_params
    params.permit(:nickname, :encrypted_password, :phone, :role, :status)
  end

  def set_user
    if params[:user_type] == 'admin'
      @user = Admin.find(params[:id])
    elsif params[:user_type] == 'user'
      @user = User.find(params[:id])
    end

  end

  def set_admin
    @admin = Admin.find(params[:id])
  end

end
