<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="contextPath" value="<%=request.getContextPath()%>"></c:set>
<%@ page language="java" session="false"
         contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<%-- istc_f0_1_base --%>
<%-- 기본필터 화면 --%>
    <%@include file="/resources/inc/meta.inc" %>
    <title>스마트수도미터원격검침시스템</title>
    <script type="text/javascript">
    </script>
    <script>
	    $(function () {
	    	//화면 오픈시
	    	loadComponentBase();
	    });
	    
	    var searchComponentes = {
				statCd : null,
				useType : null,
				blkSq : null,
				readOpr : null,
				setYears : null,
				comSq : null,
				amiType : null,
				pipeDia : null,
				siteSq : null,
				upSiteSq : parent.getSiteSq(), 
				lv : 1,
				fullNm : ['전체']
		}; 
	    
	    /*
         * 검색 컴포넌트 변경
         */
        function baseComponentChangHandler(el) {
            var val = $(el).val() != '-1' ? $(el).val() : null;
            searchComponentes[$(el).attr('id')] = val;
        };
	    
	    function selectChange(url, key) {
            var params = {};

            $('#addr_2 option').remove(); //초기화
            var el = $('<option>').attr('value', "").text("전체");
            $('.componentsSelect[name="' + "addr_2" + '"]').append(el);

            var addr_1 = $('#addr_1').val()
            if (addr_1 == null || addr_1 == "") {
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

                }
            });
        };
    
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

        		statCd : null,
        		useType : null,
        		blkSq : null,
        		readOpr : null,
        		setYears : null,
        		comSq : null,
        		amiType : null,
        		pipeDia : null

        	});
        };
        
     // 기본컴포넌트 생성.
    	function loadComponentBase() {
    		var params = {key:0};
    		$.extend(params, searchComponentes);
    		baseComponent('mars.icbm.map1.selectComponentes', 'setYears', params); //0
    		params.key = 1;
    		baseComponent('mars.icbm.map1.selectComponentes', 'comSq', params);
    		params.key = 2;
    		baseComponent('mars.icbm.map1.selectComponentes', 'amiType', params);
    		params.key = 3;
    		baseComponent('mars.icbm.map1.selectComponentes', 'pipeDia',params);
    		params.key = 4;
    		baseComponent('mars.icbm.map1.selectComponentes', 'useType', params);
    		params.key = 5;
    		baseComponent('mars.icbm.map1.selectComponentes', 'readOpr', params);
    		params.key = 6;
    		baseComponent('mars.icbm.map1.selectComponentes', 'blkSq' , params);
    	}
     
    	/**
    	 * base 조회조건 조회
    	 */
    	function baseComponent(url, name, param) {
    		ajaxSelect({
    			sql : url,
    			data : param,
    			success : function(data) {
    				if (data != 0) {
    					data.forEach(function(item, idx) {
    						if (item != null) {
    							if (item.sq != '' && item.sq != null && item.val != '' && item.val != null) {
    								var el = $('<option>').attr('value', item.sq).text(item.val);
    								$('.componentsSelect[name="' + name + '"]').append(el);
    							}
    						}
    					});
    				}
    				
    			},
    			error : function(result) {
    				jAlert.error('오류', '데이터를 가져오는데 실패하였습니다.');
    			}
    		});
    	};

        /* 조회조건 필터 숨김 */
        function blankbase() {

            $('#statCd_Grp').hide();
            $('#useType_Grp').hide();
            $('#blkSq_Grp').hide();
            $('#readOpr_Grp').hide();
            $('#setYears_Grp').hide();
            $('#comSq_Grp').hide();
            $('#amiType_Grp').hide();
            $('#pipeDia_Grp').hide();

        };

        /* 조회조건 필터 숨김 */
        function showInsertbtn() {

        };
    </script>
</head>
<body>

<div class="dj-card" id="filter">
    <div class="row">
        <div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
            <div class="dj-input-group">
                <span class="info componentsFont">수용가번호</span>
                <input type="text" class="componentsSelect" id="admin_no" onKeypress="javascript:if(event.keyCode == 13) { parent.searchGrid(); }"/>
            </div>
        </div>
        <div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
            <div class="dj-input-group">
                <span class="info componentsFont">수용가명</span>
                <input type="text" class="componentsSelect" id="cust_nm" onKeypress="javascript:if(event.keyCode == 13) { parent.searchGrid(); }"/>
            </div>
        </div>
        <div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
            <div class="dj-input-group">
                <span class="info componentsFont">기준일자</span>
				<input type="date" class="form-control" id="toDate" name="toDate" value="">   
            </div>
        </div>
		<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
            <div class="dj-input-group">
                <span class="info componentsFont">연속일</span>
                <input type="text" class="form-control" name="cntdate" id="cntdate" value="5" onKeypress="javascript:if(event.keyCode == 13) { parent.searchGrid(); }"/>
            </div>
        </div>

        <div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
            <div class="dj-input-group">
                <span class="info componentsFont">설정시작시간</span>
				<input type="time" class="form-control" id="fromtime" name="fromtime" value="01:00:00" min="00:00:00" max="24:00:00">   
            </div>
        </div>
        <div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
            <div class="dj-input-group">
                <span class="info componentsFont">설정끝시간</span>
				<input type="time" class="form-control" id="totime" name="totime" value="05:00:00" min="00:00:00" max="24:00:00">   
            </div>
        </div>
		<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
            <div class="dj-input-group">
                <span class="info componentsFont">최소사용량</span>
                <input type="text" class="form-control" name="compare_term_cv" id="compare_term_cv" value="0" onKeypress="javascript:if(event.keyCode == 13) { parent.searchGrid(); }"/>
            </div>
        </div>
        <div class="col-12 col-sm-6 col-md-8 col-lg-12 col-xl-12">
            <div class="dj-btn-group">
                <button type="button" id = "searchbtn" class="btn dj-btn-primary btn-sm" onclick="parent.searchGrid(); siteinfogrid.search();">검색</button>
                <button type="button" onclick="dataDownload();" class="btn btn-sm dj-btn-outline-green"><i
                        class="ico i-export"></i>Export
                </button>
            </div>
        </div>
    </div>
</div>

</body>
</html>
