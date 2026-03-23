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

<!-- DB 에러로그 화면 -->
<script type="text/javascript">

	var _animate = !AceApp.Util.isReducedMotion();

	var mainGrid;
	
	var pointListData;
	
	var leakSetting;
	
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
		
		mainGrid  = initGrid('mainGrid', mainFields);

		mainGrid.search();

		blankbase();
		$('#excelbtn').hide();
		$('#clearbtn').hide();
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
		
		return "${user.getUserRoll()}";
		
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
	
	function loadData(qid, params, callback) {
		
		var qid = qid ? qid : 'mars.icbm.map1.selectDbErrorLogList';
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
	
	
	
	/*
	* 그리드 갱신
 	*/
	function refreshGrid(grid, data) {
		
		if(data)
			grid.finishLoad(data||[]);
			//grid.command('refresh');
		else
			grid.command('refresh');
			
	};
		
	var colfnc = function(value, item, c, d, e) {
		
		switch (this.name) {
		case 'num':		
			return (item.pageNo - 1) * item.pageSize + (c + 1);
		}
		

		return (value||value==0)?value:'-';
	};

	var mainFields = [		
		{ name: "num", 		title: "순번", 	type: "text", align:"center", 	width: 20, 	sortingDisabled:true},	    
		{ name: "log_date", 	title: "날짜", 	type: "text", 	align:"left",   width: 40, itemTemplate:colfnc, hasGroup:false},	    
	    { name: "log_mesg",      title: "메시지", 	 type: "text",  		width: 80,  		itemTemplate:colfnc, hasGroup:false},	    	   
	    { name: "log_name",       title: "이름", 		 type: "text",          width: 40, itemTemplate:colfnc, hasGroup:false},
	    { name: "log_attrib",       title: "힌트", 		 type: "text",          width: 40, itemTemplate:colfnc, hasGroup:false},
	];



	function initGrid(container, fields) {
	    
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
		    	//parent.loadModalData(false, evt.item);
		    }
	    };
	    
	    return new DataGrid(container, opt);
	};
	
	function makeParams() {
		
		var params = {};

		$.extend(params, mainGrid.loadParams());

		params['log_mesg']    = $('#log_mesg').val()// 기준 일자.
		params['log_name']    = $('#log_name').val(); // 기준 일자.
		params['log_attrib']  = $('#log_attrib').val();

		return params; 
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
		
		/*
		 * ajax 조회 기본 함수
		 */
		function getAjax(qid, params, beforesend, callback, errCallback, bCallback) {

			ajaxSelect({
				sql : qid,
				data : params,
				//async : async ? async : true,
				beforeSend : function() {

				
					if (beforesend) {
						
						bCallback ? beforesend(bCallback) : beforesend();
						
					}

				},
				success : function(result) {
					if (callback) {
						
						bCallback ? callback(result, bCallback) : callback(result);
					}
				},
				error : function(error) {
					
					if(error.status == 401) {
						
						parent.document.location.reload();
						return;
					}

					
					if (errCallback) {
						
						bCallback ? errCallback(error, bCallback) : errCallback(error);
						
					}

					var msg = '데이터를 읽을 수 없습니다.<br>';
					msg += (error.responseText ? error.responseText.trim()
							: '서버에 오류가 있습니다.');

					jAlert.error('오류', msg);

				}
			});

		};
		
		function deleteAjax(qid, params, beforesend, callback, errCallback, async) {
			
			ajaxDelete({
				sql : qid,						
				data: params,
				async : async ? async : true,
				beforeSend : function() {

					if (beforesend)
						beforesend();

				},			
				success: function(result) {
					
					if (callback)
						callback(result);		
					
				},
				error: function(error) {
					
					if (errCallback)
						errCallback(error);

					var msg = '삭제 오류.<br>';
					msg += (error.responseText ? error.responseText.trim()
							: '서버에 오류가 있습니다.');
					
					jAlert.error('오류', msg);
					
				}
			});
		};
</script>

<style type="text/css">

	
	
</style>

	

</head>



<body>
<div role="main" class="sub-content">
	<%@ include file="ISTC_F12_CONTENT.jsp" %>
	<div class="sub-cont-header">
		<h1></h1>
		<div class="sub-cont-header-area" >
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
    
    
	<script type="text/javascript" src="${contextPath}/resources/lib/chart.js/dist/Chart.js"></script>	

	

</body>



</html>

