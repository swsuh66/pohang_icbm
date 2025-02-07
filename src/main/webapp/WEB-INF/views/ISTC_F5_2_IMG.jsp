<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<!DOCTYPE html>
<html>
<head>
<meta charset=UTF-8>

<%@include file="/resources/inc/meta.inc"%>
<title>스마트수도미터원격검침시스템</title>

<%@include file="/resources/inc/base.inc"%>
<%@include file="/resources/inc/jsgrid.inc"%>

	<link rel="stylesheet" href="${contextPath}/resources/page/common/css/istc-file_wiz.css">	
<!--
	<script type="text/javascript" src="${contextPath}/resources/page/common/js/istc-file_wiz.js?v=1.1"></script>
-->

<script type="text/javascript">
// js 파일 없애고 개조

// 끝



var errorExcelGrid;
var resultParam;




$(function(){
	errorExcelGrid = errorInitGrid('errorExcelGrid');

	$('#insertForm').show();
	$('#gridWindow').hide();
	
	//errorExcelGrid.search();
});

function getContextPath() {
	
   return "${contextPath}";
   
};

function errorDataGridSearch(data) {
	
	if(data)
		errorExcelGrid.finishLoad(data||[]);
	else
		alert("data null");
		
};


function imgUpload() {
	$.ajax({
		url : "file/image_reset",
		processData : false,
		contentType : false,
		data : new FormData(imgForm),
		type : 'POST',
		success : function(result) {
			jAlert.info('정보', '이미지 저장 성공');

			closeImgModal();
		},
		error: function(xhr, status, error) {
            // 오류 발생 시 동작
            console.error(error);
			jAlert.error('오류', 'import 에 실패하였습니다.');
            // 오류 처리를 수행합니다.
        }
	});
}

	function closeImgModal() {
		$('#imgImportContainer').modal('hide');
		$('#imgForm').show();
		document.getElementById('file').value='';
	};

	function openImgModal() {
		$('#imgImportContainer').modal({backdrop:'static',keyboard:false});
	};
	
</script>

</head>
<body>
	<div id="imgFileUp">
			<form id="imgForm" action="" method="post" enctype="multipart/form-data" style="border: 1px solid #eee;background-color: white; padding: 10px;">
				
				<div class="form-group">
					<label for="file_info"
					class="control-label col-md-4  requiredField"><spring:message
					code="mgmt.equipinfo.col.model" text="파일 첨부" /><span
					class="asteriskField">*</span> </label>
					<div class="controls col-md-8 ">
						<div class="filebox bs3-primary">
							<input  type="file" class="info componentsFont" id="imgFile" name="imgFile" accept=".JPEG" multiple>
						</div> 
					</div>
				</div>
				<div class="form-group ">
					<label for="exFileDown"
					class="control-label col-md-4  requiredField"><spring:message
					code="mgmt.equipinfo.col.model" text="" /><span
					class="asteriskField"></span></label>
					<div class="controls col-md-8 ">
						<p>1.	전경 = 수용가번호_gum.JPEG</p>
						<p>2.   단말기사진 = 수용가번호_af.JPEG</p>
						<p>3.   계량기사진 = 수용가번호_bf.JPEG</p>
						<p>4.   설치후사진 = 수용가번호_add.JPEG</p>
					</div>
				</div>
				<div class="dj-btn-group">
					<a class="btn dj-btn-primary btn-sm" onclick="imgUpload();"> 
						업로드					
					</a>
					<a class="btn dj-btn-outline-red btn-sm" onclick="closeImgModal();"> 
						닫기					
					</a>
				</div>
			</form>
	</div>   		
</body>
</html>