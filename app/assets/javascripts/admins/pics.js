/**
 * Created by iuzuan on 2017/3/2.
 */



//修改展示图片modal
function showUpdateImgModal(id, flag) {
    //flag，1=修改缩略图，2=修改展示图，3=添加展示图，flag=1，3时，id为prodcut的id,flag=2时为image的id
    $("#updatePicModal").modal('show')
    $("#updatePicModal").on('show.bs.modal', function () {
        $('#update_img_pre').attr('src', '')

    })

    $("#updatePicModal").on('shown.bs.modal', function () {

        $('#update_id').val(id)
        $('#flag').val(flag)
    })
}


//图片修改
$(function () {

    $('#fileupload').fileupload({
        dataType: 'json',
        accept: 'application/json',
        //maxFileSize: 5000000, //5mb

        add: function (e, data) {
            if (data.originalFiles[0]['size'] > 100000) {
                alert('图片最大为100k')
            } else {

                if (data.files && data.files[0]) {
                    var reader = new FileReader();
                    reader.onload = function (e) {
                        $('#update_img_pre').attr('src', e.target.result);
                    }
                    reader.readAsDataURL(data.files[0]);
                }

                $("#update_img_submit").on("click", function () {
                    data.formData = $("#fileupload").serializeArray();
                    data.submit();
                    return false;
                });
            }
        },
        complete: function (result, textStatus, jqXHR) {
            location.reload()
        }

    });

});