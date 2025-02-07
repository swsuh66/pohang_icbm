<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="contextPath" value="<%=request.getContextPath()%>"></c:set>
<%@ page language="java" session="false"
	contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<%@include file="/resources/inc/meta.inc"%>
<title>스마트수도미터원격검침시스템</title>
<script type="text/javascript">
	/* 회사 추가/수정 모달창을 띄웁니다.(회사 아이콘을 ctrl + shift 누른채로 클릭) */
	function companyModal(event){
		if(event.ctrlKey && event.shiftKey)
			document.getElementById('iframeBody').contentWindow.companyModal();
	}
</script>
<style>
.chosen-container.chosen-container-single {
    width: 100% !important; /* or any value that fits your needs */
}

.pipe-width > div {
width:83px !important;
}

.navbar-inner> .container {
justify-content: space-around;
flex-wrap: nowrap;
aling-itmes: stretch;
padding: 0 30px;
height: 100%;
position: relative;
}

.searchComponent {
   color :#2d81e7 !important;
   background-color: #F8F7FE !important;
   border-color : #F8F7FE !important;
   box-shadow:  0 3px 6px #00000036 !important;
}

.searchComponent:hover {
   color :#F8F7FE !important;
   background-color: #2d81e7 !important;
   border-color : #2d81e7 !important;
}

.searchComponent:active {
   color :#F8F7FE !important;
   background-color: #2d81e7 !important;
   border-color : #2d81e7 !important;
}
</style>
</head>
<body>
<div class="search-area">
<%--	<h6>전체</h6>--%>
	<div class="dj-input-group">
		<label>상태</label>
		<select data-placeholder="전체" class="form-control" data-component="statCd" onchange="selectChangHandler(this);">
			<option value="-1" selected>전체</option>
			<option value="0">정상</option>
			<option value="1">통신 장애</option>
			<option value="2">계량기 장애</option>
		</select>
	</div>
	<div class="dj-input-group">
		<label>업종</label>
		<select data-placeholder="전체" class="form-control" name="4"  data-component="useType" onchange="selectChangHandler(this);">
			<option value="-1" selected>전체</option>
			<option value="-2">미지정</option>
		</select>
	</div>
	<div class="dj-input-group">
		<label>블록</label>
		<select data-placeholder="전체" class="form-control" name="6" data-component="blkSq" onchange="selectChangHandler(this);">
			<option value="-1" selected>전체       </option>
			<option value="-2">미지정</option>
		</select>
	</div>
	<div class="dj-input-group">
		<label>검침원</label>
		<select data-placeholder="전체" class="form-control" name="5" data-component="readOpr" onchange="selectChangHandler(this);">
			<option value="-1" selected>전체             </option>
			<option value="-2">미지정   </option>
		</select>
	</div>
	<div class="dj-input-group">
		<label>설치년</label>
		<select data-placeholder="전체" class="form-control" name="0" data-component="setYears" onchange="selectChangHandler(this);">
			<option value="-1" selected>전체       </option>
			<option value="-2">미지정</option>
		</select>
	</div>
	<div class="dj-input-group">
		<label>회사</label>
		<select data-placeholder="전체" class="form-control" name="1"  data-component="comSq" onchange="selectChangHandler(this);">
			<option value="-1" selected>전체       </option>
			<option value="-2">미지정</option>
		</select>
	</div>
	<div class="dj-input-group">
		<label>통신</label>
		<select data-placeholder="전체" class="form-control" name="2"  data-component="amiType" onchange="selectChangHandler(this);">
			<option value="-1" selected>전체       </option>
			<option value="-2">미지정</option>
		</select>
	</div>
	<div class="dj-input-group">
		<label>구경</label>
		<select data-placeholder="전체" class="form-control" name="3" data-component="pipeDia" onchange="selectChangHandler(this);">
			<option value="-1" selected>전체          </option>
			<option value="-2">미지정   </option>
		</select>
	</div>
	<div class="dj-btn-group">
		<button type="button" class="btn btn-sm dj-btn-outline-primary" data-toggle="modal" data-target="#siteModal">지역설정</button>
		<button type="button" class="btn btn-sm dj-btn-outline-red" onclick="resetComponentes();">초기화</button>
		<button type="button" class="btn btn-sm dj-btn-primary" onclick="parent.searchGrid();">검색</button>
	</div>

</div>

<%--	<div class="d-flex align-items-center">--%>

<%--		<ul class="breadcrumb">--%>
<%--			<li><a>전체</a></li>--%>
<%--		 </ul>--%>

<%--		<span class="info-container">--%>
<%--			<span class="info">--%>
<%--			</span>--%>
<%--			<a href="#none" title="지역 설정"--%>
<%--				class="btn btn-outline-warning btn-brc-tp radius-3px py-2"--%>
<%--				data-toggle="modal" data-target="#siteModal"--%>
<%--				onclick=""> <i class="fa fa-layer-group text-140"></i>--%>
<%--			</a>--%>
<%--		</span>--%>
<%--	</div>--%>
<!-- 	<div class="d-flex align-items-center"> -->
<!-- 		<span class="info-container"> -->
<!-- 			<i class="fa fa-grip-lines-vertical text-black"></i>				 -->
<!-- 		</span> -->
<!-- 	</div> -->
<%--	<div class="sidebar-section-item fadeable-below fadeable-center ">--%>
<%--		<div class="fadeinable w-auto">--%>
<%--			<a href="#none" title="초기화"--%>
<%--				class="btn btn-outline-warning btn-brc-tp radius-3px py-2"--%>
<%--				onclick="resetComponentes();"> <i--%>
<%--				class="fa fa-eraser text-140"></i>--%>
<%--			</a>--%>
<%--		</div>--%>
<%--	</div>--%>

<%--<div class="search-area">--%>
<%--	<div class="d-flex align-items-center">--%>

<%--		<span class="info-container">--%>
<%--			<i class="fa fa-wifi text-blue"></i> <span class="info"> 상태</span>--%>
<%--			<select data-placeholder="전체" class="chosen-select form-control" data-component="statCd" onchange="selectChangHandler(this);">--%>
<%--				<option value="-1" selected>전체</option>--%>
<%--				<option value="0">정상</option>--%>
<%--				<option value="1">통신 장애</option>--%>
<%--				<option value="2">계량기 장애</option>--%>
<%--				<option value="3">Q4초과</option>--%>
<%--				<option value="4">역류</option>--%>
<%--				<option value="5">누수</option>--%>
<%--				<option value="8">배터리 장애</option>--%>
<%--			</select>--%>
<%--		</span>--%>
<%--	</div>--%>
<%--	<div class="d-flex align-items-center">--%>
<%--		<span class="info-container"> <i--%>
<%--			class="fa fa-home text-blue"></i> <span class="info"> 업종</span>--%>
<%--		<select data-placeholder="전체" class="chosen-select form-control" name="4"  data-component="useType" onchange="selectChangHandler(this);">--%>
<%--			<option value="-1" selected>전체     </option>--%>
<%--			<option value="-2">미지정</option>--%>
<%--		</select>--%>
<%--		</span>--%>
<%--	</div>--%>
<%--	<div class="d-flex align-items-center">--%>
<%--		<span class="info-container"> <i class="fa fa-th text-blue"></i>--%>
<%--			<span class="info"> 블록</span>--%>
<%--		<select data-placeholder="전체" class="chosen-select form-control" name="6" data-component="blkSq" onchange="selectChangHandler(this);">--%>
<%--			<option value="-1" selected>전체       </option>--%>
<%--			<option value="-2">미지정</option>--%>
<%--		</select>--%>
<%--		</span>--%>
<%--	</div>--%>
<%--	<div class="d-flex align-items-center">--%>
<%--		<span class="info-container">--%>
<%--			<i class="fa fa-user-tie text-blue"></i>--%>
<%--			<span class="info"> 검침원</span>--%>
<%--			<select data-placeholder="전체" class="chosen-select form-control" name="5" data-component="readOpr" onchange="selectChangHandler(this);">--%>
<%--				<option value="-1" selected>전체             </option>--%>
<%--				<option value="-2">미지정   </option>--%>
<%--			</select>--%>
<%--		</span>--%>
<%--	</div>--%>
<%--	<div class="d-flex align-items-center">--%>
<%--		<span class="info-container">--%>
<%--			<i class="fa fa-calendar-alt text-blue"></i>--%>
<%--			<span class="info">  설치년</span>--%>
<%--			<select data-placeholder="전체" class="chosen-select form-control" name="0" data-component="setYears" onchange="selectChangHandler(this);">--%>
<%--					<option value="-1" selected>전체       </option>--%>
<%--					<option value="-2">미지정</option>--%>
<%--			</select>--%>
<%--		</span>--%>
<%--	</div>--%>
<%--	<div class="d-flex align-items-center">--%>
<%--		<span class="info-container">--%>
<%--		<i class="fa fa-building text-blue" onclick="companyModal(event)"></i>--%>
<%--		<span class="info">  회사</span>--%>
<%--		<select data-placeholder="전체" class="chosen-select form-control" name="1"  data-component="comSq" onchange="selectChangHandler(this);">--%>
<%--			<option value="-1" selected>전체       </option>--%>
<%--			<option value="-2">미지정</option>--%>
<%--		</select>--%>
<%--		</span>--%>
<%--	</div>--%>
<%--	<div class="d-flex align-items-center">--%>
<%--		<span class="info-container">--%>
<%--			<i class="fa fa-rss-square text-blue"></i>--%>
<%--			<span class="info">  통신</span>--%>
<%--			<select data-placeholder="전체" class="chosen-select form-control" name="2"  data-component="amiType" onchange="selectChangHandler(this);">--%>
<%--				<option value="-1" selected>전체       </option>--%>
<%--				<option value="-2">미지정</option>--%>
<%--			</select>--%>
<%--		</span>--%>
<%--	</div>--%>
<%--	<div class="d-flex align-items-center">--%>
<%--		<span class="info-container pipe-width">--%>
<%--		<i class="fa fa-circle-notch text-blue"></i>--%>
<%--		<span class="info">  구경</span>--%>
<%--		<select data-placeholder="전체" class="chosen-select form-control" name="3" data-component="pipeDia" onchange="selectChangHandler(this);">--%>
<%--			<option value="-1" selected>전 체          </option>--%>
<%--			<option value="-2">미지정   </option>--%>
<%--		</select>--%>
<%--		</span>--%>
<%--	</div>--%>

<%--	<div class="d-flex align-items-center p-40">--%>
<%--	            <a href="#none"--%>
<%--					  title="검색"--%>
<%--					  class="btn searchComponent btn-brc-tp radius-3px py-2"--%>
<%--					  onclick="parent.searchGrid();"--%>
<%--					  style="padding-bottom: 0px !important; padding-top: 3px !important; font-size:1.3em">--%>
<%--					  <i class="fa fa-search text-120"></i> 검색--%>
<%--				   </a>--%>
<%--	</div>--%>
<%--</div>--%>
</body>
</html>
