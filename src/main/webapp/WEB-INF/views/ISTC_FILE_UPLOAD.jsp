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

<!-- file wizard -->
<link rel="stylesheet" href="${contextPath}/resources/page/common/css/istc-file_wiz.css">	
<script type="text/javascript" src="${contextPath}/resources/page/common/js/istc-file_wiz.js?v=1.1"></script>

</head>
<body>

	<div id="fileUp">

		<h3>파일</h3>	
		
			<form id="fileForm" action="file/upload" method="post" enctype="multipart/form-data">
	
				<div class="form-group ">
					<label for="fileType" class="control-label col-md-4  requiredField"><spring:message
							code="mgmt.equipinfo.col.model" text="파일 타입" /><span
						class="asteriskField">*</span> </label>
					<div class="controls col-md-8 ">
						<select id="fileType"
							class=" textinput textInput form-control select-input-md"
							onchange="selectorHandleChange(this);" name="fileType">
							<option value="2" disabled>텍스트</option>
							<option value="0" selected>엑셀</option>
							<option value="1" disabled>CSV</option>							
							<!-- <option value="3" disabled="disabled">XML</option> -->
						</select>
					</div>
				</div>
				<div class="form-group ">
					<label for="delimeter" class="control-label col-md-4  requiredField"><spring:message
							code="mgmt.equipinfo.col.model" text="딜리미터" /><span
						class="asteriskField">*</span> </label>
					<div class="controls col-md-8 ">
						<select id="delimeter"
							class=" textinput textInput form-control select-input-md"
							name="delimeter" disabled>
							<option value="\t">탭</option>
							<option value=";">세미콜론 ( ; )</option>
							<option value=",">콤마 ( , )</option>
							<option value=" ">띄어쓰기</option>
						</select>
					</div>
				</div>
				<div class="form-group ">
					<label for="encodingType"
						class="control-label col-md-4  requiredField"><spring:message
							code="mgmt.equipinfo.col.model" text="인코딩" /><span
						class="asteriskField">*</span> </label>
					<div class="controls col-md-8 ">
						<select id="encodingType"
							class=" textinput textInput form-control select-input-md"
							name="encodingType">
							<option value="utf-8">UTF-8</option>
							<option value="euc-kr">EUC-KR</option>
						</select>
					</div>
				</div>
				<div class="form-group ">

					<label for="file_info"
						class="control-label col-md-4  requiredField"><spring:message
							code="mgmt.equipinfo.col.model" text="파일 첨부" /><span
						class="asteriskField">*</span> </label>
					<div class="controls col-md-8 ">
						<div class="filebox bs3-primary">
						<input class="upload-name upload-sm inline-contents" value="파일을 첨부해 주세요." disabled="disabled">
						
						<label title="업로드 파일 선택" for="file_info">선택</label> 
						<input type="file" id="file_info" name="file_info" onchange="fileHandleChange(this);" class="upload-hidden" accept=".xlsx">							
					</div> 
					</div>
	
				</div>
				
				<div class="form-group ">

					<label for="exFileDown"
						class="control-label col-md-4  requiredField"><spring:message
							code="mgmt.equipinfo.col.model" text="" /><span
						class="asteriskField"></span></label>
					<div class="controls col-md-8 ">
						<button type="button" id="exFileDown" class="btn btn-default form-button" onclick="exFileDownload();">
							<i class="glyphicon glyphicon-download-alt"></i>
							첨부파일 예시 다운로드						
						</button>
					</div>
				</div>
				
			</form>
		
		<h3>세부</h3>
			
			<form id="fileSetForm" action="confirmData" method="post">
				<div class="form-group">
					<div id="file_grid_container" class="data-list file-grid"></div>
				</div>
				<div class="row">
					<div class="col-sm-6">
						<div class="form-group">
							<div class="checkbox checkbox-success">
								<input id="isHeader" name="isHeader" type="checkbox"
									onchange='chkboxHandleChange(this);'> <label
									for="isHeader"> 첫 행 헤더 </label>
							</div>
	
						</div>
					</div>
					<div class="col-sm-6">
						<div class="form-group">
							<div class="checkbox checkbox-success">
								<input id="trim" name="trim" type="checkbox"
									onchange='chkboxHandleChange(this);'> <label for="trim">
									양 끝자리 공백 제거 </label>
							</div>
	
						</div>
					</div>
				</div>

	    	</form>
		
	</div>  		
</body>
</html>