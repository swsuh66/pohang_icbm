var _animate = !AceApp.Util.isReducedMotion();

var useGraphOpt = {
	    type: 'line',
	    data: {
	      labels: null,
	      datasets: [{
	        type: 'line',
	        label: '총사용량(㎥)',

	        data: null,

	        borderColor: 'rgba(23, 167, 178, 0.67)',
	        borderWidth: 1.25,

	        fill: false,
	        backgroundColor : null,

	        pointRadius: 10,
	        pointBorderWidth: 10,
	        pointBackgroundColor: 'transparent',
	        pointHoverBackgroundColor: 'rgba(0, 0, 0, 0.27)',
	        pointBorderColor: 'transparent',

	        lineTension: 0.3
	      },
	      {
	        type: 'line',
	        label: '최고 사용량(㎥/전)',

	        data: null,


	        borderColor: 'rgba(22, 176, 255, 0.67)',
	        borderWidth: 1.25,

	        fill: false,
	        backgroundColor : null,

	        pointRadius: 10,
	        pointBorderWidth: 10,
	        pointBackgroundColor: 'transparent',
	        pointHoverBackgroundColor: 'rgba(0, 0, 0, 0.27)',
	        pointBorderColor: 'transparent',

	        lineTension: 0.3
	      },
	      {
	        type: 'line',
	        label: '최저 사용량(㎥/전)',

	        data: null,


	        borderColor: 'rgb(42, 128, 200)',
	        borderWidth: 1.25,

	        fill: false,
	        backgroundColor : null,

	        pointRadius: 10,
	        pointBorderWidth: 10,
	        pointBackgroundColor: 'transparent',
	        pointHoverBackgroundColor: 'rgba(0, 0, 0, 0.27)',
	        pointBorderColor: 'transparent',

	        lineTension: 0.3
		  }
	    ]
	    },
	    options: {
	      responsive: true,

	      animation: {
	        duration: _animate ? 1000 : false
	      },

	      tooltips: {
	        enabled: true,
	        callbacks: {
	          label: function(tooltipItem, data) {
	            var label = data.datasets[tooltipItem.datasetIndex].label || ''

	            if (label) {
	                label += ': '
	            }
	            label += parseFloat(tooltipItem.yLabel / 1000)
	            return  " " + label
	          },
	        }
	      },

	      scales: {
	        yAxes: [
	            {
	              ticks: {
	                fontFamily: "Open Sans",
	                fontColor: "#95909e",
	                fontStyle: "normal",
	                fontSize: "13",
	                beginAtZero: false,
	                maxTicksLimit: 6,
	                padding: 12,
	                callback: function(value, index, values) {
	                  var val = parseInt(value / 1000)
	                  return val > 0 ? val + 'k' : val
	                }
	              },
	              gridLines: {
	                drawBorder: false,

	                borderDash: [2, 4],
	                color: '#cbd1d5'
	              }
	            }
	        ],

	        xAxes: [
	          {
	            gridLines: {
	              display: false,
	              borderDash: [2, 2],
	              tickMarkLength: 16,
	              color: '#dbe1e5'
	            },
	            ticks: {
	              fontFamily: "Open Sans",
	              fontColor: "#95909e",
	              fontSize: "13",
	              padding: 0,
	              scaleBeginAtZero : true
	            }
	          },
	        ]
	      },

	      legend: {
	        display: true,
	        position: 'top',
	        labels: {
	          generateLabels: function(chart) {
	            labels = Chart.defaults.global.legend.labels.generateLabels(chart)
	            labels[0].fillStyle = '#75cad0'
	            labels[1].fillStyle = '#5dc7fe'
	            labels[2].fillStyle = '#2a80c8'
	            return labels;
	          }
	        }
	      },
	    }
	  };



	var commonOpt = {
        responsive: false,

        cutoutPercentage: 70,
        legend: {
            display: false
        },
        animation: {
            animateRotate: true,
            duration: _animate ? 1000 : false
        },
        tooltips: {
            enabled: true,
            cornerRadius: 0,
            bodyFontColor: '#fff',
            bodyFontSize: 14,
            fontStyle: 'bold',

            backgroundColor: 'rgba(34, 34, 34, 0.73)',
            borderWidth: 0,

            caretSize: 5,

            xPadding: 12,
            yPadding: 12,

            callbacks: {
              label: function(tooltipItem, data) {
                return ' ' + data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index] //+ '%'
              }
            }
        }
    };

	var statChartOpt = {
	    type: 'doughnut',
	    data: {
	        datasets: [{
	            label: '계량기 상태이상',
	            data: null,
	            // backgroundColor: [
	            //   "#00addd",
	            //   "#cf4a32",
	            //   "#f28603",
	            //   "#2a80c8",
	            //   "#56a856",
	            //   "#7167af",
	            //   "#738794"
	            // ],
				backgroundColor: [
					"#2C478E",
					"#DE0000",
					"#E87D00",
				],
	        }],
	        labels: null
	    },

	    options: commonOpt
	  };

	 var tRatioChartOpt = {
	    type: 'doughnut',
	    data: {
	        datasets: [{
	            label: '시간 검침률',
	            data: null,
	            // backgroundColor: [
	            //   "#00addd",
	            //   "#2a80c8",
	            //   "#f28603",
	            //   "#cf4a32"
	            // ],
				backgroundColor: [
					"#2C478E",
					"#04E193",
					"#F9AB40",
					"#FF405A"
				],
	        }],
	        labels: null
	    },

	    options: commonOpt
	  };

	 var dRatioChartOpt = {
	    type: 'doughnut',
	    data: {
	        datasets: [{
	            label: '일 검침률',
	            data: null,
	            // backgroundColor: [
	            //   "#00addd",
	            //   "#2a80c8",
	            //   "#f28603",
	            //   "#cf4a32"
	            // ],
				backgroundColor: [
					"#2C478E",
					"#04E193",
					"#F9AB40",
					"#FF405A"
				],
	        }],
	        labels: null
	    },
	    options: commonOpt
	  };



















	 		var useGraph = {
				dataType:null
			};

	 		useGraph.make = function(container, data) {
				if(!this.instance)
					this.instance = new BuildStockchart(container, data)
			}
	 		useGraph.setDataSource = function(data, dataType) {
				if(this.instance) {
					this.dataType = dataType;
					this.instance.getChart().hideLoading();
					this.instance.setDataSource(data);
				}
			}
	 		useGraph.showLoading = function(mesg) {
				if(this.instance) {
					//this.instance.setDataSource([]);
					this.instance.getChart().showLoading(mesg);
				}
			}
	 		useGraph.hideLoading = function() {
				if(this.instance)
					this.instance.getChart().hideLoading();
			}

			/******************************************************************************/
			/*
			 *
			 */

			function BuildStockchart(container, data)
			{
				var _chart;
				var xAxisDate = [];
				var tickInterval;
				var xDateFormat = '%Y-%m-%d';
				var tooltip = {};
				var xAxisConfig = [{
				        crosshair: true,
				        type: 'datetime',
					    labels: {
					    	overflow: 'justify',
				            formatter: function () {
				            	return Highcharts.dateFormat('.%b.%d', this.value);
				            	//return Highcharts.dateFormat(xDateFormat, this.value);
				            },
				            dateTimeLabelFormats: {
				                minute: '%H:%M',
				                hour: '%H:%M',
				                //day: xDateFormat,
				                day: '%b.%d',
				                week: '%b.%d',
				                month: '%Y-%m',
				                year: '%Y'
				            },
				            labels: {
				                enabled: true,
				            },
				            minorTickLength: 0,
				            tickLength: 0
					    }
				    }];

				/******************************************************/

				this.setDataSource = function(data) {
					var seriesData = [[],[]];

					for(var ix=0; ix<seriesData.length; ix++)
						_chart.series[ix].setData([]);
					_chart.zoomOut();

					if(data) {
						var cnt = data.length;
						for(var ix=cnt-1; ix>=0; ix--) {
							//seriesData[0].push([data[ix].measDt, data[ix].totUse]);
							//seriesData[1].push([data[ix].measDt, data[ix].avgUse]);
							var dateStr = data[ix].measDt;
							const [year, month, day] = dateStr.split('-').map(Number);
							var reDate = Date.UTC(year, month - 1, day);

							seriesData[0].push([reDate, data[ix].totUse]);
							seriesData[1].push([reDate, data[ix].avgUse]);
						}

					}
					for(var ix=0; ix<seriesData.length; ix++) {
						_chart.series[ix].setData(seriesData[ix]);

						//-------------------------------------------------------
						// added by mona
						// change tooltip date format for each daily and monthly chart
						_chart.series[ix].update({
				            tooltip: tooltip
				        });
						//-------------------------------------------------------
					}

					_chart.zoomOut();
					//setTimeout(_chart.zoomOut(), 1000);
				}

				this.getChart = function() {
					return _chart;
				}

				var clickDetected = false;

				//_chart = Highcharts.stockChart(container, {
				_chart = Highcharts.chart(container, {
				    chart: {
				    	//renderTo: container,
				        //zoomType: 'xy'
				    	zoomType: 'x',
				    	events: {
				    		click: function(event) {
				                if(clickDetected) {
				                    //alert ('x: '+ event.xAxis[0].value +', y: '+ event.yAxis[0].value);
				                    this.zoomOut();
				                    clickDetected = false;
				                } else {
				                    clickDetected = true;
				                    setTimeout(function() {
				                        clickDetected = false;
				                    }, 500);
				                }
				            },
				            load: function(event) {
				            	/*var self = this;
				            	setTimeout(self.zoomOut(), 300);*/
				            	//this.zoomOut();
				            }
				    	}
				    },
				    plotOptions: {
				    	series: {
				    		//stickyTracking: false
				    		marker: {
				                fillColor: '#FFFFFF',
				                lineWidth: 1,
				                lineColor: null,
				                width: 5,
				                height: 5
				            }
				    	},
				    	dataGrouping: {
					        enabled: false
					    },
					    column: {
					        //groupPadding: 0.2,
					        //pointPadding: 0.37,
					        pointWidth: 5,
					    }
				    },
				    scrollbar: {
			            enabled: false
			        },
			        navigator: {
			        	enabled: false,
			        	xAxis: {
			                dateTimeLabelFormats: {
			                    minute: '%H:%M',
			                    hour: '%H:%M',
			                    //day: xDateFormat,
			                    day: '%b.%d',
			                    week: '%b.%d',
			                    month: '\'%y %b',
			                    year: '%Y'
			                }
			            }
			        },
				    //tooltip: tooltip,
			        tooltip: {
			            split: false,
				        shared: true,
				        xDateFormat: '<span style="font-size:12px;color:gray;">%Y.%b.%d</span>'
				    },
				    legend: {
				    	enabled: true,
				        floating: false,
				    	layout: 'horizontal',
				    	align: 'center',
				        verticalAlign: 'top'
				        //x: 80,
				        //y: 0,
				        //backgroundColor: (Highcharts.theme && Highcharts.theme.legendBackgroundColor) || '#FFFFFF'
				    },

				    title: {
				        text: null//'24h 저수현황'
				    },
				    /*subtitle: {
				        text: 'Source: WorldClimate.com'
				    },*/

				    rangeSelector: {

				    	enabled: false,
				        /*buttons: [{
				            count: 1,
				            type: 'minute',
				            text: '1M'
				        }, {
				            count: 5,
				            type: 'minute',
				            text: '5M'
				        }, {
				            type: 'all',
				            text: 'All'
				        }],
				        selected: 0,
				        inputEnabled: false*/
				    },

				    //xAxis: xAxisConfig,
				    xAxis: [{
			            crosshair: true,
			            type: 'datetime',
			            //ordinal: false,
			            //tickInterval: 24*3600*1000,
				        //minorTickLength: 7,
				        tickLength: 0,
					    labels: {
					    	overflow: 'justify',
				            formatter: function () {
				            	return Highcharts.dateFormat('%y.%b.%d', this.value);
				            },
				            dateTimeLabelFormats: {
			                    //minute: '%H:%M',
			                    //hour: '%H:%M',
			                    day: '%b.%d',
			                    week: '%b.%d',
			                    month: '\'%y %b',
			                    year: '%Y'
				            },
				            labels: {
				                enabled: true,
				            },
					    }
				    }],
				    yAxis: [
				    	{
					        title: {
					            text: '총사용량 (㎥)',
					            //style: {color: Highcharts.getOptions().colors[1]}
					        },
					        labels: {
					        	align: 'left',
					        	x: 0,
					            format: '{value} ㎥',
					            //style: {color: Highcharts.getOptions().colors[1]},
					            formatter: function () {return Highcharts.numberFormat(this.value, 2);}
					        },
					        min: 0,
					        opposite: false,
					        height: '100%',
				            lineWidth: 0
					    },
				    	{
					        title: {
					            text: '전별사용량 (㎥/전)',
					            //style: {color: Highcharts.getOptions().colors[1]}
					        },
					        labels: {
					        	align: 'right',
					        	x: 0,
					            format: '{value} ㎥/전',
					            //style: {color: Highcharts.getOptions().colors[1]},
					            formatter: function () {return Highcharts.numberFormat(this.value, 2);}
					        },
					        min: 0,
					        opposite: true,
				            height: '100%',
				            lineWidth: 0
					    }/*,
				    	{
					        title: {
					            text: '검침수',
					            //style: {color: Highcharts.getOptions().colors[1]}
					        },
					        labels: {
					        	align: 'left',
					            format: '{value}',
					            x: 0,
					            formatter: function () {return Highcharts.numberFormat(this.value, 0);}
					        },
					        min: 0,
					        opposite: false,
					        top: '65%',
				            height: '35%',
				            offset: 0,
				            lineWidth: 0
					    },
				    	{
					        title: {
					            text: '시간 검침율 (%)',
					            //style: {color: Highcharts.getOptions().colors[1]}
					        },
					        labels: {
					        	align: 'right',
					            format: '{value} %',
					            x: 0,
					            formatter: function () {return Highcharts.numberFormat(this.value, 1);}
					        },
					        labels: {
					        	align: 'right',
					            format: '검침율 %',
					            x: 0,
					            formatter: function () {return Highcharts.numberFormat(this.value, 1);}
					        },
					        min: 0,
					        opposite: true,
					        top: '65%',
				            height: '35%',
				            offset: 0,
				            lineWidth: 0
					    },
				    	{
					        title: {
					            text: '일 검침율 (%)',
					            //style: {color: Highcharts.getOptions().colors[1]}
					        },
					        labels: {
					        	align: 'right',
					            format: '{value} %',
					            x: 0,
					            formatter: function () {return Highcharts.numberFormat(this.value, 1);}
					        },
					        min: 0,
					        opposite: true,
					        top: '65%',
				            height: '35%',
				            offset: 0,
				            lineWidth: 0
					    }*/
					],
				    series: [
					    {
					        name: '총 사용량',
					        type: 'area',
					        fillOpacity: 0.2,
					        //type: 'column',
					        //type: 'line',
					        lineWidth: 1,
					        yAxis: 0,
					        //zIndex: 2,
					        //lineWidth: 3,
					        //dashStyle: 'shortdot',
					        //color: Highcharts.getOptions().colors[0],
					        data: [],
					        tooltip: {valueDecimals: 3, valueSuffix: ' ㎥'}
					    },
					    {
					        name: '전별사용량',
					        ///*type: 'line',
					        lineWidth: 1,
					        type: 'area',
					        fillOpacity: 0.2,
					        yAxis: 1,
					        color: Highcharts.getOptions().colors[3],
					        //borderWidth: 2,
					        //borderColor: 'gray',
					        //color: 'orange',
					        data: [],
					        tooltip: {valueDecimals: 3, valueSuffix: ' ㎥/전'}
					    }/*,
					    {
					        name: '검침수',
					        type: 'column',
					        //color: 'gray',
					        color: Highcharts.getOptions().colors[9],
					        yAxis: 2,
					        data: [],
					        tooltip: {valueDecimals: 0, valueSuffix: ' 건'}
					    },
					    {
					        name: '시간 검침율',
					        type: 'line',
					        color: Highcharts.getOptions().colors[8],
					        //fillOpacity: 0.2,
					        yAxis: 3,
					        //borderWidth: 2,
					        //borderColor: 'gray',
					        data: [],
					        tooltip: {valueDecimals: 1, valueSuffix: ' %'}
					    },
					    {
					        name: '일 검침율',
					        type: 'line',
					        color: Highcharts.getOptions().colors[1],
					        //fillOpacity: 0.2,
					        yAxis: 4,
					        //borderWidth: 2,
					        //borderColor: 'gray',
					        data: [],
					        tooltip: {valueDecimals: 1, valueSuffix: ' %'}
					    }*/
				    ]
				});

				if(data)
					this.setDataSource(data);

				return this;
			};



			var ratioGraph = {
					dataType:null
				};

				ratioGraph.make = function(container, data) {
					if(!this.instance)
						this.instance = new BuildRatioStockchart(container, data)
				}
				ratioGraph.setDataSource = function(data, dataType) {
					if(this.instance) {
						this.dataType = dataType;
						this.instance.getChart().hideLoading();
						this.instance.setDataSource(data);
					}
				}
				ratioGraph.showLoading = function(mesg) {
					if(this.instance) {
						//this.instance.setDataSource([]);
						this.instance.getChart().showLoading(mesg);
					}
				}
				ratioGraph.hideLoading = function() {
					if(this.instance)
						this.instance.getChart().hideLoading();
				}

				/******************************************************************************/
				/*
				 *
				 */

				function BuildRatioStockchart(container, data)
				{
					var _chart;
					var xAxisDate = [];
					var tickInterval;
					var xDateFormat = '%Y-%m-%d';
					var tooltip = {};
					var xAxisConfig = [{
					        crosshair: true,
					        type: 'datetime',
						    labels: {
						    	overflow: 'justify',
					            formatter: function () {
					            	return Highcharts.dateFormat('%b.%d', this.value);
					            	//return Highcharts.dateFormat(xDateFormat, this.value);
					            },
					            dateTimeLabelFormats: {
					                minute: '%H:%M',
					                hour: '%H:%M',
					                //day: xDateFormat,
					                day: '%b.%d',
					                week: '%b.%d',
					                month: '%Y-%m',
					                year: '%Y'
					            },
					            labels: {
					                enabled: true,
					            },
					            minorTickLength: 0,
					            tickLength: 0
						    }
					    }];

					/******************************************************/

					this.setDataSource = function(data) {
						var seriesData = [[],[]];

						for(var ix=0; ix<seriesData.length; ix++)
							_chart.series[ix].setData([]);
						_chart.zoomOut();

						if(data) {
							var cnt = data.length;
							for(var ix=cnt-1; ix>=0; ix--) {
								var dateStr = data[ix].measDt;
								const [year, month, day] = dateStr.split('-').map(Number);
								var reDate = Date.UTC(year, month - 1, day);

								//seriesData[0].push([data[ix].measDt, data[ix].measRat]);
								//seriesData[1].push([data[ix].measDt, data[ix].dayMeasRat]);
								seriesData[0].push([reDate, data[ix].measRat]);
								seriesData[1].push([reDate, data[ix].dayMeasRat]);
							}
						}
						for(var ix=0; ix<seriesData.length; ix++) {
							_chart.series[ix].setData(seriesData[ix]);

							//-------------------------------------------------------
							// added by mona
							// change tooltip date format for each daily and monthly chart
							_chart.series[ix].update({
					            tooltip: tooltip
					        });
							//-------------------------------------------------------
						}

						_chart.zoomOut();
						//setTimeout(_chart.zoomOut(), 1000);
					}

					this.getChart = function() {
						return _chart;
					}

					var clickDetected = false;

					//_chart = Highcharts.stockChart(container, {
					_chart = Highcharts.chart(container, {
					    chart: {
					    	//renderTo: container,
					        //zoomType: 'xy'
					    	zoomType: 'x',
					    	events: {
					    		click: function(event) {
					                if(clickDetected) {
					                    //alert ('x: '+ event.xAxis[0].value +', y: '+ event.yAxis[0].value);
					                    this.zoomOut();
					                    clickDetected = false;
					                } else {
					                    clickDetected = true;
					                    setTimeout(function() {
					                        clickDetected = false;
					                    }, 500);
					                }
					            },
					            load: function(event) {
					            	/*var self = this;
					            	setTimeout(self.zoomOut(), 300);*/
					            	//this.zoomOut();
					            }
					    	}
					    },
					    plotOptions: {
					    	series: {
					    		//stickyTracking: false
					    		marker: {
					                fillColor: '#FFFFFF',
					                lineWidth: 1,
					                lineColor: null,
					                width: 5,
					                height: 5
					            }
					    	},
					    	dataGrouping: {
						        enabled: false
						    },
						    column: {
						        //groupPadding: 0.2,
						        //pointPadding: 0.37,
						        pointWidth: 5,
						    }
					    },
					    scrollbar: {
				            enabled: false
				        },
				        navigator: {
				        	enabled: false,
				        	xAxis: {
				                dateTimeLabelFormats: {
				                    minute: '%H:%M',
				                    hour: '%H:%M',
				                    //day: xDateFormat,
				                    day: '%b.%d',
				                    week: '%b.%d',
				                    month: '\'%y %b',
				                    year: '%Y'
				                }
				            }
				        },
					    //tooltip: tooltip,
				        tooltip: {
				            split: false,
					        shared: true,
					        xDateFormat: '<span style="font-size:12px;color:gray;">%Y.%b.%d</span>'
					    },
					    legend: {
					    	enabled: true,
					        floating: false,
					    	layout: 'horizontal',
					    	align: 'center',
					        verticalAlign: 'top'
					        //x: 80,
					        //y: 0,
					        //backgroundColor: (Highcharts.theme && Highcharts.theme.legendBackgroundColor) || '#FFFFFF'
					    },

					    title: {
					        text: null//'24h 저수현황'
					    },
					    /*subtitle: {
					        text: 'Source: WorldClimate.com'
					    },*/

					    rangeSelector: {

					    	enabled: false,
					        /*buttons: [{
					            count: 1,
					            type: 'minute',
					            text: '1M'
					        }, {
					            count: 5,
					            type: 'minute',
					            text: '5M'
					        }, {
					            type: 'all',
					            text: 'All'
					        }],
					        selected: 0,
					        inputEnabled: false*/
					    },

					    //xAxis: xAxisConfig,
					    xAxis: [{
				            crosshair: true,
				            type: 'datetime',
				            //ordinal: false,
				            //tickInterval: 24*3600*1000,
					        //minorTickLength: 7,
					        tickLength: 0,
							labels: {
								overflow: 'justify',
								formatter: function () {
									return Highcharts.dateFormat('%y.%b.%d', this.value);
								},
								dateTimeLabelFormats: {
									//minute: '%H:%M',
									//hour: '%H:%M',
									day: '%b.%d',
									week: '%b.%d',
									month: '\'%y %b',
									year: '%Y'
								},
								labels: {
									enabled: true,
								},
							}
					    }],
					    yAxis: [
					    	{
						        title: {
						            text: '시간 검침율 (%)',
						            //style: {color: Highcharts.getOptions().colors[1]}
						        },
						        labels: {
						        	align: 'left',
						        	x: 0,
						            format: '검침율 %',
						            //style: {color: Highcharts.getOptions().colors[1]},
						            formatter: function () {return Highcharts.numberFormat(this.value, 1);}
						        },
						        min: 0,
						        opposite: false,
						        height: '100%',
					            lineWidth: 0
						    },
					    	{
						        title: {
						            text: '일 검침률 (%)',
						            //style: {color: Highcharts.getOptions().colors[1]}
						        },
						        labels: {
						        	align: 'right',
						        	x: 0,
						            format: '검침율 %',
						            //style: {color: Highcharts.getOptions().colors[1]},
						            formatter: function () {return Highcharts.numberFormat(this.value, 1);}
						        },
						        min: 0,
						        opposite: true,
					            height: '100%',
					            lineWidth: 0
						    }/*,
					    	{
						        title: {
						            text: '검침수',
						            //style: {color: Highcharts.getOptions().colors[1]}
						        },
						        labels: {
						        	align: 'left',
						            format: '{value}',
						            x: 0,
						            formatter: function () {return Highcharts.numberFormat(this.value, 0);}
						        },
						        min: 0,
						        opposite: false,
						        top: '65%',
					            height: '35%',
					            offset: 0,
					            lineWidth: 0
						    },
					    	{
						        title: {
						            text: '시간 검침율 (%)',
						            //style: {color: Highcharts.getOptions().colors[1]}
						        },
						        labels: {
						        	align: 'right',
						            format: '{value} %',
						            x: 0,
						            formatter: function () {return Highcharts.numberFormat(this.value, 1);}
						        },
						        labels: {
						        	align: 'right',
						            format: '검침율 %',
						            x: 0,
						            formatter: function () {return Highcharts.numberFormat(this.value, 1);}
						        },
						        min: 0,
						        opposite: true,
						        top: '65%',
					            height: '35%',
					            offset: 0,
					            lineWidth: 0
						    },
					    	{
						        title: {
						            text: '일 검침율 (%)',
						            //style: {color: Highcharts.getOptions().colors[1]}
						        },
						        labels: {
						        	align: 'right',
						            format: '{value} %',
						            x: 0,
						            formatter: function () {return Highcharts.numberFormat(this.value, 1);}
						        },
						        min: 0,
						        opposite: true,
						        top: '65%',
					            height: '35%',
					            offset: 0,
					            lineWidth: 0
						    }*/
						],
					    series: [
						    {
						        name: '시간 검침률',
						        type: 'area',
						        fillOpacity: 0.2,
						        //type: 'column',
						        //type: 'line',
						        lineWidth: 1,
						        yAxis: 0,
						        //zIndex: 2,
						        //lineWidth: 3,
						        //dashStyle: 'shortdot',
						        //color: Highcharts.getOptions().colors[0],
						        data: [],
						        tooltip: {valueDecimals: 3, valueSuffix: ' %'}
						    },
						    {
						        name: '일 검침률',
						        ///*type: 'line',
						        lineWidth: 1,
						        type: 'area',
						        fillOpacity: 0.2,
						        yAxis: 1,
						        color: Highcharts.getOptions().colors[3],
						        //borderWidth: 2,
						        //borderColor: 'gray',
						        //color: 'orange',
						        data: [],
						        tooltip: {valueDecimals: 3, valueSuffix: ' %'}
						    }/*,
						    {
						        name: '검침수',
						        type: 'column',
						        //color: 'gray',
						        color: Highcharts.getOptions().colors[9],
						        yAxis: 2,
						        data: [],
						        tooltip: {valueDecimals: 0, valueSuffix: ' 건'}
						    },
						    {
						        name: '시간 검침율',
						        type: 'line',
						        color: Highcharts.getOptions().colors[8],
						        //fillOpacity: 0.2,
						        yAxis: 3,
						        //borderWidth: 2,
						        //borderColor: 'gray',
						        data: [],
						        tooltip: {valueDecimals: 1, valueSuffix: ' %'}
						    },
						    {
						        name: '일 검침율',
						        type: 'line',
						        color: Highcharts.getOptions().colors[1],
						        //fillOpacity: 0.2,
						        yAxis: 4,
						        //borderWidth: 2,
						        //borderColor: 'gray',
						        data: [],
						        tooltip: {valueDecimals: 1, valueSuffix: ' %'}
						    }*/
					    ]
					});

					if(data)
						this.setDataSource(data);

					return this;
				};
