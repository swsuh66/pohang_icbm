<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="contextPath" value="<%=request.getContextPath()%>"></c:set>
<%@ page language="java" session="false" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<%-- ISTC_F0_F1_2 2,4,6 필터 --%> <%@include file="/resources/inc/meta.inc" %>
		<title>스마트수도미터원격검침시스템</title>
		<script type="text/javascript"></script>
		<script>
			$(function () {
				//화면 오픈시
				loadComponentBase();
				//component('mars.icbm.map1.selecTapGbComponent', 'tap_gb', {});
				//component('mars.icbm.map1.selecSiteComponent', 'addr_1', {});
				//component('mars.icbm.map1.selecSiteComponent', 'addr_3', {});
				//component('mars.icbm.map1.selecTapCdComponent', 'tap_cd', {});
				//component('mars.icbm.map1.selecBunguCdComponent', 'bungu_cd', {});
			});

			var searchComponentes = {
				statCd: null,
				useType: null,
				blkSq: null,
				readOpr: null,
				setYears: null,
				comSq: null,
				amiType: null,
				pipeDia: null,
				siteSq: null,
				upSiteSq: parent.getSiteSq(),
				lv: 1,
				fullNm: ['전체'],
			};

			/*
			 * 검색 컴포넌트 변경
			 */
			function baseComponentChangHandler(el) {
				var val = $(el).val() != '-1' ? $(el).val() : null;
				searchComponentes[$(el).attr('id')] = val;
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

			function resetComponentes() {
				$('.componentsSelect').each(function() {
					if ($(this).is('select')) {
						$(this).val($(this).find('option:first').val());
					} else {
						$(this).val('');
					}
				});
				$('.componentsSelect').trigger('chosen:updated');
				$.extend(searchComponentes, {
					statCd: null,
					useType: null,
					blkSq: null,
					readOpr: null,
					setYears: null,
					comSq: null,
					amiType: null,
					pipeDia: null,
				});
			}

			/**
			 * 조회조건 조회
			 */
			function component(url, key, param) {
				ajaxSelect({
					sql: url,
					data: param,
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

			/**
			 * base 조회조건 조회
			 */
			function baseComponent(url, name, param) {
				ajaxSelect({
					sql: url,
					data: param,
					success: function (data) {
						if (data != 0) {
							data.forEach(function (item, idx) {
								if (item != null) {
									if (item.sq != '' && item.sq != null && item.val != '' && item.val != null) {
										var el = $('<option>').attr('value', item.sq).text(item.val);
										$('.componentsSelect[name="' + name + '"]').append(el);
									}
								}
							});
						}
					},
					error: function (result) {
						jAlert.error('오류', '데이터를 가져오는데 실패하였습니다.');
					},
				});
			}

			function loadComponentBase() {
				var params = { key: 0 };
				$.extend(params, parent.searchComponentes);
				baseComponent('mars.icbm.map1.selectComponentes', 'setYears', params); //0
				params.key = 1;
				baseComponent('mars.icbm.map1.selectComponentes', 'comSq', params);
				params.key = 2;
				baseComponent('mars.icbm.map1.selectComponentes', 'amiType', params);
				params.key = 3;
				baseComponent('mars.icbm.map1.selectComponentes', 'pipeDia', params);
				params.key = 4;
				baseComponent('mars.icbm.map1.selectComponentes', 'useType', params);
				params.key = 5;
				baseComponent('mars.icbm.map1.selectComponentes', 'readOpr', params);
				params.key = 6;
				baseComponent('mars.icbm.map1.selectComponentes', 'blkSq', params);
			}
		</script>
	</head>
	<body>
		<div class="dj-card" id="filter">
			<div class="row">
				<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
					<div class="dj-input-group">
						<span class="info componentsFont">수용가번호</span>
						<input type="text" class="componentsSelect" id="admin_no" onKeypress="javascript:if(event.keyCode == 13) { parent.searchGrid(); }" />
					</div>
				</div>
				<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
					<div class="dj-input-group">
						<span class="info componentsFont">수용가명</span>
						<input type="text" class="componentsSelect" id="cust_nm" onKeypress="javascript:if(event.keyCode == 13) { parent.searchGrid(); }" />
					</div>
				</div>
				<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
					<div class="dj-input-group">
						<span class="info componentsFont">주소</span>
						<input type="text" class="componentsSelect" id="addr" name="addr" onKeypress="javascript:if(event.keyCode == 13) { parent.searchGrid(); }" />
					</div>
				</div>
				<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
					<div class="dj-input-group">
						<span class="info componentsFont">단말/기물번호</span>
						<input type="text" class="componentsSelect" id="meter_no" name="meter_no" onKeypress="javascript:if(event.keyCode == 13) { parent.searchGrid(); }" />
					</div>
				</div>
				<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
					<div class="dj-input-group">
						<span class="info componentsFont">계량기 상태</span>
						<select data-placeholder="전체" class="componentsSelect" id="statCd" name="statCd" onchange="baseComponentChangHandler(this);">
							<option value="-1" selected>전체</option>
							<option value="0">정상</option>
							<option value="1">통신 장애</option>
							<option value="2">계량기 장애</option>
							<option value="3">Q3초과</option>
							<option value="4">역류</option>
							<option value="5">누수</option>
							<option value="8">배터리 장애</option>
						</select>
					</div>
				</div>
				<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
					<div class="dj-input-group">
						<span class="info componentsFont">업종</span>
						<select data-placeholder="전체" class="componentsSelect" id="useType" name="useType" onchange="baseComponentChangHandler(this);">
							<option value="-1" selected>전체</option>
							<option value="-2">미지정</option>
						</select>
					</div>
				</div>
				<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
					<div class="dj-input-group">
						<span class="info componentsFont">블록</span>
						<select data-placeholder="전체" class="componentsSelect" id="blkSq" name="blkSq" onchange="baseComponentChangHandler(this);">
							<option value="-1" selected>전체</option>
							<option value="-2">미지정</option>
						</select>
					</div>
				</div>
				<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
					<div class="dj-input-group">
						<span class="info componentsFont">검침원</span>
						<select data-placeholder="전체" class="componentsSelect" id="readOpr" name="readOpr" onchange="baseComponentChangHandler(this);">
							<option value="-1" selected>전체</option>
							<option value="-2">미지정</option>
						</select>
					</div>
				</div>
				<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
					<div class="dj-input-group">
						<span class="info componentsFont">설치년</span>
						<select data-placeholder="전체" class="componentsSelect" id="setYears" name="setYears" onchange="baseComponentChangHandler(this);">
							<option value="-1" selected>전체</option>
							<option value="-2">미지정</option>
						</select>
					</div>
				</div>
				<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
					<div class="dj-input-group">
						<span class="info componentsFont">회사</span>
						<select data-placeholder="전체" class="componentsSelect" id="comSq" name="comSq" onchange="baseComponentChangHandler(this);">
							<option value="-1" selected>전체</option>
							<option value="-2">미지정</option>
						</select>
					</div>
				</div>
				<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
					<div class="dj-input-group">
						<span class="info componentsFont">통신</span>
						<select data-placeholder="전체" class="componentsSelect" id="amiType" name="amiType" onchange="baseComponentChangHandler(this);">
							<option value="-1" selected>전체</option>
							<option value="-2">미지정</option>
						</select>
					</div>
				</div>
				<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
					<div class="dj-input-group">
						<span class="info componentsFont">구경</span>
						<select data-placeholder="전체" class="componentsSelect" id="pipeDia" name="pipeDia" onchange="baseComponentChangHandler(this);">
							<option value="-1" selected>전체</option>
							<option value="-2">미지정</option>
						</select>
					</div>
				</div>
				<div class="col-12 col-sm-6 col-md-8 col-lg-12 col-xl-12">
					<div class="dj-btn-group">
						<button type="button" class="btn dj-btn-primary btn-sm" onclick="parent.searchGrid();">검색</button>
						<button type="button" class="btn dj-btn-outline-gray btn-sm" onclick="resetComponentes();">초기화</button>
						<button type="button" class="btn dj-btn-outline-green btn-sm" onclick="dataDownload();"><i class="ico i-excel"></i>엑셀다운</button>
					</div>
				</div>
			</div>
		</div>
	</body>
</html>
