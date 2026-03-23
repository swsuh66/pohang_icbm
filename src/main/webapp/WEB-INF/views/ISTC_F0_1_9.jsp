<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="contextPath" value="<%=request.getContextPath()%>"></c:set>
<%@ page language="java" session="false"
         contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <%@include file="/resources/inc/meta.inc" %>
    <title>스마트수도미터원격검침시스템</title>
    <script type="text/javascript">
    </script>
    <script>
        function resetComponentes() {
            $('.componentsSelect').each(function() {
                if ($(this).is('select')) {
                    $(this).val($(this).find('option:first').val());
                } else {
                    $(this).val('');
                }
            });
            $('.componentsSelect').trigger('chosen:updated');
        };
    </script>

</head>
<body>

<div id="filter" class="dj-card">
    <div class="row">
        <div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
            <div class="dj-input-group">
                <span class="info componentsFont">검침원</span>
                <input type="text" class="componentsSelect" id="read_responsi" name="read_responsi"/>
            </div>
        </div>
        <div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
            <div class="dj-input-group">
                <span class="info componentsFont">분구</span>
                <select data-placeholder="전체" class="componentsSelect" id="bungu_cd" name="bungu_cd">
                    <option value="" selected>전체</option>
                </select>
            </div>
        </div>
        <div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
            <div class="dj-input-group">
                <span class="info componentsFont">수용가번호</span>
                <input type="text" class="componentsSelect" id="cs_no"/>
            </div>
        </div>
        <div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
            <div class="dj-input-group">
                <span class="info componentsFont">성명</span>
                <input type="text" class="componentsSelect" id="cust_nm"/>
            </div>
        </div>
        <div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
            <div class="dj-input-group">
                <span class="info componentsFont">연락처</span>
                <input type="text" class="componentsSelect" id="cust_phone"/>
            </div>
        </div>
        <div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
            <div class="dj-input-group">
                <span class="info componentsFont">장애상태</span>
                <select data-placeholder="전체" class="componentsSelect" id="remark" name="remark">
                    <option value="" selected>전체</option>
                </select>
            </div>
        </div>
        <div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
            <div class="dj-input-group">
                <span class="info componentsFont">검침상태</span>
                <select data-placeholder="전체" class="componentsSelect" id="flag" name="flag">
                    <option value="" selected>전체</option>
                    <option value="Y">완료</option>
                    <option value="N">미검침</option>
                </select>
            </div>
        </div>
        <div class="col-12 col-sm-6 col-md-8 col-lg-12 col-xl-10">
            <div class="dj-btn-group">
                <button type="button" class="btn dj-btn-primary btn-sm" onclick="parent.searchGrid();">검색</button>
                <button type="button" class="btn dj-btn-outline-gray btn-sm" onclick="resetComponentes();">초기화</button>
                <button type="button" class="btn dj-btn-outline-green btn-sm" onclick="dataDownload();"><i
                        class="ico i-excel"></i>엑셀다운
                </button>
            </div>
        </div>
    </div>
</div>


</body>
</html>
