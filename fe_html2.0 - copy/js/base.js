/*loading*/

var Sheight;
$(function() {
  /*带底色背景选项卡切换效果*/
  /*$('.tab-box .tab-btn').on('click',function(){
    $(this).addClass('active').siblings().removeClass('active');
    var idx = $(this).index()
    $($(".tab-content .tab-lister")[idx]).show().siblings().hide();
    $($(".tab-content .tab-btner")[idx]).show().siblings().hide();
  })*/

  // $(".Voice-prompt").on("click",function(){
  //   alertTx("验证码将通过语音电话通知到您，请注意接听");
  // })

  // 设置0元夺宝页图片大小为正方形
  $(".bodygray .Ind-left").css({
    height: $(".bodygray .Ind-left").width()
  });


  /*页面底部--footer*/
  $(".body-box").parents("html").css("height","inherit");

  /*$(".body-box").append("<div class='img-pre'></div>");
  $(".bodygray").append("<div class='img-pre'></div>");*/

  /*首页底部跳转*/
  /*$('body').on("click",".footer>ul>li",function(){
    $(this).addClass("active");
    $(this).siblings().removeClass("active");
  })*/

  //隐藏弹框
  $(document).on('click', '.hidden', function () {
    unalertTx()
  })
})

  //99+
function overflow_num(overNum){
  if(overNum > 99){
    overNum = 99 + '+';
  }
  return overNum;
}


 //字符串截取
// function filter_String(s){
//   var Length = s.length;

//   if(typeof(s) !="string"){
//     s = s.toString(s);
//   }
//   if((Length>0) && (Length<3)){
//     s = s.substr(0,1) + '**';
//   }
//   else if(Length >= 3){
//     s = s.substr(0,1) + '**' + s.substr(Length-1,1);
//   }
//   else{
//     s = "";
//   }
//   return s;
// }

// 验证输入数据格式
function DataValidation(){
  $("body").on("blur", "input", function (e) {
    if($(this).attr("maxlength") != null){
      if($(this).val().length > parseInt($(this).attr("maxlength"))){
        $(this).val($(this).val().substr(0, parseInt($(this).attr("maxlength")) ));
      }
    }
    if($(this).attr("type") == 'number'){
      $(this).val($(this).val().replace(/[^\d]/g, ''));
    }
    if($(this).attr("type") == 'tel'){
      $(this).val($(this).val().replace(/\D/g,''));
    }
  })


  /*$("body").on("blur", "input", function () {
    var regphone = /^1[34578]\d{9}$/;   /!*手机号验证*!/
    var regzipCode= /^[1-9][0-9]{5}$/;   /!*邮编验证*!/

    var textVal = $(this).val();
    if(textVal != ""){
      if($(this).attr("type") == "tel"){
        if(!(regphone.test(textVal))){
          alertTx("请输入正确手机号！");
        }
      }
      if($(this).attr("class") == "zipCode"){
        if(!(regzipCode.test(textVal))){
          alertTx("请输入正确邮编！");
        }
      }
    }
  })*/

  $(".Onclick-event").on("click",function(){

    if(!($(".Agreement>span").hasClass("Check-mark"))){
      alertTx("请阅读《用户协议》");
    }
    /*if($("input").val() == ""){
      alertTx("输入框不能为空！");
    }*/
  })
}

/*微信分享弹框*/
$(document).on("click", ".wechat" ,function() {
  Sheight=$('body').scrollTop();
  $('body').append($('<div class="wechat-share-bg"><div class="wechat-share"></div></div>'));
  $('body').addClass('PostionFixed');
  $('body').css({
    top:Sheight*-1+'px' ,
  });
  img_class = $(this).attr("data-img")
  if($('#share_btn').attr('value') == 'jingong' && !img_class){
      //进贡邀请好友弹出框
      img_class = "friend-cricle-box"
  }
  if(!img_class){
    img_class = "index-box"
  }
  $('.wechat-share').addClass(img_class)
  /*关闭——微信分享弹框*/
  $(".wechat-share-bg").on("click", function () {
    wechatClose();
  });
  function wechatClose(){
    $(".wechat-share-bg").hide();
    $('body').removeClass('PostionFixed');
    $('body').removeAttr("style");
    $('body').scrollTop(Sheight);
  }
})

/*浏览器复制当前页链接*/

  function UrlCopy(selector,text, callback){

    var btn = $('#' + selector);
    btn.attr('data-clipboard-text',text);
    var clipboard = new Clipboard(btn[0]);

    clipboard.on('success', function(e) {
      if(callback){
        alertTx("分享链接已复制，"+"<br/>"+"您可以用微信发给好友！", callback);
      }else{
        alertTx("分享链接已复制，"+"<br/>"+"您可以用微信发给好友！");
      }
    });

    clipboard.on('error', function(e) {
      alertTx("当前浏览器不支持复制，请手动复制！");
    });
  }


  /*判断微信打开or浏览器打开*/
/*function is_weixn(){
  var ua = navigator.userAgent.toLowerCase();
  if(ua.match(/MicroMessenger/i)=="micromessenger") {
    is_weixin_share()
  } else {
    UrlCopy('btn',document.URL);
  }
}
is_weixn()*/


/*})*/



/*显示*/
  function lockPage() {
    $('.lock-box').show();
    $('body').addClass('PostionFixed');
  }

  /*隐藏*/
  function unlockPage() {
    $('.lock-box').hide();
    $('body').removeClass('PostionFixed');
  }

  /*添加loading*/
  function initLockBox() {
    $('body').append($('<div class="lock-box" id="lock-box"><p></p></div>'));
    $('body').addClass('PostionFixed');
  }
  /*弹框*/
  function Scrollheight(){
    Sheight=$('body').scrollTop();
    $('body').addClass('PostionFixed');
    $('body').css({
      top:Sheight*-1+'px' ,
    });
  }
  function unScrollheight(){
    $('body').removeClass('PostionFixed');
    $('body').removeAttr("style");
    $('body').scrollTop(Sheight);
  }
  function alertTx(msg, callback) {
    Scrollheight()
    $('body').append($('<div class="prompt-box"><div><div class="Close-Right"></div><p>'+msg+'</p><button class="hidden">确认</button></div></div>'));
    $(".hidden").on('click',function(){
      $('.prompt-box').hide();
      unScrollheight()
      if(callback){
        callback()
      }
    })
    $(".Close-Right").on('click',function(){
      $('.prompt-box').hide();
      unScrollheight()
    })
  }
  function alertTxPro(msg, callback) {
    $('body').append($('<div class="prompt-box"><div><div class="Close-Right"></div><p>'+msg+'</p><button class="hidden">确认</button></div></div>'));
    $(".hidden").on('click',function(){
      $('.prompt-box').hide();
      if(callback){
        callback()
      }
    })
    $(".Close-Right").on('click',function(){
      $('.prompt-box').hide();
    })
  }
  /*弹框*/
  function alertYzm(msg, callback) {
    Scrollheight()
    $('body').before($('<div id="tiptxt" class="prompt-box"><div><div class="Close-Right"></div><p>' + msg + '</p><button class="hidden">确认</button></div></div>'));
    $(".hidden").on('click',function(){
      $('.prompt-box').hide();
      if(callback){
        callback()
      }
    })
    $(".Close-Right").on('click',function(){
      $('.prompt-box').hide();
      unScrollheight()
    })
  }

  /*倒计时*/
  function Conutdown(endtime,selector){
  var ConutdownTImer = setInterval(function () {
    var date = new Date();
    var end = new Date(endtime);
    var _time = end - date;
    if(_time<0){

      $(selector).html("00:00:00");
      clearInterval(ConutdownTImer);   //停止执行函数'setInterval()'
      /*return false;*/

      $(selector).parent("p").html("幸运号码计算中...");
      clearInterval(ConutdownTImer)
      return false;

    }
    else{
      var d = Math.floor(_time/1000/60/60/24);
      var h = Math.floor(_time/1000/60/60%24);
      var m = Math.floor(_time/1000/60%60);
      var s = Math.floor(_time/1000%60);
      var ms = Math.floor(_time%1000);

      if(h<10){
        h ='0'+h;
      }
      if(m<10){
        m ='0'+m;
      }
      if(s<10){
        s ='0'+s;
      }
      $(selector).html(h + ":" + m + ":" + s);
    }
    if ($(selector) == undefined) {
      clearInterval(ConutdownTImer);   //停止执行函数'setInterval()'
    };
  },10);

  // setTimeout(function(){
  //   $(selector).removeClass("show-txt")
  // }, 5000)
}
  /*function Conutdown(endtime,timeId){
    timeId = "#"+timeId
    setInterval(function () {
      var date = new Date();
      var end = new Date(endtime);
      var _time = end - date;
      if(_time<0){
        $(timeId).html("00:00:00");
        return false;
      }
      else{
        var d = Math.floor(_time/1000/60/60/24);
        var h = Math.floor(_time/1000/60/60%24);
        var m = Math.floor(_time/1000/60%60);
        var s = Math.floor(_time/1000%60);
        var ms = Math.floor(_time%1000);

        if(h<10){
          h ='0'+h;
        }
        if(m<10){
          m ='0'+m;
        }
        if(s<10){
          s ='0'+s;
        }
        $(timeId).html(h + ":" + m + ":" + s);
      }
    },10)
  }*/


  /*排行榜弹框*/
  function Rankingalert(msg,url,text, callback) {
    Scrollheight()
    $('body').append($('<div class="prompt-box"><div><div class="Close-Right"></div><p>' + msg + '</p><a href="'+url+'" class="hidden">'+text+'</a></div></div>'));
    $(".Close-Right").on('click',function(){
      $('.prompt-box').hide();
      unScrollheight()
    })
  }

  /*隐藏弹框*/
  function unalertTx() {
    // $('.prompt-box').hide();
    // $('body').removeClass('PostionFixed');
  }

  /*首页的冒泡显示*/
  function Bubble(imgsrc, userName, PriceMoney, delay) {//图片地址，用户名称，奖品价格，动画延迟3s标准,2s最小
    $('body > div:nth-child(1)').css('position', 'relative')
    $('body > div').append($('<div class="pro-absolute index-animation">' +
      '<p class="Small-header"><img src="' + imgsrc + '" alt=""></p>' +
      '<p class="Small-user"><span>' + userName + '</span>　获得价值<span class="colorYellow">￥' + PriceMoney + '</span>的商品</p>' +
      '</div>'));
    if (delay < 1) {
      delay = 1;
    }
    for (i = 0; i < $('.index-animation').length; i++) {
      $('.index-animation').eq(i).css('animation-delay', i * delay + 's')
    }
  }

  /*商品页的冒泡显示*/
  function GoodsBubble(imgsrc, userName, Trips,time, delay) {//图片地址，用户名称，参与人次，时间，动画延迟3s标准，2s最小
    $('body > div:nth-child(1)').css('position', 'relative');
    if(time<=0){
      time=1
    }
    $('body > div').append($('<div class="pro-absolute index-animation">' +
      '<p class="Small-header"><img src="' + imgsrc + '" alt=""></p>' +
      '<p class="Small-user"><span>'+userName+'</span>　参加了<span>'+Trips+'</span>人次，<span>'+time+'</span>秒前</p>' +
      '</div>'));
    if (delay < 1) {
      delay = 1;
    }
    for (i = 0; i < $('.index-animation').length; i++) {
      $('.index-animation').eq(i).css('animation-delay', i * delay + 's')
    }
  }
  /*收起显示*/
  function ShowHide(){
    $('.Proann-More').on('click', function(event) {
      var text=$(this).text();
      if(text=='展开全部'){
        $('.Proann-BuyNum').css({
          height: 'auto',
          overflow: 'visible'
        });
        $(this).text('收起');
      }else{
        $('.Proann-BuyNum').css({
          height: '44px',
          overflow: 'hidden'
        });
        $(this).text('展开全部');
      }
    });
  }

  /*价格加减*/
  function Additions(minus, buyCont, add,msg) {
    var min=parseFloat($(buyCont).attr('min'));
    var max=parseFloat($(buyCont).attr('max'))
    var valueAdd=$(buyCont).attr('data-base')
    isNaN(min)?min=0:min=min;
    isNaN(max)?max=0:max=max;
    valueAdd= parseFloat(valueAdd) || 1;
    function check_val(){
      var cont = parseFloat($(buyCont).val());
      if(!cont){
        cont = 0
      }
      if (min >= max) {
        min=max;
      }
      if (cont <= min) {
        cont = min
        $(minus).addClass('unminus');
        $(add).removeClass('unadd');
      }else if (cont >= max) {
        cont = max;
        $(add).addClass('unadd');
        $(minus).removeClass('unminus');
      }else{
        $(minus).removeClass('unminus');
        $(add).removeClass('unadd');
      }
      if (min >= max) {
          min = max
          max =min
          $(add).addClass('unadd');
          $(minus).addClass('unminus');
      }
      $(buyCont).val('');
      $(buyCont).val(cont);
      if(msg){
        $(buyCont).val(cont.toFixed(2));
      }
    }
    check_val()
    $(buyCont).blur(function () {
      check_val()
    })
    $(minus).on('touchstart', function () {
      $(buyCont).val((parseFloat($(buyCont).val()) - valueAdd).toFixed(2));
      check_val()
    });
    /*加*/
    $(add).on('touchstart', function () {
      $(buyCont).val((parseFloat($(buyCont).val()) + valueAdd).toFixed(2))
      check_val()
    })
  }
  /*只用在product-detail.html*/
  function addMuin() {
    var min =parseInt($('.buy-cont').attr('min'));//最小值
    isNaN(min)?min=0:min=min;
    var max = parseInt($('.buy-cont').attr('max'));//最大值
    isNaN(max)?max=0:max=max;
    var valueAdd = parseInt($('.buy-cont').attr('change-base')) || 1;
    var base= parseInt($('.buy-cont').attr('data-base')) || 1;
    function exchange(){
      var cont = parseInt($('.buy-cont').val());
      if(!cont){
        cont=0
      }
      if (min >= max) {
        min=max;
      }
      if (cont <= min) {
        cont=min;
        $('.minus').addClass('unminus');
        $('.add').removeClass('unadd');
      } else if (cont >= max) {
        cont=max;
        $('.add').addClass('unadd');
        $('.minus').removeClass('unminus');
      }else{
        $('.add').removeClass('unadd');
        $('.minus').removeClass('unminus');
      }
      if (min >= max) {
        min=max;
        $('.add').addClass('unadd');
        $('.minus').addClass('unminus');
      }

      $('.buy-cont').val('');
      $('.buy-cont').val(cont);
      $('.Change-Num').text(cont * base);
    }
    exchange()
    $('.buy-cont').blur(function () {
      exchange();
    })

    /*减*/
    $('.minus').on('touchstart', function () {
     $('.buy-cont').val(Number($('.buy-cont').val()) - valueAdd);
     exchange();
    });
    /*加*/
    $('.add').on('touchstart', function () {
      $('.buy-cont').val(Number($('.buy-cont').val()) + valueAdd);
      exchange();
    });
    //新增全投
    $('.allNumber').on('click',function(){
      var number=parseInt($('.allNumber').attr('number'))||1;
      $('.Change-Num').text(number * base);
      $('.buy-cont').val(max);
      exchange();
    })

    $('.Pro-close img').on('click',function(){
      $('.Pro-Mask').hide();
      $('.Pro-Mask').attr('value','0');
      $('.layerPostion').remove()
      unScrollheight();
    })
  }

  function alertDb(msg, btn, callback) {
    Scrollheight()
    $('body').append($('<div class="prompt-box"><div><div class="Close-Right"></div><p>'+msg+'</p><button class="hidden">'+btn+'</button></div></div>'));
    $(".hidden").on('click',function(){
      $('.prompt-box').hide();
      unScrollheight()
      if(callback){
        callback()
      }
    })
    $(".Close-Right").on('click',function(){
      $('.prompt-box').hide();
      unScrollheight()
      if(callback){
        callback()
      }
    })
  }
/*——————————————————————————————————————————————————*/

  /*数字用逗号间隔*/
function outputmoney(number) {
  /*number = number.replace(/\,/g, "");*/
  /*if(isNaN(number) || number == "")return "";*/
  number = Math.round(number * 100) / 100;
  if (number < 0)
    return '-' + outputdollars(Math.floor(Math.abs(number) - 0) + '') + outputcents(Math.abs(number) - 0);
  else
    return outputdollars(Math.floor(number - 0) + '') + outputcents(number - 0);
}
//格式化金额
function outputdollars(number) {
  if (number.length <= 3)
    return (number == '' ? '0' : number);
  else {
    var mod = number.length % 3;
    var output = (mod == 0 ? '' : (number.substring(0, mod)));
    for (i = 0; i < Math.floor(number.length / 3); i++) {
      if ((mod == 0) && (i == 0))
        output += number.substring(mod + 3 * i, mod + 3 * i + 3);
      else
        output += ',' + number.substring(mod + 3 * i, mod + 3 * i + 3);
    }
    return (output);
  }
}
function outputcents(amount) {
  amount = Math.round(((amount) - Math.floor(amount)) * 100);
  return (amount < 10 ? '.0' + amount : '.' + amount);
}
