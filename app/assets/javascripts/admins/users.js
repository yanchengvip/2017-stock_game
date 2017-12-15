/**
 * Created by iuzuan on 2017/3/10.
 */
//管理员修改自己的密码
function show_password_modal(){
    $('#updatePasswordModal').modal('show')
}

//修改别人的密码
function show_forget_password_modal(user_id,nickname,phone){
    $('#updateForgetPasswordModal').modal('show')
    $('#updateForgetPasswordModal').on('shown.bs.modal',function(){
        $('#forget_password_user_id').val(user_id)
        $('.reset_password_user_name').html(nickname)
        $('.reset_password_user_phone').html(phone)
    })
}



function add_amdmin_role_for_user_modal(user_id,nickname,phone){
    $('#addAdminRoleForUserModal').modal('show')
    $('#addAdminRoleForUserModal').on('shown.bs.modal',function(){
        $('#add_role_user_id').val(user_id)
        $('.add_role_user_name').html(nickname)
        $('.add_role_user_phone').html(phone)
    })
}
