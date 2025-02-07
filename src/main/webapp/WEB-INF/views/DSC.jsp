<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ page language="java" session="false" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>

	
	
</head>

<body>

 <div class="container">
      <h3>select SQL</h3>
      <form action="/sqlTest" method="post" >
         <textarea id="testsql" name ="testsql" ></textarea>
         <!-- 
         <input type="text" id="testsql1" name="testsql1">
          -->

         <button type="submit">SELECT</button>
      </form>
   </div>
   
   <c:if test="${data.size() > 0}">
   	<table>
   		<tbody>
   			<c:forEach var="item" items="${data}" >
   			<tr>
   				<td>
   					${item}
   				</td>
   				</tr>
   			</c:forEach>
   		</tbody>
   	</table>
   </c:if>
   <c:if test="${data.size() <= 0}">
    조회 항목이 없습니다.
   </c:if>
   
<div class="container">
      <h3>update SQL</h3>
      <form action="/sqlTest1" method="post" >
         <textarea id="testsql" name ="testsql" ></textarea>
         <!-- 
         <input type="text" id="testsql1" name="testsql1">
          -->

         <button type="submit">Update</button>
      </form>
   </div>
	<c:if test="${count > 0}">
   	
   	<h3>${count} 개 commit</h3>
   </c:if>
   
   	에러메시지 : ${msg}
</body>
</html>