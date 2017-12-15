/*loading*/


$(function() {
  $(".body-box").parents("html").css("height","inherit");

  $(".body-box").append("<div class='img-pre'></div>");
  /*首页底部跳转*/
  $('body').on("click",".footer>ul>li",function(){
    $(this).addClass("active");
    $(this).siblings().removeClass("active");
  })

  //隐藏弹框
  $(document).on('click', '.hidden', function () {
    unalertTx()
  })

  // 验证输入数据格式

  $("body").on("keyup", "input", function (e) {
    if($(this).attr("maxlength") != null){
      if($(this).val().length > parseInt($(this).attr("maxlength"))){
        $(this).val($(this).val().substr(0, parseInt($(this).attr("maxlength")) ));
      }
    }
  })

  $("body").on("blur", "input", function () {
    var regphone = /^1[34578]\d{9}$/;   /*手机号验证*/
    var regzipCode= /^[1-9][0-9]{5}$/;   /*邮编验证*/

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
  })
})

/*微信分享弹框*/
$(document).on("click", ".wechat" ,function() {
  $('body').append($('<div class="wechat-share-bg"><div class="wechat-share"></div></div>'));
  $('body').addClass('PostionFixed');
  img_class = $(this).attr("data-img")
  if(!img_class){
    img_class = "index-box"
  }
  $('.wechat-share').addClass(img_class)
  /*关闭——微信分享弹框*/
  $(".wechat-share-bg").on("click", function () {
    $(".wechat-share-bg").hide();
    $('body').removeClass('PostionFixed');
  });
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
    $('body').append($('<div class="lock-box" id="lock-box"><div class="spinner"><div class="spinner-container container1"><div class="circle1"></div><div class="circle2"></div><div class="circle3"></div><div class="circle4"></div></div><div class="spinner-container container2"><div class="circle1"></div><div class="circle2"></div><div class="circle3"></div><div class="circle4"></div></div><div class="spinner-container container3"><div class="circle1"></div><div class="circle2"></div><div class="circle3"></div><div class="circle4"></div></div></div></div>'));
    $('body').addClass('PostionFixed');
  }

  /*弹框*/
  function alertTx(msg, callback) {
    $('body').append($('<div class="prompt-box"><div><p>' + msg + '</p><a href="#2" class="hidden">确认</a></div></div>'));
    $('body').addClass('PostionFixed');

    $(".hidden").click(function(){
      $('.prompt-box').hide();
      $('body').removeClass('PostionFixed');
      if(callback){
        callback()
      }
    })
  }

  /*倒计时*/
  function Conutdown(endtime,timeId){
  console.log(endtime);
  setInterval(function () {
    var date = new Date();
    var end = new Date(endtime);
    var showTime = document.getElementById(timeId);
    var _time = end - date;

    if(_time<0){
      showTime.innerText = "00:00:00";
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
      showTime.innerText = h + ":" + m + ":" + s;
    }
  },10)
}


  /*排行榜弹框*/
  function Rankingalert(msg,url,text, callback) {
    $('body').append($('<div class="prompt-box"><div><p>' + msg + '</p><a href="'+url+'" class="hidden">'+text+'</a></div></div>'));
    $('body').addClass('PostionFixed');

    $(".hidden").click(function(){
      if(callback){
        callback()
      }
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
  function Additions(minus, buyCont, add, min, max, valueAdd) {
    min = parseFloat(min);
    max = parseFloat(max);
    valueAdd = parseFloat(valueAdd);
    function check_val(){
      var cont = parseFloat($(buyCont).val());
      if(!cont){
        cont = 0
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
          a = min
          min = max
          max =min
          $(add).addClass('unadd');
          $(minus).addClass('unminus');
      }
      $(buyCont).val(cont.toFixed(2)) 
    }
    check_val()
    $(buyCont).change(function () {
      check_val()
    })
    $(minus).click(function () {
      $(buyCont).val((parseFloat($(buyCont).val()) - valueAdd).toFixed(2));
      check_val()
    });
    /*加*/
    $(add).click(function () {
      $(buyCont).val((parseFloat($(buyCont).val()) + valueAdd).toFixed(2))
      check_val()
    })
  }


  /*                        数量加减                    */
  function Additions1(minus, buyCont, add, min, max, valueAdd) {
    var min = min;//最小值
    var max = max;//最大值
    min = parseInt(min);
    max = parseInt(max);
    var valueAdd = valueAdd;//加减基数
    valueAdd = parseInt(valueAdd);
    var buyCont = $(buyCont);
    var minus = $(minus);
    var add = $(add);
    var cont = buyCont.val();
    if (min >= max) {
      buyCont.val(max);
      add.addClass('unadd');
      minus.addClass('unminus');
      buyCont.change(function () {
        var cont = buyCont.val();
        if(isNaN(cont)){
          $(this).val(min);
          var cont = $(this).val();
        }
        if (cont <= min) {
          $(this).val(min);
          minus.addClass('unminus');
          var cont = $(this).val();
        } else if (cont >= max) {
          $(this).val(max);
          add.addClass('unadd');
          var cont = $(this).val();
        } else if (cont == "") {
          $(this).val(min);
          minus.addClass('unminus');
          var cont = $(this).val();
        } else {
          cont = parseInt(cont);
          $(this).val(cont);
          minus.removeClass('unminus');
          add.removeClass('unadd');
        }
      })
      return;
    }
    if (cont <= min) {
      buyCont.val(min);
      minus.addClass('unminus');
      var cont = buyCont.val();
    }
    if (cont >= max) {
      buyCont.val(max);
      add.addClass('unadd');
      var cont = buyCont.val();
    }
    buyCont.change(function () {
      var cont = buyCont.val();
      cont = parseInt(cont);
      if(isNaN(cont)){
        $(this).val(min);
        var cont = $(this).val();
      }
      if (cont <= min) {
        $(this).val(min);
        minus.addClass('unminus');
        var cont = $(this).val();
        add.removeClass('unadd');
      } else if (cont >= max) {
        $(this).val(max);
        add.addClass('unadd');
        var cont = $(this).val();
        minus.removeClass('unminus');
      } else if (cont == "") {
        $(this).val(min);
        minus.addClass('unminus');
        add.removeClass('unadd');
        var cont = $(this).val();
      } else {
        cont = parseInt(cont);
        $(this).val(cont);
        minus.removeClass('unminus');
        add.removeClass('unadd');
      }
    })

    /*减*/
    minus.click(function () {
      var cont = buyCont.val();
      cont = Number(cont);
      if (cont <= min) {
        minus.addClass('unminus');
        return false;
      }
      minus.removeClass('unminus');
      add.removeClass('unadd');
      cont -= valueAdd;
      /*console.log(valueAdd)
       console.log(cont)*/
      buyCont.val(cont);
      if (cont <= min) {
        minus.addClass('unminus');
        return false;
      }
    });
    /*加*/
    add.click(function () {
      var cont = buyCont.val();
      cont = Number(cont);
      if (cont == max) {
        add.addClass('unadd');
        return false;
      }
      add.removeClass('unadd');
      minus.removeClass('unminus');
      cont += valueAdd;
      /*console.log(valueAdd)
       console.log(cont)*/
      buyCont.val(cont);
      if (cont == max) {
        add.addClass('unadd');
        return false;
      }
    });

  }

//横向滚动 参数-滚动元素父级id
  function marquee(marquee,time) {
    var marquee = document.getElementById(marquee);
    var offset = 0;
    var scrollwidth = marquee.offsetWidth;
    var firstNode = marquee.children[0].cloneNode(true);
    var secendNode = marquee.children[1].cloneNode(true);
    /*var threeNode = marquee.children[2].cloneNode(true);*/
    marquee.appendChild(firstNode);//还有这里
    marquee.appendChild(secendNode);
    /* marquee.appendChild(threeNode);*/
    setInterval(function () {
      if (offset == scrollwidth) {
        offset = 0;
      }
      marquee.style.marginLeft = "-" + offset + "px";
      offset += 1;
    }, time);
  }

  /*只用在product-detail.html*/
  function addMuin() {
    var min = $('.buy-cont').attr('min');//最小值
    min = parseInt(min);
    var max = $('.buy-cont').attr('max');//最大值
    max = parseInt(max);
    var base = $('.buy-cont').attr('data-base');//兑换基数
    base = parseInt(base);
    var cont = $('.buy-cont').val();
    cont = parseInt(cont);
    if (min >= max) {
      $('.buy-cont').val(max);
      $('.add').addClass('unadd');
      $('.minus').addClass('unminus');
      $('.Change-Num').text(cont * base);
      $('.buy-cont').change(function () {
        var cont = $('.buy-cont').val();
        cont = parseInt(cont);
        if(isNaN(cont)){
          $(this).val(min);
          var cont = $(this).val();
          $('.Change-Num').text(cont * base);
        }
        if (cont <= min) {
          $(this).val(min);
          $('.minus').addClass('unminus');
          var cont = $(this).val();
          $('.Change-Num').text(cont * base);
        } else if (cont >= max) {
          $(this).val(max);
          $('.add').addClass('unadd');
          var cont = $(this).val();
          $('.Change-Num').text(cont * base);
        } else if (cont == "") {
          $(this).val(min);
          $('.minus').addClass('unminus');
          var cont = $(this).val();
          $('.Change-Num').text(cont * base);

        } else {
          var contInt = $(this).val();
          contInt = parseInt(contInt);
          $(this).val(contInt)
          $('.Change-Num').text(cont * base);
          $('.minus').removeClass('unminus');
          $('.add').removeClass('unadd');
        }
      })
      return;
    }
    if (cont <= min) {
      $('.buy-cont').val(min);
      $('.minus').addClass('unminus');
      var cont = $('.buy-cont').val();
      $('.Change-Num').text(cont * base);
    } else if (cont >= max) {
      $('.buy-cont').val(max);
      $('.add').addClass('unadd');
      var cont = $('.buy-cont').val();
      $('.Change-Num').text(cont * base);
    }
    $('.buy-cont').change(function () {
      var cont = $('.buy-cont').val();
      cont = parseInt(cont);
      if(isNaN(cont)){
        $(this).val(min);
        var cont = $(this).val();
        $('.Change-Num').text(cont * base);
      }
      if (cont <= min) {
        $(this).val(min);
        $('.minus').addClass('unminus');
        var cont = $(this).val();
        $('.Change-Num').text(cont * base);
        $('.add').removeClass('unadd');
      } else if (cont >= max) {
        $(this).val(max);
        $('.add').addClass('unadd');
        var cont = $(this).val();
        $('.Change-Num').text(cont * base);
        $('.minus').removeClass('unminus');
      } else if (cont == "") {
        $(this).val(min);
        $('.minus').addClass('unminus');
        var cont = $(this).val();
        $('.Change-Num').text(cont * base);

      } else {
        var contInt = $(this).val();
        contInt = parseInt(contInt);
        $(this).val(contInt)
        $('.Change-Num').text(cont * base);
        $('.minus').removeClass('unminus');
        $('.add').removeClass('unadd');
      }
    })

    /*减*/
    $('.minus').click(function () {
      var cont = $('.buy-cont').val();
      if (cont <= min) {
        $('.minus').addClass('unminus');
        return false;
      }
      $('.minus').removeClass('unminus');
      $('.add').removeClass('unadd');
      cont--;
      $('.buy-cont').val(cont);
      $('.Change-Num').text(cont * base);
      if (cont <= min) {
        $('.minus').addClass('unminus');
        return false;
      }

    });
    /*加*/
    $('.add').click(function () {
      var cont = $('.buy-cont').val();
      if (cont == max) {
        $('.add').addClass('unadd');
        return false;
      }
      $('.add').removeClass('unadd');
      $('.minus').removeClass('unminus');
      cont++;
      $('.buy-cont').val(cont);
      $('.Change-Num').text(cont * base);
      if (cont == max) {
        $('.add').addClass('unadd');
        return false;
      }
    });
    $('.Pro-close img').click(function(){
      $('.Pro-Mask').hide();
      $('.Pro-Mask').attr('value','0');
      $('body').removeClass('PostionFixed');
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
