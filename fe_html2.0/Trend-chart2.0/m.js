function mData() {

  //模拟当日数据
  var demoData = dataTestOut();
  var minData = [] //分时图数据
  var averageData = [] //分时图均线数据
  var columnData = [] //分时图成交量数据
  for (var i = 0; i < demoData.length; i++) {
    minData.push([demoData[i][0], demoData[i][1]])
    averageData.push([demoData[i][0], demoData[i][2]])
    columnData.push([demoData[i][0], demoData[i][3]])
  }
  // 生成模拟数据函数
  function dataTestOut() {
    var dataTest = [];
    var dataBranch1 = [];

    var a = 1489023000000;
    var b = 2400.45;
    var c = 0;
    for (var i = 0; i < 330; i++) {
      if (a<1489030200000 || a>=1489030200000 + 5400000) {
        a = a + 60000;
        if (i < 50) {
          b -= 0.03
        } else {
          b += 0.06
        }
        if (i <= 120) {
          var randomNum = Math.random();
          dataBranch1.push(a)
          dataBranch1.push(b + Math.random() * 50 - Math.random() * 50)
          dataBranch1.push(b + Math.random() * 50 - Math.random() * 50)
          dataBranch1.push(c + Math.random())
        } else {
          var randomNum = Math.random();
          dataBranch1.push(a)
          dataBranch1.push(null)
        }
        dataTest.push(dataBranch1)
        dataBranch1 = [];
      }else if(a=1489030200000){
        a=1489030200000 + 5400000
      };
    }
    // console.log(dataTest)

    return dataTest
  }


  var todayDate = demoData[0];
  var day = Highcharts.dateFormat('%Y/%m/%d', todayDate),
    breaks = [{
      from: new Date(day + ' 11:30').getTime(),
      to: new Date(day + ' 13:00').getTime(),
      breakSize: 0 * 60
    }]

  var crrentData = [];
  var retTrade = [minData, averageData, columnData];
  // console.log(retTrade)
  return retTrade
}


function mLine(divId) {

  Highcharts.setOptions({
    global: {
      timezoneOffset: -8*60
    },
    lang:{
      loading:'加载中...',  
      // resetZoom:'还原图表',
    }
  });
  var result = mData();
  var $reporting = $("#report");
  var mouseX;
  var open = 2400.45  //开盘价
  var minTime,midTime,maxTime; //每日分时图起始时间、中点、终止时间
  minTime=1489023000000;
  midTime=1489030200000;
  maxTime=1489042800000;
  var sourceMinTime = minTime;
  var sourceMaxTime = maxTime;

  var ZoomStep = 1000*3600*0.5
  var maxZoomTime = maxTime - ZoomStep*3
  var minZoomTime = minTime + ZoomStep*3


  // var openPrice,closePrice,minPrice,maxPrice; //开盘价、收盘价、最低价、最高价
  // openPrice = 298;
  // closePrice = 305;
  // maxPrice = 305;
  // minPrice = 298;
  
  //这一部分判断已有现价集合中最大值和最小值
  var minPrice,maxPrice; //最高价、最低价
  var allPrice=[]; //现价集合数组

  for(var i=0;i<result[0].length;i++){
    if(result[0][i][1] != undefined){
      allPrice.push(result[0][i][1])
    }
  }

  maxPrice = Math.max.apply(null, allPrice)
  minPrice = Math.min.apply(null, allPrice)
  var maxY,minY;   //y轴最大刻度值，y轴最小刻度值
  if(maxPrice-open > open-minPrice){
    maxY = maxPrice;
    minY = open - (maxY - open);
  }else if(maxPrice-open < open-minPrice){
    minY = minPrice;
    maxY = open + (open - minPrice)
  }



  var linestep = (open-minY)/2 //刻度线和刻度线之间的距离，因为scaleRatio算出来有除不尽，算的不准
  var scaleRatio = (maxY - minY)/5;   //y轴刻度值比例，把y轴分成n等分，没份为scaleRatio
  // var scaleRatio = Math.ceil((maxY - minY)/4);   //y轴刻度值比例
  // var scaleRatio = Math.floor((maxY - minY)/4);   //y轴刻度值比例

  console.log("open：" + open)
  console.log("allPrice：" + allPrice)
  console.log("maxPrice：" + maxPrice)
  console.log("minPrice：" + minPrice)
  console.log("maxY：" + maxY)
  console.log("minY：" + minY)
  console.log("scaleRatio：" + scaleRatio)
  console.log(result)


  var mychart = Highcharts.StockChart({
    chart: {
      margin: [-10,60,30,60],
      panning: true,
      zoomType: null,
      pinchType: null,
      type:'spline', // 让线条变得圆滑
      renderTo: divId,
      backgroundColor: '#1E1E26',
      // plotBorderColor: 'red',
      // borderColor: 'red',
      events: {
        load: function () {
          // set up the updating of the chart each second
          var series0 = this.series[0];
          var series0 = this.series[1];

          var idx = 250;
          var mTimer = setInterval(function () {

            //画点
            var x = result[0][idx - 1][0] + 60000;
            y0 = 2400 + Math.random()*50 - Math.random()*50;
            y1 = 2400 + Math.random()*50 - Math.random()*50;
            series0.addPoint([x, y0], false);
            series1.addPoint([x, y1], false);
            idx++;


            // 当前点大于等于或小于等于y轴极值是更新y轴极值及刻度比例
            if(y0 >= maxY || y0 <= minY) {
              if(y0 >= maxY){
                maxY = y0
                minY= open-(maxY-open)
              }else if(y0<minY){
                minY = y0
                maxY = open+(open-y0)
              }
                // 重置坐标轴刻度比例
                // 更新变化了的变量
                linestep = (open-minY)/2 
                scaleRatio = (maxY-minY)/5
                mychart.yAxis[0].update({
                  tickInterval: scaleRatio, //刻度比例
                  max: maxY,  // 定义Y轴 最大值
                  min: minY,  // 定义最小值
                  tickPositioner: function () {
                    return [minY, minY+linestep, open, open+linestep,maxY, maxY+linestep]  //9:30,11:30,13:00
                  },
                });
                mychart.yAxis[1].update({
                  tickInterval: scaleRatio,  //刻度比例
                  max: maxY,  // 定义Y轴 最大值
                  min: minY,  // 定义最小值
                  tickPositioner: function () {
                    return [minY, minY+linestep, open, open+linestep,maxY, maxY+linestep]  //9:30,11:30,13:00
                  },
                });
            }

                // 重置坐标轴极值
                // var yAxis0 = mychart.yAxis[0];
                // var yAxis1 = mychart.yAxis[1];
                // yAxis0.options.startOnTick = false;
                // yAxis1.options.endOnTick = false;
                // yAxis0.options.startOnTick = false;
                // yAxis1.options.endOnTick = false;
                // mychart.yAxis[0].setExtremes(y0, minY);
                // mychart.yAxis[1].setExtremes(y0, minY);
                // mychart.yAxis[0].setExtremes(2346, 2454);
                // mychart.yAxis[1].setExtremes(2346, 2454);

            //重绘
            
            mychart.redraw();
          }, 600);


            $(".m-zoom .to-large").on('click', function(event) {
                console.log("变大")
                minTime = minTime + ZoomStep
                maxTime = maxTime - ZoomStep
                if (maxTime <= maxZoomTime){
                  maxTime = maxZoomTime
                  minTime = minZoomTime
                }
                mychart.xAxis[0].update({
                  min: minTime, //1489023000000,
                  max: maxTime, //1489042800000,
                  tickPositioner: function () {
                    return [minTime, maxTime]  //9:30,11:30,13:00 
                  }, 
                });
            });

            $(".m-zoom .to-small").on('click', function(event) {
                console.log("缩小")
                minTime = minTime - ZoomStep
                maxTime = maxTime + ZoomStep
                if (minTime <= 1489023000000 || maxTime  >= 1489042800000) {
                  minTime = 1489023000000
                  maxTime = 1489042800000
                  mychart.xAxis[0].update({
                    min: minTime, //1489023000000,
                    max: maxTime, //1489042800000,
                    tickPositioner: function () {
                      return [minTime,midTime, maxTime]  //9:30,11:30,13:00 
                    }, 
                  });
                  return
                };
                
                mychart.xAxis[0].update({
                  min: minTime, //1489023000000,
                  max: maxTime, //1489042800000,
                  tickPositioner: function () {
                    return [minTime, maxTime]  //9:30,11:30,13:00 
                  }, 
                });
            });

            $(".m-zoom .to-left").on('click', function(event) {
              console.log("向左")
                minTime = minTime - ZoomStep
                maxTime = maxTime - ZoomStep
                if (minTime <= sourceMinTime) {
                  minTime = sourceMinTime
                  maxTime = maxTime + ZoomStep
                };
                mychart.xAxis[0].update({
                  min: minTime, //1489023000000,
                  max: maxTime, //1489042800000,
                  tickPositioner: function () {
                    return [minTime, maxTime]  //9:30,11:30,13:00 
                  }, 
                });
            });

            $(".m-zoom .to-right").on('click', function(event) {
              console.log("向右")
                minTime = minTime + ZoomStep
                maxTime = maxTime + ZoomStep
                if (maxTime >= sourceMaxTime) {
                  maxTime = sourceMaxTime
                  minTime = minTime - ZoomStep
                };
                mychart.xAxis[0].update({
                  min: minTime, //1489023000000,
                  max: maxTime, //1489042800000,
                  tickPositioner: function () {
                    return [minTime, maxTime]  //9:30,11:30,13:00 
                  }, 
                });
            });

            $(".m-zoom .to-restore").on('click', function(event) {
                console.log("复原")
                minTime = 1489023000000
                maxTime = 1489042800000
                mychart.xAxis[0].update({
                  min: minTime, //1489023000000,
                  max: maxTime, //1489042800000,
                  tickPositioner: function () {
                    return [minTime, midTime, maxTime]  //9:30,11:30,13:00 
                  }, 
                });
            });
        }
      }
    },
    plotOptions: {
      series: {
        states: {
          hover: {
            enabled: false,
            lineWidth: 0
          }
        },
        dataGrouping: { //关闭数据分组，解决大量数据无法全部显示点的问题
           forced: true,
           units: [
               ['minute', [1]]
           ]
        }
      },
    },
    rangeSelector: {
      enabled: false  //隐藏左上角范围选择器
    },
    scrollbar: {
      enabled: false  //隐藏滚动条
    },
    navigation: {
      buttonOptions: {
        enabled: false  //隐藏顶部导航条
      }
    },
    navigator: {
      enabled: false    //隐藏底部范围选择
    },
    credits: {
      enabled: false //隐藏highchart.com字样
    },
    xAxis: {
      crosshair: {     //鼠标经过出现十字线
        dashStyle: 'Solid',   //十字线样式,默认是Solid
        snap: true,  //十字线是否跟随线上的点
      },
      // gridLineWidth: 0,
      min: minTime, //1489023000000,
      max: maxTime, //1489042800000,
      type: 'datetime',
      tickLength: 0,//X轴下标长度
      lineWidth:1,  //x轴坐标轴宽度
      lineColor:"#564e68",  //x轴坐标轴颜色
      labels: {
        x: 0,
        y: 15,
        formatter: function () {
          if (this.value === midTime) {  //11:30 -- 1489030200000
            return '<span style="color:#fff">'+'11:30/13:00'+'</span>';
          }
          return '<span style="color:#fff">'+ Highcharts.dateFormat("%H:%M", this.value) +'</span>';
        },
      },
      tickPositioner: function () {
        return [minTime, midTime, maxTime]  //9:30,11:30,13:00 
      },   
    },
    yAxis: [{
      title: {
        text: ''
      },
      crosshair: {     //鼠标经过出现十字线
        // dashStyle: 'dash',   //十字线样式Solid
        dashStyle: 'Solid',   //十字线样式,默认是Solid
        snap: true,  //十字线是否跟随线上的点
      },
      opposite: false,
      lineWidth: 0,//Y轴边缘线条粗细
      gridLineColor: '#292931', //横线颜色
      gridLineWidth: 0.8, //刻度行线透明度
      gridLineDashStyle: 'longdash',  //行线样式
      tickInterval: scaleRatio,  //刻度比例
      max: maxY,  // 定义Y轴 最大值
      min: minY,  // 定义最小值
      labels: {
        align: "left",
        x: -50,
        y: 5,
        formatter: function () {
          var a = ( this.value - open ) / this.value
          if (this.value > open) {
            return '<span style="color: #E91D25">' + this.value.toFixed(2) + '</span>';
          } else if (this.value < open) {
            if (this.value === minY) {
              // return '<span style="color: #fff">' + '' + '</span>';
            }
            return '<span style="color: #18EAAB">' + this.value.toFixed(2) + '</span>';
          } else if (this.value === open) {
            return '<span style="color: #fff">' + open + '</span>';
          };
          
          
          // return (this.value > 0 ? ' <span style="color: red">' : '<span style="color: green">') + this.value + '</span>';
        }
      },
      tickPositioner: function () {
        return [minY, minY+linestep, open, open+linestep,maxY, maxY+linestep]  //9:30,11:30,13:00
      },
    }, {
      title: {
        text: ''    //右侧Y轴名字
      },
      // crosshair: {     //鼠标经过出现十字线
      //   dashStyle: 'dash',   //十字线样式Solid
      //   // dashStyle: 'Solid',   //十字线样式,默认是Solid
      //   snap: false,  //十字线是否跟随线上的点
      // },
      opposite: true,
      lineWidth: 0,//Y轴边缘线条粗细
      gridLineDashStyle: 'longdash',
      gridLineColor: '#292931', //横线颜色
      gridLineWidth: 0.8, //刻度行线透明度
      // data:demoData,
      tickInterval: scaleRatio,  //刻度比例
      max: maxY,  // 定义Y轴 最大值
      min: minY,  // 定义最小值
      labels: {
        align: "right",
        x: 50,
        y: 5,
        formatter: function () {
          if (this.value > open) {
            return '<span style="color: #E91D25">' + ((this.value-open) / open * 100).toFixed(2) + '% </span>';
          } else if (this.value < open) {
            if (this.value === minY) {
              // return '<span style="color: #fff">' + '' + '</span>';
            } 
            return '<span style="color: #18EAAB">' + ((this.value-open) / open * 100).toFixed(2) + '% </span>';
          } else if (this.value === open) {
            return '<span style="color: #fff">' + '' + '0.00% </span>';
          } 
          
          // return (this.value > 0 ? ' <span style="color: red">' : '<span style="color: green">') + this.value + '% </span>';
        }
      },
      tickPositioner: function () {
        return [minY, minY+linestep, open, open+linestep,maxY, maxY+linestep]  //9:30,11:30,13:00
      },
    }],
    
    series: [{
      name: 'GOOGL',
      data: result[0],
      color: '#fff', //线条颜色
      lineWidth: 1, //曲线线条粗细
      yAxis: 0,
      marker: {
        enabled: false,  //是否在点出突出画一个圆点
        states: {
          hover: {
            enabled: false
          }
        }
      }
    }, {
      name: 'GOOGL',
      data: result[1],
      color: '#E1B91B', //线条颜色
      lineWidth: 1, //曲线线条粗细
      yAxis: 1,
      marker: {
        enabled: false,  //是否在点出突出画一个圆点
        states: {
          hover: {
            enabled: false
          }
        }
      }
    }],
    tooltip: {
      positioner: function () { //设置tips显示的相对位置
        var halfWidth = this.chart.chartWidth / 2;//chart宽度
        var width = this.chart.chartWidth - 141;
        var height = this.chart.chartHeight / 5 - 30;//chart高度
        if (mouseX < halfWidth) {
          return {x: width, y: height,};
        } else {
          return {x: 8, y: height};
        }
      },
      shared: true,
      useHTML: true,
      shadow: false,
      // borderColor: "rgba(255, 255, 255, 0)",
      // backgroundColor: "rgba(255, 255, 255, 0)",
      borderColor: '#666',
      valueDecimals: 2,
      formatter: function () {
        mouseX = this.points[0].point.plotX
        var time = Highcharts.dateFormat("20%y-%m-%d %H:%M", this.x);  //当前点的时间
        var cprice,aprice;
        aprice = this.points[0].y;
        cprice = this.points[1].y;
        aprice = aprice.toFixed(2);
        cprice = cprice.toFixed(2);

          if (cprice > open && aprice > open) {
            cprice = "现价：" + '<span style="color:red;padding-right: 5px;">' + cprice + '</span>';
            aprice = "均价：" + '<span style="color:red;padding-right: 5px;">' + aprice + '</span>';
          } else if (cprice < open && aprice < open) {
            cprice = "现价：" + '<span style="color:green;padding-right: 5px;">' + cprice + '</span>';
            aprice = "均价：" + '<span style="color:green;padding-right: 5px;">' + aprice + ' </span>';
          } else if (cprice > open && aprice < open) {
            cprice = "现价：" + '<span style="color:red;padding-right: 5px;">' + cprice + '</span>';
            aprice = "均价：" + '<span style="color:green;padding-right: 5px;">' + aprice + ' </span>';
          } else if (cprice < open && aprice > open) {
            cprice = "现价：" + '<span style="color:green;padding-right: 5px;">' + cprice + '</span>';
            aprice = "均价：" + '<span style="color:red;padding-right: 5px;">' + aprice + ' </span>';
          } else if (cprice === open && aprice === open) {
            cprice = "现价：" + '<span style="color:gray;padding-right: 5px;">' + cprice + '</span>';
            aprice = "均价：" + '<span style="color:gray;padding-right: 5px;">' + aprice + ' </span>';
          }


          $reporting.html("时间：" + time + ' ' + cprice + ' ' + aprice + '');
          var t = "<b>" + time + '</b>' + '<br>' + cprice + '<br>' + aprice;
          return t

        //当前时间，当前价，均价
        // return $.each(this.points, function () {
        //   var n = this.point.index;
        //   var a = Highcharts.numberFormat(o.y, 2);
        //   var b = Highcharts.numberFormat(o.y, 3);
        //   time = Highcharts.dateFormat("20%y-%m-%d %H:%M", this.x),   //当前点的时间
        //     cprice = "现价：" + '<span style="color:red;padding-right: 10px;">' + Highcharts.numberFormat(o.y, 2) + '</span>',
        //     z = "现价：" + Highcharts.numberFormat(o.y, 3)
        //   aprice = "均价：" + Highcharts.numberFormat(o.y, 2)
          
          
        //   if (a > open) {
        //     cprice = "现价：" + '<span style="color:red;padding-right: 5px;">' + a + '</span>';
        //     aprice = "均价：" + '<span style="color:red;padding-right: 5px;">' + b + '</span>';
        //   } else if (a < open) {
        //     cprice = "现价：" + '<span style="color:green;padding-right: 5px;">' + a + '</span>';
        //     aprice = "均价：" + '<span style="color:green;padding-right: 5px;">' + b + ' </span>';
        //   } else if (a = open) {
        //     cprice = "现价：" + '<span style="color:gray;padding-right: 5px;">' + a + '</span>';
        //     aprice = "均价：" + '<span style="color:gray;padding-right: 5px;">' + b + ' </span>';
        //   }

        //   $reporting.html("时间：" + time + ' ' + cprice + ' ' + aprice + '');
        // }),
        // '<b>' + time + '</b><br>' + cprice + '<br>' + aprice;

      }
    }
  });


}


