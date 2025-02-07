<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="contextPath" value="<%= request.getContextPath()%>"></c:set>
<%@ page language="java" session="false" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <%@include file="/resources/inc/meta.inc" %>
    <title>스마트수도미터원격검침시스템</title>

    <%@include file="/resources/inc/base.inc" %>

    <script type="text/javascript">

        function initPage() {

            /* 브라우저 권고 문구 출력 */
            var info = browserInfo().split(' ');
            var br = info[0];
            var ver = info[1];

            if (br != 'Firefox' && br != 'Chrome') {
                $('#warning').show();
            }


            /* 로그인 정보가 틀렸을 시 알림 */
            var para = document.location.href.split("?");
            if (para[1] == 'error')
                alert('로그인 정보가 잘못되었습니다.');


            /* 로그인 시도 */
            $('#loginform').submit(function () {
                var ele = document.getElementById('inputPassword');
                ele.value = ele.value.trim();
                //var hash = SHA256(ele.value);
                var hash = SHA256(SHA256(ele.value));
                document.getElementById('pw').value = hash;
                document.getElementById('loginType').value = 'noneAuto';

                ele = document.getElementById('inputId');
                document.getElementById('id').value = ele.value.trim();

                //document.getElementById('loginform').submit();
                return true;
            });
        }

        $(function () {
            $(window).resize();
            initPage();
        });
    </script>

    <style type="text/css">

    </style>

</head>

<body>
<!--
	<div class="container" style="margin-top: 200px; border:2px solid #dfdfdf; border-radius:5px;">
 -->
<div class="login-wrap">

    <div class="login-area">
        <div class="login-input">
            <form class="form-signin form-horizontal" name="form" method="post"
                  action="loginProcess" id="loginform">
                <div class="img-group">
                    <img src="${contextPath}/resources/img/ISTEC-LOGO-L.png">
                </div>
                <div class="form-group">
                    <label for="inputId" class="sr-only">사용자아이디</label>
                    <input
                        type="text" id="inputId" name="inputId" class="form-control"
                        placeholder="사용자아이디" required autofocus>
                </div>
                <div class="form-group">
                    <label for="inputPassword" class="sr-only">암호</label>
                    <input
                        type="password" id="inputPassword" class="form-control"
                        placeholder="암호" required>
                </div>
                <div class="form-group">
                    <button class="btn btn-lg dj-btn-primary" type="submit" id="loginSm"><small>로그인</small></button>
                </div>

                <input type="hidden" name="id" id="id"> <input type="hidden"
                                                               name="pw" id="pw">
                <input type="hidden" name="loginType" id="loginType">
            </form>
        </div>
        <div class="login-img">
            <img src="${contextPath}/resources/img/istec-login.png">
        </div>
    </div>
    <h6>이 사이트는 Chrome · Edge · Whale 에 최적화되어 있습니다.</h6>


</div>

<!--
</div>
 -->


<div class="container" id="warning" style="max-width:360px; margin-top:10px;" hidden>

    <div class="row">
        <div class="col-lg-12">

            <h6>본 사이트는 HTML5로 제작되었습니다.</h6>
            <h6>구형 브라우저에서는 기능이 제한될 수 있습니다.</h6>
            <h6>원활한 사용을 위해 크롬 브라우저를 권장합니다.</h6>

            <div class="row">
                <div class="col-sm-6">
                    <a href="https://www.google.com/intl/ko/chrome/browser/desktop/index.html">
                        <img class="rounded-circle" src="resources/img/login_chrome.png"
                             alt="Generic placeholder image">
                    </a>
                </div>
                <div class="col-sm-6">
                    <a href="https://www.mozilla.org/ko/firefox/new/">
                        <img class="rounded-circle" src="resources/img/login_firefox.png"
                             alt="Generic placeholder image">
                    </a>
                </div>
            </div>

        </div>
    </div>

</div>


</body>
</html>
