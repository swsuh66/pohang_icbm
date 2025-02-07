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

<!-- 미량누수검출 ISTC_F11_3 -->
<script type="text/javascript">

	var _animate = !AceApp.Util.isReducedMotion();

	var mainGrid;
	
	// 누수설정 모달 그리드
	var settingGrid;

	// 누수설정 수용가 제외 모달 그리드.
	var hideSettingGrid;
	
	var dbParams;
	
	var dbParamsTb = 'f11-3-export';
	
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
		
		
		/* 엑셀다운도르를 위한 db 파람조회  */
		getDbtableInfo();
		
		/*
		* cookie manager 초기화
		*/
		cookie = new CookieManager();
		$('#stdDate').val(kutil.dateFormat(new Date(), 'yyyy-mm-dd'));
		$('#stdTime').val('00:00:00');
		
		settingGrid = initGrid('settingGrid', settingFields);
		hideSettingGrid = initGrid('hideSettingGrid', hideSettingFields);
		
		mainGrid  = initGrid('mainGrid', mainFields);
		
		loadSettingData();

		loadHideSettingData();
		
		setSubmitValidation('settingForm', updateLeakSetting);

		setSubmitValidation('hideSettingForm', updateLeakHideSetting);
		
		loadComponent('select_pipe_diameter');

		loadComponent('select_business_name');

		//mainGrid.search();
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
		
		var qid = qid ? qid : 'mars.icbm.map1.select_waterLeakList_page2';
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
	
	function loadSites() {

		var obj = new Object();
		obj.upSiteSq = parent.getSiteSq();
		obj.noMaster = true;
		obj.lv = 1; //지자체 까지만

		/* 계량기 상태이상 데이터 조회 */
		getAjax('mars.icbm.map1.sitesList', obj, function() {
			

		}, function() {
			
			
			
		}, null);

	};
		

	function loadSettingData(callback) {
		
		var params = new Object();
		$.extend(params, parent.searchComponentes);
		params.limit = 1;
		
		getAjax('mars.icbm.map1.leakSetting2', params, null, function(result) {
			
				
				if(result.length > 0) {
					leakSetting = result[0];
					pushData(leakSetting);				
					refreshGrid(settingGrid, result);
				}
				else {
					refreshGrid(settingGrid, []);
				}
				
				//if(result.length > 0) {
					//chartPriod = leakSetting.daysBefore;
				//}
				
				if(callback)
					callback();
				
			
		}, null);
			
		return false;
	};
	
	function loadHideSettingData(callback) {
		
		var params = new Object();
		$.extend(params, parent.searchComponentes);
		
		getAjax('mars.icbm.map1.leakHideSetting_List', params, null, function(result) {
				if(result.length > 0) {
					refreshGrid(hideSettingGrid, result);
				}
				else {
					refreshGrid(hideSettingGrid, []);
				}
				
				if(callback)
					callback();
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
			//grid.command('refresh');
		else
			grid.command('refresh');
			
	};
		
	var colfnc = function(value, item, c, d, e) {
		
		switch (this.name) {
		case 'num':		
			return (item.pageNo - 1) * item.pageSize + (c + 1);
		case 'blkNm':
			value = item.blkNm2;
			if(value && value.indexOf(':') >= 0)
				value = value.substr(value.indexOf(':')+1);
			return value;		
		case 'sendDt':
		case 'leakMeasDt':	
			/*
		case 'measDt':
			if(!value)
				return '-';
			var dt = new Date(value);		
			return '<small>' + kutil.dateFormat(dt, 'yy.mm.dd') +' </small> ' + kutil.dateFormat(dt, 'HH:MM');*/
		case 'max_date':
		case 'min_date':
 			if(!value)
 				return '-';
 			var dt = new Date(value);		
 			return '' + kutil.dateFormat(dt, 'yyyy.mm.dd') +' ' +
 				kutil.dateFormat(dt, 'HH:MM');
		case 'stat_yn':
			if (value == 'Y') {
				return '계량기누수'
			}
			else {
				return '정상'
			}		
		}
		

		return (value||value==0)?value:'-';
	};

	var colfncSMS = function(value, item, c, d, e) {
		
		switch (this.name) {
		case 'num':		
			value = c + 1;		
			break;
		case 'sendDt':
			
			if(!value) {
				value = '-';
				break;
			}
				
			var dt = new Date(value);		
			value = '<small>' + kutil.dateFormat(dt, 'yy.mm.dd') +' </small> ' + kutil.dateFormat(dt, 'HH:MM');
			break;

		}
		
		value = value?value:'-';
		
		if(!item.custPhone) {
			
			value = '<span style="color:#ccc">' + value + '</span>';
			
		}
			
		return value;
	};

	var groups = [
		{title:'구분', columns: 2, align:"center"},
		{title:'수용가', columns: 3, align:"center"},
		{title:'검침상태', columns: 2, align:"center"},
		{title:'SMS', columns: 4, align:"center"}
	];

	var smsFields = [
		{ name: "num", 		title: "순번", 	type: "text", align:"center", width: 20, 	itemTemplate:colfncSMS, sortingDisabled:true},
		{ name: "adminId",  title: "수용가 번호",type: "text",   width: 50, itemTemplate:colfncSMS, sortingDisabled:true},
	    { name: "custNm",   title: "이름", 	type: "text",   width: 40, itemTemplate:colfncSMS, sortingDisabled:true},
	    { name: "custPhone",title: "전화번호", 	type: "text",   width: 40, itemTemplate:colfncSMS, sortingDisabled:true},
	    { name: "sendDt",   title: "전송일", 	type: "text",   width: 40, itemTemplate:colfncSMS, sortingDisabled:true}
	];

	var rawFields = [
		{ name: "measDt", 		title: "검침일시", 		type: "text", 	align:"center", width: 40, itemTemplate:colfnc, sortingDisabled:true},
		{ name: "termCh", 		title: "사용량(㎥/h)",	type: "number",   width: 50, itemTemplate:colfnc, sortingDisabled:true},    
	    { name: "accuIv", 		title: "최종지침(㎥)", 	type: "number", align:"right",  width: 60, itemTemplate:colfnc , sortingDisabled:true}
	];

	var settingFields = [
		{ name: "rownum", 		    title: "순번", 		type: "text", 	align:"center", width: 60, sortingDisabled:true},
		{ name: "pipe_diameter",    title: "구경", 		type: "text", 	align:"center", width: 60, sortingDisabled:true},
		{ name: "business_name",    title: "업종", 		type: "text", 	align:"center", width: 60, sortingDisabled:true},
		{ name: "compare_term_cv",  title: "최소사용량", 		type: "text", 	align:"center", width: 60, sortingDisabled:true},
		{       		
	        itemTemplate: function(_, item) {
	        	if(item.adminId)
	        		return;
	        	var iEl = $("<i>")
	        			 .attr("data-site_sq", item.site_sq)
	        			 .attr("data-business_name", item.business_name)
	        			 .attr("data-pipe_diameter", item.pipe_diameter)
	        			 .addClass("fa fa-trash");
	        	var aEl = $("<a>").attr("href", "#none")
	        			  .addClass("btn btn-outline-red btn-brc-tp radius-3px py-2")
	        			  .append(iEl)
	        			  .attr("data-site_sq", item.site_sq)
	        			 .attr("data-business_name", item.business_name)
	        			 .attr("data-pipe_diameter", item.pipe_diameter)
	        			  .on("click", function (evt) {
	        				  var el = $(evt.target);
		                      var site_sq = el.data('site_sq');
		                      var business_name = el.data('business_name');
		                      var pipe_diameter = el.data('pipe_diameter');
		                      var qid = "mars.icbm.map1.deleteWaterLeak_List";
		                      
		                      var params = new Object();
		                      params.site_sq = String(site_sq);
		                      params.business_name = String(business_name);
		                      params.pipe_diameter = String(pipe_diameter);
		                      
	        				  
		                      jAlert.confirm('알림','단말을 삭제합니까?', function(){
		                    	  
		                    	  deleteAjax(qid, params, function() {
			              			$('.bcard .settingGrid').aceWidget('startLoading');
			                      }, function(result) {
			                    	  
			                    	  jAlert.info('삭제', '삭제에 성공했습니다.');
			                    	  $('.bcard .settingGrid ').aceWidget('stopLoading');
			                    	  loadSettingData();
			                    	  //settingGrid.search();
			                    	  
			                  		  //$('button[name="closeBtn"]').click();
			                    	  var modal = $('#settingModal'); 
				             			
			             			  modal.modal({backdrop: 'static'});
			             				
			             			  modalGridLayout(modal, 289);
			                    	  
		                 		  }, null);
		                    	  
		                      });
	        				
	                        
	                     });
	        	
	        	
	            return aEl;
	            
	        },		        
	        align: "center",
	        width: 50,
	        title: '단말삭제',
	        hasGroup:false
	        //sortingDisabled:true			      
	    }
	];

	var hideSettingFields = [
		{ name: "rownum", 		    title: "순번", 		type: "text", 	align:"center", width: 60, sortingDisabled:true},
		{ name: "admin_no",         title: "수용가번호",    type: "text", 	align:"center", width: 60, sortingDisabled:true},
		{ name: "ins_dt",    		title: "입력날짜", 		type: "text", 	align:"center", width: 60, sortingDisabled:true},
		{       		
	        itemTemplate: function(_, item) {
	        	if(item.adminId)
	        		return;
	        	var iEl = $("<i>")
	        			 .attr("data-point_sq", item.point_sq)
	        			 .addClass("fa fa-trash");
	        	var aEl = $("<a>").attr("href", "#none")
	        			  .addClass("btn btn-outline-red btn-brc-tp radius-3px py-2")
	        			  .append(iEl)
	        			  .attr("data-point_sq", item.point_sq)
	        			  .on("click", function (evt) {
	        				  var el = $(evt.target);
		                      var point_sq = el.data('point_sq');
		                      var qid = "mars.icbm.map1.deleteWaterLeak_Hide_List";
		                      
		                      var params = new Object();
		                      params.point_sq = String(point_sq);
	        				  
		                      jAlert.confirm('알림','수용가를 삭제합니까?', function(){
		                    	  
		                    	  deleteAjax(qid, params, function() {
			              			$('.bcard .settingGrid').aceWidget('startLoading');
			                      }, function(result) {
			                    	  
			                    	  jAlert.info('삭제', '삭제에 성공했습니다.');
			                    	  $('.bcard .settingGrid ').aceWidget('stopLoading');
			                    	  loadHideSettingData();
			                    	  
			                    	  var modal = $('#hideSettingModal'); 
				             			
			             			  modal.modal({backdrop: 'static'});
			             				
			             			  modalGridLayout(modal, 289);
		                 		  }, null);
		                      });
	                     });
	            return aEl;
	        },		        
	        align: "center",
	        width: 50,
	        title: '수용가삭제',
	        hasGroup:false
	        //sortingDisabled:true			      
	    }
	];

	var mainFields = [		
		{ name: "num", 		title: "순번", 	type: "text", align:"center", 	width: 20, 	sortingDisabled:true},	    
		{ name: "cust_nm", 	title: "이름", 	type: "text", 	align:"left",   width: 40, itemTemplate:colfnc, hasGroup:false, group:groups[0]},	    
	    { name: "admin_id",      title: "수용가번호", 	 type: "text",  		width: 80,  		itemTemplate:colfnc, hasGroup:false},	    	   
	    { name: "use_type",       title: "업종", 		 type: "text",          width: 40, itemTemplate:colfnc, hasGroup:false},
	    { name: "pipe_dia",       title: "구경", 	 type: "text",              width: 40, itemTemplate:colfnc, hasGroup:false},	    
	    { name: "max_date",       title: "최대시간", 	 type: "text",          width: 40, itemTemplate:colfnc, hasGroup:false},	    
	    { name: "min_date",       title: "최소시간", 	 type: "text",          width: 40, itemTemplate:colfnc, hasGroup:false},	    
	    { name: "max_term_cv",       title: "최고사용량", 	 type: "text",      width: 40, itemTemplate:colfnc, hasGroup:false},	    
	    { name: "min_term_cv",       title: "최소사용량", 	 type: "text",      width: 40, itemTemplate:colfnc, hasGroup:false},
		{ name: "stat_yn",        title: "계량기누수여부", 	 type: "text",      width: 40, itemTemplate:colfnc, hasGroup:false}	    
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
		    	parent.loadModalData(false, evt.item);
		    }
	    };
	    
	    return new DataGrid(container, opt);
	};
	
	
	function openSettingModal() {
		
		var modal = $('#settingModal');
		
		modal.modal({backdrop: 'static', keyboard: false});
		
		modalGridLayout(modal, 250);
		
	};

	function openHideSettingModal() {
		
		var modal = $('#hideSettingModal');
		
		modal.modal({backdrop: 'static', keyboard: false});
		
		modalGridLayout(modal, 250);
		
	};

	function openSMSModal(seq) {
		
		var display = function(data) {
			
			var modal = $('#smsModal');
			
			refreshGrid(smsGrid, data);
			
			$('#adminPhone').val( cookie.getCookie('callback_no') );
			
			$('#content').text( cookie.getCookie('content') );
				
			modal.modal({backdrop: 'static', keyboard: false});
			
			smsTargetes = data;
			
			modalGridLayout(modal, 50);
		
		};
		
		if(seq == 0 || seq) { //특정 수용가 선택
			
			var data = [findObject(pointListData, 'pointSq', seq)];
			display(data);
			
		} else { // SMS일괄 전송
			
			
			var params = new Object();
			params.sendCd = '1';
			params.leakFg = '1';		
			
			loadData('mars.icbm.map1.pointList', params, function(data) {
				
				if(data.length == 0) {
					
					jAlert.error('오류', '전송을 허용한 수용가가 없습니다.');
					return;
					
				}
				
				display(data);
				
			});
			
		}
		
			
	};

	function sendSMS(e) {};


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

		$.extend(params, mainGrid.loadParams());

		params['stdDate'] = $('#stdDate').val()+ ' '+ $('#stdTime').val(); // 기준 일자.
		params['stdTime'] = $('#stdTime').val(); // 기준 일자.
		params['cust_nm']  = $('#cust_nm').val();
		params['admin_no'] = $('#admin_no').val();
		params['calc_hour'] = $('#calc_hour').val();
		params['pipe_diameter'] = $('#pipe_diameter').val();
		params['business_name'] = $('#business_name').val();
		params['compare_term_cv'] = $('#compare_term_cv').val();
		params['statYn'] = $('#statYn').val();
		
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
		//var inList = $(e).find('input');
		/*
		$.each(inList, function(i, item) {
			
			var id = $(item).attr('id');
			params[id] = Number($(item).val());
						
		});
		*/
		
		
		$.extend(params, parent.searchComponentes);
		params.pipe_diameter = $('#pipe_diameter').val();
		params.business_name = $('#business_name').val();
		params.calc_hour = $('#calc_hour').val();
		params.compare_term_cv = $('#compare_term_cv').val();
		
		var result = ajaxUpdate({sql:'mars.icbm.map1.insertWaterLeak_List', data:params});
		if(!result.success) {
			
			jAlert.error('저장', '정보를 저장하지 못하였습니다.<br><br>'+ (result.error?result.error.statusText:'서버에서 오류가 발생하였습니다.'));
			return false;
			
		}
		
		jAlert.info('저장', '수정한 정보를 저장 완료하였습니다.');
		
		loadSettingData(function() {
			
			mainGrid.search();
			
		});
		
		var modal = $('#settingModal'); 
			
	    modal.modal({backdrop: 'static'});
		
	    modalGridLayout(modal, 289);
		
		//$('button[name="closeBtn"]').click();
		
		return true;
		
	};

	// 수용가 제외 셋팅
	function updateLeakHideSetting() {
		var params = new Object();	
		
		$.extend(params, parent.searchComponentes);
		params.admin_no = $('#modal_admin_no').val();
		
		var result = ajaxUpdate({sql:'mars.icbm.map1.insertWaterLeak_hide_List', data:params});
		if(!result.success) {
			
			jAlert.error('저장', '정보를 저장하지 못하였습니다.<br><br>'+ (result.error?result.error.statusText:'서버에서 오류가 발생하였습니다.'));
			return false;
			
		}
		
		jAlert.info('저장', '수정한 정보를 저장 완료하였습니다.');
		
		loadHideSettingData(function() {
			
			mainGrid.search();
			
		});
		
		var modal = $('#hideSettingModal'); 
			
	    modal.modal({backdrop: 'static'});
		
	    modalGridLayout(modal, 289);
		
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

		
		params.downloadFileName = "WaterMinLeak_"+ kutil.dateFormat( new Date(), 'yymmddHHMMss');							
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
		
		
		// 2023.12.11 김용희 추가 
		/*
		 * 각 요소 조회
		 */
		function loadComponent(qid) {

			var obj = new Object();
			/* 계량기 상태이상 데이터 조회 */
			getAjax(qid, obj, function() {

			}, refreshComponent, null, null);		

		};
		
		function refreshComponent(result, bCallback) {
			if (result.length != 0) {
				var key = result[0].key;
				result.forEach(function(item, idx) {
					var el = $('<option>').attr('value', item.val).text(item.val);
					$('.form-control[name="' + key + '"]').append(el);
				});
				var el = $('<option>').attr('value', "").text("전체");
				$('.form-control[name="' + key + '"]').append(el);
			}
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
				error: function(result) {
					
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
	<%@ include file="ISTC_F11_3_CONTENT.jsp" %>
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

	<div class="modal fade" id="hideSettingModal" tabindex="-1" role="dialog">
    	<div class="modal-dialog modal-dialog-scrollable modal-dialog-centered " role="document">
    		 <div class="modal-content">
    		 	<div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLabel2">
                        제외 수용가 설정
                    </h5>

                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                
                <form id="hideSettingForm" class="mt-lg-3 validator" autocomplete="off"  data-toggle="validator" role="form">
		        	<div class="modal-body">
						<div class="bcard ccard  overflow-hidden settingGrid">
							<div class="card-header border-0 bgc-white card-header-sm">
								<h6 class="card-title text-dark-m3 pl-25 pt-15 text-110">
									사용자 설정 <br>
									<span class="text-85 text-dark-l2"></span>										
								</h6>
							</div>
							<div class="modal-body">
								<div class="form-group row">
									<div class="col-sm-12">
									  <div class="form-group row">
										<div class="col-sm-2 col-form-label text-sm-right pr-0">
											<label class="mb-0" for="calc_hour">수용가 입력</label>
										</div>
										<div class="col-sm-8">
		                                    <input type="text" id="modal_admin_no" class="form-control">
										</div>
									  </div>
									  <div class="row">
									  	<div class="col-sm-12 ">
									  		<div class="dj-btn-group">
								            	<button class="btn dj-btn-primary btn-sm" type="submit">등록</button>
								            </div>
										</div>
									  </div>
									</div>
								</div>
								
							</div>
							<div class="card-body p-0 bgc-whit flex-grow-1">
								<div id="hideSettionContainer" class="card-body p-0">					
									<div id="hideSettingGrid" class="data-list containerBorder"></div>
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

