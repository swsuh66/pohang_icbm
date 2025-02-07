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

<!-- local css -->
<style type="text/css">

	
	
</style>

</head>

<body>

	<div>
		<button id="ist-test-1">test1</button>
	</div>	
	
	<!-- local script -->
	<script type="text/javascript">
	
		$(document).ready(function(){
			
			$(document).on('click', 'button#ist-test-1', function(){
				// test code...
			});
			
			/*
			var eventSource = new EventSource(_ctx+'/test/sse.do'); 
			
			eventSource.onmessage = function(e){
				var d = JSON.parse(event.data); 
				console.log(d.message);
			}
			
			eventSource.onerror = function(){
				eventSource.close();
			}
			*/
			
		});
		
	</script>
</body>

</html>

