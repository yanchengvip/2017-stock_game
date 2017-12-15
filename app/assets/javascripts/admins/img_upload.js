/**
 * Created by iuzuan on 2017/3/20.
 */
$(function () {

    //缩略图添加
    $('#add_product_thumb').fileupload({
        dataType: 'json',
        url:'/admins/images/add_img',
        accept: 'application/json',
        sequentialUploads: true,
        //maxFileSize: 5000000, //5mb
        add: function(e,data){
            if(data.originalFiles[0]['size'] > 100000){
                alert('图片最大为100k')
            }else{
                data.submit();
            }

        },
        complete: function(result, textStatus, jqXHR){
            var data = JSON.parse(result.responseText)
            $("#head_image_url").val(data.url)
            $("#preview_product_thumb").attr('src',data.url)
        }

    });


    //添加产品展示图
    $('#add_product_imgs').fileupload({
        dataType: 'json',
        url:'/admins/images/add_img',
        accept: 'application/json',
        sequentialUploads: true,
        //maxFileSize: 5000000, //5mb
        add: function(e,data){
            if(data.originalFiles[0]['size'] > 100000){
                alert('图片最大为100k')
            }else{
                data.submit();
            }

        },
        complete: function(result, textStatus, jqXHR){
            var pro_image_urls = $('#pro_image_urls').val()
            var data = JSON.parse(result.responseText)

            if (pro_image_urls.split(',').length > 4){
                alert('展示图最多5张')
                return
            }
            var img = $("<img >").attr('src',data.url)
            $('#preview_product_imgs').append(img)

            if (pro_image_urls == ""){
                $('#pro_image_urls').val(data.url)
            }else{
                img_url = pro_image_urls + "," +  data.url
                $('#pro_image_urls').val(img_url)
            }

        }

    });


});