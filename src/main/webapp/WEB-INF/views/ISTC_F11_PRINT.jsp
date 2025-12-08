<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="com.istec.m1.common.JacksonParsing" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>

<html>
<head>
    <title>레이테크 3016 라벨 출력</title>
    <style>
        @page {
            size: A4;
            margin: 0;
        }

        @media print {
            body {
                margin: 0;
            }
            .no-print {
                display: none;
            }
        }

        body {
            font-family: 'Malgun Gothic', Arial, sans-serif;
            margin: 0;
            padding: 0;
        }

        .toolbar {
            margin: 10px;
        }

        /* A4 한 장 = 1 sheet */
        .sheet {
            width: 210mm;
            height: 297mm;
            padding: 8mm 5mm; /* 위/아래 8mm, 좌/우 5mm 여백 */
            box-sizing: border-box;

            display: grid;
            grid-template-columns: repeat(2, 99.1mm);  /* 2열 */
            grid-template-rows: repeat(8, 33.9mm);     /* 8행 */
            column-gap: 1.8mm;  /* 열 사이 간격 */
            row-gap: 1.4mm;     /* 행 사이 간격 */

            page-break-after: always;
        }

        .label {
            box-sizing: border-box;
            padding: 4mm 5mm;
            font-size: 13pt;
            line-height: 1.6;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            justify-content: center;

            /* 처음 위치 맞출 때만 보더 켜고, 맞으면 주석 처리 */
            border: 1px dashed #cccccc;
        }

        .label strong {
            font-size: 16pt;
            font-weight: bold;
            margin-bottom: 2mm;
            display: block;
        }

        .label .zipcode {
            font-size: 12pt;
            color: #333;
            margin-bottom: 1mm;
        }

        .label .zipcode-boxes {
            display: inline-flex;
            gap: 2mm;
            align-items: center;
            margin-bottom: 1mm;
        }

        .label .zipcode-box {
            width: 6mm;
            height: 6mm;
            border: 1.5pt solid #000;
            display: inline-block;
            box-sizing: border-box;
        }

        .label .address {
            font-size: 12pt;
            color: #555;
            line-height: 1.5;
        }
    </style>
</head>
<body>

<div class="toolbar no-print">
    <button onclick="window.print();">🖨 인쇄하기</button>
</div>

<%
    // 전달받은 데이터 파싱
    List<Map<String, String>> customers = new java.util.ArrayList<>();
    
    String printDataStr = request.getParameter("printData");
    if (printDataStr != null && !printDataStr.isEmpty()) {
        try {
            // JacksonParsing을 사용하여 JSON 파싱
            List<Map<String, Object>> dataList = JacksonParsing.toList(printDataStr);
            
            for (Map<String, Object> item : dataList) {
                Map<String, String> customer = new java.util.HashMap<>();
                
                // zipCode 추출 (없으면 null로 설정하여 사각형 표시)
                Object zipCodeObj = item.get("zipCode");
                String zipCode = null;
                if (zipCodeObj != null) {
                    String zipCodeStr = String.valueOf(zipCodeObj).trim();
                    if (!zipCodeStr.isEmpty() && !zipCodeStr.equals("null") && !zipCodeStr.equals("123-123")) {
                        zipCode = zipCodeStr;
                    }
                }
                customer.put("zipCode", zipCode);
                
                // custName 추출
                Object custNameObj = item.get("custName");
                if (custNameObj != null) {
                    customer.put("custName", String.valueOf(custNameObj));
                }
                
                // addr 추출
                Object addrObj = item.get("addr");
                if (addrObj != null) {
                    String addr = String.valueOf(addrObj);
                    customer.put("addrNew", addr);
                    customer.put("addrOld", addr);
                }
                
                customers.add(customer);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    // 데이터가 없으면 빈 리스트
    request.setAttribute("customers", customers);
%>

<c:set var="pageSize" value="16" />
<c:set var="total" value="${fn:length(customers)}" />
<c:set var="pageCount" value="${(total + pageSize - 1) / pageSize}" />

<c:forEach begin="0" end="${pageCount - 1}" var="pageIdx">
    <div class="sheet">
        <c:forEach begin="${pageIdx * pageSize}"
                   end="${pageIdx * pageSize + pageSize - 1}"
                   var="i">
            <c:if test="${i < total}">
                <c:set var="cust" value="${customers[i]}" />
                <div class="label">
                    <strong>${cust.custName}</strong>
                    <c:choose>
                        <c:when test="${not empty cust.zipCode}">
                            <span class="zipcode">(${cust.zipCode})</span>
                        </c:when>
                        <c:otherwise>
                            <span class="zipcode-boxes">
                                <span class="zipcode-box"></span>
                                <span class="zipcode-box"></span>
                                <span class="zipcode-box"></span>
                                <span class="zipcode-box"></span>
                                <span class="zipcode-box"></span>
                            </span>
                        </c:otherwise>
                    </c:choose>
                    <span class="address">
                        <c:choose>
                            <c:when test="${not empty cust.addrNew}">
                                ${cust.addrNew}
                            </c:when>
                            <c:when test="${not empty cust.addrOld}">
                                ${cust.addrOld}
                            </c:when>
                        </c:choose>
                    </span>
                </div>
            </c:if>
        </c:forEach>
    </div>
</c:forEach>

</body>
</html>


