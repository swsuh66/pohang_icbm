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

	var _animate = !AceApp.Util.isReducedMotion();

	var mainGrid;
	
	var errGrid;
	
	var devGrid;
	
	var dbParams;
	
	var dbImportParams;
	
	var dbParamsTb = 'f5-export';
	
	var dbImportTb = 'f5-import';
	
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
		
		/* err grid 초기화 */
		errGrid = initGrid('errGrid', errFields);
		
		/* grid 초기화 */
		mainGrid = initGrid('mainGrid', mainFields);
		
		devGrid = initGrid('devGrid', devFields);
		
		/* 수용가 조회 */		
		mainGrid.search();
			
	});
	
	
	/*
	* 리소스 path
 	*/
	function getContextPath() {
		
	   return "${contextPath}";
	   
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
		
		$('#errGridContainer').height(480);
		
	};
	
	function modalGridLayout(modal, height) {
		
		modal.find('.jsgrid-grid-body').css('height',  height + 'px');
		
		$(window).resize(function () {
			
			modal.find('.jsgrid-grid-body').css('height',  height + 'px');
			
		});
		
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
	
	function refreshErrGrid(data) {
		
		if(data)
			errGrid.finishLoad(data||[]);
		else
			errGrid.command('refresh');
		
		
		$('#errGridContainer .jsgrid-grid-body').height(400);
			
	};
	
	function closeDevModal() {
		
		devGrid.finishLoad([]);
		
		$('#searchInputD').val('');
		
	};
	
	/*
	* 그리드 컬럼 요소 리빌딩
 	*/
 	var colfnc = function(value, item, c, d, e) {
 		
 		switch (this.name) {
 		case 'num':		
 			return (item.pageNo - 1) * item.pageSize + (c + 1);
 		case 'instlDay':
 			return kutil.dateFormat(new Date(value), 'yyyy');		
 			
 		}
 		

 		return value?value:'-';
	};
	
	var groups = [		
		{title : '구분', columns : 1,align : "center"},		
		{title : '수용가', columns : 5, align : "center"},		 
		{title : '계량기', columns : 2, align : "center"},					
	    {title : '단말기', columns : 3, align : "center"} ,
	    {title : '동작', columns : 5, align : "center"}
	];
	
	
	var devFields = [
		 { name: "amiType",   title: "통신", 	 type: "text",   width: 80, itemTemplate:colfnc, sortingDisabled:true},
		 { name: "subDevNo",  title: "부번호", 	 type: "text",   width: 140,  itemTemplate:colfnc, sortingDisabled:true},
	     { name: "devNo",  	  title: "주번호", 	 type: "text",   width: 140,  itemTemplate:colfnc, sortingDisabled:true},
	     { name: "adminId",   title: "매핑수용가", 	 type: "text",   width: 140,  itemTemplate:colfnc, sortingDisabled:true},
	     {       		
		        itemTemplate: function(_, item) {
		        	
		        	if(item.pointSq) {
		        		
		        		var iEl = $("<i>")		       			 
		       			 .addClass("fa fa-times")
		       			 .text("매핑불가");
   	
   	
					   	var aEl = $("<a>").attr("href", "#none")
					   			  .addClass("btn btn-outline-red btn-brc-tp radius-3px py-2")
					   			  .append(iEl)	
		        		
					   	return aEl;
		        	}
		        	
		        	var iEl = $("<i>")
					       			 .attr("data-dev-no", item.devNo)
					       			 .attr("data-sub-dev-no", item.subDevNo)
					       			 .attr("data-ami-type", item.amiType)
					       			 .addClass("fa fa-link")
					       			 .text("매핑하기");
		        	
		        	
		        	var aEl = $("<a>").attr("href", "#none")
		        			  .addClass("btn btn-outline-blue btn-brc-tp radius-3px py-2")
		        			  .append(iEl)		        			  
		        			  .attr("data-dev-no", item.devNo)
	        			      .attr("data-sub-dev-no", item.subDevNo)
	        			      .attr("data-ami-type", item.amiType)			        			      
		        			  .on("click", function (evt) {
		        				  		        				  
		        				  var el = $(evt.target);
			                      var devNo = el.data('dev-no');
			                      var subDevNo = el.data('sub-dev-no');
			                      var amiType = el.data('ami-type');
		        				  
			                      
			                      var qid = (amiType == 'lora') ? 'updateLoraMapping' :  'updateNbiotMapping';
			                      
			                      var params = new Object();
			                      params.devNo = devNo;
			                      params.subDevNo = subDevNo;
			                      params.pointSq = $('#devModal #pointSq').val();
			                      
			                      var modal = $('#devGrid');
			                      
			                      jAlert.confirm('알림','단말을 매핑합니까?', function(){
			                    	  
			                    	  insertAjax(qid, params, function() {
				                    	  
			                    		  modal.aceWidget('startLoading');
				                    	  
				                      }, function(result) {
				                    	  
				                    	  modal.aceWidget('stopLoading');
			                 			
				                    	  mainGrid.search();
				                    	  
				                    	  $('#closeBtn').click();
				                    	  
				                    	  /* devGrid.search();
				                    	  
				                    	  modalGridLayout(modal, 270); */
				                    	  
				                    	  jAlert.info('알림', '매핑에 성공했습니다.');
			                 			
			                 		  }, null);
			                    	  
			                      });
		        				
		                    	 
		                     });
		        	
		        	
		            return aEl;
		        },		        
		        align: "center",
		        width: 100 ,
		        title: '동작',		        
		        sortingDisabled:true
		    }
	];
	
	var errFields = [
        { name: "dataSq", 		title: "엑셀 순번", 	     	 type: "text", 	align:"center", width: 80, sortingDisabled:true},
        { name: "msg",			title: "엑셀 오류 내용", 	 	 type: "text",   width: 'auto', sortingDisabled:true}                     
 	];	
	
	var mainFields = [
     	{ name: "num", 			title: "순번", 	     type: "text", align:"center", width: 60, 	itemTemplate:colfnc, sortingDisabled:true},
     	
     	 { name: "siteNm0",        title: "지자체", 		 type: "text",   width: 100, itemTemplate:colfnc, hasGroup:true, group:groups[1]},
          	            
         { name: "adminId",      title: "고객 번호", 	 type: "text",   width: 150, itemTemplate:colfnc, hasGroup:true}, 	             	           
         /* { name: "ctcharNm",     title: "정수장", 	 	 type: "text",   width: 140, itemTemplate:colfnc, hasGroup:true}, */ 	            
         { name: "custNm",       title: "이름", 		 type: "text",   width: 200, itemTemplate:colfnc, hasGroup:true},
         { name: "useType",      title: "업종", 		 type: "text",   width: 70,  itemTemplate:colfnc, hasGroup:true},
         { name: "blkNm",        title: "블록", 		 type: "text",   width: 100, itemTemplate:colfnc, hasGroup:true},
         { name: "pipeDia",      title: "관경(mm)", 	 type: "text",   width: 100,  itemTemplate:colfnc, hasGroup:true , group:groups[2]},
         { name: "meterNo",      title: "번호", 	 type: "text",   width: 100,  itemTemplate:colfnc, hasGroup:true},
         
         
         { name: "amiType",   title: "통신", 	 type: "text",   width: 80, itemTemplate:colfnc, hasGroup:true, group:groups[3]},
        { name: "devNo",     title: "번호", 	 type: "text",   width: 140,  itemTemplate:colfnc, hasGroup:true},
        { name: "comNm",     title: "제조회사", 	 type: "text",   width: 100,  itemTemplate:colfnc, hasGroup:true},	            
        {       		
	        itemTemplate: function(_, item) {
	        	
				var iEl = $("<i>").addClass("fa fa-sync-alt");
	        	
	        	
	        	var aEl = $("<a>").attr("href", "#none")
	        			  .addClass("btn btn-outline-blue btn-brc-tp radius-3px py-2")
	        			  .append(iEl)
	        			  .attr("data-sq", item.pointSq)
	        			  .on("click", function (evt) {
	        				  
	        				  var sq = $(evt.target).data('sq');
	        				  
	        				  jAlert.error('오류', '해당 기능은 아직 사용 불가합니다.');
	        				  return;
	                    	 
	                     });
	        	
	        	
	            return aEl;
	        },		        
	        align: "center",
	        width: 100 ,
	        title: '동기화',
	        hasGroup:true,		
	        group:groups[4],
	        sortingDisabled:true
	    },
	    {       		
	        itemTemplate: function(_, item) {
	        
	        	if(!item.devNo)
	        		return;
	        	
	        	if(!item.adminId)
	        		return;
	        	
	        	var iEl = $("<i>")
	        			 .attr("data-sq", item.pointSq)
	        			 .attr("data-ami-type", item.amiType)
	        			 .addClass("fa fa-window-close");
	        	
	        	
	        	var aEl = $("<a>").attr("href", "#none")
	        			  .addClass("btn btn-outline-blue btn-brc-tp radius-3px py-2")
	        			  .append(iEl)
	        			  .attr("data-sq", item.pointSq)
	        			  .attr("data-ami-type", item.amiType)
	        			  .on("click", function (evt) {
	        				  
	        				  
	        				  var el = $(evt.target);
		                      var sq = el.data('sq');
		                      var amiType = el.data('ami-type');
		                      
		                      
		                      var qid = (amiType == 'lora') ? 'removeLoraMapping' :  'removeNbiotMapping';
		                      
		                      var params = new Object();
		                      params.pointSq = sq;
		                      
	        				  
		                      jAlert.confirm('알림','단말 매핑을 삭제합니까?', function(){
		                    	  
		                    	  updateAjax(qid, params, function() {
			                    	  
				                    	
			              			$('.bcard.point-grid').aceWidget('startLoading');
			                    	  
			                      }, function(result) {
			                    	  
			                    	  $('.bcard.point-grid').aceWidget('stopLoading');
		                 			
			                    	  mainGrid.search();
			                    	  
			                    	  jAlert.info('알림', '업데이트에 성공했습니다.');
		                 			
		                 		  }, null);
		                    	  
		                      });
	        				
	                        
	                     });
	        	
	        	
	            return aEl;
	            
	        },		        
	        align: "center",
	        width: 100,
	        title: '단말해제',
	        hasGroup:true,
	        sortingDisabled:true			      
	    },
	    {       		
	        itemTemplate: function(_, item) {
	        
	        	if(item.devNo)
	        		return;
	        	
	        	if(!item.adminId)
	        		return;
	        	
	        	var iEl = $("<i>")
	        			 .attr("data-sq", item.pointSq)			        			 
	        			 .addClass("fa fa-link");
	        	
	        	
	        	var aEl = $("<a>").attr("href", "#none")
	        			  .addClass("btn btn-outline-blue btn-brc-tp radius-3px py-2")
	        			  .append(iEl)
	        			  .attr("data-sq", item.pointSq)			        			  
	        			  .on("click", function (evt) {
	        				  
	        				  var el = $(evt.target);
		                      var sq = el.data('sq');
		                      
		                      
		                      var modal = $('#devModal');
		             			
		                      modal.modal({backdrop: 'static'});
		                      
	             			  modalGridLayout(modal, 270);
	             			  
	             			  modal.find('#pointSq').val(sq);
	             			  
	             			  devGrid.finishLoad([]);
		                      
	                        
	                     });
	        	
	        	
	            return aEl;
	            
	        },		        
	        align: "center",
	        width: 100,
	        title: '단말매핑',
	        hasGroup:true,
	        sortingDisabled:true			      
	    },
	    {       		
	        itemTemplate: function(_, item) {
	        
	        	if(item.adminId)
	        		return;
	        	
	        	var iEl = $("<i>")
	        			 .attr("data-dev-no", item.devNo)
	        			 .attr("data-sub-dev-no", item.subDevNo)
	        			 .attr("data-ami-type", item.amiType)
	        			 .addClass("fa fa-trash");
	        	
	        	
	        	var aEl = $("<a>").attr("href", "#none")
	        			  .addClass("btn btn-outline-red btn-brc-tp radius-3px py-2")
	        			  .append(iEl)
	        			  .attr("data-dev-no", item.devNo)
	        			  .attr("data-sub-dev-no", item.subDevNo)
	        			  .attr("data-ami-type", item.amiType)
	        			  .on("click", function (evt) {
	        				  
	        				  
	        				  var el = $(evt.target);
		                      var devNo = el.data('dev-no');
		                      var subDevNo = el.data('sub-dev-no');
		                      var amiType = el.data('ami-type');
		                      
		                      
		                      var qid = (amiType == 'lora') ? 'deleteLora' :  'deleteNbiot';
		                      
		                      var params = new Object();
		                      params.devNo = devNo;
		                      params.subDevNo = subDevNo;
		                      
	        				  
		                      jAlert.confirm('알림','단말을 삭제합니까?', function(){
		                    	  
		                    	  deleteAjax(qid, params, function() {
			                    	  
			              			$('.bcard.point-grid').aceWidget('startLoading');
			                    	  
			                      }, function(result) {
			                    	  
			                    	  $('.bcard.point-grid').aceWidget('stopLoading');
			                    	  
			                    	  mainGrid.search();
			                    	  
			                    	  jAlert.info('알림', '삭제에 성공했습니다.');
			                    	  
		                 		  }, null);
		                    	  
		                      });
	        				
	                        
	                     });
	        	
	        	
	            return aEl;
	            
	        },		        
	        align: "center",
	        width: 100,
	        title: '단말삭제',
	        hasGroup:true,
	        sortingDisabled:true			      
	    },
	    {       		
	        itemTemplate: function(_, item) {
	        	
	        	if(!item.adminId)
	        		return;
	        	
	        	var input = $("<input>").attr("type", "checkbox")
	        			    .attr("id", "switch" + item.pointSq)
	            	        .addClass("ace-switch ace-switch-thin")
	            	        .attr("data-sq", item.pointSq)
	                        .on("change", function (evt) {
	                        
		                    	var el = $(evt.target);
		                    	var sq = el.data('sq');			                    	 
		                    	var checked = el.is(':checked');
		                    	 
		                    	var params = new Object();
		                    	params.pointSq = sq;
		                    	params.useCd = checked ? '1' : '7';
		                    	 
		                 		updateAjax('updateUseCd', params, function() {

		                 			/* 로딩 시작 */
		                 			$('.bcard.point-grid').aceWidget('startLoading');

		                 		}, function(result) {
		                 			
		                 			if(result.response.length == 0 )
		                 				return;
		                 			
		                 			var pointSq = result.response[0].pointSq;
		                 			var useCd = result.response[0].useCd;
		                 			
		                 			
		                 			$('.ace-switch[id="switch' + pointSq + '"]').prop(
		                 				'checked', (useCd == '1') ? true : false
		                 			);
		                 			
		                 			
		                 			$('.bcard.point-grid').aceWidget('stopLoading');
		                 			
		                 		}, null);
	                    	 
	                    	 
	                     });
	        	
	        	
	        	input.prop('checked', (item.useCd == '1') ? true : false) ;

	            return input;
	        },		        
	        align: "center",
	        width: 100,
	        title: '검침상태',
	        hasGroup:true,
	        sortingDisabled:true
	    }
     ];
	
	/*
	* 그리드 초기화
 	*/
 	function initGrid(container, field) {
 	    
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
 		   
 	        fields: field,
 	        
 	        loadStrategy: function() {			
 	        	
 	        	return new CustomPageLoadingStrategy(this, loadData);          	        	        
 	        	
 	        },
 			rowDoubleClick: function(evt) {
 				
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
	
	function selectChangHandler(el) {
	
		var searchOption = $(el).val();
		var target = $('#' + $(el).data('target'));
		var plh;
		
		plh = (searchOption == 0) ? '수용가 번호/이름/주소 ...' : '단말기 번호 ...'; 
		
		target.attr('placeholder', plh);
		
	};

	function makeParams() {
		
		var params = {};

		$.extend(params, parent.searchComponentes);
		$.extend(params, mainGrid.loadParams());
		
		params.searchOption = $('#searchOptionSelect').val();
		
		params.useCd = $('#useCdSelect').val() > 0 ? $('#useCdSelect').val() : null;
		
		return params;
	};
	
	
	/* 메인 gird 로드  */
	function loadData() {
		
		var params = makeParams();
		
		/* 수용가 조회 */
		getAjax('settingList_paging', params, function() {

			/* 로딩 시작 */
			$('.bcard.point-grid').aceWidget('startLoading');

		}, refreshGrid, null);

	};
	
	/* dev gird 로드  */
	function loadDevData() {
		
		var searchParam = $('#searchInputD').val();
		
		
		if(!searchParam || searchParam.length == 0) {
			
			jAlert.error('오류', '검색어를 입력하세요.');
			return;
			
		}
		
		var params = new Object();
		
		$.extend(params, mainGrid.loadParams());
		
		params.searchParam = searchParam;
		params.searchOption = 1;
		
		/* 장비 조회 */
		getAjax('settingList_paging', params, function() {

			/* 로딩 시작 */
			$('#devModal').aceWidget('startLoading');

		}, function(data) {
			
			devGrid.finishLoad(data||[]);
			
			modalGridLayout($('#devModal'), 270);
						
			$('#devModal').aceWidget('stopLoading');
			
		}, null);

	};
	
	
	
	function updateAjax(qid, params, beforesend, callback, errCallback, async) {
		
		ajaxUpdate({			
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
			
				jAlert.error('오류', '서버에 오류가 있습니다.');
				
			}
			
		});
		
	};
	
	function insertAjax(qid, params, beforesend, callback, errCallback, async) {
		
		ajaxInsert({			
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
			
				jAlert.error('오류', '서버에 오류가 있습니다.');
				
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
	
	function openModal() {

		$('#importContainer').modal({backdrop:'static',keyboard:false});
		
	};
	
	/**
	 * 임포트할 예시 파일을 다운로드 합니다.
	 */
	function exFileDownload() {
		
		window.location = getContextPath() + '/resources/excel/import.xlsx';
		
	};
	
	/**
	 * 임포트 끝날시 로직 정의
	 */
	function doCreateCompleteLogic(result) {
		
		if(result.length > 0) {
			
			jAlert.error('오류', '엑셀에 오류가 있습니다.');
			
			$('#errModal').modal({backdrop: 'static', keyboard: false});
			
			refreshErrGrid(result);
			
			
		} else
			jAlert.info('성공', '저장되었습니다.');
		
		mainGrid.search();
		
		
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
	
		params.downloadFileName = "Setting_"+ kutil.dateFormat( new Date(), 'yymmddHHMMss');
		$.extend(params, makeParams());

		templetDownLoadStream(params, null, null, function() {
			
			jAlert.error('오류', '다운로드에 실패했습니다.');
			
		}); 

	};
	
</script>

<style type="text/css">

	
	
</style>

	

</head>



<body>


	<div role="main" class="main-content">


		<!-- <div class="page-content container container-plus px-md-4 px-xl-5"> -->
		<div class="page-content container container-plus px-md-4 px-xl-5">
		
		
		<div class="page-header mt-2 mx-lg-n2 border-0 justify-content-start flex-wrap flex-md-nowrap">
              <h1 class="text-dark-m3 pb-0 mb-3 mb-md-0 text-130">
                	설정
              </h1>

              

              <!-- search box -->
              <div class="ml-auto d-flex">
              
              
              	<div class="d-flex align-items-center" style="padding: 0 20px 0 0;">
              		<select data-placeholder="선택" id="useCdSelect" class="form-control border-1p">
              			<option value="0">전체 검침상태</option>
	                  	<option value="1">검침중</option>
	                  	<option value="7">검침중지</option>					                  	
	                  </select>
              	</div>
              	
              	
              	<div class="d-flex align-items-center" style="padding: 0 20px 0 0;">
              		<select data-placeholder="선택" id="searchOptionSelect" class="form-control border-1p" onchange="selectChangHandler(this);" data-target="searchInput">
	                  	<option value="0">수용가 정보로 검색</option>
	                  	<option value="1">단말기 번호로 검색</option>					                  	
	                  </select>
              	</div>
              
              
                <div class="d-flex align-items-center px-lg-0">               
                  
                  <div class="d-flex align-items-center mx-4 mx-lg-0">
	                <i href="#none" class="fa fa-search mr-n35 text-black"></i>
	                <input type="text" id="searchInput" placeholder="수용가 번호/이름/주소 ..." class="pl-45 text-black form-control form-control-lg bgc-transparent brc-yellow-tp3 brc-on-focus border-none border-b-1 radius-0 shadow-none">		                
	                <a href="#none" title="검색 문구 지우기" class="btn btn-outline-warning btn-brc-tp radius-3px py-2" onclick="$('#searchInput').val('')"> <i class="fa fa-eraser text-140"></i></a>
						
	              </div>
                  
                  <!-- <input type="text" id="searchInput" placeholder="수용가 번호/이름 ..." class="form-control brc-blue-m1 brc-on-focus border-none border-b-2 radius-0 shadow-none bgc-transparent pl-35 mr-1"> -->
                  <a href="#none" title="검색" class="btn btn-outline-blue btn-brc-tp radius-3px py-2" onclick="mainGrid.search();"> <i class="fa fa-sync-alt text-140"></i></a>
					                
                </div>
                
                
                <c:if test="${user.getSiteLv() >= 1}">
	                 <div class="d-flex align-items-center px-lg-0">               
	                  <div class="card-toolbar align-self-center no-border">
	                      <div class="dropdown dd-backdrop dd-backdrop-none-md">
	                        <a class="btn btn-light-primary text-600 btn-xs mr-1" href="#" role="button" data-toggle="dropdown" data-display="static" aria-haspopup="true" aria-expanded="false" onclick="openModal();">
	                          Import
	                          <i class="fa fa-upload ml-1 text-90"></i>
	                        </a>
	                        
	                      </div>
	                    </div>
	                </div>
                </c:if>
                
                
                <div class="d-flex align-items-center px-lg-0">               
                  <div class="card-toolbar align-self-center no-border">
                      <div class="dropdown dd-backdrop dd-backdrop-none-md">
                        <a class="btn btn-light-green text-600 btn-xs mr-1"  onclick="dataDownload();">
                          Export
                          <i class="fa fa-download ml-1 text-90"></i>
                        </a>
                        
                      </div>
                    </div>
                </div>
                
                
              </div>
              
              
            </div>


			<!-- <div class="page-header border-0 justify-content-start flex-wrap flex-md-nowrap">
              <h1 class="text-dark-m3 pb-0 mb-3 mb-md-0 text-130">
                	검침현황
              </h1>
              
              <div class="d-flex align-items-center px-lg-0">
                  <i class="fa fa-search text-blue mr-n3"></i>
                  <input type="text" placeholder="Search ..." class="form-control brc-blue-m1 brc-on-focus border-none border-b-2 radius-0 shadow-none bgc-transparent pl-35 mr-1">
                </div>
         
            </div> -->


			<div class="row mt-def">

				<div class="col-12">

					<div class="bcard card h-100 point-grid">
					
					
						<div class="card-body p-0" id="gridContainer"">							
							<div id="mainGrid" class="data-list containerBorder" style="width: 100%; height: 100%;"></div>
						</div>

					</div>
				
			</div>



			</div>


		</div>
	
	
	
	</div>
	
	
	
	


	 
	 
	 <div class="modal fade dialog-50" id="devModal" tabindex="-1" role="dialog">
     <div class="modal-dialog modal-dialog-scrollable" role="document">
       <div class="modal-content">
         <div class="modal-header">
           <h5 class="modal-title">
             	단말매핑
           </h5>

           <button type="button" class="close" data-dismiss="modal" aria-label="Close" id="closeBtn" onclick="closeDevModal();">
	          <span aria-hidden="true">&times;</span>
	        </button>
         </div>

       	 <div class="modal-body">
			
		 <input type="number" id="pointSq" style="display: none;">
         
         <div class="d-flex align-items-center px-lg-0">
           <i class="fa fa-search text-blue mr-n3"></i>
           <input type="text" id="searchInputD" placeholder="단말 검색" class="form-control brc-blue-m1 brc-on-focus border-none border-b-2 radius-0 shadow-none bgc-transparent pl-35 mr-1">
           <a href="#none" title="검색" class="btn btn-outline-blue btn-brc-tp radius-3px py-2" onclick="loadDevData();"> <i class="fa fa-sync-alt text-140"></i></a>
         </div>
     	
		<div id="devContainer">					
			<div id="devGrid" class="data-list"></div>
		</div>
			
           

         </div>

		
         
       </div>
     </div>
   </div>
   
   
   
   
   
   
   <div class="modal fade" id="errModal" tabindex="-1" role="dialog">
	     <div class="modal-dialog modal-dialog-scrollable" role="document">
	       <div class="modal-content">
	         <div class="modal-header">
	           <h5 class="modal-title" id="">
	           	오류 항목
	           </h5>	             	
	           
	
	           <button type="button" class="close" data-dismiss="modal" aria-label="Close">
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
	<%-- <script type="text/javascript" src="${contextPath}/resources/lib/sortablejs/dist/sortable.umd.js"></script> --%>
	

</body>



</html>

