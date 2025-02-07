<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="contextPath" value="<%=request.getContextPath()%>"></c:set>
<%@ page language="java" session="false"
	contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>

<%@include file="/resources/inc/meta.inc"%>
<title>스마트수도미터원격검침시스템</title>

<%@include file="/resources/inc/base.inc"%>
<%@include file="/resources/inc/jsgrid.inc"%>
<%@include file="/resources/inc/hichart.inc"%>
<%@include file="/resources/inc/validation.inc"%>

<!-- 대량누수검출 ISTC_F11_2 -->
<script type="text/javascript">

	var _animate = !AceApp.Util.isReducedMotion();
	
	var paramsT;

	var mainGrid;
	
	var rawGrid;
	
	var rawChart;
	
	var dbParams;
	
	var dbParamsTb = 'f9-2-export';
	
	var pointListData;
		
	var leakSetting;
	
	var _chartObj = new Object();
	
	var stringByteLength;
	
	
	$(function(){
		
	
		
		/*
		* 페이지 리싸이징
		*/
		$(window).resize(function () {
			
			/* main grid layout */
			layoutSize();
			
		});  	
		
		/* main grid layout */
		layoutSize();
		
		
		/* 엑셀다운도르를 위한 db 파람조회  */
		getDbtableInfo();
		
		mainGrid  = initGrid('mainGrid', mainFields);
		
		rawGrid   = initGrid('rawGrid', rawFields);
		
		rawChart = new rawStockchart('rawChart');
		
		rawChart.initChart('rawChart');
		
		loadSettingData(function() {
		
			mainGrid.search();
			
		});
		
		setSubmitValidation('settingForm', updateLeakSetting);
		
		$.validator.addMethod(
			"leak_priod",
			function(value, element, param) {
				//if( !(_point.input_change && _point.remote_fail) ) return true;
				
				var rDays = parseInt(value);
				var obDays = parseInt( $(this.currentForm).find('#obDays').val() );
				
				if(rDays >= obDays) return false;
							
				return true; 
			}
		);
			
	});
	
	
	/*
	* 리소스 path
 	*/
	function getContextPath() {
		
	   return "${contextPath}";
	   
	};
	
	function getAbsolutepath(path) {
		
		return '${contextPath}/' + path;
		
	};
	
	function getUserRoll() {
		
		return ${user.getUserRoll()};
		
	};
	
	/*
	* 레이아웃 사이즈
	*/
	function layoutSize() {
	
		var ht1 = $(window).innerHeight();
		var off = $('#gridContainer').offset();

		if (off) {

			var ht = ht1 - off.top - 10;
			$('#gridContainer').height(ht);

		}
		
	};
	
	function modalGridLayout(modal, height) {
		
		modal.find('.jsgrid-grid-body').css('height',  height + 'px');
		
		
		$(window).resize(function () {
			
			modal.find('.jsgrid-grid-body').css('height',  height + 'px');
			
		});
		
	};
	
	function loadHisData(params) {
		
		if(!params && !paramsT) {
			
			jAlert.error('저장', '알 수 없는 이상이 발생하였습니다.');
			return;
			
		} 
		
		if(params) {
			paramsT = params;
			rawGrid.resetSorting();
		}
			
		var qid = (paramsT.dayWeekType == 0) ? 'mars.icbm.map1.pointHisdata' : 'mars.icbm.map1.pointWeekHisdata';
		
		
		var loadParams = rawGrid.loadParams();				
		paramsT = $.extend(paramsT, loadParams);
		
		getAjax(qid, paramsT, function() {
   		 
   		 $('.bcard.point-grid').aceWidget('startLoading');
   		 
	   	 }, function(data) {
	   		 
	   		if(params)
				rawChart.setDataSource(data);	
			
			rawGrid.command('refreshData', data);
			
			$('#rawModal').modal();
			
			$('.bcard.point-grid').aceWidget('stopLoading');
				
		 }, true);
	
		
	};
	
	function loadData(qid, params, callback) {
		
		var qid = qid ? qid : 'mars.icbm.map1.iqrLeak_paging';
		//var qid = qid ? qid : 'mars.icbm.map1.pointList_paging';
		var params = params ? params :  makeParams();			
		
		/* 수용가 조회 */
		getAjax(qid, params, function() {

			/* 로딩 시작 */
			$('.bcard.point-grid').aceWidget('startLoading');

		}, function(result) {
			
			if(callback) {
				
				callback(result);
				return;
			}
				
			
			pointListData = result;
			
			refreshGrid(mainGrid, result);
			
			$('.bcard.point-grid').aceWidget('stopLoading');
			
		}, null);
		
			
		return false;
	};
	
	
	
	function loadRawData() {};

	function loadSettingData(callback) {
		
		var params = new Object();
		$.extend(params, parent.searchComponentes);
		params.limit = 1;
		
		getAjax('mars.icbm.map1.leakSetting', params, null, function(result) {
			
			if(result.length > 0) {
				
				leakSetting = result[0];	
				
				pushData(leakSetting);		
				
				if(callback)
					callback();
				
			}
			
		}, null);
			
		return false;
	};
	

	function pushData(data) {
		
		var elList = $('#settingForm').find('input');
		
		$.each(elList, function(i, item) {
			
			var id = $(item).attr('id');
			if(id) {
				
				var value = data[id];
				$(item).val( value );
				
			}
						
		});
		
	};
	
	
	/*
	* 그리드 갱신
 	*/
	function refreshGrid(grid, data) {
		
		if(data)
			grid.finishLoad(data||[]);
		else
			grid.command('refresh');
			
	};
		
	var colfnc = function(value, item, c, d, e) {
		
		switch (this.name) {
		case 'num':		
			if(!item.pageNo) return c + 1;
			return (item.pageNo - 1) * item.pageSize + (c + 1);
		case 'blkNm':
			value = item.blkNm;
			if(value && value.indexOf(':') >= 0)
				value = value.substr(value.indexOf(':')+1);
			return value;
		case 'termCh':
			if(item.termCv != null && item.intavlH)
				return kutil.v2n(item.termCv / item.intavlH, 3);
			return '-';
		case 'statCd':
			if(!value)
				return '-';
				
			return item.statCd == 1 ? '누수의심' : '누수';
		
		case 'leakMeasDt':			
			if(!value)
				return '-';
			var dt = new Date(value);		
			return '<small>' + kutil.dateFormat(dt, 'yy.mm.dd') +' </small> ' +
				kutil.dateFormat(dt, 'HH:MM');	
					
		case 'measDt':
			if(!value)
				return '-';
			var dt = new Date(value);		
			return '<small>' + kutil.dateFormat(dt, 'yy.mm.dd') +' </small> '	
			
		
			

		}
		
		
		return (value||value==0)?value:'-';
	};


	var groups = [
		{title:'구분', columns: 2, align:"center"},
		{title:'수용가', columns: 3, align:"center"},
		{title:'최초 누수감지 정보', columns: 6, align:"center"},
		{title:'검침데이터', columns: 1, align:"center"}		
	];



	var rawFields = [
		{ name: "measDt", 		title: "검침일", 		type: "text", 	align:"center", width: 40, itemTemplate:colfnc},
		//{ name: "termCv", 		title: "구간 사용량(㎥)",	type: "number",   width: 50, itemTemplate:colfnc, sortingDisabled:true},
		{ name: "termCv", 		title: "사용량(㎥/d)",	type: "number", align:"center", width: 50, itemTemplate:colfnc}    
	    /*{ name: "accuIv", 		title: "최종지침(㎥)", 	type: "number", align:"right",  width: 60, itemTemplate:colfnc , sortingDisabled:true}*/
	];

	var mainFields = [	
		{ name: "num", 		title: "순번", 	type: "text", align:"center", 	width: 30, 	itemTemplate:colfnc, sortingDisabled:true},
	    { name: "blkNm",        title: "블록", 		 type: "text",   		width: 50, 		itemTemplate:colfnc, hasGroup:true, group:groups[0]},
	    /*{ name: "useType",      title: "업종", 		 type: "text",  		width: 40,  		itemTemplate:colfnc, hasGroup:true},*/
	    { name: "pipeDia",      title: "관경(mm)", 	 type: "text",  		width: 40,  		itemTemplate:colfnc, hasGroup:true},
	    
	    
	    { name: "adminId",      title: "수용가 번호", 	 type: "text",   width: 70, itemTemplate:colfnc, hasGroup:true, group:groups[1]},
	    { name: "custNm",       title: "이름", 		 type: "text",   width: 60, itemTemplate:colfnc, hasGroup:true},
	    { name: "readOpr",       title: "검침원", 	 type: "text",   width: 40, itemTemplate:colfnc, hasGroup:true},
	    
	    
	    { name: "q1",         title: "Q1", 		 type: "text",   width: 40, itemTemplate:colfnc, hasGroup:true, group:groups[2]},
	    { name: "q2",         title: "Q2", 		 type: "text",   width: 40, itemTemplate:colfnc, hasGroup:true},
	    { name: "iqr",         title: "기준차이", 		 type: "text",   width: 60, itemTemplate:colfnc, hasGroup:true},
	    { name: "iqr30",       title: "누수 기준", 		 type: "text",   width: 60, itemTemplate:colfnc, hasGroup:true},
	    { name: "iqr15",       	title: "경보 기준", 		 type: "text",   width: 60, itemTemplate:colfnc, hasGroup:true},
	    /* { name: "termCv",      title: "사용량(㎥/d)", 		 type: "text",   width: 60, itemTemplate:colfnc, hasGroup:true}, */
	    //{ name: "statCd", 	title: "누수상태", 	 type: "text",   align:"left", width: 50,  itemTemplate:colfnc, hasGroup:true},
	    { name: "measDt",      title: "일시", 		 type: "text",   width: 40, itemTemplate:colfnc, hasGroup:true},
	    
	    
	 /*  {
			title : "사용량 (㎥/d)",
			itemTemplate : function(_, item) {

				return $("<div>").attr('id', item.pointSq + '_dataList');

			},
			hasGroup : true,
			sortingDisabled:true,
			align:"center",
			group:groups[3]
		}, */
		//{ name: "leakMeasDt", 	title: "최종검침일", 	 type: "text",   align:"center", width: 60,  itemTemplate:colfnc, hasGroup:true},	
	    {       		
        itemTemplate: function(_, item) {
        	
        	var icon = $("<span>").addClass("fa fa-search")
			  					  .attr("data-point", item.pointSq);
        	
        	var btn = $("<button>").attr("type", "button")
            	     .addClass("btn btn-md trans")		                    	            		 
            	     .attr("data-point", item.pointSq)
                     .on("click", function (evt) {
                    	 
                    	 var seq = $(this).data('point');	
                    	 if(!seq) {
                    		 
                    		jAlert.alert('오류', '해당 지점 상세 데이터 조회 불가.');
                 			return;
                 			
                    	 }
                    	 
                    	 var seq = item.pointSq;

         				if (!seq)
         					return;

         				var d = new Date();			
         				var params = {
         						
         					pointSq : seq,
         					begDate : kutil.dateFormat( d.setDate(d.getDate() - leakSetting.obDays -1), 'yyyy-mm-dd' ),
         					endDate : kutil.dateFormat(new Date(), 'yyyy-mm-dd'),
         					dayWeekType : 0
         					
         				}

         				loadHisData(params);
         		
                    	             		                    
                     });
        	
	        	btn.append(icon);
	        		        		        
	            return btn;
	        },		     
	        title: "일간",
	        align: "center",
	        width: 40,
	        group:groups[3],
	        hasGroup:true,
	        sortingDisabled:true            	       
	    }/* ,
	    {       		
	        itemTemplate: function(_, item) {
	        	
	        	var icon = $("<span>").addClass("fa fa-search")
				  					  .attr("data-point", item.pointSq);
	        	
	        	var btn = $("<button>").attr("type", "button")
	            	     .addClass("btn btn-md trans")		                    	            		 
	            	     .attr("data-point", item.pointSq)
	                     .on("click", function (evt) {
	                    	 
	                    	 
	                    	 
	                    	 var seq = $(this).data('point');	
	                    	 if(!seq) {
	                    		 
	                    		jAlert.alert('오류', '해당 지점 상세 데이터 조회 불가.');
	                 			return;
	                 			
	                    	 }
	                    	 
	                    	 var seq = item.pointSq;
	
	         				if (!seq)
	         					return;
	
	         				var d = new Date();			
	         				var params = {
	         						
	         					pointSq : seq,
	         					begDate : kutil.dateFormat( d.setDate(d.getDate() - leakSetting.obDays -1), 'yyyy-mm-dd' ),
	         					endDate : kutil.dateFormat(new Date(), 'yyyy-mm-dd'),
	         					dayWeekType : 1
	         					
	         				}

	         				loadHisData(params);
	         
	                    	             		                    
	                     });
	        	
	        	btn.append(icon);
	        		        		        
	            return btn;
	        },		     
	        title: "주간",
	        align: "center",
	        width: 40,        
	        hasGroup:true,
	        sortingDisabled:true            	       
	    } */
	    
	];



	function initGrid(container, fields, searchContainer, loadFn) {
	    
	    var opt = {
	        height: "100%",
	        width: "100%",
	        sorting: true,
	        
	        
	        pageLoading: true,       
	        paging: true,        
	        pageSize: 50,
		 	pageButtonCount: 5, 	// 페이지 버튼 개수
		 	pagerFormat: "{first} {prev} {pages} {next} {last}    {pageIndex} of {pageCount}",	        
	        pagePrevText: "이전",
	        pageNextText: "다음",
	        pageFirstText: "처음",
	        pageLastText: "마지막",	     
	        
	        
	        rnTop: 50,
	        rnBottom: 0,
	        
	        searchContainer: '#searchInput',
	        

	        fields: fields,
	        
	        loadStrategy: function() {			
	        	
	        	return new CustomPageLoadingStrategy(this, loadData);
	        	
	        },
		    rowDoubleClick: function(evt) {
		    	
		    }
	    };
	    
	    return new DataGrid(container, opt);
	};
	
	
	function openSettingModal() {
		
		var modal = $('#settingModal');
		
		modal.modal({backdrop: 'static', keyboard: false});
		
		modalGridLayout(modal, 50);
		
	};

	

	function ajaxPost(url, params , callback) {
		//return;
		$.ajax({			
			url : url,
			data : JSON.stringify(params),
			type : "POST",
			contentType : 'application/json;charset=UTF-8',
			async : true,  
			success: function(data, status, xhr) {

		        if(callback) callback(data, status, xhr);
		    },
			error : function(data, status, xhr) {

				if(callback) callback(data, status, xhr);

			}
		});
		
	};
	
	function makeParams() {
		
		var params = {};

		$.extend(params, parent.searchComponentes);
		$.extend(params, mainGrid.loadParams());
		
		params.searchOption = $('#searchOptionSelect').val();

		params.useCd = '1';
		params['obDays'] = leakSetting.obDays;
		params['rDays'] = leakSetting.rDays;
		
		return params; 
	};


	function setSubmitValidation(id, fn){
		
		var _form = $('#' + id);	
		
		_form.validate({
			focusCleanup: false,		
			onfocusout: false,
			onkeyup: false,
			focusInvalid: false,
			showErrors : function(errorMap, errorList) {
				validate_util.setError(this, errorList);
			},
			onfocusin : function(element){			
				validate_util.setValid(this, element);			
			},
			submitHandler: function(e) {	
				if(fn)
					fn(e);
			},
	        rules: validate_util.rules,
	        messages: validate_util.messages
		});
			
		_form.submit(function(){
			_form.valid();
		})	
		
	};

	function updateLeakSetting(e) {
		
		var params = new Object();	
		var inList = $(e).find('input');
		
		
		$.each(inList, function(i, item) {
			
			var id = $(item).attr('id');
			params[id] = Number($(item).val());
						
		});
		
		$.extend(params, parent.searchComponentes);
		
		var result = ajaxUpdate({sql:'mars.icbm.map1.updateleakSetting', data:params});
		if(!result.success) {
			
			jAlert.error('저장', '정보를 저장하지 못하였습니다.<br><br>'+ (result.error?result.error.statusText:'서버에서 오류가 발생하였습니다.'));
			return false;
			
		}
		
		jAlert.info('저장', '수정한 정보를 저장 완료하였습니다.');
		
		loadSettingData(function() {
			
			mainGrid.search();
			
		});
		
		$('button[name="closeBtn"]').click();
		
		return true;
		
	};
	
	function findObject(list, key, value) {
		
		var result;
		list.some(function(item) {
			
			if(item[key] && item[key] == value) {
				
				result = item;
				return true;
				
			}
			
		});
		
		return result;		
	};

	function refreshChart(id, data1, data2) {};


	function setTimer(data) {};
		
	function saveTimer() {};
		

	function updateSiteItems(data) {};
		

	function rawStockchart(container, data) 
	{
		var _chart;
		
		/******************************************************/
		
		this.setDataSource = function(data) {
			var seriesData = [[]];
			
			for(var ix=0; ix<seriesData.length; ix++) {
				_chart.series[ix].setData([]);
			}
			_chart.zoomOut();
			
			if(data) {
				var cnt = data.length;

				for(var ix=data.length-1; ix>=0; ix--) {
					
					if(data[ix].pointSq) {					
						seriesData[0].push([data[ix].measDt, data[ix].termCv]);										
					}													
					else {
						seriesData[0].push([data[ix].measDt, null] );					
					}
						
					
				}
			}
			
			for(var ix=0; ix<seriesData.length; ix++) {
				_chart.series[ix].setData(seriesData[ix]);
			}
			_chart.zoomOut();
		}

		this.getChart = function() {
			return _chart;
		}
		
		this.getConfig = function() {
			return _config;
		}
		
		var clickDetected = false;
		
	    var clr = [
	    	Highcharts.getOptions().colors[0],    	
	    ]
	    for(var ix=0; ix<clr.length; ix++)
			clr[ix] = (new Highcharts.Color(clr[ix])).setOpacity(1).get();	

		var _config = {
		    chart: {
		    	//renderTo: container, 
		        //zoomType: 'xy'
		    	zoomType: 'x',
		    	events: {
		    		click: function(event) {
		                if(clickDetected) {
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
		            	
		            }
		    	}	    	
		    },
		    plotOptions: {
			    dataGrouping: {
			        enabled: false
			    }	    
		    },
		    scrollbar: {
	            enabled: false
	        },
	        navigator: {
	        	xAxis: {
	                dateTimeLabelFormats: {
	                    minute: '%H:%M',
	                    hour: '%H:%M',
	                    day: '%b.%d',
	                    week: '%b.%d',
	                    month: '\'%y %b',
	                    year: '%Y'
	                }
	            }
	        },
		    tooltip: {
	            split: false,
		        shared: true,
		        xDateFormat: '<span style="font-size:12px;color:gray;">%Y.%b.%d %H:%M:%S</span>'
		    },
		    legend: {
		    	enabled: true,
		        floating: false,
		    	layout: 'horizontal',
		    	align: 'center',
		        verticalAlign: 'top'
		    },

		    title: {
		        text: null//'24h 저수현황'
		    },
		    rangeSelector: {
		    	enabled: false,
		    },
		    
		    xAxis: [{
	            crosshair: true,
	            type: 'datetime',
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
			            text: '사용량(㎥/d)',
			        },
			        labels: {
			        	align: 'left',
			        	x: 3,
			            //format: '{value}㎥/H',
			            formatter: function () {return Highcharts.numberFormat(this.value, 1);}
			        },
			        opposite: false,		        
			        height: '100%',
		            lineWidth: 0
			    }
			],
		    series: [
			    {
			        name: '사용량',
			        type: 'line',
			        yAxis: 0,
			        data: [],		        
				    dataGrouping: {
				        enabled: false
				    },
				    tooltip: {valueDecimals: 3, valueSuffix: ' ㎥/h'}
			    } 	
		    ]
		};
		
		this.initChart = function(container, data) {
			var config = $.extend(true, {}, _config);
			_chart = Highcharts.stockChart(container, config);

			if(data)
				this.setDataSource(data);
		};
		
		return this;
	};




	function getAjax(qid, params, beforesend, callback, errCallback, async) {

		ajaxSelect({
			sql : qid,
			data : params,
			async : async ? async : true,
			beforeSend : function() {

				if (beforesend)
					beforesend();

			},
			success : function(result) {

				if (callback)
					callback(result);

			},
			error : function(error) {
				
				if(error.status == 401) {
					
					parent.document.location.reload();
					return;
				}

				if (errCallback)
					errCallback(error);

				refreshGrid([]);

				var msg = '데이터를 읽을 수 없습니다.<br>';
				msg += (error.responseText ? error.responseText.trim()
						: '서버에 오류가 있습니다.');

				jAlert.error('오류', msg);

			}
		});

	};
	
	
	/**
	 * 미터기 DB 테이블 기본 정보를 가져옵니다.
	 */
	function getDbtableInfo() {

		var url = getContextPath() + '/file/dbParams/' + dbParamsTb;

		ajaxSelect({
			url : url,
			success : function(data) {
				
				dbParams = data;				
				
			},
			error : function(result) {
				
				jAlert.error('오류', '데이터를 가져오는데 실패하였습니다.');
				
			}
		});

	};
	
	
	function dataDownload() {

		
		if(!dbParams) {
			
			jAlert.error('오류', '조건이 맞지 않아 데이터를 다운로드할 수 없습니다.');
			return;
			
		} 

		var params = new Object();
				
		params.qid = dbParams[dbParamsTb]['refer-sql'];
		params.colMapping = dbParams[dbParamsTb]['cols'];
		params.length = params.colMapping.length;

		
		params.downloadFileName = "WaterMaxLeak__"+ kutil.dateFormat( new Date(), 'yymmddHHMMss');							
		$.extend(params, makeParams());

		templetDownLoad(params, null, null, function() {
			
			jAlert.error('오류', '다운로드에 실패했습니다.');
			
		}); 

	};
	
	/* 단말번호 검색을 위한 스크립트 */
	 function selectChangHandler(el) {
		
			var searchOption = $(el).val();
			var target = $('#' + $(el).data('target'));
			var plh;
			
			plh = (searchOption == 0) ? '수용가 번호/이름/주소 ...' : '단말기 번호/미터기 번호 ...'; 
			
			target.attr('placeholder', plh);
			
		};
	
	
</script>

<style type="text/css">

	
	
</style>

	

</head>



<body>
	<div role="main" class="sub-content">
		<%@ include file="ISTC_F0_1_11.jsp" %>
		<div class="sub-cont-header">
			<h6></h6>
			<div class="sub-cont-header-area">
			</div>
		</div>
		<div class="dj-card">
			<div class="bcard card point-grid">
				<div class="card-body p-0" id="gridContainer">
				<div id="mainGrid" class="data-list containerBorder" style="width: 100%; height: 100%;"></div>
			</div>
			</div>
		</div>
	</div>
	
	
	
   
   
   
   
   <div class="modal fade dialog-80" id="settingModal" tabindex="-1" role="dialog">
     <div class="modal-dialog modal-dialog-scrollable" role="document">
       <div class="modal-content">
         <div class="modal-header">
           <h5 class="modal-title">
             	누수 설정
           </h5>

           <button type="button" class="close" data-dismiss="modal" aria-label="Close" name="closeBtn">
	          <span aria-hidden="true">&times;</span>
	        </button>
         </div>

		<form id="settingForm" class="mt-lg-3 validator" autocomplete="off"  data-toggle="validator" role="form">

        	<div class="modal-body">
      	
				<div class="bcard ccard  overflow-hidden">
					<div class="card-header border-0 bgc-white card-header-sm">
						<h6 class="card-title text-dark-m3 pl-25 pt-15 text-110">
							사용자 설정 <br>
							<span class="text-85 text-dark-l2"></span>										
						</h6>
					</div>
	
					<div class="card-body p-0 bgc-whit flex-grow-1">
					
						<div class="form-group row">
							
							<div class="col-sm-6 row">
				                <div class="col-sm-3 col-form-label text-sm-right pr-0">
				                  <label for="obDays" class="mb-0">
				                    	기간(일)
				                  </label>
				                </div>
				
				                <div class="col-sm-9">
				                  <input type="text" class="form-control" id="obDays" name="obDays"/>
				                  <label for="obDays" generated="true" class="error errclr">1~50일로 지정하세요.</label>
				                </div>			                               
			                </div>
			                
			                <div class="col-sm-6 row">
				                <div class="col-sm-3 col-form-label text-sm-right pr-0">
				                  <label for="rDays" class="mb-0">
				                    	판단일 (일)
				                  </label>
				                </div>
				
				                <div class="col-sm-9">
				                  <input type="text" class="form-control" id="rDays" name="rDays"/>
				                  <label for="rDays" generated="true" class="error errclr">1~10일로 지정하세요.</label>
				                </div>			                               
		               		</div>
			                
		               </div>
	
					</div>
				</div>
				
            

	         </div>
	         
	         <div class="modal-footer">
		        
		        <button class="btn btn-info btn-bold px-4" type="submit">
	                  <i class="fa fa-check mr-1"></i>저장                  	
	            </button>
		        
	      	</div>

		</form>
         
       </div>
     </div>
   </div>
   
   
   
   
   
   
   
   
   
   <div class="modal fade dialog-50" id="rawModal" tabindex="-1" role="dialog">
     <div class="modal-dialog modal-dialog-scrollable" role="document">
       <div class="modal-content">
         <div class="modal-header">
           <h5 class="modal-title">
             	상세 데이터 조회
           </h5>

           <button type="button" class="close" data-dismiss="modal" aria-label="Close" name="closeBtn">
	          <span aria-hidden="true">&times;</span>
	        </button>
         </div>

		<form id="settingForm" class="mt-lg-3 validator" autocomplete="off"  data-toggle="validator" role="form">

        	<div class="modal-body">
      	
				<div class="bcard ccard  overflow-hidden">
					<div class="card-header border-0 bgc-white card-header-sm">
						<h6 class="card-title text-dark-m3 pl-25 pt-15 text-110">
							사용자 설정 <br>
							<span class="text-85 text-dark-l2"></span>										
						</h6>
					</div>
	
					<div class="card-body p-0 bgc-whit flex-grow-1">
					
						<div id="rawChart" style="height:240px;"></div>
					
						<div id="rawContainer">					
							<div id="rawGrid" class="data-list"></div>
						</div>
	
					</div>
				</div>
				
            

	         </div>

		</form>
         
       </div>
     </div>
   </div>
	
	
	
	
	
	
	
	
	
	
	
	



	<script type="text/javascript" src="${contextPath}/resources/lib/chart.js/dist/Chart.js"></script>	
	

</body>



</html>

