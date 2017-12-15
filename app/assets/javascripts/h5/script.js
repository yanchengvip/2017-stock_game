function  goldShow(){
  var browser = {
    versions: function () {
    var u = navigator.userAgent, app = navigator.appVersion;
    return {//移动终端浏览器版本信息
     trident: u.indexOf('Trident') > -1, //IE内核
     presto: u.indexOf('Presto') > -1, //opera内核
     webKit: u.indexOf('AppleWebKit') > -1, //苹果、谷歌内核
     gecko: u.indexOf('Gecko') > -1 && u.indexOf('KHTML') == -1, //火狐内核
     mobile: !!u.match(/AppleWebKit.*Mobile/i) || !!u.match(/MIDP|SymbianOS|NOKIA|SAMSUNG|LG|NEC|TCL|Alcatel|BIRD|DBTEL|Dopod|PHILIPS|HAIER|LENOVO|MOT-|Nokia|SonyEricsson|SIE-|Amoi|ZTE/), //是否为移动终端
     ios: !!u.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/), //ios终端
     android: u.indexOf('Android') > -1 || u.indexOf('Linux') > -1, //android终端或者uc浏览器
     iPhone: u.indexOf('iPhone') > -1 || u.indexOf('Mac') > -1, //是否为iPhone或者QQHD浏览器
     iPad: u.indexOf('iPad') > -1, //是否iPad
     webApp: u.indexOf('Safari') == -1 //是否web应该程序，没有头部与底部
    };
    } (),
    language: (navigator.browserLanguage || navigator.language).toLowerCase()
  }
  
  window.onload=function () {
    if (browser.versions.iPhone || browser.versions.iPad || browser.versions.ios) {
      document.addEventListener("WeixinJSBridgeReady", function () {  
        lpay();  
      }, false); 
      function lpay(){  
        document.getElementById("music").setAttribute("src","../images/1.mp3");  
        document.getElementById("music").play();   
      }  
    }
    if (browser.versions.android) {
      $("#music")[0].play();
    }
    (genClips = function () {
      $t = $('.item1');
      var amount = 5;
      var width = $t.width() / amount;
      var height = $t.height() / amount;
      var totalSquares = Math.pow(amount, 2);
      var y = 0;
      var index = 1;
      for (var z = 0; z <= (amount * width) ; z = z + width) {
        $('<img class="clipped" src="../images/jb' + index + '.png" />').appendTo($('.item1 .clipped-box'));
        if (z === (amount * width) - width) {
            y = y + height;
            z = -width;
        }
        if (index >= 5) {
            index = 1;
        }
        index++;
        if (y === (amount * height)) {
            z = 9999999;
        }
      }
    })();
    function rand(min, max) {
      return Math.floor(Math.random() * (max - min + 1)) + min;
    }
    var first = false,
        clicked = false;
    $('.item1 .clipped-box').css({
        'display': 'block'
    });
    $('.clipped-box img').each(function () {
      var v = rand(120, 90),
        angle = rand(80, 89), 
        theta = (angle * Math.PI) / 180, 
        g = -9.8; 

      // $(this) as self
      var self = $(this);
      var t = 0,
        z, r, nx, ny,
        totalt =10;
      var negate = [1, -1, 0],
        direction = negate[Math.floor(Math.random() * negate.length)];

      var randDeg = rand(-5, 10),
        randScale = rand(0.9, 1.1),
        randDeg2 = rand(30, 5);

      // And apply those
      $(this).css({
        'transform': 'scale(' + randScale + ') skew(' + randDeg + 'deg) rotateZ(' + randDeg2 + 'deg)'
      });

      // Set an interval
      z = setInterval(function () {
        var ux = (Math.cos(theta) * v) * direction;
        var uy = (Math.sin(theta) * v) - ((-g) * t);
        nx = (ux * t);
        ny = (uy * t) + (0.9 * (g) * Math.pow(t, 2));
        if (ny < -800) {
            ny = -800;
        }
        //$("#html").html("g:" + g + "bottom:" + ny + "left:" + nx + "direction:" + direction);
        $(self).css({
            'bottom': (ny) + 'px',
            'left': (nx) + 'px',
        });
        // Increase the time by 0.10
        t = t + 0.1;

        //跳出循环
        if (t > totalt) {
          clicked = false;
          first = true;
          $('.goldAlertBox').remove()
          clearInterval(z);
        }
      }, 10);
    });
  };
}