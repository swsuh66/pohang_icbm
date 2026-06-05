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

	var companyGrid;

	var dbParams;

	var dbImportParams;

	var dbParamsTb = 'f5-7-export';

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

		companyGrid = initGrid('companyGrid', companyFields);

		/* 수용가 조회 */
		mainGrid.search();

		loadComponent('mars.icbm.devSqlMapper.selectComponentCompany');
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

			var ht = ht1 - off.top - 36 ;
			$('#gridContainer').height(ht);

		}

		$('#errGridContainer').height(480);

	};

	function setSubmitValidation(){

		//var _form = $('#adminIdForm');

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
			submitHandler: function() {
				updateAdminId(this.currentForm);
			},
	        rules: validate_util.rules,
	        messages: validate_util.messages
		});

		_form.submit(function(){
			_form.valid();
		})
	};


	function modalGridLayout(modal, height) {

		modal.find('.jsgrid-grid-body').css('height',  height + 'px');

		$(window).resize(function () {

			modal.find('.jsgrid-grid-body').css('height',  height + 'px');

		});

	};


	function updateAdminId(el) {
		//return;

		var modal = $('#adminIdModal');

		var params = {};

		var fields = modal.find('input');

		for (var ix = 0; ix < fields.length; ix++) {

			var target = $(fields[ix]);

			var fid = target.attr('name');
			var val = target.val();

			params[fid] = val;
		}

		var fields2 = modal.find('select');

		for (var ix = 0; ix < fields2.length; ix++) {

			var target = $(fields2[ix]);

			var fid = target.attr('name');
			var val = target.val();

			params[fid] = val;

		}
		//return;

		if(!params.adminIdNew || params.adminIdNew.length == 0) {

			jAlert.error('오류', '수정할 수용가번호를 입력하세요.');
			return;

		}

		if(!params.new_sub_dev_no) {

			jAlert.error('오류', '수정할 단말 부번호를 입력하세요.');
			return;

		}

		if(!params.new_dev_no) {

			jAlert.error('오류', '수정할 단말 주번호를 입력하세요.');
			return;

		}

		updateAjax('mars.icbm.map1.updateAdminId', params, function() {

    		  modal.aceWidget('startLoading');

          }, function(result) {

        	  modal.aceWidget('stopLoading');

        	  $('#adminIdModalCloseBtn').click();

        	  jAlert.info('알림', '갱신에 성공했습니다.');

        	  mainGrid.search();


 		  }, function() {

 			 jAlert.error('오류', '알 수 없는 오류가 발생했습니다.');

 			 modal.aceWidget('stopLoading');

 			mainGrid.search();

 		  });

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
					var el = $('<option>').attr('value', item.val).text(item.name);
					$('.form-control[name="' + key + '"]').append(el);
				});
			}
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

	function clearForm(id) {

    	$('#' + id).find('input').val('');

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
		case 'useCd':
			var selected = item.useCd == 1 ? "checked" : "";
			var pointSq = item.pointSq;
			var adminId = "'"+item.adminId + "'";
 			return '<input type="checkbox" name="useCdtext" onchange="gridChecked('+ pointSq + ',' + adminId +', this)" '+ selected + '>';
 		}


 		return value?value:'-';
	};

	// 그리드 체크 변경
	function gridChecked(pointSq, adminId, checkInput) {
		if (confirm("수용가번호 :" + adminId + " 를 검침상태를 변경하시겠습니까? ") == false ) {
			mainGrid.search();
			return;
		}

		var params = {};
		
		 params['pointSq']  = pointSq;
         params['useCd'] = checkInput.checked ? "1" : "0";

		getAjax('mars.icbm.map1.updateUseCd', params, false, function (result) {
			mainGrid.search();
		}, null);

	};

	var groups = [];


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
					   			  .addClass("btn dj-btn-outline-red btn-sm")
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


	var companyFields = [
		{
		itemTemplate: function(_ , item) {
    		var input = $("<input>").attr("type", "text")
									.attr("placeholder","입력")
									.attr("name", "companyNm")
									.addClass("table-item company_nm")

					if(item.companyNm)
						input.val(item.companyNm);

			return input;
        },
        title: "회사명",
        width: 100,
        sortingDisabled:true
		},
			{
				itemTemplate: function(_ , item) {
	    			var input = $("<input>").attr("type", "text")
										.attr("placeholder","입력")
										.attr("name", "companyCd")
										.addClass("table-item company_cd")

					if(item.companyCd)
						input.val(item.companyCd);

					return input;
		        },
		        title: "회사코드",
		        width: 100,
		        sortingDisabled:true
		},
	/* 	{
			itemTemplate: function(_ , item) {
    			var input = $("<input>").attr("type", "text")
									.attr("placeholder","입력")
									.attr("name", "companySq")
									.addClass("table-item company_sq")
									.attr("company-sq", item.companySq)

				if(item.companySq)
					input.val(item.companySq);

				return input;
				console.log(input)
	        },
	        title: "회사seq",
	        width: 50,
	        sortingDisabled:true
	}, */
	{
		itemTemplate: function(_, item) {

        	var iEl = $("<i>")
		   			 .addClass("fa fa-edit");

		   	var aEl = $("<a>").attr("href", "#none")
		   			  .addClass("btn btn-outline-blue btn-brc-tp radius-3px py-2")
		   			  .append(iEl)
		   			  .on("click", function (evt) {
							updateCompanyFields($(this),item.companySq);
		                });

		       return aEl;

        },
        title: "수정",
        width: 40,
        sortingDisabled:true,
        align:"center"
}

	];

	var errFields = [
        { name: "dataSq", 		title: "엑셀 순번", 	     	 type: "text", 	align:"center", width: 80, sortingDisabled:true},
        { name: "msg",			title: "엑셀 오류 내용", 	 	 type: "text",   width: 'auto', sortingDisabled:true}
 	];

	var mainFields = [
     	{ name: "num", 			title: "순번", 	     type: "text", align:"center", width: 60, 	itemTemplate:colfnc, editing: false, sortingDisabled:true},
        { name: "modemId",      title: "모뎀ID", 	 type: "text",   width: 110, itemTemplate:colfnc, editing: false, sortingDisabled:true},
        { name: "devNo",      title: "주번호", 	 type: "text",   width: 110,  itemTemplate:colfnc, editing: false, sortingDisabled:true},
        { name: "subDevNo",   title: "부번호", 	 type: "text",   width: 210,  itemTemplate:colfnc, editing: false, sortingDisabled:true},
        { name: "meterId",      title: "계량기ID", 	 type: "text",   width: 150, itemTemplate:colfnc, editing: false, sortingDisabled:true},
        { name: "telNum",      title: "IMEI", 	 type: "text",   width: 150,  itemTemplate:colfnc, editing: false, sortingDisabled:true},
        { name: "imsi",      title: "IMSI", 	 type: "text",   width: 150,  itemTemplate:colfnc, editing: false, sortingDisabled:true},
        { name: "measCycle",      title: "검침주기(분)", 	 type: "text",   width: 120,  itemTemplate:colfnc, editing: false, sortingDisabled:true},
        { name: "reportCycle",      title: "검침횟수", 	 type: "text",   width: 100,  itemTemplate:colfnc, editing: false, sortingDisabled:true},
        { name: "modemControl",      title: "리셋Flag", 	 type: "text",   width: 100,  itemTemplate:colfnc, editing: false, sortingDisabled:true}
     ];

	/* ============================================
	 * 단말 점검 모달
	 * ============================================ */
	var deviceCheckData = [];
	var backupHistoryData = [];
	var dcShowAll = false;

	function openDeviceCheckModal() {
		var modalHtml = ''
			+ '<div id="deviceCheckOverlay" style="position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.45);z-index:99999;display:flex;align-items:center;justify-content:center;">'
			+ '<div style="background:#fff;width:94%;max-width:1020px;max-height:85vh;border-radius:12px;box-shadow:0 12px 40px rgba(0,0,0,0.2);display:flex;flex-direction:column;overflow:hidden;">'
			/* 헤더 */
			+ '<div style="padding:16px 24px;background:#fff;border-bottom:1px solid #e5e7eb;display:flex;justify-content:space-between;align-items:center;">'
			+ '<div style="display:flex;align-items:center;gap:12px;">'
			+ '<div style="width:36px;height:36px;background:#f0fdf4;border:1px solid #bbf7d0;border-radius:8px;display:flex;align-items:center;justify-content:center;"><i class="fa fa-stethoscope" style="color:#16a34a;font-size:15px;"></i></div>'
			+ '<div><span style="color:#111827;font-size:16px;font-weight:700;">단말 점검</span><span style="margin-left:10px;font-size:11px;color:#6b7280;">위지트 &harr; 서버 부번호 비교</span></div>'
			+ '</div>'
			+ '<span style="cursor:pointer;color:#9ca3af;font-size:22px;line-height:1;width:32px;height:32px;display:flex;align-items:center;justify-content:center;border-radius:6px;" onmouseover="this.style.background=\'#f3f4f6\';this.style.color=\'#374151\'" onmouseout="this.style.background=\'transparent\';this.style.color=\'#9ca3af\'" onclick="closeDeviceCheckModal();">&times;</span>'
			+ '</div>'
			/* 검색 바 */
			+ '<div style="padding:12px 24px;background:#fff;border-bottom:1px solid #f3f4f6;display:flex;align-items:center;gap:8px;flex-wrap:wrap;">'
			+ '<input id="dcSearchDevNo" type="text" placeholder="주번호" style="padding:6px 10px;font-size:12px;border:1px solid #d1d5db;border-radius:6px;width:140px;outline:none;" onkeydown="if(event.keyCode===13)searchDeviceCheck();" />'
			+ '<input id="dcSearchCustNm" type="text" placeholder="수용가명" style="padding:6px 10px;font-size:12px;border:1px solid #d1d5db;border-radius:6px;width:120px;outline:none;" onkeydown="if(event.keyCode===13)searchDeviceCheck();" />'
			+ '<input id="dcSearchModemId" type="text" placeholder="모뎀ID" style="padding:6px 10px;font-size:12px;border:1px solid #d1d5db;border-radius:6px;width:140px;outline:none;" onkeydown="if(event.keyCode===13)searchDeviceCheck();" />'
			+ '<button type="button" style="padding:6px 14px;font-size:12px;font-weight:500;border:none;background:#2563eb;color:#fff;border-radius:6px;cursor:pointer;" onmouseover="this.style.background=\'#1d4ed8\'" onmouseout="this.style.background=\'#2563eb\'" onclick="searchDeviceCheck();"><i class="fa fa-search" style="margin-right:3px;"></i>조회</button>'
			+ '<button type="button" style="padding:6px 14px;font-size:12px;font-weight:500;border:1px solid #d1d5db;background:#fff;color:#374151;border-radius:6px;cursor:pointer;" onmouseover="this.style.background=\'#f9fafb\'" onmouseout="this.style.background=\'#fff\'" onclick="resetDeviceCheckSearch();"><i class="fa fa-redo" style="margin-right:3px;"></i>초기화</button>'
			+ '<div style="margin-left:auto;display:flex;align-items:center;gap:6px;">'
			+ '<span style="font-size:11px;color:#6b7280;">불일치만</span>'
			+ '<label id="dcToggleLabel" style="position:relative;display:inline-block;width:36px;height:20px;margin:0;cursor:pointer;">'
			+ '<input id="dcToggleAll" type="checkbox" style="opacity:0;width:0;height:0;" onchange="toggleDeviceCheckAll(this);" />'
			+ '<span style="position:absolute;top:0;left:0;right:0;bottom:0;background:#2563eb;border-radius:10px;transition:background 0.2s;"></span>'
			+ '<span id="dcToggleKnob" style="position:absolute;top:2px;left:2px;width:16px;height:16px;background:#fff;border-radius:50%;transition:transform 0.2s;"></span>'
			+ '</label>'
			+ '<span style="font-size:11px;color:#6b7280;">전체</span>'
			+ '</div>'
			+ '</div>'
			/* 바디 */
			+ '<div id="deviceCheckBody" style="padding:20px 24px;overflow-y:auto;flex:1;background:#f9fafb;">'
			+ '<div style="text-align:center;padding:40px 20px;">'
			+ '<i class="fa fa-spinner fa-spin" style="font-size:20px;color:#6b7280;"></i>'
			+ '<p style="margin-top:12px;color:#6b7280;font-size:13px;">조회 중...</p>'
			+ '</div>'
			+ '</div>'
			/* 푸터 */
			+ '<div id="deviceCheckFooter" style="display:none;padding:14px 24px;background:#fff;border-top:1px solid #e5e7eb;justify-content:space-between;align-items:center;">'
			+ '<span id="deviceCheckCount" style="font-size:12px;color:#6b7280;"></span>'
			+ '<div style="display:flex;gap:8px;">'
			+ '<button type="button" style="padding:8px 16px;font-size:12px;font-weight:500;border:1px solid #f97316;background:#fff;color:#f97316;border-radius:6px;cursor:pointer;" onmouseover="this.style.background=\'#fff7ed\'" onmouseout="this.style.background=\'#fff\'" onclick="openBackupHistory();"><i class="fa fa-history" style="margin-right:4px;"></i>되돌리기</button>'
			+ '<button type="button" style="padding:8px 16px;font-size:12px;font-weight:600;border:none;background:#dc2626;color:#fff;border-radius:6px;cursor:pointer;" onmouseover="this.style.background=\'#b91c1c\'" onmouseout="this.style.background=\'#dc2626\'" onclick="confirmSyncAll();"><i class="fa fa-sync-alt" style="margin-right:4px;"></i>전체 동기화</button>'
			+ '<button type="button" style="padding:8px 16px;font-size:12px;font-weight:500;border:1px solid #d1d5db;background:#fff;color:#374151;border-radius:6px;cursor:pointer;" onmouseover="this.style.background=\'#f9fafb\'" onmouseout="this.style.background=\'#fff\'" onclick="closeDeviceCheckModal();">닫기</button>'
			+ '</div>'
			+ '</div>'
			+ '</div></div>';

		$('#deviceCheckOverlay').remove();
		$('body').append(modalHtml);
		$('#deviceCheckFooter').hide();

		searchDeviceCheck();
	}

	function toggleDeviceCheckAll(el) {
		dcShowAll = el.checked;
		var knob = document.getElementById('dcToggleKnob');
		var label = document.getElementById('dcToggleLabel');
		var slider = label.querySelector('span:first-of-type');
		if (dcShowAll) {
			knob.style.transform = 'translateX(16px)';
			slider.style.background = '#16a34a';
		} else {
			knob.style.transform = 'translateX(0)';
			slider.style.background = '#2563eb';
		}
		searchDeviceCheck();
	}

	function searchDeviceCheck() {
		var params = {
			search_dev_no: ($('#dcSearchDevNo').val() || '').trim(),
			search_cust_nm: ($('#dcSearchCustNm').val() || '').trim(),
			search_modem_id: ($('#dcSearchModemId').val() || '').trim(),
			mismatch_only: dcShowAll ? 'N' : 'Y'
		};

		$('#deviceCheckBody').html(
			'<div style="text-align:center;padding:40px 20px;">'
			+ '<i class="fa fa-spinner fa-spin" style="font-size:20px;color:#6b7280;"></i>'
			+ '<p style="margin-top:12px;color:#6b7280;font-size:13px;">조회 중...</p></div>'
		);

		getAjax('mars.icbm.map1.wizitSubDevMismatchList', params, null, function(data) {
			deviceCheckData = data || [];
			renderDeviceCheckResult();
		}, function(error) {
			$('#deviceCheckBody').html(
				'<div style="text-align:center;padding:40px 20px;">'
				+ '<i class="fa fa-exclamation-circle" style="font-size:22px;color:#dc2626;"></i>'
				+ '<p style="margin-top:10px;color:#dc2626;font-size:13px;">조회에 실패했습니다.</p></div>'
			);
		});
	}

	function resetDeviceCheckSearch() {
		$('#dcSearchDevNo').val('');
		$('#dcSearchCustNm').val('');
		$('#dcSearchModemId').val('');
		searchDeviceCheck();
	}

	function closeDeviceCheckModal() {
		$('#deviceCheckOverlay').remove();
	}

	function renderDeviceCheckResult() {
		var list = deviceCheckData;
		var body = $('#deviceCheckBody');

		if (list.length === 0) {
			body.html(
				'<div style="text-align:center;padding:40px 20px;">'
				+ '<div style="width:52px;height:52px;background:#dcfce7;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;margin-bottom:12px;">'
				+ '<i class="fa fa-check" style="font-size:22px;color:#16a34a;"></i></div>'
				+ '<p style="font-size:15px;font-weight:600;color:#166534;margin-bottom:4px;">모두 정상</p>'
				+ '<p style="font-size:13px;color:#4ade80;margin:0;">위지트와 서버의 단말 부번호가 모두 일치합니다.</p>'
				+ '</div>'
			);
			$('#deviceCheckFooter').css('display','flex');
			$('#deviceCheckCount').html('');
			return;
		}

		var mismatchCnt = 0;
		var matchCnt = 0;
		for (var k = 0; k < list.length; k++) {
			if (list[k].mismatch === 'Y') mismatchCnt++;
			else matchCnt++;
		}

		var html = '';
		if (dcShowAll) {
			html += '<div style="background:#eff6ff;border:1px solid #bfdbfe;border-radius:8px;padding:12px 16px;margin-bottom:16px;display:flex;align-items:center;justify-content:space-between;">'
				+ '<div style="display:flex;align-items:center;gap:10px;">'
				+ '<i class="fa fa-list" style="color:#2563eb;font-size:14px;"></i>'
				+ '<span style="font-size:13px;color:#1e40af;">전체 <strong>' + list.length + '건</strong> (일치 <strong style="color:#16a34a;">' + matchCnt + '</strong> / 불일치 <strong style="color:#dc2626;">' + mismatchCnt + '</strong>)</span>'
				+ '</div>'
				+ '<button type="button" style="padding:5px 12px;font-size:11px;font-weight:500;border:1px solid #16a34a;background:#fff;color:#16a34a;border-radius:5px;cursor:pointer;white-space:nowrap;" onmouseover="this.style.background=\'#f0fdf4\'" onmouseout="this.style.background=\'#fff\'" onclick="downloadMismatchExcel();"><i class="fa fa-file-excel" style="margin-right:4px;"></i>엑셀 다운로드</button>'
				+ '</div>';
		} else {
			html += '<div style="background:#fffbeb;border:1px solid #fde68a;border-radius:8px;padding:12px 16px;margin-bottom:16px;display:flex;align-items:center;justify-content:space-between;">'
				+ '<div style="display:flex;align-items:center;gap:10px;">'
				+ '<i class="fa fa-exclamation-triangle" style="color:#d97706;font-size:14px;"></i>'
				+ '<span style="font-size:13px;color:#92400e;">부번호 불일치 <strong style="color:#dc2626;">' + list.length + '건</strong> &mdash; 동기화 시 서버 값이 위지트 값으로 변경됩니다.</span>'
				+ '</div>'
				+ '<button type="button" style="padding:5px 12px;font-size:11px;font-weight:500;border:1px solid #16a34a;background:#fff;color:#16a34a;border-radius:5px;cursor:pointer;white-space:nowrap;" onmouseover="this.style.background=\'#f0fdf4\'" onmouseout="this.style.background=\'#fff\'" onclick="downloadMismatchExcel();"><i class="fa fa-file-excel" style="margin-right:4px;"></i>엑셀 다운로드</button>'
				+ '</div>';
		}

		html += '<div style="border:1px solid #e5e7eb;border-radius:8px;overflow:hidden;">';
		html += '<table style="width:100%;border-collapse:collapse;font-size:12px;">';
		html += '<thead><tr style="background:#f9fafb;">';
		html += '<th style="padding:10px 8px;text-align:center;font-weight:600;color:#6b7280;border-bottom:1px solid #e5e7eb;width:38px;">No</th>';
		if (dcShowAll) html += '<th style="padding:10px 8px;text-align:center;font-weight:600;color:#6b7280;border-bottom:1px solid #e5e7eb;width:50px;">상태</th>';
		html += '<th style="padding:10px 8px;font-weight:600;color:#6b7280;border-bottom:1px solid #e5e7eb;">수용가</th>';
		html += '<th style="padding:10px 8px;font-weight:600;color:#6b7280;border-bottom:1px solid #e5e7eb;">주번호</th>';
		html += '<th style="padding:10px 8px;font-weight:600;color:#6b7280;border-bottom:1px solid #e5e7eb;"><i class="fa fa-building" style="color:#7c3aed;margin-right:4px;font-size:10px;"></i>위지트</th>';
		html += '<th style="padding:10px 8px;font-weight:600;color:#6b7280;border-bottom:1px solid #e5e7eb;"><i class="fa fa-server" style="color:#2563eb;margin-right:4px;font-size:10px;"></i>서버</th>';
		if (!dcShowAll) {
			html += '<th style="padding:10px 8px;font-weight:600;color:#6b7280;border-bottom:1px solid #e5e7eb;"><i class="fa fa-arrow-right" style="color:#16a34a;margin-right:4px;font-size:10px;"></i>동기화 후</th>';
			html += '<th style="padding:10px 8px;text-align:center;font-weight:600;color:#6b7280;border-bottom:1px solid #e5e7eb;width:60px;">조치</th>';
		}
		html += '</tr></thead><tbody>';

		for (var i = 0; i < list.length; i++) {
			var item = list[i];
			var isMismatch = (item.mismatch === 'Y');
			var bgColor = isMismatch ? ((i % 2 === 0) ? '#fff' : '#fef2f2') : ((i % 2 === 0) ? '#fff' : '#f9fafb');
			var hoverColor = isMismatch ? '#fef2f2' : '#f0f9ff';
			html += '<tr style="background:' + bgColor + ';" onmouseover="this.style.background=\'' + hoverColor + '\'" onmouseout="this.style.background=\'' + bgColor + '\'">';
			html += '<td style="padding:9px 8px;text-align:center;color:#9ca3af;border-bottom:1px solid #f3f4f6;">' + (i + 1) + '</td>';
			if (dcShowAll) {
				if (isMismatch) {
					html += '<td style="padding:9px 8px;text-align:center;border-bottom:1px solid #f3f4f6;"><span style="background:#fef2f2;color:#dc2626;padding:2px 6px;border-radius:4px;font-size:10px;font-weight:600;">불일치</span></td>';
				} else {
					html += '<td style="padding:9px 8px;text-align:center;border-bottom:1px solid #f3f4f6;"><span style="background:#f0fdf4;color:#16a34a;padding:2px 6px;border-radius:4px;font-size:10px;font-weight:600;">일치</span></td>';
				}
			}
			html += '<td style="padding:9px 8px;border-bottom:1px solid #f3f4f6;"><span style="font-weight:500;color:#111827;">' + (item.custNm || '-') + '</span><br><span style="font-size:10px;color:#9ca3af;">' + (item.custNo || '') + '</span></td>';
			html += '<td style="padding:9px 8px;border-bottom:1px solid #f3f4f6;"><code style="background:#f3f4f6;padding:2px 6px;border-radius:3px;font-size:11px;color:#374151;">' + (item.devNo || '-') + '</code></td>';
			html += '<td style="padding:9px 8px;border-bottom:1px solid #f3f4f6;"><span style="background:#f5f3ff;color:#6d28d9;padding:3px 8px;border-radius:4px;font-size:11px;font-family:monospace;">' + (item.wizitSubDevNo || '-') + '</span></td>';
			html += '<td style="padding:9px 8px;border-bottom:1px solid #f3f4f6;"><span style="background:#eff6ff;color:#1d4ed8;padding:3px 8px;border-radius:4px;font-size:11px;font-family:monospace;">' + (item.cmapSubDevNo || '-') + '</span></td>';
			if (!dcShowAll) {
				html += '<td style="padding:9px 8px;border-bottom:1px solid #f3f4f6;"><span style="background:#f0fdf4;color:#15803d;padding:3px 8px;border-radius:4px;font-size:11px;font-family:monospace;"><i class="fa fa-check" style="font-size:9px;margin-right:3px;color:#22c55e;"></i>' + (item.wizitSubDevNo || '-') + '</span></td>';
				html += '<td style="padding:9px 8px;text-align:center;border-bottom:1px solid #f3f4f6;">'
					+ '<button style="padding:5px 10px;font-size:11px;border:none;background:#2563eb;color:#fff;border-radius:5px;cursor:pointer;" onmouseover="this.style.background=\'#1d4ed8\'" onmouseout="this.style.background=\'#2563eb\'" onclick="confirmSyncOne(' + i + ');">'
					+ '<i class="fa fa-sync-alt"></i></button></td>';
			}
			html += '</tr>';
		}

		html += '</tbody></table></div>';
		body.html(html);
		$('#deviceCheckFooter').css('display','flex');
		if (dcShowAll) {
			$('#deviceCheckCount').html('<i class="fa fa-info-circle" style="color:#9ca3af;"></i> 전체 <strong>' + list.length + '</strong>건 (불일치 <strong style="color:#dc2626;">' + mismatchCnt + '</strong>건)');
		} else {
			$('#deviceCheckCount').html('<i class="fa fa-info-circle" style="color:#9ca3af;"></i> 총 <strong>' + list.length + '</strong>건 불일치');
		}
	}

	function confirmSyncOne(idx) {
		var item = deviceCheckData[idx];
		var msg = '<strong>' + (item.custNm || '수용가') + '</strong> (' + (item.custNo || '') + ')<br>';
		msg += '서버 부번호를 위지트 값으로 동기화합니다.<br><br>';
		msg += '<table style="width:100%;font-size:12px;border-collapse:collapse;">';
		msg += '<tr><td style="padding:4px 8px;color:#805ad5;"><i class="fa fa-building"></i> 위지트</td><td style="padding:4px 8px;font-family:monospace;">' + (item.wizitSubDevNo || '-') + '</td></tr>';
		msg += '<tr><td style="padding:4px 8px;color:#2b6cb0;"><i class="fa fa-server"></i> 서버(현재)</td><td style="padding:4px 8px;font-family:monospace;">' + (item.cmapSubDevNo || '-') + '</td></tr>';
		msg += '<tr style="background:#c6f6d5;"><td style="padding:4px 8px;color:#276749;"><i class="fa fa-arrow-right"></i> 변경 후</td><td style="padding:4px 8px;font-family:monospace;font-weight:bold;">' + (item.wizitSubDevNo || '-') + '</td></tr>';
		msg += '</table>';
		msg += '<br><small style="color:#6b7280;"><i class="fa fa-shield-alt"></i> 백업 후 변경되며, 되돌리기 가능합니다.</small>';

		jAlert.error('알림', '현재 사용이 불가능합니다.');
		return;
		/* -- 동기화 비활성화 (아래 코드는 활성화 시 return 제거) --
		jAlert.confirm('단말 정보 변경 확인', msg, function() {
			var params = { devNo: item.devNo, wizitSubDevNo: item.wizitSubDevNo };
			insertAjax('mars.icbm.map1.backupCmapSubDevNo', params, null, function() {
				updateAjax('mars.icbm.map1.syncCmapSubDevNo', params, null, function() {
					jAlert.info('완료', (item.custNm || '수용가') + '의 단말 부번호가 정상 반영되었습니다.');
					deviceCheckData.splice(idx, 1);
					renderDeviceCheckResult();
					mainGrid.search();
				}, function() {
					jAlert.error('오류', '변경에 실패했습니다.');
				});
			}, function() {
				jAlert.error('오류', '백업 생성에 실패했습니다. 동기화를 중단합니다.');
			});
		});
		*/
	}

	function confirmSyncAll() {
		jAlert.error('알림', '현재 사용이 불가능합니다.');
		return;
		/* -- 전체 동기화 비활성화 (아래 코드는 활성화 시 return 제거) --
		var cnt = deviceCheckData.length;
		var msg = '<strong>총 ' + cnt + '건</strong>의 수용가 단말 부번호를 일괄 변경합니다.<br><br>';
		msg += '모뎀 교체 후 미반영된 부번호를 정상값으로 동기화합니다.<br>';
		msg += '<small style="color:#6b7280;"><i class="fa fa-shield-alt"></i> 변경 전 백업이 생성되며, 되돌리기 버튼으로 원복 가능합니다.</small>';

		jAlert.confirm('전체 동기화 확인', msg, function() {
			insertAjax('mars.icbm.map1.backupAllCmapSubDevNo', {}, null, function() {
				updateAjax('mars.icbm.map1.syncAllCmapSubDevNo', {}, null, function() {
					jAlert.info('완료', cnt + '건의 단말 부번호가 정상 반영되었습니다.');
					deviceCheckData = [];
					renderDeviceCheckResult();
					mainGrid.search();
				}, function() {
					jAlert.error('오류', '일괄 동기화에 실패했습니다.');
				});
			}, function() {
				jAlert.error('오류', '백업 생성에 실패했습니다. 동기화를 중단합니다.');
			});
		});
		*/
	}

	function openBackupHistory() {
		getAjax('mars.icbm.map1.backupSubDevNoHistory', {}, null, function(data) {
			var list = data || [];
			if (list.length === 0) {
				$('#deviceCheckBody').html(
					'<div style="text-align:center;padding:40px 20px;">'
					+ '<i class="fa fa-inbox" style="font-size:28px;color:#d1d5db;"></i>'
					+ '<p style="margin-top:10px;color:#6b7280;font-size:13px;">되돌릴 수 있는 백업 이력이 없습니다.</p>'
					+ '</div>'
				);
				$('#deviceCheckFooter').css('display','flex');
				$('#deviceCheckCount').html('');
				return;
			}

			backupHistoryData = list;

			var html = '<div style="margin-bottom:12px;display:flex;justify-content:space-between;align-items:center;">';
			html += '<span style="font-size:13px;font-weight:600;color:#111827;"><i class="fa fa-history" style="color:#f97316;margin-right:6px;"></i>변경 이력 (' + list.length + '건)</span>';
			html += '<div style="display:flex;gap:6px;">';
			html += '<button style="padding:6px 14px;font-size:11px;font-weight:500;border:1px solid #16a34a;background:#fff;color:#16a34a;border-radius:5px;cursor:pointer;" onmouseover="this.style.background=\'#f0fdf4\'" onmouseout="this.style.background=\'#fff\'" onclick="downloadBackupHistoryExcel();"><i class="fa fa-file-excel" style="margin-right:4px;"></i>엑셀 다운로드</button>';
			html += '<button style="padding:6px 14px;font-size:11px;font-weight:600;border:none;background:#f97316;color:#fff;border-radius:5px;cursor:pointer;" onmouseover="this.style.background=\'#ea580c\'" onmouseout="this.style.background=\'#f97316\'" onclick="doRestoreAll(' + list.length + ');"><i class="fa fa-undo" style="margin-right:4px;"></i>전체 되돌리기</button>';
			html += '</div>';
			html += '</div>';

			html += '<div style="max-height:350px;overflow-y:auto;border:1px solid #e5e7eb;border-radius:8px;">';
			html += '<table style="width:100%;border-collapse:collapse;font-size:12px;">';
			html += '<thead><tr style="background:#f9fafb;position:sticky;top:0;">';
			html += '<th style="padding:8px;border-bottom:1px solid #e5e7eb;">수용가</th>';
			html += '<th style="padding:8px;border-bottom:1px solid #e5e7eb;">변경 전</th>';
			html += '<th style="padding:8px;border-bottom:1px solid #e5e7eb;">변경 후</th>';
			html += '<th style="padding:8px;border-bottom:1px solid #e5e7eb;">일시</th>';
			html += '<th style="padding:8px;border-bottom:1px solid #e5e7eb;text-align:center;width:60px;">되돌리기</th>';
			html += '</tr></thead><tbody>';

			for (var i = 0; i < list.length; i++) {
				var b = list[i];
				var dt = b.backupDt ? b.backupDt.substring(0, 16).replace('T', ' ') : '-';
				var bgColor = (i % 2 === 0) ? '#fff' : '#f9fafb';
				html += '<tr style="background:' + bgColor + ';">';
				html += '<td style="padding:6px 8px;border-bottom:1px solid #f3f4f6;">' + (b.custNm || '-') + '<br><small style="color:#9ca3af;">' + (b.custNo || '') + '</small></td>';
				html += '<td style="padding:6px 8px;border-bottom:1px solid #f3f4f6;"><span style="font-family:monospace;font-size:11px;background:#fef3c7;padding:2px 6px;border-radius:3px;">' + (b.subDevNoOld || '-') + '</span></td>';
				html += '<td style="padding:6px 8px;border-bottom:1px solid #f3f4f6;"><span style="font-family:monospace;font-size:11px;background:#e0e7ff;padding:2px 6px;border-radius:3px;">' + (b.subDevNoNew || '-') + '</span></td>';
				html += '<td style="padding:6px 8px;border-bottom:1px solid #f3f4f6;font-size:11px;color:#6b7280;">' + dt + '</td>';
				html += '<td style="padding:6px 8px;border-bottom:1px solid #f3f4f6;text-align:center;">'
					+ '<button style="padding:4px 8px;font-size:10px;border:1px solid #f97316;background:#fff;color:#f97316;border-radius:4px;cursor:pointer;" onmouseover="this.style.background=\'#fff7ed\'" onmouseout="this.style.background=\'#fff\'" onclick="doRestore(' + b.backupSq + ',\'' + b.devNo + '\');"><i class="fa fa-undo"></i></button></td>';
				html += '</tr>';
			}
			html += '</tbody></table></div>';

			$('#deviceCheckBody').html(html);
			$('#deviceCheckFooter').css('display','flex');
			$('#deviceCheckCount').html('<span style="color:#f97316;cursor:pointer;" onclick="searchDeviceCheck();"><i class="fa fa-arrow-left" style="margin-right:4px;"></i>불일치 목록으로</span>');
		}, function() {
			jAlert.error('오류', '백업 이력 조회에 실패했습니다.');
		});
	}

	function doRestore(backupSq, devNo) {
		jAlert.confirm('되돌리기 확인', '해당 수용가의 부번호를 변경 전 값으로 되돌립니다.<br>계속하시겠습니까?', function() {
			var params = { backupSq: backupSq, devNo: devNo };
			updateAjax('mars.icbm.map1.restoreCmapSubDevNo', params, null, function() {
				updateAjax('mars.icbm.map1.markRestoredBackup', { backupSq: backupSq }, null, function() {
					jAlert.info('완료', '부번호가 원래 값으로 되돌려졌습니다.');
					openBackupHistory();
					mainGrid.search();
				}, null);
			}, function() {
				jAlert.error('오류', '되돌리기에 실패했습니다.');
			});
		});
	}

	function doRestoreAll(cnt) {
		var msg = '<strong>총 ' + cnt + '건</strong>의 부번호를 모두 변경 전 값으로 되돌립니다.<br><br>';
		msg += '<small style="color:#dc2626;"><i class="fa fa-exclamation-triangle"></i> 이 작업은 모든 동기화를 원복합니다. 신중하게 진행하세요.</small>';

		jAlert.confirm('전체 되돌리기 확인', msg, function() {
			updateAjax('mars.icbm.map1.restoreAllCmapSubDevNo', {}, null, function() {
				updateAjax('mars.icbm.map1.markAllRestoredBackup', {}, null, function() {
					jAlert.info('완료', cnt + '건의 부번호가 원래 값으로 되돌려졌습니다.');
					openBackupHistory();
					mainGrid.search();
				}, null);
			}, function() {
				jAlert.error('오류', '전체 되돌리기에 실패했습니다.');
			});
		});
	}

	function dcExcelDate() {
		var d = new Date();
		var yyyy = d.getFullYear();
		var mm = ('0' + (d.getMonth() + 1)).slice(-2);
		var dd = ('0' + d.getDate()).slice(-2);
		var hh = ('0' + d.getHours()).slice(-2);
		var mi = ('0' + d.getMinutes()).slice(-2);
		return yyyy + mm + dd + '_' + hh + mi;
	}

	function dcMakeExcelBlob(tableHtml) {
		var html = '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/TR/REC-html40">'
			+ '<head><meta charset="utf-8">'
			+ '<style>td,th{mso-number-format:"\\@";border:1px solid #999;padding:4px 8px;font-size:11px;} th{background:#f0f0f0;font-weight:bold;}</style>'
			+ '</head><body>' + tableHtml + '</body></html>';
		return new Blob(['\ufeff' + html], { type: 'application/vnd.ms-excel' });
	}

	function dcTriggerDownload(blob, fileName) {
		var link = document.createElement('a');
		link.href = URL.createObjectURL(blob);
		link.download = fileName;
		document.body.appendChild(link);
		link.click();
		document.body.removeChild(link);
		URL.revokeObjectURL(link.href);
	}

	function downloadMismatchExcel() {
		var list = deviceCheckData;
		if (!list || list.length === 0) {
			jAlert.error('알림', '다운로드할 불일치 데이터가 없습니다.');
			return;
		}

		var table = '<table>';
		table += '<tr><th>No</th><th>수용가명</th><th>수용가번호</th><th>주번호</th><th>모뎀ID</th><th>위지트 부번호</th><th>서버 부번호</th></tr>';
		for (var i = 0; i < list.length; i++) {
			var item = list[i];
			table += '<tr>';
			table += '<td>' + (i + 1) + '</td>';
			table += '<td>' + (item.custNm || '') + '</td>';
			table += '<td>' + (item.custNo || '') + '</td>';
			table += '<td>' + (item.devNo || '') + '</td>';
			table += '<td>' + (item.modemId || '') + '</td>';
			table += '<td>' + (item.wizitSubDevNo || '') + '</td>';
			table += '<td>' + (item.cmapSubDevNo || '') + '</td>';
			table += '</tr>';
		}
		table += '</table>';

		var blob = dcMakeExcelBlob(table);
		dcTriggerDownload(blob, '부번호_불일치_' + dcExcelDate() + '.xls');
	}

	function downloadBackupHistoryExcel() {
		var list = backupHistoryData;
		if (!list || list.length === 0) {
			jAlert.error('알림', '다운로드할 되돌리기 이력이 없습니다.');
			return;
		}

		var table = '<table>';
		table += '<tr><th>No</th><th>수용가명</th><th>수용가번호</th><th>주번호</th><th>변경 전 부번호</th><th>변경 후 부번호</th><th>변경 일시</th></tr>';
		for (var i = 0; i < list.length; i++) {
			var b = list[i];
			var dt = b.backupDt ? b.backupDt.substring(0, 16).replace('T', ' ') : '';
			table += '<tr>';
			table += '<td>' + (i + 1) + '</td>';
			table += '<td>' + (b.custNm || '') + '</td>';
			table += '<td>' + (b.custNo || '') + '</td>';
			table += '<td>' + (b.devNo || '') + '</td>';
			table += '<td>' + (b.subDevNoOld || '') + '</td>';
			table += '<td>' + (b.subDevNoNew || '') + '</td>';
			table += '<td>' + dt + '</td>';
			table += '</tr>';
		}
		table += '</table>';

		var blob = dcMakeExcelBlob(table);
		dcTriggerDownload(blob, '부번호_되돌리기이력_' + dcExcelDate() + '.xls');
	}

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
			pagePrevText: "<i class='ico i-prev'></i>", // 이전
			pageNextText: "<i class='ico i-next'></i>", // 다음
			pageFirstText: "<i class='ico i-prev-double'></i>", // 처음
			pageLastText: "<i class='ico i-next-double'></i>", // 마지막
			editing: false,

 	        rnTop: 50,
 	        rnBottom: 0,

 	        searchContainer: '#searchInput',

 	        fields: field,

 	        loadStrategy: function() {

 	        	return new CustomPageLoadingStrategy(this, loadData);

 	        },
			 rowClick: function (evt) {

			},
 			rowDoubleClick: function(evt) {
				// 위지트 모뎀 등록에서는 더블클릭 이벤트 비활성화
			},
			deleteItem: function(item) {
				// 위지트 모뎀 등록에서는 삭제 기능 비활성화
			},
			updateItem: function (item, editedItem) {
				// 위지트 모뎀 등록에서는 수정 기능 비활성화

				if (!editRow) {
					alert('수정 editRow 에러');
					return;
				}

				$.extend(row, editRow);

				if (!row.devNo || row.devNo == null || row.devNo == '') {
					alert('단말 주번호 공백 확인');
					return;
				} 

				if (!row.subDevNo || row.subDevNo == null || row.subDevNo == '') {
					alert('단말 주번호 공백 확인');
					return;
				} 

				getAjax('mars.icbm.devSqlMapper.updateCustomerInfo', row, false, function (result) {
					mainGrid.search();
				}, null);


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

		plh = (searchOption == 0) ? '수용가 번호/이름/주소 ...' : '단말기 번호/미터기 번호 ...';

		target.attr('placeholder', plh);

	};

	function makeParams() {

		var params = {};

		$.extend(params, mainGrid.loadParams());

		var modem_id = $('#modem_id').val();
		if (modem_id && modem_id.trim() != '') {
			params['modem_id'] = modem_id;
		}
		
		var dev_no = $('#dev_no').val();
		if (dev_no && dev_no.trim() != '') {
			params['dev_no'] = dev_no;
		}
		
		var sub_dev_no = $('#sub_dev_no').val();
		if (sub_dev_no && sub_dev_no.trim() != '') {
			params['sub_dev_no'] = sub_dev_no;
		}
		
		var tel_num = $('#tel_num').val();
		if (tel_num && tel_num.trim() != '') {
			params['tel_num'] = tel_num;
		}
		
		var imsi = $('#imsi').val();
		if (imsi && imsi.trim() != '') {
			params['imsi'] = imsi;
		}
		
		var modem_control = $('#modem_control').val();
		if (modem_control && modem_control.trim() != '') {
			params['modem_control'] = modem_control;
		}

		return params;
	};


	/* 메인 gird 로드  */
	function loadData() {
		var params = makeParams();
		console.log ('params: ', params);
		/* 위지트 모뎀 조회 */
		getAjax('mars.icbm.map1.wizitModemList_paging', params, function() {

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

				/*
				fileUp.setIsModal('importContainer');
				fileUp.initStepWizard('fileUp');

				fileUp.initFileGrid('file_grid_container', data);
				*/

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

		window.location = getContextPath() + '/resources/excel/import-wizit.xlsx';

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
		// console.log('dbParams:', dbParams);
		// console.log ('dbParamsTb:', dbParamsTb);
		var params = new Object();

		params.qid = dbParams[dbParamsTb]['refer-sql'];
		params.colMapping = dbParams[dbParamsTb]['cols'];
		params.length = params.colMapping.length;

		params.downloadFileName = "WizitModem_"+ kutil.dateFormat( new Date(), 'yymmddHHMMss');
		$.extend(params, makeParams());

		templetDownLoadStream(params, null, null, function() {

			jAlert.error('오류', '다운로드에 실패했습니다.');

		});

	};

 	function companyModal(event) {

    	var params = {};

		$.extend(params, companyGrid.loadParams());



        var modal = $('#companyModal');

        modal.modal('show');

        getAjax('companyList_paging', params, function() {


			$('#companyModal').aceWidget('startLoading');


		}, function(data) {

			companyGrid.finishLoad(data||[]);

			modalGridLayout($('#companyModal'), 270);

			$('#companyModal').aceWidget('stopLoading');

		}, null);


	}


	function insertCompany(){

		var form = $('.company-footer').find('input').serializeArray();

		var text = $('.company-footer').find('input').val();

		if(text == ''){
			jAlert.error('오류', '값을 입력해주세요.');
			return;
		}

		var params = {};

		var modal = $('#companyModal');

		form.forEach(arg => params[arg.name] = arg.value);



		insertAjax('mars.icbm.map1.insertCompany', params, function() {

  		  modal.aceWidget('startLoading');

        }, function(result) {

      	  modal.aceWidget('stopLoading');

      	    companyModal();

      	  jAlert.info('알림', '저장 되었습니다.');

		  }, function() {

			 jAlert.error('오류', '알 수 없는 오류가 발생했습니다.');

			 modal.aceWidget('stopLoading');

			companyModal();

		  });
	}

/* 회사 업데이트 모듈 */

	function updateCompanyFields(node,idx){

		var params = {};

		var modal = $('#companyModal');

		var text = node.parent().parent().find('input').val();

		if(text == ''){
			jAlert.error('오류', '값을 입력해주세요.');
			return;
		}


		node.parent().parent().find('input').each(function() {

			var fields = $(this).attr('name');

			params[fields] = $(this).val();

		});

		params.companySq = idx;


		updateAjax('mars.icbm.map1.updateCompany', params, function() {

    		  modal.aceWidget('startLoading');

          }, function(result) {

        	  modal.aceWidget('stopLoading');

        	    companyModal();

        	  jAlert.info('알림', '수정 되었습니다.');

 		  }, function() {

 			 jAlert.error('오류', '알 수 없는 오류가 발생했습니다.');

 			 modal.aceWidget('stopLoading');

 			companyModal();

 		  });


	}
	
	function saveConfigModal() {
		var params = {};
		params['config_time'] = $('#config_time').val();
		
		/* 수용가 조회 */
		getAjax('set_errstat_time_config', params, function() {
		}, 
		function (data) {
			jAlert.info('알림', '수정 되었습니다.');
			 
		}, null);
	};

	function deleteCustInfo(param) {
		$.ajax({
			url : "data/adminclear",
			contentType: 'application/json',
			data : JSON.stringify(param),
			type : 'POST',
			success : function(result) {
				if (result.isSuccess == 'Y') {
					jAlert.info('정보', "삭제처리 되었습니다.");
					mainGrid.search();
				}
				else {
					jAlert.error('오류', result.msg);
				}
			},
			error: function(xhr, status, error) {
				// 오류 발생 시 동작
				console.error(error);
				jAlert.error('오류', 'import 에 실패하였습니다.');
				// 오류 처리를 수행합니다.
			}
		});
	};

	function formatPhoneNumber(input) {
		let phoneNumber = input.value.replace(/\D/g, ''); // 숫자만 남기기
		let formattedNumber = '';

		// 휴대폰 번호 형식 (010-xxxx-xxxx)
		if (phoneNumber.startsWith('010')) {
			if (phoneNumber.length > 3 && phoneNumber.length <= 7) {
				formattedNumber = phoneNumber.replace(/(\d{3})(\d{1,4})/, '$1-$2');
			} else if (phoneNumber.length > 7) {
				formattedNumber = phoneNumber.replace(/(\d{3})(\d{4})(\d{1,4})/, '$1-$2-$3');
			} else {
				formattedNumber = phoneNumber;
			}
		} 
		// 일반 전화번호 형식 (02-xxxx-xxxx)
		else if (phoneNumber.startsWith('02')) {
			if (phoneNumber.length > 2 && phoneNumber.length <= 6) {
				formattedNumber = phoneNumber.replace(/(\d{2})(\d{1,4})/, '$1-$2');
			} else if (phoneNumber.length > 6) {
				formattedNumber = phoneNumber.replace(/(\d{2})(\d{4})(\d{1,4})/, '$1-$2-$3');
			} else {
				formattedNumber = phoneNumber;
			}
		} 
		// 기타 지역번호 (0xx-xxxx-xxxx)
		else if (phoneNumber.startsWith('0')) {
			if (phoneNumber.length > 3 && phoneNumber.length <= 7) {
				formattedNumber = phoneNumber.replace(/(\d{3})(\d{1,4})/, '$1-$2');
			} else if (phoneNumber.length > 7) {
				formattedNumber = phoneNumber.replace(/(\d{3})(\d{4})(\d{1,4})/, '$1-$2-$3');
			} else {
				formattedNumber = phoneNumber;
			}
		} 
		// 하이픈을 포함하지 않는 경우
		else {
			formattedNumber = phoneNumber;
		}

		// 백스페이스 시 하이픈 자동 삭제 처리
		if (input.value.length > formattedNumber.length) {
			input.value = formattedNumber.slice(0, -1); // 마지막 문자 제거
		} else {
			input.value = formattedNumber;
		}
	}

	function filterInput(event) {
        const allowedKeys = [
            "Backspace", "Delete", "ArrowLeft", "ArrowRight", "Tab", "Home", "End"
        ];
        const key = event.key;

        // 숫자, 하이픈(-) 및 허용된 키만 입력 가능
        if (!/[\d-]/.test(key) && !allowedKeys.includes(key)) {
            event.preventDefault();
        }
    }
</script>

<style type="text/css">

.table-item {
	width: 100%;
	border: none;
	background: transparent;
}
.company-footer{
	display:flex;
	background-color: #eff3f8;
	border-top: 1px solid #dee2e6;
}
.mg{
	margin:0.25rem;
}

#deviceCheckModal .table td,
#deviceCheckModal .table th {
	vertical-align: middle;
}
#deviceCheckModal .btn-xs {
	padding: 2px 6px;
	font-size: 11px;
}
#deviceCheckModal .text-danger small {
	word-break: break-all;
}
#deviceCheckModal .text-success small {
	word-break: break-all;
}

</style>



</head>



<body>

<div role="main" class="sub-content">
	<%@ include file="ISTC_F5_7_CONTENT.jsp" %>
	<div class="sub-cont-header">
		<h6></h6>
	</div>
	<div class="dj-card">
		<div class="bcard card point-grid">
			<div class="card-body p-0" id="gridContainer">
				<div id="mainGrid" class="data-list containerBorder" style="width: 100%; height: 100%;"></div>
			</div>
		</div>
	</div>
</div>

	 <div class="modal fade dialog-50" id="devModal" tabindex="-1" role="dialog">
     <div class="modal-dialog modal-dialog-scrollable modal-dialog-centered" role="document">
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
	     <div class="modal-dialog modal-dialog-scrollable modal-dialog-centered" role="document">
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
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="exampleModalLabel2">
             		IMPORT
           			</h5>
				</div>

				<div class="modal-body" id="fileUpload" align="center">
					<%-- 
						<%@ include file="ISTC_FILE_UPLOAD.jsp"%>
					--%> 
				<%@ include file="ISTC_F5_7_IMPORT.jsp"%>
				</div>
			</div>
		</div>
	</div>

	<!-- 이미지 업로드 -->
	<div id="imgImportContainer" class="modal fade" role="dialog">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="exampleModalLabel2">
             		이미지 업로드
           			</h5>
				</div>

				<div class="modal-body" id="imgUpload" align="center">
					<%@ include file="ISTC_F5_2_IMG.jsp"%>
				</div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="config_form" tabindex="-1" role="dialog">
		<div class="modal-dialog modal-dialog-scrollable modal-dialog-centered" role="document">
		  <div class="modal-content">
			<div class="modal-header">
			  <h5 class="modal-title" id="">
					 기타 설정
			  </h5>
   
			  <button type="button" class="close" id="configFormClose" data-dismiss="modal" aria-label="Close"  onclick="">
				 <span aria-hidden="true">&times;</span>
			   </button>
			</div>
   
			<form id="configForm" class="mt-lg-3 validator" autocomplete="off"  data-toggle="validator" role="form">
				<div class="modal-body">
					 <input class="form-control" name="custSq" type="text" style="display: none;"/>
					 <div class="form-group row">
						 <div class="col-sm-12">
							  <div class="form-group row">
							   <div class="col-sm-3 col-form-label text-sm-right pr-0">
								 <label for="config_time" class="mb-0">
									   통신장애 일자 기준
								 </label>
							   </div>
   
							   <div class="col-sm-9">
								 <input class="form-control" name="config_time" id="config_time" type="text" />
								 <label for="config_time" generated="true" class="error errclr">day 기준입니다.</label>
							   </div>
						 </div>
					 </div>
				</div>
				</div>
				<div class="modal-footer">
				   <button class="btn btn-info btn-bold px-4" type="button" onclick="saveConfigModal();">
					   <i class="fa fa-check mr-1"></i>저장
				   </button>
			   </div>
		   </form>
		  </div>
		</div>
	  </div>



	<div class="modal fade dialog-50" id="adminIdModal" tabindex="-1" role="dialog">
     <div class="modal-dialog modal-dialog-scrollable modal-dialog-centered" role="document">
       <div class="modal-content">
         <div class="modal-header">
           <h5 class="modal-title" id="">
             	수용가 정보 변경
           </h5>

           <button type="button" class="close" id="adminIdModalCloseBtn" data-dismiss="modal" aria-label="Close"  onclick="clearForm('adminIdForm');">
	          <span aria-hidden="true">&times;</span>
	        </button>
         </div>

         <form id="adminIdForm" class="mt-lg-3 validator" autocomplete="off"  data-toggle="validator" role="form">
	         <div class="modal-body">
	      		<input class="form-control" name="custSq" type="text" hidden/>
	      		<input class="form-control" name="pointSq" type="text"  hidden/>
	      		<div class="form-group row">
	      			<div class="col-sm-6">
	      			    <div class="col-sm-12">
	      				 	<div class="form-group row">
			                <div class="col-sm-3 col-form-label text-sm-right pr-0">
			                  <label for="adminIdNew" class="mb-0">
			                    	수용가 번호 
			                  </label>
			                </div>

			                <div class="col-sm-9">
			                  <input class="form-control" name="adminIdNew" id="adminIdNew" type="text" disabled="disabled"/>
			                </div>
		              		</div>
      				 	</div>
						<div class="col-sm-12">
							<div class="form-group row">
								<div class="col-sm-3 col-form-label text-sm-right pr-0">
								<label for="adminNmNew" class="mb-0">
										수용가 명
								</label>
								</div>

								<div class="col-sm-9">
								<input class="form-control" name="adminNmNew" id="adminNmNew" type="text"/>
								</div>
							</div>
						</div>
						<div class="col-sm-12">
							<div class="form-group row">
								<div class="col-sm-3 col-form-label text-sm-right pr-0">
								<label for="modalAddr" class="mb-0">
										구 주소
								</label>
								</div>

								<div class="col-sm-9">
								<input class="form-control" name="modalAddr" id="modalAddr" type="text"/>
								</div>
							</div>
						</div>
						<div class="col-sm-12">
							<div class="form-group row">
								<div class="col-sm-3 col-form-label text-sm-right pr-0">
								<label for="modalAddrNew" class="mb-0">
										도로명 주소
								</label>
								</div>

								<div class="col-sm-9">
								<input class="form-control" name="modalAddrNew" id="modalAddrNew" type="text"/>
								</div>
							</div>
						</div>
						<div class="col-sm-12">
							<div class="form-group row">
								<div class="col-sm-3 col-form-label text-sm-right pr-0">
								<label for="meterNoNew" class="mb-0">
										계량기 번호
								</label>
								</div>

								<div class="col-sm-9">
								<input class="form-control" name="meterNoNew" id="meterNoNew" type="text"/>
								</div>
							</div>
						</div>
						<div class="col-sm-12">
							<div class="form-group row">
							<div class="col-sm-3 col-form-label text-sm-right pr-0">
							<label for="new_pipe" class="mb-0">
									구경
							</label>
							</div>

							<div class="col-sm-9">
							<input class="form-control" name="new_pipe" id="new_pipe" type="text"/>
							</div>
							</div>
						</div>
						<div class="col-sm-12">
							<div class="form-group row">
								<div class="col-sm-3 col-form-label text-sm-right pr-0">
									<label for="phoneNumber" class="mb-0">
										전화번호
									</label>
								</div>

								<div class="col-sm-9">
									<input class="form-control" name="phoneNumber" id="phoneNumber" type="text" onkeydown="filterInput(event)" oninput="formatPhoneNumber(this)" maxlength="13" />
								</div>
							</div>
						</div>
				</div>
				<div class="col-sm-6">
					<div class="col-sm-12">
						<div class="form-group row">
							<div class="col-sm-3 col-form-label text-sm-right pr-0">
							<label for="new_dev_no" class="mb-0">
								단말 주번호
							</label>
							</div>

							<div class="col-sm-9">
							<input class="form-control" name="new_dev_no" id="new_dev_no" type="text"/>
							</div>
						</div>
					</div>
					<div class="col-sm-12">
						<div class="form-group row">
							<div class="col-sm-3 col-form-label text-sm-right pr-0">
							<label for="new_sub_dev_no" class="mb-0">
									단말 부번호
							</label>
							</div>

							<div class="col-sm-9">
							<input class="form-control" name="new_sub_dev_no" id="new_sub_dev_no" type="text"/>
							</div>
						</div>
					</div>
					<div class="col-sm-12">
						<div class="form-group row">
							<div class="col-sm-3 col-form-label text-sm-right pr-0">
							<label for="new_read_opr" class="mb-0">
									검침원
							</label>
							</div>

							<div class="col-sm-9">
							<input class="form-control" name="new_read_opr" id="new_read_opr" type="text"/>
							</div>
						</div>
					</div>
				   <div class="col-sm-12">
						<div class="form-group row">
							<div class="col-sm-3 col-form-label text-sm-right pr-0">
							<label for="new_check_day" class="mb-0">
									검침일
							</label>
							</div>
	
							<div class="col-sm-9">
							<input class="form-control" name="new_check_day" id="new_check_day" type="text"/>
							</div>
						</div>
					</div>
					<div class="col-sm-12">
						<div class="form-group row">
							<div class="col-sm-3 col-form-label text-sm-right pr-0">
							<label for="new_use_type" class="mb-0">
									업종
							</label>
							</div>

							<div class="col-sm-9">
							<input class="form-control" name="new_use_type" id="new_use_type" type="text"/>
							</div>
						</div>
					</div>
					<div class="col-sm-12">
						<div class="form-group row">
							<div class="col-sm-3 col-form-label text-sm-right pr-0">
							<label for="new_use_type" class="mb-0">
									회사
							</label>
							</div>

							<div class="col-sm-9">
								<select class="form-control" id="newCompany" name="newCompany">
								</select>
							</div>
						</div>
					</div>
				</div>
	         </div>
	         <div class="modal-footer">
		        <button class="btn btn-info btn-bold px-4" type="button" onclick="updateAdminId();">
		        	<i class="fa fa-check mr-1"></i>저장
		        </button>
		    </div>
		</form>
       </div>
     </div>
   </div>


	<script type="text/javascript" src="${contextPath}/resources/lib/chart.js/dist/Chart.js"></script>
	<%-- <script type="text/javascript" src="${contextPath}/resources/lib/sortablejs/dist/sortable.umd.js"></script> --%>


</body>



</html>

