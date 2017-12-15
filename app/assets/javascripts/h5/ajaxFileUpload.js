/**
 * Created by Zl on 2017/3/7.
 */

$.ajaxFileUpload({
  url: 'http://localhost:8080/HNUST/crawler/ordinary2',
  type: 'post',
  data : {
    url : url,
    keyword : keyword,
    rule : rule,
    data : data,
    sign:sign
  },
  secureuri: false, //一般设置为false
  fileElementId: 'file', // 上传文件的id、name属性名
  dataType: 'JSON', //返回值类型，一般设置为json、application/json  这里要用大写  不然会取不到返回的数据
  success: function(data, status){
    alert(data);
  },
  error: function(data, status, e){
    alert(e);
  }
});