<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="contextPath" value="<%=request.getContextPath()%>"></c:set>
<%@ page language="java" session="false" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<%@include file="/resources/inc/meta.inc" %>
		<title>스마트수도미터원격검침시스템</title>
		<!-- 화면명 : ISTC_F8 -->
		<!-- 화면명 : 수용가정보 -->

		<%@include file="/resources/inc/base.inc" %> <%@include file="/resources/inc/jsgrid.inc" %>

		<script type="text/javascript">
			var _animate = !AceApp.Util.isReducedMotion();

			var mainGrid;

			var dbParamsTb = 'f8-export-deajeon';

			var dbParams;

			$(function () {
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

				/* grid 초기화 */
				mainGrid = initGrid('mainGrid');

				/* 수용가 조회 */
				mainGrid.search();
			});

			function updateColPos(cols, parentElement) {
				var left =
					$(parentElement + ' .jsgrid-grid-body').scrollLeft() <
					$(parentElement + ' .jsgrid-grid-body .jsgrid-table').width() - $(parentElement + ' .jsgrid-grid-body').width() + 16
						? $(parentElement + ' .jsgrid-grid-body').scrollLeft()
						: $(parentElement + ' .jsgrid-grid-body .jsgrid-table').width() - $(parentElement + ' .jsgrid-grid-body').width() + 16;
				$(
					parentElement +
						' .jsgrid-header-row th:nth-child(-n+' +
						cols +
						'),' +
						parentElement +
						' .jsgrid-filter-row td:nth-child(-n+' +
						cols +
						'),' +
						parentElement +
						' .jsgrid-insert-row td:nth-child(-n+' +
						cols +
						'),' +
						parentElement +
						' .jsgrid-grid-body tr td:nth-child(-n+' +
						(cols + 1) +
						')'
				).css({
					position: 'relative',
					left: left,
				});
			}

			/*
			 * 리소스 path
			 */
			function getContextPath() {
				return '${contextPath}';
			}

			/*
			 * 레이아웃 사이즈
			 */
			function layoutSize() {
				var ht1 = $(window).innerHeight();
				var off = $('#gridContainer').offset();

				if (off) {
					var ht = ht1 - off.top - 36;
					// var ht = ht1 - off.top - 66;
					$('#gridContainer').height(ht);
				}
			}

			/*
			 * 그리드 갱신
			 */
			function refreshGrid(data) {
				mainGrid = initGrid('mainGrid');

				if (data) mainGrid.finishLoad(data || []);
				else mainGrid.command('refresh');

				$('.bcard.point-grid').aceWidget('stopLoading');

				var jsGrid = document.querySelector('#mainGrid .jsgrid-grid-body');

				console.log(jsGrid);
				$(jsGrid).on('scroll', function (item) {
					//console.log("scroll");
					var element = '#' + $(item.target).parent().attr('id');
					console.log(element);
					updateColPos(5, element);
				});
			}

			/*
			 * 그리드 컬럼 요소 리빌딩
			 */
			var colfnc = function (value, item, c, d, e) {
				switch (this.name) {
					case 'rowChk':
                        return '<input type="checkbox" name="rowChk" data-pointSq="'+item.pointSq+'" data-custSq="'+item.custSq+'" data-siteSq="'+item.siteSq+'">';
					case 'num':
						return (item.pageNo - 1) * item.pageSize + (c + 1);
					case 'tap_gb':
						var str = '';
						if (item.tap_gb == '0100') {
							str = '수도';
						} else if (item.tap_gb == '0200') {
							str = '지하수';
						} else if (item.tap_gb == '0300') {
							str = '사용안함';
						} else {
							str = '원격검침';
						}
						return str;
					case 'tap_cd':
						var str = '';
						if (item.tap_cd == '0100') {
							str = '사용중';
						} else if (item.tap_cd == '0200') {
							str = '정수처분';
						} else if (item.tap_cd == '0300') {
							str = '급수중지';
						} else {
							str = '폐전';
						}

						return str;
				}

				return value == 0 || value ? value : '-';
			};

			/*
			 * 그리드 초기화
			 */
			function initGrid(container) {
				var fields = [
					{
						name: 'rowChk',
						title: '',
						type: 'checkbox',
						align: 'center',
						width: 20,
						itemTemplate: colfnc,
						sortingDisabled: true,
					},
					{
						name: 'rownum',
						title: '순번',
						type: 'text',
						align: 'center',
						width: 46,
						itemTemplate: colfnc,
						sortingDisabled: true,
					},
					{
						name: 'admin_no',
						title: '수용가 번호',
						type: 'text',
						align: 'center',
						width: 100,
						itemTemplate: colfnc,
						hasGroup: false,
					},
					{
						name: 'cust_name',
						title: '수용가 명',
						type: 'text',
						align: 'center',
						width: 140,
						itemTemplate: colfnc,
						hasGroup: false,
					},
					{
						name: 'cust_phone',
						title: '전화번호',
						type: 'text',
						align: 'center',
						width: 120,
						itemTemplate: colfnc,
						hasGroup: false,
					},
					{
						name: 'addr',
						title: '(구)주소',
						type: 'text',
						align: 'center',
						width: 250,
						itemTemplate: colfnc,
						hasGroup: false,
					},
					{
						name: 'addr_new',
						title: '도로명',
						type: 'text',
						align: 'center',
						width: 250,
						itemTemplate: colfnc,
						hasGroup: false,
					},
				];

				//fields = refactFields(fields);

				var opt = {
					height: '100%',
					width: '100%',
					sorting: true,

					pageLoading: true,
					paging: true,
					pageSize: 50,
					pageButtonCount: 5, // 페이지 버튼 개수
					pagerFormat: '{first} {prev} {pages} {next} {last}    {pageIndex} of {pageCount}',
					pagePrevText: "<i class='ico i-prev'></i>", // 이전
					pageNextText: "<i class='ico i-next'></i>", // 다음
					pageFirstText: "<i class='ico i-prev-double'></i>", // 처음
					pageLastText: "<i class='ico i-next-double'></i>", // 마지막

					rnTop: 50,
					rnBottom: 0,

					searchContainer: '#searchInput',

					fields: fields,

					loadStrategy: function () {
						return new CustomPageLoadingStrategy(this, loadData);
					},
					rowDoubleClick: function (evt) {
						$('#infoModal', window.parent.document).modal('show'); //infoModal

						parent.loadModalData(false, evt.item);
						parent.loadChartData(false, evt.item);
					},
					onRefreshed: function (args) {
						$.each(args.grid._headerGrid[0].rows[0].cells, function (i, obj) {
							$(args.grid._bodyGrid[0].rows[0].cells[i]).css('width', $(obj).css('width'));
						});
						$('table').colResizable({
							onResize: function () {
								$.each(args.grid._headerGrid[0].rows[0].cells, function (i, obj) {
									$(args.grid._bodyGrid[0].rows[0].cells[i]).css('width', $(obj).css('width'));
								});
							},
						});
					},
				};

				return new DataGrid(container, opt);
			}

			var groups = [
				{ title: '수전', columns: 3, align: 'center' },
				//	{title:'일간 검침값 (㎥)', 	columns: 30, align:"center"}
			];

			/* modal 데이터 로드 */
			function loadModalData(useGparams, item) {
				var params = new Object();
				var type = $('#typeSelect', window.parent.document).val();
				var endDate = $('#fromDate', window.parent.document).val();

				if (!endDate || endDate.length == 0) {
					/* 날짜 초기화 */
					$('#fromDate', window.parent.document).val(kutil.dateFormat(new Date(), 'yyyy-mm-dd'));
					endDate = kutil.dateFormat(new Date(), 'yyyy-mm-dd');
				}

				if (useGparams) params = parent._params;
				else {
					if (item) {
						params.pointSq = item.pointSq;
						params.siteSq = item.siteSq;
					}
				}

				params.endDate = endDate;

				var begDate = kutil.addMonth(endDate, type == '0' ? -1 : -12);
				params.begDate = moment(Date.parse(begDate)).format('YYYY-MM-DD');

				loadPointData(params);

				type == '0' ? loadRawData('pointHisdataRaw', params) : loadRawData('pointHisdata', params);

				parent._params = params;
			}

			function loadRawData(qid, params) {
				/* 검침값 조회 */
				getAjax(
					qid,
					params,
					function () {
						$('#infoModal', window.parent.document).aceWidget('startLoading');
					},
					function (result) {
						parent.refreshModalMain(result);
					},
					null
				);
			}

			/* 로드 수용가 정보 */
			function loadPointData(params) {
				/* 수용가 조회 */
				getAjax(
					'mars.icbm.map1.pointList',
					params,
					null,
					function (result) {
						parent.updateValueFields(result);
					},
					null
				);
			}

			function makeParams() {
				var params = {};

				//$.extend(params, parent.searchComponentes);
				$.extend(params, mainGrid.loadParams());

				//var baseDate = $('#baseDate').val();
				//params.baseDate = baseDate;
				//params.useCd = '1';
				//params.searchOption = $('#searchOptionSelect').val();
				params['cs_no'] = $('#cs_no').val();
				params['cust_nm'] = $('#cust_nm').val();
				params['admin_no'] = $('#admin_no').val();
				params['tap_cd'] = $('#tap_cd').val();
				params['tap_gb'] = $('#tap_gb').val();
				params['addr_1'] = $('#addr_1').val();
				if ($('#addr_2').val() != '' && $('#addr_2').val() != null && $('#addr_2').val() != '') {
					params['addr_1'] = $('#addr_2').val(); // 오타아님 addr1 안에 2가있음
				}
				//params['addr_3'] = $('#addr_3').val();
				params['addr'] = $('#addr').val();
				params['bungu_cd'] = $('#bungu_cd').val();

				return params;
			}

			/* 메인 gird 로드  */
			function loadData() {
				var params = makeParams();
				/* 수용가 조회 */
				getAjax(
					'adminList_paging',
					params,
					function () {
						/* 로딩 시작 */
						$('.bcard.point-grid').aceWidget('startLoading');
					},
					refreshGrid,
					null
				);
			}

			function getAjax(qid, params, beforesend, callback, errCallback, async) {
				ajaxSelect({
					sql: qid,
					data: params,
					async: async ? async : true,
					beforeSend: function () {
						if (beforesend) beforesend();
					},
					success: function (result) {
						if (callback) callback(result);
					},
					error: function (error) {
						if (error.status == 401) {
							parent.document.location.reload();
							return;
						}

						if (errCallback) errCallback(error);

						refreshGrid([]);

						var msg = '데이터를 읽을 수 없습니다.<br>';
						msg += error.responseText ? error.responseText.trim() : '서버에 오류가 있습니다.';

						jAlert.error('오류', msg);
					},
				});
			}

			/**
			 * 미터기 DB 테이블 기본 정보를 가져옵니다.
			 */
			function getDbtableInfo() {
				var url = getContextPath() + '/file/dbParams/' + dbParamsTb;

				ajaxSelect({
					url: url,
					success: function (data) {
						dbParams = data;
					},
					error: function (result) {
						jAlert.error('오류', '데이터를 가져오는데 실패하였습니다.');
					},
				});
			}

			/**
			 * 조회조건 조회
			 */
			function component(url, key) {
				ajaxSelect({
					sql: url,
					success: function (data) {
						if (data != 0) {
							data.forEach(function (item, idx) {
								if (item != null) {
									var el = $('<option>').attr('value', item.val).text(item.name);
									$('.componentsSelect[name="' + key + '"]').append(el);
								}
							});
						}
					},
					error: function (result) {
						jAlert.error('오류', '데이터를 가져오는데 실패하였습니다.');
					},
				});
			}

			function selectChange(url, key) {
				var params = {};

				$('#addr_2 option').remove(); //초기화
				var el = $('<option>').attr('value', '').text('전체');
				$('.componentsSelect[name="' + 'addr_2' + '"]').append(el);

				var addr_1 = $('#addr_1').val();
				if (addr_1 == null || addr_1 == '') {
					component('mars.icbm.map1.selecAllSecondSiteComponent', 'addr_2');
					return;
				}

				params['up_site_sq'] = addr_1;

				ajaxSelect({
					sql: url,
					data: params,
					success: function (data) {
						if (data != 0) {
							data.forEach(function (item, idx) {
								if (item != null) {
									var el = $('<option>').attr('value', item.val).text(item.name);
									$('.componentsSelect[name="' + key + '"]').append(el);
								}
							});
						}
					},
					error: function (result) {
						jAlert.error('오류', '데이터를 가져오는데 실패하였습니다.');
					},
				});
			}

			function dataDownload() {
				if (!dbParams) {
					jAlert.error('오류', '조건이 맞지 않아 데이터를 다운로드할 수 없습니다.');
					return;
				}

				var params = new Object();

				params.qid = dbParams[dbParamsTb]['refer-sql'];
				params.colMapping = dbParams[dbParamsTb]['cols'];
				params.length = params.colMapping.length;

				params.downloadFileName = 'Admin' + kutil.dateFormat(new Date(), 'yymmddHHMMss');

				var tParams = makeParams();

				/*
            var fromDate = $('#fromDate').val();
            if(!fromDate || fromDate.length == 0) {

                $('#fromDate').val(kutil.dateFormat(new Date(Date.now()), 'yyyy-mm'));
                 fromDate = kutil.dateFormat(new Date(Date.now()), 'yyyy-mm');
            }

            tParams.fromDate = fromDate + '-01';
            */

				$.extend(params, tParams);

				templetDownLoad(params, null, null, function () {
					jAlert.error('오류', '다운로드에 실패했습니다.');
				});
			}

			function deleteGridRows() {
				//if ('9' != parent.getUserLv()) {
				//	jAlert.error('오류', '마스터만 이용 가능한 기능입니다.');
				//	return;
				//}

                if($('#mainGrid').find('input[name=rowChk]:checked').length < 1){
					jAlert.error('오류', '선택된 데이터가 없습니다.');
					return;
                }

                if( !confirm('정말 삭제하시겠습니까?')){
                    return ;
                }

                var rowList = [];
                $.each($('#mainGrid').find('input[name=rowChk]:checked'), function(i, item){
                    var pointSq = $(item).attr('data-pointSq');
                    var custSq = $(item).attr('data-custSq');
                    rowList.push({pointSq:pointSq, custSq:custSq});
                });
                console.log('rowList', rowList);

				getAjax(
                    '/customer/deleteCustomInfo',
                    {rowList : rowList},
                    null,
                    function (result) {
                        parent.searchGrid();
                    },
                    null
                );

			}
		</script>
	</head>

	<body>
		<div role="main" class="sub-content">
			<%@ include file="ISTC_F0_1_8.jsp" %>

			<div class="dj-card">
				<div class="bcard point-grid" id="gridContainer">
					<div id="mainGrid" class="data-list containerBorder"></div>
				</div>
			</div>
		</div>

		<script type="text/javascript" src="${contextPath}/resources/lib/chart.js/dist/Chart.js"></script>
		<%--
		<script type="text/javascript" src="${contextPath}/resources/lib/sortablejs/dist/sortable.umd.js"></script>
		--%>
	</body>
</html>
