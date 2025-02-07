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
<%@include file="/resources/inc/validation.inc"%>


<script type="text/javascript">

	var _animate = !AceApp.Util.isReducedMotion();

	var mainGrid;

	var siteinfogrid;
	var companyinfogrid;

	var errGrid;

	var dbParams;

	var dbImportParams;

	var dbParamsTb = 'f5-1-export';

	var userQid;

	var userData = [];

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

		siteinfogrid = initGrid2('siteinfogrid', siteFields);

		companyinfogrid = initGrid3('companyinfogrid', companyFields);


		/* 수용가 조회 */
		mainGrid.search();
		siteinfogrid.search();
		companyinfogrid.search();

		loadSites();

		setSubmitValidation('pwdForm', updatePwd);

		setSubmitValidation('editForm', userControll);
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

	function getSiteSq() {

		return ${user.getSiteSq()};

	};

	function getSiteLv() {

		return ${user.getSiteLv()};

	};

	function getUserRoll() {

		return ${user.getUserRoll()};

	};

	function getUserSq() {

		return ${user.getuserSq()};

	};

	function getUserNm() {

		return ${user.getUserNm()};

	};



	getUserNm

	/*
	* 레이아웃 사이즈
	*/
	function layoutSize() {

		var ht1 = $(window).innerHeight();
		var off = $('#gridContainer').offset();

		if (off) {

			var ht = ht1 - off.top - 36;
			$('#gridContainer').height(ht);

		}

		var siteoff = $('#sitegridContainer').offset();

		if (siteoff) {

			var ht = ht1 - siteoff.top - 36;
			$('#sitegridContainer').height(ht);

		}

		var companyoff = $('#companygridContainer').offset();

		if (companyoff) {

			var ht = ht1 - companyoff.top - 36;
			$('#companygridContainer').height(ht);

		}

		$('#errGridContainer').height(480);

	};

	function modalGridLayout(modal, height) {

		modal.find('.jsgrid-grid-body').css('height',  height + 'px');

		$(window).resize(function () {

			modal.find('.jsgrid-grid-body').css('height',  height + 'px');

		});

	};

	function refreshSites(data) {

		if(!data || data.length == 0)
			return;

		var input = $('select[name="siteSq"]');
		input.empty();

		data.forEach(function(item) {

			var opt = $("<option>").val(item.grpSeq).text(item.grpName);
			input.append(opt);

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

		userData = data;

	};

	/*
	* 그리드 갱신
 	*/
	 function refreshSiteGrid(data) {

		if(data)
			siteinfogrid.finishLoad(data||[]);
		else
			siteinfogrid.command('refresh');

		$('.bcard.point-grid').aceWidget('stopLoading');
	};

	/*
	* 그리드 갱신
 	*/
	 function refreshCompanyGrid(data) {

		if(data)
			companyinfogrid.finishLoad(data||[]);
		else
			companyinfogrid.command('refresh');

		$('.bcard.point-grid').aceWidget('stopLoading');
	};

	function refreshErrGrid(data) {

		if(data)
			errGrid.finishLoad(data||[]);
		else
			errGrid.command('refresh');


		$('#errGridContainer .jsgrid-grid-body').height(400);

	};

	function setSubmitValidation(id, callback){

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
			submitHandler: function(element) {
				if(callback)
					callback(element);
			},
	        rules: validate_util.rules,
	        messages: validate_util.messages
		});

		_form.submit(function(){
			_form.valid();
		})
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



	var errFields = [
        { name: "dataSq", 		title: "엑셀 순번", 	     	 type: "text", 	align:"center", width: 80, sortingDisabled:true},
        { name: "msg",			title: "엑셀 오류 내용", 	 	 type: "text",   width: 'auto', sortingDisabled:true}
 	];

	 var siteFields = [
        { name: "site_sq", 		    title: "소속 순번", 	     type: "text", 	 width: 50, sortingDisabled:true, editing: false},
        { name: "up_site_sq",		title: "상위소속순번", 	 	 type: "text",   width: 50, sortingDisabled:true, editing: false},
        { name: "site_nm",			title: "소속명", 	 	     type: "text",   width: 50, sortingDisabled:true},
        { name: "scco_cd",			title: "소속GIS코드", 	 	 type: "text",   width: 50, sortingDisabled:true},
        { name: "ins_dt",			title: "생성일자", 	 	     type: "text",   width: 80, sortingDisabled:true, editing: false},
 	];

	 var companyFields = [
        { name: "company_sq", 		    title: "회사 순번", 	     type: "text", 	 width: 50, sortingDisabled:true, editing: false},
        { name: "company_nm",		    title: "회사명", 	 	         type: "text",   width: 50, sortingDisabled:true},
        { name: "company_cd",			title: "회사코드", 	 	     type: "text",   width: 50, sortingDisabled:true},
 	];

	var mainFields = [
     	 { name: "num", 			title: "순번", 	     type: "text", align:"center", width: 60, 	itemTemplate:colfnc, sortingDisabled:true},
     	 { name: "siteNm",        title: "소속명", 		 type: "text",   width: 100, itemTemplate:colfnc},
         { name: "userNm",      title: "사용자 이름", 	     type: "text",   width: 150, itemTemplate:colfnc},
         { name: "userId",       title: "사용자 ID", 		 type: "text",   width: 200, itemTemplate:colfnc},
         { name: "useCdStr",       title: "사용자 유형", 		 type: "text",   width: 200, itemTemplate:colfnc},


         { name: "email",       title: "이메일", 		 	 type: "text",   width: 200, itemTemplate:colfnc},
         { name: "custPhone",       title: "전화번호", 		 type: "text",   width: 200, itemTemplate:colfnc},
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

	/*
	* 생성 수정 삭제 그리드 초기화 소속용
 	*/
 	function initGrid2(container, field) {

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
			//inserting : true,
			//editing: true,
			rnTop: 50,
			rnBottom: 0,

			searchContainer: '#searchInput',

			fields: field,

			loadStrategy: function() {

				return new CustomPageLoadingStrategy(this, siteData);

			},
			rowDoubleClick: function(evt) {

			},
			insertItem: function(item) {
				var insertingItem = item || this._getValidatedInsertItem();

				if(!insertingItem) {
					return alert('insert row 이상');
				}

				getAjax('mars.icbm.devSqlMapper.insertsiteSq', insertingItem, function () {
				}, function() {alert('입력 성공'); siteinfogrid.search();}, function() {alert('입력 실패'); siteinfogrid.search();});
			},
			deleteItem: function(item) {
				var delRow = this.rowByItem(item);
				if(!delRow.length){
					return;
				}
				var param = delRow.data('JSGridItem');

				if (confirm("삭제하시겠습니까?") == false ) {
					return;
				}

				if (param.site_sq == 1) {
					alert('마스터는 삭제할수없습니다.');
					return;
				}
				
				getAjax('mars.icbm.devSqlMapper.deletesiteSq', param, function () {
				}, function() {alert('삭제 성공'); siteinfogrid.search();}, function() {alert('삭제 실패'); siteinfogrid.search();});
			},
			updateItem: function (item, editedItem) {
                    var row = this._editingRow.data('JSGridItem');//JSGRID_ROW_DATA_KEY
                    var editRow = this._getValidatedEditedItem();//JSGRID_ROW_DATA_KEY

                    if (!row) {
                        alert('수정 row 에러');
                        return;
                    }

                    if (!editRow) {
                        alert('수정 editRow 에러');
                        return;
                    }
                    $.extend(row, editRow);

					getAjax('mars.icbm.devSqlMapper.updatesiteSq', row, function () {
					}, function() {alert('수정 성공'); siteinfogrid.search();}, function() {alert('수정 실패'); siteinfogrid.search();});

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

	/*
	* 생성 수정 삭제 그리드 초기화 회사용
 	*/
 	function initGrid3(container, field) {

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
			//inserting : true,
			//editing: true,
			rnTop: 50,
			rnBottom: 0,

			searchContainer: '#searchInput',

			fields: field,

			loadStrategy: function() {

				return new CustomPageLoadingStrategy(this, companyData);

			},
			rowDoubleClick: function(evt) {

			},
			insertItem: function(item) {
				var insertingItem = item || this._getValidatedInsertItem();

				if(!insertingItem) {
					return alert('insert row 이상');
				}

				getAjax('mars.icbm.devSqlMapper.insertCompanySq', insertingItem, function () {
				}, function() {alert('입력 성공'); companyinfogrid.search();}, function() {alert('입력 실패'); companyinfogrid.search();});
			},
			deleteItem: function(item) {
				var delRow = this.rowByItem(item);
				if(!delRow.length){
					return;
				}
				var param = delRow.data('JSGridItem');

				if (confirm("삭제하시겠습니까?") == false ) {
					return;
				}
				
				getAjax('mars.icbm.devSqlMapper.deleteCompanySq', param, function () {
				}, function() {alert('삭제 성공'); companyinfogrid.search();}, function() {alert('삭제 실패'); companyinfogrid.search();});
			},
			updateItem: function (item, editedItem) {
					var row = this._editingRow.data('JSGridItem');//JSGRID_ROW_DATA_KEY
					var editRow = this._getValidatedEditedItem();//JSGRID_ROW_DATA_KEY

					if (!row) {
						alert('수정 row 에러');
						return;
					}

					if (!editRow) {
						alert('수정 editRow 에러');
						return;
					}
					$.extend(row, editRow);

					getAjax('mars.icbm.devSqlMapper.updateCompanySq', row, function () {
					}, function() {alert('수정 성공'); companyinfogrid.search();}, function() {alert('수정 실패'); companyinfogrid.search();});

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

	function userControll(el) {

		var modal = $('#editModal');

		var params = {};

		var fields = $(el).find('input, select');

		for (var ix = 0; ix < fields.length; ix++) {

			var target = $(fields[ix]);

			var fid = target.attr('name');
			var val = target.val();

			if(fid == 'userPwd')
				params[fid] = SHA256(SHA256(val));
			else
				params[fid] = val;

		}

		params.userPwdConfirm = null;

		insertAjax(userQid, params, function() {

    		  modal.aceWidget('startLoading');

          }, function(result) {

        	  modal.aceWidget('stopLoading');

        	  mainGrid.search();

        	  $('#editModalCloseBtn').click();

        	  jAlert.info('알림', '작업에 성공했습니다.');

 		  }, function() {

 			 jAlert.error('오류', '서버에 오류가 있습니다. 생성 시 아이디 중복은 허용이 되지 않습니다.');

 			 modal.aceWidget('stopLoading');

 		  });

	};



	function updatePwd(el) {

		var modal = $('#pwdModal');

		var params = {};

		var fields = $(el).find('input');

		for (var ix = 0; ix < fields.length; ix++) {

			var target = $(fields[ix]);

			var fid = target.attr('name');
			var val = target.val();

			if(fid == 'userPwd')
				params[fid] = SHA256(SHA256(val));
			else
				params[fid] = val;

		}

		params.userPwdConfirm2 = null;

		updateAjax('mars.icbm.map1.updatePwd', params, function() {

    		  modal.aceWidget('startLoading');

          }, function(result) {

        	  modal.aceWidget('stopLoading');

        	  $('#pwdModalCloseBtn').click();

        	  jAlert.info('알림', '갱신에 성공했습니다.');

 		  }, function() {

 			 jAlert.error('오류', '알 수 없는 오류가 발생했습니다.');

 			 modal.aceWidget('stopLoading');

 		  });



	};


	function loadSites() {

		var params = {};
		params.upSiteSq = getSiteSq();
		params.lv = 1;
		params.noMaster = 1;


		/* 수용가 조회 */
		getAjax('sitesList', params, function() {

		}, refreshSites, null);

	};


	function makeParams() {

		var params = {};

		$.extend(params, parent.searchComponentes);
		$.extend(params, mainGrid.loadParams());

		params.lv = 1;

		return params;
	};


	/* 메인 gird 로드  */
	function loadData() {

		var params = makeParams();

		/* 수용가 조회 */
		getAjax('userInfo_paging', params, function() {

			/* 로딩 시작 */
			$('.bcard.point-grid').aceWidget('startLoading');

		}, refreshGrid, null);

	};

	/* 메인 gird 로드  */
	function siteData() {

		var params = makeParams();

		/* 수용가 조회 */
		getAjax('selectsiteInfoList', params, function() {

			/* 로딩 시작 */
			$('.bcard.point-grid').aceWidget('startLoading');

		}, refreshSiteGrid, null);

	};

	/* 메인 gird 로드  */
	function companyData() {

		var params = makeParams();

		/* 수용가 조회 */
		getAjax('mars.icbm.devSqlMapper.selectCompanyListPage', params, function() {

			/* 로딩 시작 */
			$('.bcard.point-grid').aceWidget('startLoading');

		}, refreshCompanyGrid, null);

	};


	function openEditModal() {

		//setSubmitValidation('editForm', insertUser);

		userQid = 'mars.icbm.map1.insertUser';

		clearForm('editForm');
		loadSites();

		var modal = $('#editModal');

		modal.find('input[name="userId"]').attr('disabled', false);

		modal.find('.show-add-user').show();

		modal.find('.modal-title').text('').text('사용자 추가');

	    modal.modal({backdrop: 'static'});

	};

	/*
	 * 모달창에 정보 넣기
	 */
	function updateValueFields(data) {

		var modal = $('#editModal');

		var fields = modal.find('input, select');

		for (var ix = 0; ix < fields.length; ix++) {

			var target = $(fields[ix]);

			var fid = target.attr('name');
			var val = data[fid];

			target.val(val);

		}


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
			error: function(result) {

				if (errCallback)
					errCallback(result);

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
			error: function(result) {

				if (errCallback)
					errCallback(result);


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
					errCallback(result);

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

	function clearForm(id) {

    	$('#' + id)[0].reset();

    	$('#' + id).resetValidation();

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

		params.downloadFileName = "User_"+ kutil.dateFormat( new Date(), 'yymmddHHMMss');
		$.extend(params, makeParams());

		templetDownLoad(params, null, null, function() {

			jAlert.error('오류', '다운로드에 실패했습니다.');

		});

	};

</script>

<style type="text/css">


</style>



</head>



<body>
	<div role="main" class="sub-content">
		<%@ include file="ISTC_F5_1_1_CONTENT.jsp" %>
		<div class="sub-cont-header">
			<div class="sub-cont-header-area">
			</div>
		</div>
		<div class="dj-card">
			<div class="bcard card h-100 point-grid">
				<ul class="nav nav-tabs custom-nav-tabs" role="tablist">
                    <li class="nav-item">
                        <a class="nav-link active custom-nav-link" id="userinfo-tab-btn"
                           data-toggle="tab" href="#userinfo" role="tab" aria-controls="userinfo"
                           aria-selected="true">사용자 관리
                        </a>
                    </li>

                    <li class="nav-item">
                        <a class="nav-link custom-nav-link"
                           id="siteinfo-tab-btn" data-toggle="tab" href="#siteinfo" role="tab"
                           aria-controls="siteinfo" aria-selected="false">
                            소속 관리
                        </a>
                    </li>

					<li class="nav-item">
                        <a class="nav-link custom-nav-link"
                           id="siteinfo-tab-btn" data-toggle="tab" href="#companyinfo" role="tab"
                           aria-controls="companyinfo" aria-selected="false">
                            회사 관리
                        </a>
                    </li>
                </ul>
				<div class="card-body px-0 py-2">
					<div class="tab-content tab-sliding border-0 px-0">
						<div class="tab-pane show active text-95 px-25" id="userinfo" role="tabpanel" aria-labelledby="userinfo-tab-btn">
							<div class="card-body p-0" id="gridContainer">
								<div id="mainGrid" class="data-list containerBorder" style="width: 100%; height: 100%;"></div>
							</div>
						</div>
						<div class="tab-pane text-95 px-25" id="siteinfo" role="tabpanel" aria-labelledby="siteinfo-tab-btn">
							<div class="card-body p-0" id="sitegridContainer">
								<div id="siteinfogrid" class="data-list containerBorder" style="width: 100%; height: 100%;"></div>
							</div>
						</div>
						<div class="tab-pane text-95 px-25" id="companyinfo" role="tabpanel" aria-labelledby="companyinfo-tab-btn">
							<div class="card-body p-0" id="companygridContainer">
								<div id="companyinfogrid" class="data-list containerBorder" style="width: 100%; height: 100%;"></div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>



<!-- 모달쪽 -->
	<div class="modal fade dialog-50" id="editModal" tabindex="-1" role="dialog">
     <div class="modal-dialog modal-dialog-scrollable modal-dialog-centered" role="document">
       <div class="modal-content">
         <div class="modal-header">
           <h5 class="modal-title" id="">
             	정보 수정
           </h5>

           <button type="button" class="close" id="editModalCloseBtn" data-dismiss="modal" aria-label="Close" onclick="clearForm('editForm');">
	          <span aria-hidden="true">&times;</span>
	        </button>
         </div>

         <form id="editForm" class="mt-lg-3 validator" autocomplete="off"  data-toggle="validator" role="form">

	         <div class="modal-body">


	      		<input class="form-control" name="userSq" type="text" style="display: none;"/>
	      		<input class="form-control" name="qid" type="text" style="display: none;"/>

	      		<div class="form-group row">
	      			<div class="col-sm-6" style="border-right: solid 0.1px #dcdcdc;">

	      				<div class="form-group row">
			                <div class="col-sm-3 col-form-label text-sm-right pr-0">
			                  <label for="userNm" class="mb-0">
			                    	사용자 이름<span class="asteriskField">*</span>
			                  </label>
			                </div>

			                <div class="col-sm-9">
			                  <input class="form-control" name="userNm" type="text"/>
			                  <label for="userNm" generated="true" class="error errclr">24자 이내로 입력해 주세요.</label>
			                </div>
		              </div>

		              <div class="form-group row">
			                <div class="col-sm-3 col-form-label text-sm-right pr-0">
			                  <label for="userId" class="mb-0">
			                    	사용자 ID<span class="asteriskField">*</span>
			                  </label>
			                </div>

			                <div class="col-sm-9">
			                  <input class="form-control" name="userId" type="text"/>
			                  <label for="userId" generated="true" class="error errclr">4이상 10자 이하로 입력하세요.</label>
			                </div>
		              </div>

		              <div class="form-group row">
			                <div class="col-sm-3 col-form-label text-sm-right pr-0">
			                  <label for="rollCd" class="mb-0">
			                    	사용자 유형<span class="asteriskField">*</span>
			                  </label>
			                </div>

			                <div class="col-sm-9">
				           		<select data-placeholder="선택" name="rollCd" class="form-control border-1p">
				           			<option value="1" selected>검침원사용자</option>
				                	<option value="5">타사사용자</option>
				                	<option value="7">준마스터사용자</option>
									<option value="9">마스터사용자</option>
				                </select>
				                <label for="rollCd" generated="true" class="error errclr">사용자 유형을 선택하세요.</label>
			               </div>
			            </div>


			            <div class="form-group row">
			               <div class="col-sm-3 col-form-label text-sm-right pr-0">
			                 <label for="siteSq" class="mb-0">
			                   	소속명<span class="asteriskField">*</span>
			                 </label>
			               </div>

			                <div class="col-sm-9">
				           		<select data-placeholder="선택" name="siteSq" class="form-control border-1p">
				                </select>
				                <label for="siteSq" generated="true" class="error errclr">소속 지자체를 선택하세요.</label>
			               </div>
			            </div>



	      			</div>
	      			<div class="col-sm-6">

	      				<div class="form-group row show-add-user">
			                <div class="col-sm-3 col-form-label text-sm-right pr-0">
			                  <label for="userPwd" class="mb-0">
			                    	암호 설정<span class="asteriskField">*</span>
			                  </label>
			                </div>

			                <div class="col-sm-9">
			                  <input class="form-control" name="userPwd" id="userPwd" type="password"/>
			                  <label for="userPwd" generated="true" class="error errclr">4이상 15자 이하로 입력하세요.</label>
			                </div>
		              </div>

		              <div class="form-group row show-add-user">
			                <div class="col-sm-3 col-form-label text-sm-right pr-0">
			                  <label for="userPwdConfirm" class="mb-0">
			                    	암호 재입력<span class="asteriskField">*</span>
			                  </label>
			                </div>

			                <div class="col-sm-9">
			                  <input class="form-control" name="userPwdConfirm" type="password"/>
			                  <label for="userPwdConfirm" generated="true" class="error errclr">패스워드를 재입력하세요.</label>
			                </div>
		              </div>

			            <div class="form-group row">
			                <div class="col-sm-3 col-form-label text-sm-right pr-0">
			                  <label for="email" class="mb-0">
			                    	이메일
			                  </label>
			                </div>

			                <div class="col-sm-9">
			                  <input class="form-control" name="email" type="text"/>
			                  <label for="email" generated="true" class="error errclr">이메일 형식으로 입력하세요.</label>
			                </div>
			             </div>

			             <div class="form-group row">
			               <div class="col-sm-3 col-form-label text-sm-right pr-0">
			                 <label for="custPhone" class="mb-0">
			                   	전화번호
			                 </label>
			               </div>

			               <div class="col-sm-9">
			                 <input class="form-control" name="custPhone" type="text"/>
			                 <label for="custPhone" generated="true" class="error errclr">전화번호를 -없이 숫자만 입력하세요.</label>
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




   <div class="modal fade" id="pwdModal" tabindex="-1" role="dialog">
     <div class="modal-dialog modal-dialog-scrollable modal-dialog-centered" role="document">
       <div class="modal-content">
         <div class="modal-header">
           <h5 class="modal-title" id="">
             	암호 재설정
           </h5>

           <button type="button" class="close" id="pwdModalCloseBtn" data-dismiss="modal" aria-label="Close" onclick="clearForm('pwdForm');">
	          <span aria-hidden="true">&times;</span>
	        </button>
         </div>

         <form id="pwdForm" class="mt-lg-3 validator" autocomplete="off"  data-toggle="validator" role="form">

	         <div class="modal-body">


	      		<input class="form-control" name="userSq" type="text" style="display: none;"/>

	      		<div class="form-group row">
	      			<div class="col-sm-12">

	      				 <div class="form-group row">
			                <div class="col-sm-3 col-form-label text-sm-right pr-0">
			                  <label for="userId" class="mb-0">
			                    	사용자 ID<span class="asteriskField">*</span>
			                  </label>
			                </div>

			                <div class="col-sm-9">
			                  <input class="form-control" name="userId" type="text" disabled/>
			                  <label for="userId" generated="true" class="error errclr">현제 선택된 사용자 아이디입니다.</label>
			                </div>
		              </div>

	      				<div class="form-group row show-add-user">
			                <div class="col-sm-3 col-form-label text-sm-right pr-0">
			                  <label for="userPwd2" class="mb-0">
			                    	암호 설정<span class="asteriskField">*</span>
			                  </label>
			                </div>

			                <div class="col-sm-9">
			                  <input class="form-control" name="userPwd" id="userPwd2" type="password"/>
			                  <label for="userPwd2" generated="true" class="error errclr">4이상 15자 이하로 입력하세요.</label>
			                </div>
		              </div>

		              <div class="form-group row show-add-user">
			                <div class="col-sm-3 col-form-label text-sm-right pr-0">
			                  <label for="userPwdConfirm2" class="mb-0">
			                    	암호 재입력<span class="asteriskField">*</span>
			                  </label>
			                </div>

			                <div class="col-sm-9">
			                  <input class="form-control" name="userPwdConfirm2" type="password"/>
			                  <label for="userPwdConfirm2" generated="true" class="error errclr">패스워드를 재입력하세요.</label>
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







	<script type="text/javascript" src="${contextPath}/resources/lib/chart.js/dist/Chart.js"></script>
	<%-- <script type="text/javascript" src="${contextPath}/resources/lib/sortablejs/dist/sortable.umd.js"></script> --%>


</body>



</html>

