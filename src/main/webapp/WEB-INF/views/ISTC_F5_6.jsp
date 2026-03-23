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


<script type="text/javascript">
/* 동두천 주 부 수용가 정보 화면 - ISTC_F5_6 */
	var _animate = !AceApp.Util.isReducedMotion();

	var mainGrid;
	
	var dbParams;
	
	var dbParamsTb = 'f5-6-export';
	
	var dbImportTb = 'f5-6-import';
	
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
	
	function getUserRoll() {
		
		return ${user.getUserRoll()};
		
	};
	
	/**
	 * 엑셀 임폴트 작업
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
		
		
		var url = getContextPath() + '/file/dbParams/' + dbImportTb;

		ajaxSelect({
			url : url,
			success : function(data) {
				
				dbImportParams = data;	
				
				fileUp.setIsModal('importContainer');
				fileUp.initStepWizard('fileUp');
				
				fileUp.initFileGrid('file_grid_container', data);
				
			},
			error : function(result) {
				
				jAlert.error('오류', '데이터를 가져오는데 실패하였습니다.');
				
			}
		});
		

	};
	
	/**
	 * 임포트할 예시 파일을 다운로드 합니다.
	 */
	function exFileDownload() {
		
		window.location = getContextPath() + '/resources/excel/adminimport.xlsx';
		
	};
	
	function openModal() {
		$('#importContainer').modal({backdrop:'static',keyboard:false});
	};
	
	/**
	 * 임포트 끝날시 로직 정의
	 */
	function doCreateCompleteLogic(result) {
		jAlert.info('성공', '저장되었습니다.');
		
		mainGrid.search();
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
		
		var qid = qid ? qid : 'selectAllChildAdminList_page';
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
			
			refreshGrid(mainGrid, result);
			
			$('.bcard.point-grid').aceWidget('stopLoading');
			
		}, null);
		
			
		return false;
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
		}
		
		return (value||value==0)?value:'-';
		
	};


	var groups = [
	];
	

	var rawFields = [
	];

	var mainFields = [	
		{ name: "num", 		       title: "순번", 	         type: "text",   align:"center", 	width: 30, itemTemplate:colfnc, hasGroup:false, sortingDisabled:true},
	    { name: "admin_no",        title: "수용가 번호", 	     type: "text",   align:"center",    width: 60, itemTemplate:colfnc, hasGroup:false},
	    { name: "child_admin_id",  title: "부 수용가 번호", 		 type: "text",   align:"center",    width: 60, itemTemplate:colfnc, hasGroup:false},
	    { name: "admin_nm",        title: "수용가 이름", 		 type: "text",   align:"center",    width: 60, itemTemplate:colfnc, hasGroup:false},
	    { name: "child_admin_nm",  title: "부 수용가 이름", 		 type: "text",   align:"center",    width: 60, itemTemplate:colfnc, hasGroup:false},
	    {       		
	        itemTemplate: function(_, item) {
	        	var iEl = $("<i>")
	        			 .attr("data-admin_no", item.admin_no)
	        			 .attr("data-child_admin_id", item.child_admin_id)
	        			 .addClass("fa fa-trash");
	        	var aEl = $("<a>").attr("href", "#none")
	        			  .addClass("btn btn-outline-red btn-brc-tp radius-3px py-2")
	        			  .append(iEl)
	        			  .attr("data-admin_no", item.admin_no)
	        			  .attr("data-child_admin_id", item.child_admin_id)
	        			  .on("click", function (evt) {
	        				  var el = $(evt.target);
		                      var admin_no = el.data('admin_no');
		                      var child_admin_id = el.data('child_admin_id');
		                      var qid = "mars.icbm.map1.deleteChildAdmin";
		                      
		                      var params = new Object();
		                      params.admin_no = String(admin_no);
		                      params.child_admin_id = String(child_admin_id);
	        				  
		                      jAlert.confirm('알림','행을 삭제하겠습니까?', function(){
		                    	  
		                    	  deleteAjax(qid, params, function() {
			              			$('.bcard .point-grid').aceWidget('startLoading');
			                      }, function(result) {
			                    	  
			                    	  jAlert.info('삭제', '삭제에 성공했습니다.');
			                    	  $('.bcard .point-grid').aceWidget('stopLoading');
			                  		
			                  		  mainGrid.search();
			                    	  
		                 		  }, null);
		                    	  
		                      });
	        				
	                        
	                     });
	        	
	            return aEl;
	        },		        
	        align: "center",
	        width: 40,
	        title: '행 삭제',
	        hasGroup:false
	    }
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

		$.extend(params, searchComponentes);
		$.extend(params, mainGrid.loadParams());
		
		params['admin_no'] = $('#admin_no').val();
		params['cust_nm'] = $('#cust_nm').val();
		params['child_admin_no'] = $('#child_admin_no').val();
		params['child_cust_nm'] = $('#child_cust_nm').val();
		
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
	 */
	 function alldelete() {
         var qid = "mars.icbm.map1.deleteAllChildAdmin";
         
         var params = new Object();
		  
         jAlert.confirm('알림','전체 삭제하겠습니까?', function(){
       	  
       	  deleteAjax(qid, params, function() {
     			$('.bcard .point-grid').aceWidget('startLoading');
             }, function(result) {
           	  
           	  jAlert.info('삭제', '삭제에 성공했습니다.');
           	  $('.bcard .point-grid').aceWidget('stopLoading');
         		
         		  mainGrid.search();
           	  
    		  }, null);
         });
	 }
	
	function dataDownload() {

		
		if(!dbParams) {
			
			jAlert.error('오류', '조건이 맞지 않아 데이터를 다운로드할 수 없습니다.');
			return;
			
		} 

		var params = new Object();
				
		params.qid = dbParams[dbParamsTb]['refer-sql'];
		params.colMapping = dbParams[dbParamsTb]['cols'];
		params.length = params.colMapping.length;

		
		params.downloadFileName = "adminInfo"+ kutil.dateFormat( new Date(), 'yymmddHHMMss');							
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
		
		plh = '수용가(부 수용가) 번호/이름' 
		
		target.attr('placeholder', plh);
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
	<%@ include file="ISTC_F0_1_3.jsp" %>
	<div class="sub-cont-header">
	</div>
	<div class="dj-card">
		<div class="bcard card point-grid">
			<div class="card-body p-0" id="gridContainer">
			<div id="mainGrid" class="data-list containerBorder" style="width: 100%; height: 100%;"></div>
		</div>
		</div>
	</div>
</div>

<div id="importContainer" class="modal fade" role="dialog">
		<div class="modal-dialog modal-dialog-centered">
			<!-- <div class="panel panel-info"> -->
			<div class="modal-content">
				<!-- <div class="panel-heading" style="height:32px;"> -->
				<div class="modal-header">
					<h5 class="modal-title" id="exampleModalLabel2">
             		파일 임포트
           			</h5>
				</div>
				<div class="modal-body" id="fileUpload" align="center">
					<%@include file="ISTC_FILE_UPLOAD.jsp"%>
				</div>
			</div>
		</div>
	</div>



	<script type="text/javascript" src="${contextPath}/resources/lib/chart.js/dist/Chart.js"></script>	
	

</body>



</html>

