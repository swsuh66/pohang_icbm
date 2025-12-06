<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

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
            padding: 2mm 3mm;
            font-size: 10pt;
            line-height: 1.2;
            overflow: hidden;

            /* 처음 위치 맞출 때만 보더 켜고, 맞으면 주석 처리 */
            border: 1px dashed #cccccc;
        }

        .label strong {
            font-size: 10.5pt;
        }
    </style>
</head>
<body>

<div class="toolbar no-print">
    <button onclick="window.print();">🖨 인쇄하기</button>
</div>

<%
    // 가상의 데이터 생성
    java.util.List<java.util.Map<String, String>> customers = new java.util.ArrayList<>();
    
    // 샘플 데이터 20개 생성
    String[] names = {"홍길동", "김철수", "이영희", "박민수", "최지영", "정수진", "강동원", "윤서연", 
                      "임재현", "한소희", "조민호", "오세훈", "신동욱", "류현진", "송혜교", 
                      "전지현", "현빈", "수지", "아이유", "태연"};
    
    String[] zipCodes = {"37666", "37667", "37668", "37669", "37670", "37671", "37672", "37673", 
                         "37674", "37675", "37676", "37677", "37678", "37679", "37680", 
                         "37681", "37682", "37683", "37684", "37685"};
    
    String[] oldAddrs = {"경상북도 포항시 남구 대잠동 123-45", "경상북도 포항시 남구 대잠동 234-56",
                        "경상북도 포항시 남구 대잠동 345-67", "경상북도 포항시 남구 대잠동 456-78",
                        "경상북도 포항시 남구 대잠동 567-89", "경상북도 포항시 남구 대잠동 678-90",
                        "경상북도 포항시 남구 대잠동 789-01", "경상북도 포항시 남구 대잠동 890-12",
                        "경상북도 포항시 남구 대잠동 901-23", "경상북도 포항시 남구 대잠동 012-34",
                        "경상북도 포항시 남구 대잠동 123-45", "경상북도 포항시 남구 대잠동 234-56",
                        "경상북도 포항시 남구 대잠동 345-67", "경상북도 포항시 남구 대잠동 456-78",
                        "경상북도 포항시 남구 대잠동 567-89", "경상북도 포항시 남구 대잠동 678-90",
                        "경상북도 포항시 남구 대잠동 789-01", "경상북도 포항시 남구 대잠동 890-12",
                        "경상북도 포항시 남구 대잠동 901-23", "경상북도 포항시 남구 대잠동 012-34"};
    
    String[] newAddrs = {"경상북도 포항시 남구 대잠로 123", "경상북도 포항시 남구 대잠로 234",
                        "경상북도 포항시 남구 대잠로 345", "경상북도 포항시 남구 대잠로 456",
                        "경상북도 포항시 남구 대잠로 567", "경상북도 포항시 남구 대잠로 678",
                        "경상북도 포항시 남구 대잠로 789", "경상북도 포항시 남구 대잠로 890",
                        "경상북도 포항시 남구 대잠로 901", "경상북도 포항시 남구 대잠로 012",
                        "경상북도 포항시 남구 대잠로 123", "경상북도 포항시 남구 대잠로 234",
                        "경상북도 포항시 남구 대잠로 345", "경상북도 포항시 남구 대잠로 456",
                        "경상북도 포항시 남구 대잠로 567", "경상북도 포항시 남구 대잠로 678",
                        "경상북도 포항시 남구 대잠로 789", "경상북도 포항시 남구 대잠로 890",
                        "경상북도 포항시 남구 대잠로 901", "경상북도 포항시 남구 대잠로 012"};
    
    String[] adminIds = {"001000000001", "001000000002", "001000000003", "001000000004", "001000000005",
                        "001000000006", "001000000007", "001000000008", "001000000009", "001000000010",
                        "001000000011", "001000000012", "001000000013", "001000000014", "001000000015",
                        "001000000016", "001000000017", "001000000018", "001000000019", "001000000020"};
    
    for (int i = 0; i < 20; i++) {
        java.util.Map<String, String> customer = new java.util.HashMap<>();
        customer.put("custName", names[i]);
        customer.put("zipCode", zipCodes[i]);
        customer.put("addrOld", oldAddrs[i]);
        customer.put("addrNew", newAddrs[i]);
        customer.put("adminId", adminIds[i]);
        customers.add(customer);
    }
    
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
                    <strong>${cust.custName}</strong><br/>
                    (${cust.zipCode}) ${cust.addrOld}<br/>
                    <c:if test="${not empty cust.addrNew}">
                        ${cust.addrNew}<br/>
                    </c:if>
                    <c:if test="${not empty cust.adminId}">
                        (${cust.adminId})
                    </c:if>
                </div>
            </c:if>
        </c:forEach>
    </div>
</c:forEach>

</body>
</html>


