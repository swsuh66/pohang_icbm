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

	var groups = [
		{title : '구분', columns : 1,align : "center"},
		{title : '수용가', columns : 5, align : "center"},
		{title : '계량기', columns : 2, align : "center"},
	    {title : '단말기', columns : 3, align : "center"} ,
	    {title : '동작', columns : 2, align : "center"}
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
     	{ name: "num", 			title: "순번", 	     type: "text", align:"center", width: 60, 	itemTemplate:colfnc,editing: false, sortingDisabled:true},
		{
			type: "control", title: '수정'
			, /*editButton: false,*/ 
			hasGroup:false,
			width: 60,
			modeSwitchButton: false
		},
         { name: "adminId",      title: "수용가 번호", 	 type: "text",   width: 150, itemTemplate:colfnc,editing: false, hasGroup:true, group:groups[1]},
         { name: "custNm",       title: "이름", 		 type: "text",   width: 200, itemTemplate:colfnc, hasGroup:true},
         { name: "useType",      title: "업종", 		 type: "text",   width: 70,  itemTemplate:colfnc,editing: false, hasGroup:true},
         { name: "blkNm",        title: "블록", 		 type: "text",   width: 100, itemTemplate:colfnc,editing: false, hasGroup:true},        
         { name: "custPhone",      title: "전화번호", 	 type: "text",   width: 100,  itemTemplate:colfnc,editing: false, hasGroup:true},

		 // 계량기
		 { name: "pipeDia",      title: "관경(mm)", 	 type: "text",   width: 100,  itemTemplate:colfnc,editing: false, hasGroup:true , group:groups[2]},
         { name: "meterNo",      title: "번호", 	 type: "text",   width: 150,  itemTemplate:colfnc,editing: false, hasGroup:true},

		// 단말기
        { name: "amiType",   title: "통신", 	 type: "text",   width: 80, itemTemplate:colfnc,editing: false, hasGroup:true, group:groups[3]},
        { name: "devNo",      title: "주번호", 	 type: "text",   width: 140,  itemTemplate:colfnc,editing: true, hasGroup:true},
        { name: "subDevNo",   title: "부번호", 	 type: "text",   width: 200,  itemTemplate:colfnc,editing: true, hasGroup:true},
        { name: "comNm",      title: "제조회사", 	 type: "text",   width: 100,  itemTemplate:colfnc,editing: false, hasGroup:true},
        { name: "useCd",      title: "단말기 회사", 	 type: "checkbox",   width: 60, itemTemplate:colfnc, editing: false, hasGroup:false},
        /* {
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
	    }, */

	    {
	        itemTemplate: function(_, item) {

	        	if(!item.pointSq)
	        		return;

	        	var iEl = $("<i>")
			   			 .attr("data-sq", item.custSq)
			   			 .attr("data-id", item.adminId)
			   			 .addClass("fa fa-user-edit");


			   	var aEl = $("<a>").attr("href", "#none")
			   			  .addClass("btn btn-outline-blue btn-brc-tp radius-3px py-2")
			   			  .append(iEl)
			   			  .attr("data-sq", item.custSq)
			   			  .attr("data-id", item.adminId)
			   			  .on("click", function (evt) {

				   				 var el = $(evt.target);

			                     var custSq = el.data('sq');
			                     var adminId = el.data('id');

			                     var modal = $('#adminIdModal');

			                     modal.modal({backdrop: 'static'});

			                     //modal.find('input[name="adminIdBef"]').val(adminId);
			                     modal.find('input[name="custSq"]').val(custSq);
			                     modal.find('input[name="pointSq"]').val(item.pointSq);
			                     
			                     $('#adminIdNew').val(item.adminId);
			                     $('#adminNmNew').val(item.custNm);
			                     $('#modalAddr').val(item.addrOld);
			                     $('#modalAddrNew').val(item.addrNew);
			                     $('#meterNoNew').val(item.meterNo);
			                     $('#new_sub_dev_no').val(item.subDevNo);
			                     $('#new_dev_no').val(item.devNo);
			                     $('#new_pipe').val(item.pipeDia);
			                     $('#phoneNumber').val(item.custPhone);
			                     $('#new_use_type').val(item.useType);
			                     $('#new_read_opr').val(item.readOpr);
			                     $('#new_check_day').val(item.chkDay);
								 $('#newCompany').val(item.comNm);
			                });


			       return aEl;

	        },
	        align: "center",
	        width: 100,
	        title: '수용가정보 변경',
	        hasGroup:false,
			editing: false,
	        //group:groups[4],
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
			pagePrevText: "<i class='ico i-prev'></i>", // 이전
			pageNextText: "<i class='ico i-next'></i>", // 다음
			pageFirstText: "<i class='ico i-prev-double'></i>", // 처음
			pageLastText: "<i class='ico i-next-double'></i>", // 마지막
			editing: true,

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
				parent.loadModalData(false, evt.item);
				parent.loadChartData(false, evt.item);
			},
			deleteItem: function(item) {
				var delRow = this.rowByItem(item);
				if(!delRow.length){
					return;
				}
				var param = delRow.data('JSGridItem');

				if (confirm("수용가번호 :" + param.adminId + " 를 삭제하시겠습니까? 삭제가 되면 검침 데이터이력은 모두 사라집니다. 단말기번호 등 수정사항이 있으시다면 수용가정보 변경 버튼을 이용해주세요.") == false ) {
					return;
				}

				param['acKey'] = prompt('개발팀에서 받은 삭제 코드를 입력해주세요.');
				
				deleteCustInfo(param);
				/*
				getAjax('mars.icbm.devSqlMapper.deleteCustomerInfo', param, function () {
				}, function() {alert('삭제 성공'); mainGrid.search();}, function() {alert('삭제 실패'); mainGrid.search();});
				*/
			},
			updateItem: function (item, editedItem) {
				var row = this._editingRow.data('JSGridItem');//JSGRID_ROW_DATA_KEY
				var editRow = this._getValidatedEditedItem();//JSGRID_ROW_DATA_KEY

				if (confirm("수용가번호 :" + row.adminId + "를 수정하시겠습니까?") == false ) {
					this.cancelEdit();
					return;
				}

				if (!row) {
					alert('수정 row 에러');
					return;
				}

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

		$.extend(params, searchComponentes);
		$.extend(params, mainGrid.loadParams());

		//params.searchOption = $('#searchOptionSelect').val();

		params.useCd = $('#useCdSelect').val();
		
		params['cust_nm']  = $('#cust_nm').val();
        params['admin_no'] = $('#admin_no').val();
        params['addr']	   = $('#addr').val();
        params['meter_no'] = $('#meter_no').val();

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


	function openConfigModal() {
		
		var modal = $('#config_form');
		
		modal.modal({backdrop: 'static', keyboard: false});
		
		var params = makeParams();
		
		/* 수용가 조회 */
		getAjax('selectErrstatTime', params, function() {
			//$('#config_time').attr("value", )
		}, 
		function (data) {
			$('#config_time').val(data[0]['config_time']); 
		}, null);
	};
	
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

	function wimsSync() {
		$.confirm({
			title: 'WIMS 연동',
			content: '<p>연동하시겠습니까?</p>' +
				'<div style="margin-top:10px;">' +
				'<label><input type="checkbox" id="syncCheckDayChk"> 검침일도 함께 동기화</label>' +
				'</div>',
			type: 'blue',
			typeAnimated: true,
			buttons: {
				yes: {
					text: '예',
					btnClass: 'btn-blue',
					action: function() {
						var syncCheckDay = this.$content.find('#syncCheckDayChk').is(':checked');
						var loadingDialog = $.dialog({
							title: 'WIMS 연동 중',
							content: '<div style="text-align:center; padding:20px 0;">' +
								'<i class="fa fa-spinner fa-spin fa-3x text-blue"></i>' +
								'<p style="margin-top:15px; font-size:14px;">연동 중입니다. 잠시만 기다려주세요...</p>' +
								'</div>',
							type: 'blue',
							typeAnimated: true,
							closeIcon: false
						});
						$.ajax({
							url: getContextPath() + '/data/wimsSync',
							contentType: 'application/json',
							data: JSON.stringify({ syncCheckDay: syncCheckDay }),
							type: 'POST',
							timeout: 300000,
							success: function(result) {
								loadingDialog.close();
								if (result.isSuccess == 'Y') {
									var msg = 'WIMS 연동 완료<br>업데이트: ' + result.updatedCount + '건 / 백업: ' + result.backupCount + '건';
									if (syncCheckDay && result.checkDayUpdatedCount != null) {
										msg += '<br><br>검침일 동기화: ' + result.checkDayUpdatedCount + '건';
									}
									jAlert.info('알림', msg);
									mainGrid.search();
								} else {
									jAlert.error('오류', result.msg || 'WIMS 연동에 실패했습니다.');
								}
							},
							error: function(xhr, status, error) {
								loadingDialog.close();
								console.error(error);
								jAlert.error('오류', 'WIMS 연동 중 오류가 발생했습니다.');
							}
						});
					}
				},
				no: {
					text: '아니오',
					action: function() {}
				}
			}
		});
	};

	function img_clear() {
		$.ajax({
			url : "file/image_clear",
			processData : false,
			contentType : false,
			data : {},
			type : 'POST',
			success : function(result) {
				jAlert.info('정보', '데이터 업로드 성공');
			},
			error: function(xhr, status, error) {
				// 오류 발생 시 동작
				console.error(error);
				jAlert.error('오류', 'import 에 실패하였습니다.');
				// 오류 처리를 수행합니다.
			}
		});
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


</style>



</head>



<body>

<div role="main" class="sub-content">
	<%@ include file="ISTC_F5_2_CONTENT.jsp" %>
	<div class="sub-cont-header">
		<h6></h6>
		<div class="sub-cont-header-area">
			<div class="dj-btn-group">
				<button type="button" class="btn dj-btn-primary btn-sm" onclick="wimsSync();"><i class="fa fa-sync-alt mr-1"></i>WIMS 연동</button>
				<button type="button" class="btn dj-btn-outline-gray btn-sm" onclick="openConfigModal();"><i class="ico i-set"></i>기타 설정</button>
				<button type="button" class="btn dj-btn-outline-gray btn-sm" onclick="img_clear();">이미지 데이터 업로드</button>
				<button type="button" class="btn dj-btn-outline-gray btn-sm" onclick="openImgModal();">이미지 업로드</button>
			</div>
			
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
				<%@ include file="ISTC_F5_2_IMPORT.jsp"%>
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

