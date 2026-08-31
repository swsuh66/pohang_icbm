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
<!-- 
부과조회 , ISTC_10.jsp
 -->

<script type="text/javascript">

	var _animate = !AceApp.Util.isReducedMotion();

	var mainGrid;	
	
	var dbParams;
	
	var dbParamsTb = 'f8-export';
	
	
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
		
		/*
		* 날짜 초기 설정
		*/
		setInitDate();
		
		/* 엑셀다운도르를 위한 db 파람조회  */
		getDbtableInfo();
		
		/* grid 초기화 */
		mainGrid = initGrid('mainGrid');
		
		/* 수용가 조회 */		
		mainGrid.search();
			
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
	
	function setInitDate() {
		
		var today = new Date(Date.now());
		var todayStr = kutil.dateFormat(today, 'yyyy-mm-dd');
		
		// 시작일: 이번 달 1일
		var firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
		var fromDate = kutil.dateFormat(firstDay, 'yyyy-mm-dd');
		
		// 종료일: 이번 달 마지막 날 vs 오늘 중 더 이른 날짜
		var lastDay = new Date(today.getFullYear(), today.getMonth() + 1, 0);
		var toDate = (lastDay > today) ? todayStr : kutil.dateFormat(lastDay, 'yyyy-mm-dd');
		
		$('#fromDate').val(fromDate);
		$('#toDate').val(toDate);
		
	};

	/*
	* 그리드 갱신
 	*/
	function refreshGrid(data) {
		
		if(data)
			mainGrid.finishLoad(data||[]);
		else
			mainGrid.command('refresh');
		
		$('.bcard.point-grid').aceWidget('stopLoading');
			
	};
	
	/*
	* 그리드 컬럼 요소 리빌딩
 	*/
 	var colfnc = function(value, item, c, d, e) {
 		
 		switch (this.name) {
 		
 		case 'num':
 			if(item.pageNo) return (item.pageNo - 1) * item.pageSize + (c + 1);
 			return c + 1;
 		
 		case 'statCd':
 			var mStat = meterStatCd.getStatus(item.amiErrCode, item.metErrCode, item.measDt);
 			return '<img style="width:30px;height:30px;" src="'+ getAbsolutepath(mStat.image) +'"/><span style="font-size:11px;">'+ mStat.str +'</span>'; break;
 			
 		case 'begDay':
 		case 'endDay':
 			var dt = new Date(value);
 			return kutil.dateFormat(value, 'yyyy.mm.dd HH:MM');
 			
 		case 'readDay':
 			if(value == -1) return '마지막 날';
 			return value ? value : '-';
 			
 		}
 		
 		return value != 0 && !value ? '-' :  value;	
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
 		   
 	        fields: [
 	    	   { name: "num", 		title: "순번", 		type: "text", 	align:"center", width: 50, 	itemTemplate:colfnc, sortingDisabled:true},
 	           { name: "blockName", title: "블럭", 		type: "text", 	align:"left", 	width: 100, itemTemplate:colfnc, hasGroup:true, group:groups[0]},
 	           { name: "check_day", title: "검침일", 	type: "text", 	align:"left", 	width: 50, itemTemplate:colfnc, hasGroup:true,},
 	           { name: "useType", 	title: "업종", 		type: "text", 	align:"left", 	width: 70, 	itemTemplate:colfnc, hasGroup:true},
 	           { name: "pipeDia", 	title: "관경(mm)", 	type: "text", 	align:"left", 	width: 80, 	itemTemplate:colfnc, hasGroup:true},
 	           
 	           { name: "adminId",	title: "수용가 번호", 	type: "text", 	align:"left", 	width: 150, itemTemplate:colfnc, hasGroup:true, group:groups[1]},
 	           { name: "custName",	title: "이름", 		type: "text", 	align:"left", 	width: 120, itemTemplate:colfnc, hasGroup:true},
 	           
 	           { name: "readOpr",	title: "검침원", 		type: "text", 	align:"left", 	width: 70, itemTemplate:colfnc},
 	           
 	           { name: "statCd", 	title: "미터상태", 	 type: "text",   align:"left", width: 120,  itemTemplate:colfnc},
 	           
 	           { name: "useDays", 	title: "부과일수", 	type: "number", align:"right", 	width: 100,  itemTemplate:colfnc, hasGroup:true, group:groups[2] },
 	           { name: "rstVal",	title: "부과량(㎥)", 	type: "number", align:"right", 	width: 100, itemTemplate:colfnc, hasGroup:true },
 	           { name: "adjstV",	title: "조정량(㎥)", 	type: "number", align:"right", 	width: 100, itemTemplate:colfnc, hasGroup:true },
 	           { name: "useVal",	title: "검침량(㎥)", 	type: "number", align:"right", 	width: 100, itemTemplate:colfnc, hasGroup:true },
 	           
 	           { name: "begVal",	title: "시침값(㎥)", 	type: "number", align:"right", 	width: 100, itemTemplate:colfnc, hasGroup:true, group:groups[3] },
 	           { name: "begDay",  	title: "시침일", 		type: "text", 	align:"center", width: 120, itemTemplate:colfnc, hasGroup:true },
 	           
 	           { name: "endVal",  	title: "종침값(㎥)", 	type: "number", align:"right", 	width: 100, itemTemplate:colfnc, hasGroup:true, group:groups[4] },
 	           { name: "endDay", 	title: "종침일", 		type: "text", 	align:"center", width: 120, itemTemplate:colfnc, hasGroup:true }
 	           
 	           //{ name: "detail", title:"상세", type:"control", align:"center", width:60}
 	       ],
 	        
 	        loadStrategy: function() {			
 	        	
 	        	return new CustomPageLoadingStrategy(this, loadData);          	        	        
 	        	
 	        },
 			rowDoubleClick: function(evt) {
 				parent.loadModalData(false, evt.item);
			}
		};

		return new DataGrid(container, opt);
	};

	var groups = [
		//{title:'소속', 		columns: 2, align:"center"},
		{title:'검침구분', 	columns: 4, align:"center"},
		{title:'수용가', 		columns: 2, align:"center"},
		{title:'부과량', 		columns: 4, align:"center"},
		{title:'시작지침', 	columns: 2, align:"center"},
		{title:'종료지침', 	columns: 2, align:"center"}
		//{title:'검침상태', 	columns: 2, align:"center"},
	];	
	
	function makeParams() {
		
		var params = {};

		$.extend(params, searchComponentes);
		$.extend(params, mainGrid.loadParams());

		params['cust_nm'] = $('#cust_nm').val();
        params['admin_no'] = $('#admin_no').val();
        params['addr'] = $('#addr').val();
        params['dateOption'] = $('#dateOption').val();
        
		params.toDate = $('#toDate').val();
		params.fromDate = $('#fromDate').val();
		params.readType = $('#readType').val();
		params.useCd = '1';
		
		params.searchOption = $('#searchOptionSelect').val();
		
		
		return params; 
		
	};
	
	/* 메인 gird 로드  */
	function loadData() {

		var params = makeParams();
		
		if(!params.toDate || !params.fromDate || params.toDate.length == 0) {
			
			jAlert.error('오류', '날짜를 지정하세요');
			return;
			
		}

		/* 수용가 조회 (최적화 버전) */
		getAjax('customerList_paging_optimized', params, function() {

			/* 로딩 시작 */
			$('.bcard.point-grid').aceWidget('startLoading');

		}, refreshGrid, null);

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

		
		params.downloadFileName = "TermCv_"+ kutil.dateFormat( new Date(), 'yymmddHHMMss');							
		$.extend(params, makeParams());

		templetDownLoadStream(params, null, null, function() {
			
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
		<%@ include file="ISTC_F10_CONTENT.jsp" %>
	    <div class="sub-cont-header">
	        <div class="sub-cont-header-area">
	        </div>
	    </div>
	    <div class="dj-card">
	        <div class="bcard card h-100 point-grid">
	            <div class="card-body p-0" id="gridContainer">
	                <div id="mainGrid" class="data-list containerBorder" style="width: 100%; height: 100%;"></div>
	            </div>
	    </div>
	</div>
	

	<script type="text/javascript" src="${contextPath}/resources/lib/chart.js/dist/Chart.js"></script>
	<%-- <script type="text/javascript" src="${contextPath}/resources/lib/sortablejs/dist/sortable.umd.js"></script> --%>
	

</body>



</html>

