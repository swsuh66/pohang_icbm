<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="contextPath" value="<%=request.getContextPath()%>"></c:set>
<%@ page language="java" session="false"
	contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>

<%@include file="/resources/inc/meta.inc"%>
<title>스마트수도미터원격검침시스템</title>

<%@include file="/resources/inc/base.inc"%>
<%@include file="/resources/inc/jsgrid.inc"%>
<%@include file="/resources/inc/hichart.inc"%>

<script type="text/javascript">
	
	var statChart;
	var tRatioChart;
	var dRatioChart;
	var mainGrid;
	var errGrid;
	var dbParams;
	var dbParamsTb = 'f10-export';
	
	var gisFrame; // 메서드호출용
	var gisFrameDoc; // 태그호출용

	/*
	 * 대쉬보드 index 기억
	 */
	var dashSearchComponentes = {
		//meterStat: 'statCdSumarySimple',
		meterStat: 'statCdSumarySimple',		
		timeRatio: 1,
		dayRatio: 1,
		used: 1,		
		ratioGraph: 1
	};
	
	$(function(){
		var obj = {};
		
		$(window).resize(function () {
			layoutSize('useGraph'); 
			layoutSize('ratioGraph');
			layoutSizePage2();
		});
		layoutSize('useGraph');
		layoutSize('ratioGraph');
		layoutSizePage2();
		 
		gisFrame = document.getElementById('gisIframe').contentWindow;
	});
	
	/*
	* 특정 요소 리사이징
 	*/
	function layoutSize(id, px) {
		$("#" + id).width('100%');
		if(!px) {
			return;
		}
		var ht1 = $(window).innerHeight();
		var off = $("#" + id).offset();
		if(off) {
			var ht = ht1 - off.top - px;
			$("#" + id).height(ht);			
		}
	};
	
	/*
	* page2 요소들 page1 높이에 맞춤
 	*/
	function layoutSizePage2() {
		var ht = $('.page-content[name="page-1"]').innerHeight();
		$('#bodyContainer').height(ht - 100 + 48);
		$('#gridContainer').height(ht - 100);
	};
	/*
	* 모든데이터 로드
 	*/
	function loadAll() {
		/* 계량기 상태이상 데이터 조회 */
		loadStat();
		/* 시간 검침률 조회 */
		loadTimeRatio('selectRatio'); // 직전 1일
		/* 일 검침률 조회 */
		loadDayRatio('selectRatio'); // 직전 1일
		/* 사용량 추이 조회 */
		loadUse('selectAnalyResult'); // 30일 데이터
		/* 검침률 그래프 조회 */
		loadRatioGraph('selectAnalyResult'); // 30일 데이터
	};
	
	/*
	* 계량기 상태 조회
 	*/
	function loadStat() {
		var obj = {};
		$.extend(obj, parent.searchComponentes);
		var qid = dashSearchComponentes.meterStat; 
		/* 계량기 상태이상 데이터 조회 */
		getAjax(qid, obj, gisFrame.startStatLoading, gisFrame.refreshStat, gisFrame.stopStatLoading);
	};

	/*
	* 시간 검침률 조회
 	*/
	function loadTimeRatio(qid) {
		var obj = new Object();		
		obj.day = dashSearchComponentes.timeRatio;
		obj.indexOf = 1;
		$.extend(obj, parent.searchComponentes);
		/* 계량기 상태이상 데이터 조회 */
		getAjax(qid, obj, gisFrame.startTimeRatioLoading, gisFrame.refreshTimeRatioChart,gisFrame.stopTimeRatioLoading);
	};
	
	/*
	* 일 검침률 조회
 	*/
	function loadDayRatio(qid) {
		var obj = new Object();
		obj.day = dashSearchComponentes.dayRatio; 
		obj.indexOf = 2;
		$.extend(obj, parent.searchComponentes);
		/* 계량기 상태이상 데이터 조회 */
		getAjax(qid, obj, gisFrame.startDayRatioLoading, gisFrame.refreshDayRatioChart, gisFrame.stopDayRatioLoading);
	};
	
	/*
	* 사용량 그래프 조회
	*/
	function loadUse(qid) {
		var params = new Object();
		params.toDate = kutil.dateFormat(new Date(), 'yyyy-mm-dd');
		var fromDate = kutil.dateFormat(kutil.addMonth(params.toDate, -1 * dashSearchComponentes.used), 'yyyy-mm-dd');
		params.fromDate = fromDate;
		$.extend(params, parent.searchComponentes);
		/* 사용량 및 검침률 그래프 데이터 조회 */
		getAjax(qid, params, function() {
			/* 사용량 그래프 로딩 시작 */
			$('.bcard.use-graph').aceWidget('startLoading');
		}, gisFrame.refreshUsed, function() {
			/* 사용량 그래프 로딩 종료 */
			$('.bcard.use-graph').aceWidget('stopLoading');
		});
	};
        
        /*
        * 검침률 그래프 조회
        */
        function loadRatioGraph(qid) {
            var params = new Object();
            params.toDate = kutil.dateFormat(new Date(), 'yyyy-mm-dd');
            var fromDate = kutil.dateFormat(kutil.addMonth(params.toDate, -1 * dashSearchComponentes.ratioGraph), 'yyyy-mm-dd');
            params.fromDate = fromDate;
            $.extend(params, parent.searchComponentes);
            /* 사용량 및 검침률 그래프 데이터 조회 */
            getAjax(qid, params, function() {
                /* 검침률 그래프 로딩 시작 */
                $('.bcard.ratio-graph').aceWidget('startLoading');
            }, gisFrame.refreshRaioGraph, function() {
                /* 검침률 그래프 로딩 종료 */
                $('.bcard.ratio-graph').aceWidget('stopLoading');
            });
        };
	
	/*
	* 드롭 다운 선택 셀렉트 박스 갱신 핸들러
 	*/
	function toolBarChangHandler(el) {
		var nm = $(el).data('target-nm');
		var txt = $(el).text();
		/* 버튼 active */
		$('div[name="' + nm + '"] .dropdown-item' ).removeClass('active btn-a-bold');
		$(el).addClass('active btn-a-bold');
		/* 표시 세팅 */
		$('div[name="' + nm + '"] a.dropdown-toggle' ).text(txt);
		/* 대쉬보드 컴포넌트 세팅 */
		var component = $(el).data('component');
		var val = $(el).data('component-value');
		dashSearchComponentes[component] = val;
	};
	
	function refreshGrid(data) {
		if(data) {
			gisFrame.mainGrid.finishLoad(data||[]);
		} else {
			gisFrame.mainGrid.command('refresh');
		}
		refreshMap(data);
	};

	/*
	 function refreshErrGrid(data) {
		if(data)
			errGrid.finishLoad(data||[]);
		else
			errGrid.command('refresh');
	}; 
	*/
	function refreshMap(result) {
		if(result) {
			document.getElementById('gisIframe').contentWindow.gis.mapLy['map_point'].createFeatures(result);
			document.getElementById('gisIframe').contentWindow.gis.mapLy['map_point'].updateFeature(result, 'meas_meter');
		}
		gisFrame.stopGrid();
		//gisFrame.mainGrid.finishLoad(result||[]);
		//$('.bcard.point-grid').aceWidget('stopLoading');
	};
	
	/*
	* 그리드 컬럼 요소 리빌딩
 	*/
 	var colfnc = function(value, item, c, d, e) {
 		switch (this.name) {
 		case 'adminId':
 			value = '<span style="font-size:11px;" id="' + item.adminId + '">'+ item.adminId +'</span><br>'+ (item.custNm?item.custNm:'&nbsp;');		
 			return value;
 		case 'blkNm':
 			var ix = -1;
 			if(value) {
 				ix = value.indexOf(':');
 				if(ix >= 0){
 					value = value.substr(ix+1);
 				}
 			}
 			var useType = item.useType ? item.useType : '미지정';
 			var pipeDia = item.pipeDia ? item.pipeDia : '미지정';
 			value = (value ? value : '&nbsp;') +'<br>'+ useType +'&nbsp;'+ item.pipeDia +'<small>mm</small>';
 			return value;
 		case 'statCd':
 			if(!item.statCd) {
 				return '-';
 			}
 			return '<img style="width:30px;height:30px; "src="'+ meterStatCd.getImage(item.statCd) +'"/><br><small>' 
 			+ meterStatCd.getStr(item.statCd) + '</small>';
 		case 'rawCnt_0d':
 			return kutil.v2n(item.rawCnt_0d, 1) +'<br>'+ kutil.v2n(item.rawCnt_30d, 1);
 		case 'measDt':
 			if(!item.measDt) {
 				return '-';
 			}
 			var v1 = kutil.v2n(item.accuIv, 3) +'<span style="font-size:11px;"> ㎥</span>';
 			var v2 = '<span style="font-size:11px;">'+ kutil.dateFormat(new Date(item.measDt), 'yy.mm.dd HH:MM') 
 			+'</span>' 
 			return v2 +'<br>'+ v1;
 		}
 		return (value ? value : '-');
	};
	
	/*
	* 그리드 초기화
 	*/
 	function initGrid(container) {
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
 	        fields:  [
 		        { name: "statCd", 	title: "상태", 					type: "text", 	align:"center", width: 100, 	itemTemplate:colfnc},
 		        { name: "adminId",	title: "수용가 번호<br>수용가명", 	type: "text", 	align:"left", 	width: 'auto', 	itemTemplate:colfnc},
 		        { name: "blkNm",	title: "블록<br>구분", 			type: "text", 	align:"left", 	width: 120, 	itemTemplate:colfnc},                       
 		        { name: "rawCnt_0d",title: "일간검침수<br>당일 | 30일", 	type: "text", 	align:"right", 	width: 100, 	itemTemplate:colfnc},
 		        { name: "measDt", 	title: "최종검침일시<br>최종검침값", 	type: "text", 	align:"right", 	width: 110, 	itemTemplate:colfnc}
 		        //{ name: "meas.obsDate", 	title: "검침일시", 	type: "text", 	align:"center", width: 70, itemTemplate:colfnc }
		    ],
 	        loadStrategy: function() {			
 	        	return new CustomPageLoadingStrategy(this, loadData);          	        	        
 	        },
 	        rowClick: function(evt) {
 	        	var pointSq = evt.item.pointSq;
 	        	document.getElementById('gisIframe').contentWindow.mapCenterToPoint(pointSq);
 	        }, 	        
 			rowDoubleClick: function(evt) {
				$('#infoModal', window.parent.document).modal('show'); //infoModal
				loadModalPointData(false, evt.item);
				loadModalRawData(evt.item);
				loadModalChildAdminId(evt.item);
			},
			  onRefreshed: function (args) {
				$.each(args.grid._headerGrid[0].rows[0].cells, function (i, obj) {
					$(args.grid._bodyGrid[0].rows[0].cells[i]).css("width", $(obj).css("width"));
				});
				$("table").colResizable({
					onResize: function () {
						$.each(args.grid._headerGrid[0].rows[0].cells, function (i, obj) {
							$(args.grid._bodyGrid[0].rows[0].cells[i]).css("width", $(obj).css("width"));
						});
					}
				});
   			 }
		};
		return new DataGrid(container, opt);
	};
	
	function initErrGrid(container) {
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
 	        //searchContainer: '#searchInput',
 	        fields: [
 	          { name: "adminId", title: "수용가 번호", type: "text", align:"center", width: 60, sortingDisabled:true},
 	          { name: "custNm",	 title: "이름", 	 	type: "text",				  width: 60, sortingDisabled:true},
 	          { name: "addrNew", title: "주소", 	 	type: "text",				  width: 100, sortingDisabled:true} 	       
 	  	    ],
 	        rowClick: function(evt) {
 	        	parent.updateValueFields([evt.item]);
 				loadModalRawData(evt.item);
 				$('#infoModal', window.parent.document).modal('show');
 				$('#errModalCloseBtn').click();
 	        },
			  onRefreshed: function (args) {
				$.each(args.grid._headerGrid[0].rows[0].cells, function (i, obj) {
					$(args.grid._bodyGrid[0].rows[0].cells[i]).css("width", $(obj).css("width"));
				});
				$("table").colResizable({
					onResize: function () {
						$.each(args.grid._headerGrid[0].rows[0].cells, function (i, obj) {
							$(args.grid._bodyGrid[0].rows[0].cells[i]).css("width", $(obj).css("width"));
						});
					}
				});
   			 } 	        
		};
		return new DataGrid(container, opt);
	};
	
	function loadModalData(useGparams) {
		loadModalPointData(useGparams);
		loadModalRawData(parent._params);
		loadModalChildAdminId();
	};
	
	function loadModalData2(useGparams) {
		loadModalPointData(false, useGparams);
		loadModalRawData(useGparams);
		loadModalChildAdminId(useGparams);
	};
	
	function loadPointSearch(params) {
		if(!params.searchParam) {
			return;
		}
		loadModalPointData(false, params, function(result) {
			if(result.length == 0) {
	 			//jAlert.info('정보', '해당 수용가는 존재하지 않습니다.');
	 			return;
	 		}
			if(result.length > 10) {
	 			jAlert.info('정보', '10명이상의 수용가가 존재합니다. 수용가 리스트에서 확인하세요.');	 			
	 			return;
	 		}
			if(result.length > 1) {
	 			jAlert.info('정보', '2명이상의 수용가가 존재합니다. 수용가를 선택해 주세요.');	
	 			var modal = $('#errModal');
	        	errGrid.command('refreshData', result);
	        	modal.modal({backdrop: 'static'});
	        	modalGridLayout(modal, 500);
	 			return;
	 		}
			parent.updateValueFields(result);
			loadModalRawData(result[0]);
			$('#infoModal', window.parent.document).modal('show');
		});
	};
	
	function modalGridLayout(modal, height) {
		modal.find('.jsgrid-grid-body').css('height',  height + 'px');
		$(window).resize(function () {
			modal.find('.jsgrid-grid-body').css('height',  height + 'px');
		});
	};
	
	/* modal 데이터 point 로드 */
	function loadModalPointData(useGparams, item, pCallback) {
		var params = new Object();
		if(useGparams) {
			params = parent._params;
		} else {
			if(item && item.pointSq) {
				params.pointSq = item.pointSq;
				params.siteSq = item.siteSq;
			} else { 
				params = item;
			}
		}
		loadPointData(params, pCallback);
	};
	
	// 2023.10.25 김용희 : 부수용가 정보
	function loadModalChildAdminId(obj) {
		var params = obj;
		getAjax('mars.icbm.map1.selectChildAdminId', params, function() {
		}, function(result) {
			//if(result.length > 0) {
				parent.refreshChildAdminId(result);
			//}
		}, null);
	};
	
	/* modal 데이터 raw 로드 */
	function loadModalRawData(params) {
		var type = $('#typeSelect', window.parent.document).val();
		var endDate = $('#fromDate', window.parent.document).val(); 				 		
 		if(!endDate || endDate.length == 0) {
 			/* 날짜 초기화 */
 			$('#fromDate', window.parent.document).val(kutil.dateFormat(new Date(), 'yyyy-mm-dd')); 			
 			endDate = kutil.dateFormat(new Date(), 'yyyy-mm-dd'); 
 		}
 		var obj = new Object();
 		obj.pointSq = params.pointSq
 		obj.siteSq = params.siteSq
 		obj.endDate = endDate;
		var begDate = kutil.addMonth(endDate, (type == '0') ? -1 : -12); 		 		
		obj.begDate = moment(Date.parse(begDate)).format('YYYY-MM-DD');
		type == '0' ?
		loadRawData('pointHisdataRaw', obj) : 
		loadRawData('pointHisdata', obj);
		parent._params = params; 
	};
	
	/* raw데이터 로드 */
	function loadRawData(qid, params) {
		/* 검침값 조회 */
		getAjax(qid, params, function() {
			$('#infoModal', window.parent.document).aceWidget('startLoading');
		}, function(result) {
			parent.refreshModalMain(result);
		}, function() {
			$('#infoModal', window.parent.document).aceWidget('stopLoading');
		});
	};
	
	/* 검색 시 파람 생성 */
	function makeParams() {
		var params = {};
		var val = $('#searchInputP').val();
		params.searchParam = val;
		return $.extend(params, parent.searchComponentes); 
	};
	
	function searchComponentes(){
		return parent.searchComponentes;
	}
	
	/* 팝업 창에 채울 단일 수용가 정보 */
	function loadPointData(params, sCallback) {
		/* 수용가 조회 */
		getAjax('mars.icbm.map1.pointList', params, function() {
		
		}, function(result) {
			if(sCallback) {
				sCallback(result);
				return;
			}
			if(result.length > 0) {
				parent.updateValueFields(result);
			}
		}, null);
	};
	
	/* 메인 gird 로드  */
	function loadData() {
		var params = {};
		$.extend(params, parent.searchComponentes);
		$.extend(params, gisFrame.mainGrid.loadParams());
		params.useCd = '1';
		params.searchInputP = gisFrame.document.getElementById('searchInputP').value;
		/* 수용가 조회 */
		getAjax('newPointList_paging', params, gisFrame.startGrid, gisFrame.refreshGrid, gisFrame.stopGrid);
	};
	
	/*
	* 리소스 path
 	*/
	function getContextPath() {
	   return "${contextPath}";
	};
	
	function getAbsolutepath(path) {
		return '${contextPath}/' + path;
	};

	/*
	* ajax 조회 기본 함수
 	*/
	function getAjax(qid, params, beforesend, callback, errCallback, async) {
		ajaxSelect({			
			sql: qid,
			data: params, 
			async: async?async:true,			
			beforeSend: function(){
		        if(beforesend) {
		        	beforesend();
		        }
	        },			
			success: function(result) {
				if(callback) {
					callback(result);
				}
			},
			error: function(error) {
				if(error.status == 401) {
					parent.document.location.reload();
					return;
				}
				if(errCallback) {
					errCallback(error);
				}
				var msg = '데이터를 읽을 수 없습니다.<br>';
				msg += (error.responseText?error.responseText.trim():'서버에 오류가 있습니다.');
				jAlert.error('오류', msg);
			}
		});
	};
	
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
	
	/* 동두천 레포트 작성 모듈  */
	function reportDownload(el){
		var val = $(el).siblings('input').val();
		if (!val) {
			jAlert.error('오류','날짜를 선택해주세요');
			return;
		} else {
			if(!dbParams) {
				jAlert.error('오류', '조건이 맞지 않아 데이터를 다운로드할 수 없습니다.');
				return;
			}
			var params = new Object();
			params.reportDt = val;			
			params.qid = dbParams[dbParamsTb]['refer-sql'];			
			params.colMapping = dbParams[dbParamsTb]['cols'];
			params.length = params.colMapping.length;		
			params.downloadFileName = "Report_"+ kutil.dateFormat( new Date(), 'yymmddHHMMss');
			reportDateSearch(params);			
		}
	}
	
	function reportDateSearch(params) {
		getAjax('mars.icbm.map1.ddcList', params, function() {
			
		}, function(result) {
			if(result.length == 0) {
				jAlert.error('오류','해당 날짜에 데이터가 존재하지 않습니다.');
				return;
			} else {
				templetDownLoad(params, null, null, function() {
					jAlert.error('오류', '다운로드에 실패했습니다.');
				});
				$('#reportModal').modal('hide');
			}
		}, null);
	}
</script>

<style type="text/css">
#devContainer .form-control{
	width:60% !important;
}
</style>

</head>
<body>
	<div role="main" class="main-content">
		<!-- <div class="page-content container container-plus px-md-4 px-xl-5"> -->
		<div name="page-1" style="height: 1000px; width: 100%; border: 0px;">
            	<div style="height: 100%; width: 100%; border: 0px;">
					<div style="height: 100%; width: 100%; border: 0px;">
						<div id="bodyContainer" style="height: 100%; width: 100%; border: 0px;">
							<iframe id="gisIframe" src="ISTC_FP_GIS" style="height: 100%; width: 100%; border: 0px;"></iframe>				
						</div>
					</div>
			</div>
			<div hidden>
				<!--
					<div id="mainGrid" class="data-list containerBorder" style="width: 100%; height: 100%;" hidden></div>
					-->
			</div>
		</div>
		<div class="page-content container container-plus px-md-4 px-xl-5" name="page-2" hidden>
			<div class="row mt-def">
				<div class="col-12 col-sm-6 col-lg-6 px-2 mb-2 mb-lg-0">
					<div class="bcard ccard overflow-hidden ratio-graph" name="ratio-graph-tool-bar">	
						<div class="card-header border-0 bgc-white card-header-sm">
							<h6 class="card-title text-dark-m3 pl-25 pt-15 text-110">검침률 추이 <br />
								<span class="text-85 text-dark-l2"></span>
							</h6>
							<div class="card-toolbar no-border align-self-start mt-15 mr-1">
								<div class="dropdown dd-backdrop dd-backdrop-none-md">
									<a
										class="d-style btn btn-outline-default shadow-sm radius-2px text-600 letter-spacing px-4 dropdown-toggle"
										href="#none" role="button" data-toggle="dropdown"
										data-display="static" aria-haspopup="true"
										aria-expanded="false"> 월간 											
										<i class="fa fa-caret-down ml-2"></i>
									</a>
									<div
										class="dropdown-menu dropdown-menu-right dropdown-caret dropdown-animated dd-slide-up dd-slide-none-md">
										<div class="dropdown-inner">
											<a class="dropdown-item active btn-a-bold m-1" href="#none" data-target-nm="ratio-graph-tool-bar" data-component="ratioGraph" data-component-value="1" onclick="toolBarChangHandler(this); loadRatioGraph('selectAnalyResult');">월간</a>
											<a class="dropdown-item m-1" href="#none" data-target-nm="ratio-graph-tool-bar" data-component="ratioGraph" data-component-value="12" onclick="toolBarChangHandler(this); loadRatioGraph('selectAnalyResult');">년간</a> 														 																							
										</div>
									</div>
								</div>
							</div>
						</div>
                  		<div id="ratioGraph" class="mt-lg-4 chartjs-render-monitor"></div>
					</div>
				</div>
				<div class="col-12 col-sm-6 col-lg-6 px-2 mb-2 mb-lg-0">
					<div class="bcard ccard overflow-hidden use-graph">	
						<div class="card-header border-0 bgc-white card-header-sm" name="use-tool-bar">
							<h6 class="card-title text-dark-m3 pl-25 pt-15 text-110">사용량 추이 <br />
								<span class="text-85 text-dark-l2"></span>
							</h6>
							<div class="card-toolbar no-border align-self-start mt-15 mr-1">
								<div class="dropdown dd-backdrop dd-backdrop-none-md">
									<a
										class="d-style btn btn-outline-default shadow-sm radius-2px text-600 letter-spacing px-4 dropdown-toggle"
										href="#none" role="button" data-toggle="dropdown"
										data-display="static" aria-haspopup="true"
										aria-expanded="false"> 월간 											
										<i class="fa fa-caret-down ml-2"></i>
									</a>
									<div
										class="dropdown-menu dropdown-menu-right dropdown-caret dropdown-animated dd-slide-up dd-slide-none-md">
										<div class="dropdown-inner">
											<a class="dropdown-item active btn-a-bold m-1" href="#none" 
											data-target-nm="use-tool-bar" data-component="used" data-component-value="1" 
											onclick="toolBarChangHandler(this); loadUse('selectAnalyResult', 1);">월간</a>
											<a class="dropdown-item m-1" href="#none" data-target-nm="use-tool-bar" 
											data-component="used" data-component-value="12" 
											onclick="toolBarChangHandler(this); loadUse('selectAnalyResult', 12);">년간</a> 														 																							
										</div>
									</div>
								</div>
							</div>
						</div>
						<div id="useGraph" class="mt-lg-4 chartjs-render-monitor"></div>
					</div>
				</div>
			</div>
		</div>
	</div>
   <div class="modal fade" id="errModal" tabindex="-1" role="dialog">
	     <div class="modal-dialog modal-dialog-scrollable" role="document">
	       <div class="modal-content">
	         <div class="modal-header">
	           <h5 class="modal-title" id="">2명 이상의 수용가가 존재합니다. 선택하세요.</h5>
	           <button type="button" id="errModalCloseBtn" class="close" data-dismiss="modal" aria-label="Close">
		          <span aria-hidden="true">&times;</span>
		        </button>
	         </div>
			<div class="modal-body">
				<div class="card-body p-0" id="errGridContainer"">							
	        		<div id="errGrid" class="data-list containerBorder grid-mobile"></div>
	        	</div>
	        </div>
			</div>
		</div>
	</div>
	<div class="modal fade dialog-30" id="reportModal" tabindex="-1" role="dialog">
     <div class="modal-sm modal-dialog modal-dialog-scrollable" role="document">
       <div class="modal-content">
         <div class="modal-header">
           <h5 class="modal-title">레포트 출력</h5>
           <button type="button" class="close" data-dismiss="modal" aria-label="Close" id="closeReportModal" onclick="closeDevModal();">
	          <span aria-hidden="true">&times;</span>
	        </button>
         </div>
	  	 <div class="modal-body">
			<div id="devContainer" class="d-flex">					
			<input type="date" class="form-control search-param" id="reportDate" />
			<button type="button" class="btn btn-primary ml-3" id='report' onclick='reportDownload(this);'>다운로드</button>	
			</div>
    	 </div>
       </div>
     </div>
   </div>
	<script type="text/javascript" src="${contextPath}/resources/lib/chart.js/dist/Chart.js"></script>
	<script type="text/javascript" src="${contextPath}/resources/page/p/js/istc-f1.js?v=1.0"></script>
</body>
</html>