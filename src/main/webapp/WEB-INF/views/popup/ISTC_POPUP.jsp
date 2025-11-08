<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="contextPath" value="<%=request.getContextPath()%>"></c:set>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<%@include file="/resources/inc/meta.inc"%>
<title>스마트수도미터원격검침시스템</title>

<%@include file="/resources/inc/base.inc"%>
<%@include file="/resources/inc/jsgrid.inc"%>
<script>
// 서버에서 사용자 소속 정보 가져오기
var currentUserSiteSq = ${user.getSiteSq()};
var currentUserSiteLv = ${user.getSiteLv()};

console.log('팝업 로드 - 사용자 소속:', {
	siteSq: currentUserSiteSq,
	siteLv: currentUserSiteLv
});

$(function(){
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
* 그리드 컬럼 요소 리빌딩
	*/
	var colfnc = function(value, item, c, d, e) {
		
		switch (this.name) {
		case 'num':		
			return (item.pageNo - 1) * item.pageSize + (c + 1);
		case 'blkNm':
			value = item.blkNm2;
			if(value && value.indexOf(':') >= 0)
				value = value.substr(value.indexOf(':')+1);
			return value;
			
		case 'statCd':
			if(!item.statCd)
				return '-';
			
			return '<img style="width:30px;height:30px;" src="'+ meterStatCd.getImage(item.statCd) +'"/><span style="font-size:11px;">'+ meterStatCd.getStr(item.statCd) +'</span>'; 
			break;
		case 'deviceStatCd':
				if (!item.statCd)
					return '-';

				return '<img style="width:24px;height:24px; margin: 0 4px 0 0" src="' + deviceStatCd.getImage(item.statCd) + '"/><span style="font-size:12px;">' + deviceStatCd.getStr(item.statCd) + '</span>';
				break;
		case 'accuIv':
		case 'termCv_0d':
		case 'termCv_1d':
		case 'termCv_7d':
		case 'termCv_30d':
			if(value != 0 && !value) return '-';
			value = kutil.v2n(value, 3).split('.'); 
			return value[0] +'<small>.'+ value[1];
		case 'rawCnt_0d':
		case 'rawCnt_1d':
		case 'rawCnt_7d':
		case 'rawCnt_30d':
			if(!value) return '-';
			value = kutil.v2n(value, 1).split('.'); 
			return value[0] +'<small>.'+ value[1];

		case 'measDt':
			if(!value)
				return '-';
			var dt = new Date(value);		
			return '' + kutil.dateFormat(dt, 'yy.mm.dd') +' ' +
				kutil.dateFormat(dt, 'HH:MM');
			
		case 'instlDay':
			if(!value)
				return '-';
			var dt = new Date(value);		
			return '<small>' + kutil.dateFormat(dt, 'yy.mm.dd') +' </small> ';
			
		case 'bat2Stat':
			if(!item.bat2Stat)
				return '-'; 			
			if(item.bat2Stat == '장애'){
				return '<img style="width:23px;height:23px;" src="resources/img/marker/bat-red.png"/>&nbsp;'+ item.bat2Stat ; break;
			}else {
			return '<img style="width:23px;height:23px;" src="resources/img/marker/bat-green.png"/>&nbsp;'+ item.bat2Stat ; break;
			}
			return '-';
		case 'temperature':		   ////////////// 2022-11-30
			if(item.temperature != undefined && item.temperature != null) {
				return item.temperature+'℃';
			}
			return '';
		}
		
		return (value == 0 || value) ? value : '-';
};

var groups = [ 
	{title : '구분', columns : 1, align : "center"},
	{title : '수용가', columns : 4, align : "center"},  
	{title : '최종 검침', columns : 3, align : "center"},	
	{title : '일간(이동평균) 검침수 (건/일)', columns : 4, align : "center"},
	{title : '일간(이동평균) 사용량 (㎥/일)', columns : 4, align : "center"},
	{title : '배터리',columns : 2, align : "center"},
	{title : '기온', columns : 1, align : "center"},  ////////////// 2022-11-30
];	

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
	        	{ name: "num", 			title: "순번", 	     type: "text", align:"center", width: 50, 	itemTemplate:colfnc, sortingDisabled:true},
	            { name: "siteNm0",      title: "지자체", 	 type: "text",   width: 100, itemTemplate:colfnc, hasGroup:true, group:groups[1]},
	            { name: "useType",      title: "업종", 		 type: "text",   width: 70,  itemTemplate:colfnc, hasGroup:true},
	            { name: "adminId",      title: "수용가 번호", 	 type: "text",   width: 170, itemTemplate:colfnc, hasGroup:true}, 	             	           
	            { name: "custNm",       title: "이름", 		 type: "text",   width: 200, itemTemplate:colfnc, hasGroup:true}, 
	            { name: "statCd", 	title: "계량기 상태", 	 type: "text",   align:"left", width: 120,  itemTemplate:colfnc, hasGroup:true, group:groups[2]},
	            { name: "measDt",  		title: "검침일시", 	 type: "text", 	 align:"center", width: 120, itemTemplate:colfnc, hasGroup:true},
	            { name: "accuIv", 		title: "검침값(㎥)", 	 type: "number", align:"right",  width: 100, itemTemplate:colfnc, hasGroup:true},
	            { name: "rawCnt_0d", 	title: "당일", 	 	 type: "number", align:"right",  width: 80,  itemTemplate:colfnc, hasGroup:true, group:groups[3] },
	            { name: "rawCnt_1d", 	title: "전일",  	     type: "number", align:"right",  width: 80,  itemTemplate:colfnc, hasGroup:true },
	            { name: "rawCnt_7d", 	title: "직전7일",      type: "number", align:"right",  width: 80,  itemTemplate:colfnc, hasGroup:true },
	            { name: "rawCnt_30d", 	title: "직전30일",     type: "number", align:"right",  width: 80,  itemTemplate:colfnc, hasGroup:true },
	            { name: "termCv_0d", 	title: "당일", 	      type: "number", align:"right",  width: 80,  itemTemplate:colfnc, hasGroup:true, group:groups[4]},
	            { name: "termCv_1d", 	title: "전일",  	 	  type: "number", align:"right",  width: 80,  itemTemplate:colfnc, hasGroup:true},
	            { name: "termCv_7d", 	title: "직전7일",  	  type: "number", align:"right",  width: 80,  itemTemplate:colfnc, hasGroup:true },
	            { name: "termCv_30d", 	title: "직전30일", 	  type: "number", align:"right",  width: 80,  itemTemplate:colfnc, hasGroup:true },
	            { name: "bat2Iv", 	title: "전압(v)", 	  type: "number", align:"right",  width: 80,  itemTemplate:colfnc, hasGroup:true, group:groups[5]},
	            { name: "bat2Stat", 	title: "상태", 	  type: "number", align:"center",  width: 80,  itemTemplate:colfnc, hasGroup:true },
	            { name: "temperature",       title: "온도", 		 type: "text",   width: 200, itemTemplate:colfnc, hasGroup:true, group:groups[6]}  ////////////// 2022-11-30
	        ],
	        
	        loadStrategy: function() {			
	        	
	        	return new CustomPageLoadingStrategy(this, loadData);          	        	        
	        	
	        }
	};

	return new DataGrid(container, opt);
};

/* 메인 gird 로드  */
function loadData() {
	var params = makeParams();
	/* 수용가 조회 */
	getAjax('mars.icbm.map1.popup.popupPointList_paging', params, function() {
	//getAjax('mars.icbm.map1.newPointList_paging', params, function() {
		/* 로딩 시작 */
		$('.bcard.point-grid').aceWidget('startLoading');
	}, refreshGrid, null);
};

function makeParams() {
	var filterType = '<c:out value="${fliterType}"/>';
	var param = '<c:out value="${cdParam}"/>';
	var params = {};

	//$.extend(params, window.opener.searchComponentes);
	$.extend(params, mainGrid.loadParams());
	
	if (filterType == '1') {
		params['tap_gb'] = param;
	}
	else {
		params['statCd'] = param;
	}
	
	//params.searchOption = $('#searchOptionSelect').val();

	params.useCd = '1';
	
	
	return params; 
	
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
				
				window.opener.document.location.reload();
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
</script>

</head>
<body>
<div class="row mt-def" style="width: 100%; height: 100%;">
	<div class="col-12">
		<div class="bcard card h-100 point-grid">
			<div class="card-body p-0" id="gridContainer"">							
				<div id="mainGrid" class="data-list containerBorder" style="width: 100%; height: 100%;"></div>
			</div>
		</div>
	</div>
</div>
</body>
</html>