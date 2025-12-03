<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="contextPath" value="<%=request.getContextPath()%>"></c:set>
<%@ page language="java" session="false" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<%@include file="/resources/inc/meta.inc" %>
		<title>스마트수도미터원격검침시스템</title>
		<!-- 화면명 : ISTC_F11_4-->
		<!-- 화면명 : 누수알림톡송신조회 -->

		<%@include file="/resources/inc/base.inc" %> <%@include file="/resources/inc/jsgrid.inc" %>

		<script type="text/javascript">
			var _animate = !AceApp.Util.isReducedMotion();

			var mainGrid;

			var dbParamsTb = 'f11-4';

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

				/* 날짜 초기 설정 */
				setInitDate();

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

			function setInitDate() {
				var dt = new Date(); // 오늘 날짜

				// 오늘 날짜를 yyyy-mm-dd 형식으로
				var endDate = kutil.dateFormat(dt, 'yyyy-mm-dd');

				// 한 달 전 날짜 계산
				dt.setMonth(dt.getMonth() - 1);
				var startDate = kutil.dateFormat(dt, 'yyyy-mm-dd');

				// DOM에 값 설정
				$('#startDate').val(startDate);
				$('#endDate').val(endDate);
			}

			/*
			 * 그리드 갱신
			 */
			function refreshGrid(data) {
				// mainGrid = initGrid('mainGrid');
				// console.log('refreshGrid data ===== ', data);
				if (data) {
					mainGrid.finishLoad(data || []);
				} else {
					mainGrid.command('refresh');
				}

				$('.bcard.point-grid').aceWidget('stopLoading');

				var jsGrid = document.querySelector('#mainGrid .jsgrid-grid-body');

				// console.log(jsGrid);
				$(jsGrid).on('scroll', function (item) {
					//console.log("scroll");
					var element = '#' + $(item.target).parent().attr('id');
					// console.log(element);
					updateColPos(5, element);
				});
			}

			/*
			 * 그리드 컬럼 요소 리빌딩
			 */
			var fotmatDateTime = function (value) {
				if (!value) return '-';

				// 이미 날짜 형식인 경우 (예: "2025-12-03 19:56:55")
				if (typeof value === 'string' && value.indexOf('-') >= 0) {
					// 날짜 문자열을 Date 객체로 변환
					var date = new Date(value);
					if (!isNaN(date.getTime())) {
						return kutil.dateFormat(date, 'yyyy-mm-dd HH:MM:ss');
					}
					return value;
				}

				// 14자리 숫자 문자열인 경우 (예: "20251203195655")
				if (typeof value === 'string' && value.length >= 14 && /^\d+$/.test(value)) {
					return (
						value.substring(0, 4) +
						'-' +
						value.substring(4, 6) +
						'-' +
						value.substring(6, 8) +
						' ' +
						value.substring(8, 10) +
						':' +
						value.substring(10, 12) +
						':' +
						value.substring(12, 14)
					);
				}

				// 숫자 타입인 경우 (타임스탬프)
				if (typeof value === 'number') {
					return kutil.dateFormat(new Date(value), 'yyyy-mm-dd HH:MM:ss');
				}

				return value;
			};
			var colfnc = function (value, item, c, d, e) {
				switch (this.name) {
					case 'reg_dttm':
						return fotmatDateTime(value);
					case 'phone_num':
						return value && value.length > 0 ? value.replace(/(\d{3})(\d{3,4})(\d{4})/, '$1-$2-$3') : value;
				}

				return value == 0 || value ? value : '-';
			};

			/*
			 * 그리드 초기화
			 */
			function initGrid(container) {
				var fields = [
					{
						name: 'rownum',
						title: '순번',
						type: 'text',
						align: 'center',
						width: 60,
						itemTemplate: colfnc,
						sortingDisabled: true,
					},
					{
						name: 'tgt_nm',
						title: '수신자',
						type: 'text',
						align: 'left',
						width: 120,
						itemTemplate: colfnc,
						hasGroup: false,
					},
					{
						name: 'phone_num',
						title: '수신번호',
						type: 'text',
						align: 'left',
						width: 120,
						itemTemplate: colfnc,
						hasGroup: false,
					},
					{
						name: 'title',
						title: '제목',
						type: 'text',
						align: 'left',
						width: 200,
						itemTemplate: colfnc,
						hasGroup: false,
					},
					{
						name: 'reg_dttm',
						title: '발신일',
						type: 'text',
						align: 'left',
						width: 150,
						itemTemplate: colfnc,
						hasGroup: false,
					},
					{
						name: 'state_msg',
						title: '상태',
						type: 'text',
						align: 'left',
						width: 120,
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
						/*
						$('#infoModal', window.parent.document).modal('show'); //infoModal

						parent.loadModalData(false, evt.item);
						parent.loadChartData(false, evt.item);
						*/
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

				$.extend(params, mainGrid.loadParams());

				params.tgt_nm = $('#tgt_nm').val();
				params.phone_num = $('#phone_num').val();

				params.startDate = $('#startDate').val();
				params.endDate = $('#endDate').val();

				return params;
			}

			function hyphenizePhoneIfNeeded(v) {
				if (!v) return v;
				var digits = String(v).replace(/\D/g, '');
				if (digits.length === 11 && digits.startsWith('010')) {
					return digits.replace(/(\d{3})(\d{4})(\d{4})/, '$1-$2-$3');
				}
				return v;
			}

			function hyphenizePhone(v) {
				if (!v) return '';
				var d = String(v).replace(/\D/g, '');
				if (d.length === 11 && d.indexOf('010') === 0) {
					return d.replace(/(\d{3})(\d{4})(\d{4})/, '$1-$2-$3');
				}
				return v;
			}

			// 응답 정규화: 문자열→JSON, data/rows 래핑 대응, 키 변환
			function normalizeHistoryResponse(raw) {
				// 1) 문자열이면 파싱
				if (typeof raw === 'string') {
					try {
						raw = JSON.parse(raw);
					} catch (e) {
						console.error('JSON parse error', e);
						return [];
					}
				}

				// 2) 배열 꺼내기
				var arr = [];
				if (Array.isArray(raw)) arr = raw;
				else if (raw && Array.isArray(raw.data)) arr = raw.data;
				else if (raw && Array.isArray(raw.rows)) arr = raw.rows;
				else if (raw && typeof raw === 'object') arr = [raw]; // 방어적

				// 3) 키/포맷 변환
				var out = arr.map(function (o) {
					return {
						rownum: o.rownum,
						id: o.id,
						userId: o.user_id,
						scheduleType: o.schedule_type,
						title: o.title,
						msgContent: (o.msg_content || '').replace(/\t/g, '').trim(), // 탭 제거/트림
						callingNum: o.calling_num,
						tgtNm: o.tgt_nm,
						phoneNum: hyphenizePhone(o.phone_num), // 하이픈 보정
						stateCd: o.state_cd,
						stateMsg: o.state_msg,
						templateCd: o.template_cd,
						reservDttm: o.reserv_dttm,
						regDttm: o.reg_dttm,
						totalCount: o.totalCount,
					};
				});

				return out;
			}

			/* 메인 gird 로드  */
			function loadData() {
				const params = makeParams();
				console.log('loadData: params ===== ', params);

				/* 로딩 시작 */
				$('.bcard.point-grid').aceWidget('startLoading');

				// 필터 타입 확인
				var filterType = $('#filterType').val() || 'all';

				// '전체' 선택 시 MyBatis 데이터만 조회
				if (filterType === 'all') {
					loadDbData(params);
					return;
				}

				// '오류' 선택 시 API 데이터만 조회
				const base = getContextPath();
				if (base && base.endsWith('/')) base = base.slice(0, -1);
				const url = base + '/api/alrimtok/history';
				console.log('loadData: url ===== ', url);

				$.ajax({
					url: url,
					type: 'GET',
					data: params,
					async: true,
					success: function (result) {
						if (typeof result === 'string') {
							try {
								result = JSON.parse(result);
							} catch (e) {
								console.error(e);
								result = [];
							}
						}
						var apiData = Array.isArray(result) ? result : [];
						console.log('API data ===== ', apiData);

						// API 데이터만 표시
						refreshGrid(apiData);
					},
					error: function (error) {
						console.error('API 호출 실패:', error);
						// API 실패하면 빈 배열 표시
						refreshGrid([]);
					},
				});
			}

			// MyBatis를 통한 전송 결과 조회
			function loadDbData(params) {
				// MyBatis 조회용 파라미터 변환
				var dbParams = {
					cust_name: params.tgt_nm || '',
					cust_phone: params.phone_num || '',
					ins_dt_from: params.startDate ? params.startDate + ' 00:00:00' : '',
					ins_dt_to: params.endDate ? params.endDate + ' 23:59:59' : '',
				};

				ajaxSelect({
					sql: 'mars.icbm.map1.selectAlrimtokHistory',
					data: dbParams,
					async: true,
					success: function (result) {
						console.log('MyBatis data ===== ', result);

						// MyBatis 데이터를 그리드 형식으로 변환
						var convertedDbData = [];
						if (Array.isArray(result)) {
							convertedDbData = result.map(function (item, index) {
								// ins_dt가 이미 날짜 형식이므로 그대로 사용 (fotmatDateTime에서 처리)
								var reg_dttm = '';
								if (item.ins_dt) {
									// 이미 날짜 문자열이면 그대로 사용, 아니면 변환
									if (typeof item.ins_dt === 'string') {
										reg_dttm = item.ins_dt;
									} else {
										reg_dttm = kutil.dateFormat(new Date(item.ins_dt), 'yyyy-mm-dd HH:MM:ss');
									}
								}

								return {
									rownum: index + 1,
									tgt_nm: item.cust_name || '',
									phone_num: item.cust_phone || '',
									title: '[포항시] 원격검침 수용가 누수 의심 안내',
									msg_content: '누수알림톡 전송',
									reg_dttm: reg_dttm,
									state_msg: '',
									admin_no: item.admin_no || '',
								};
							});
						}

						// MyBatis 데이터만 표시
						refreshGrid(convertedDbData);
					},
					error: function (error) {
						console.error('MyBatis 조회 실패:', error);
						// MyBatis 실패하면 빈 배열 표시
						refreshGrid([]);
					},
				});
			}

			function getAjax(url, params, beforesend, callback, errCallback, async) {
				// console.log('getAjax', url);
				$.ajax({
					url: url,
					type: 'GET', // 또는 POST, PUT 등
					data: params, // POST일 경우엔 contentType에 따라 JSON.stringify(params)
					async: async !== undefined ? async : true,
					beforeSend: function () {
						if (beforesend) beforesend();
					},
					success: function (result) {
						if (typeof result === 'string') {
							try {
								result = JSON.parse(result);
							} catch (e) {
								console.error(e);
								result = [];
							}
						}
						console.log('getAjax result ===== ', result);
						if (callback) callback(result);
					},
					error: function (error) {
						if (errCallback) errCallback(error);

						const msg = '외부 API 호출 실패<br>' + (error.responseText ? error.responseText.trim() : '서버 오류');
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

				params.qid = null; // dbParams[dbParamsTb]['refer-sql'];
				params.url = 'http://111.1.4.87:3000/api/v1/message/history';
				params.colMapping = dbParams[dbParamsTb]['cols'];
				params.length = params.colMapping.length;

				params.downloadFileName = 'AlimTok_' + kutil.dateFormat(new Date(), 'yymmddHHMMss');

				var tParams = makeParams();
				tParams.pageIndex = null;
				tParams.pageSize = null;

				$.extend(params, tParams);

				alrimtokDownLoad(params, null, null, function () {
					jAlert.error('오류', '다운로드에 실패했습니다.');
				});
			}
		</script>
	</head>

	<body>
		<div role="main" class="sub-content">
			<%@ include file="ISTC_F11_4_CONTENT.jsp" %>

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
