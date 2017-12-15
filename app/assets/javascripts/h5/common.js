/**
 * Created by Zl on 2017/2/22.
 */
/*canvas进度条*/
function inte(percent) {
  var canvas_1 = document.querySelector('#canvas_1');
  var canvas_2 = document.querySelector('#canvas_2');
  var ctx_1 = canvas_1.getContext('2d');
  var ctx_2 = canvas_2.getContext('2d');
  ctx_1.lineWidth = 10;
  ctx_1.strokeStyle = "#584c6e";

  //画底部的灰色圆环
  ctx_1.beginPath();
  ctx_1.arc(canvas_1.width / 2, canvas_1.height / 2, canvas_1.width / 2 - ctx_1.lineWidth / 2, 3/4 * Math.PI, 9/4 * Math.PI, false);
  //ctx_1.closePath();
  ctx_1.lineCap="round";
  ctx_1.stroke();
  if (percent < 0 || percent > 100) {
    throw new Error('percent must be between 0 and 100');
    return
  }
  ctx_2.lineWidth = 10;
  ctx_2.strokeStyle = "#6b67ff";
  var angle = 0;
  var timer;
  (function draw() {
    timer = requestAnimationFrame(draw);
    ctx_2.clearRect(0, 0, canvas_2.width, canvas_2.height)
    //百分比圆环
    ctx_2.beginPath();
    ctx_2.arc(canvas_2.width / 2, canvas_2.height / 2, canvas_2.width / 2 - ctx_2.lineWidth / 2, 0, angle * Math.PI / 180, false);
    angle++;
    var percentAge = parseInt((angle / 360 * (280/360) ) * 100)
    if (angle > (percent / 100 * 360 * (280/360) )) {
      percentAge = percent
      window.cancelAnimationFrame(timer);
    };
    ctx_2.lineCap="round";
    ctx_2.stroke();
    ctx_2.closePath();
    ctx_2.save();
    ctx_2.beginPath();
    ctx_2.rotate(90 * Math.PI / 180);
    ctx_2.fillStyle = 'rgba(255,255,255,0.5)';
    ctx_2.strokeStyle = "#6b67ff";
    //var text = percentAge + '%';
    //ctx_2.fillText(text, 80, -90);
    ctx_2.restore();
  })()
}

function canvasProgress(Num){
  var Num =Num;
  if(Num<=0){
    window.onload = inte(Num);
    $('#canvas_2').css('visibility',' hidden');
  }else{
    $('#canvas_2').css('visibility','visible');
    window.onload = inte(Num);
  }
}













