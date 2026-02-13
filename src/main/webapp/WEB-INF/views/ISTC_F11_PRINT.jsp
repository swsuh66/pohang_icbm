<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="com.istec.m1.common.JacksonParsing" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>

<html>
<head>
    <title>레이테크 3016 라벨 출력</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
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
            padding: 20px;
            text-align: center;
            background: #f8f9fa;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .size-control {
            display: inline-block;
            margin: 0 20px;
            vertical-align: middle;
        }
        
        .size-control label {
            display: block;
            font-size: 14px;
            font-weight: bold;
            color: #333;
            margin-bottom: 8px;
        }
        
        .size-control input[type="range"] {
            width: 200px;
            vertical-align: middle;
        }
        
        .size-control input[type="number"] {
            width: 60px;
            padding: 5px;
            border: 1px solid #ddd;
            border-radius: 4px;
            text-align: center;
            font-size: 14px;
            margin-left: 10px;
        }
        
        .size-value {
            display: inline-block;
            min-width: 50px;
            font-size: 14px;
            color: #666;
            margin-left: 10px;
        }

        .print-button {
            background: #2196F3;
            color: white;
            border: none;
            padding: 15px 40px;
            font-size: 18px;
            font-weight: bold;
            border-radius: 8px;
            cursor: pointer;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            transition: all 0.2s ease;
        }

        .print-button:hover {
            background: #1976D2;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
        }

        .print-button:active {
            background: #1565C0;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
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
            transition: all 0.2s ease;
        }

        .label {
            box-sizing: border-box;
            padding: 3mm 4mm 8mm 4mm; /* 위 3mm, 좌우 4mm, 아래 8mm (패딩 축소) */
            font-size: 13pt;
            line-height: 1.5;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            justify-content: flex-start;
            word-wrap: break-word;
            word-break: keep-all;

            /* 처음 위치 맞출 때만 보더 켜고, 맞으면 주석 처리 */
            border: 1px dashed #cccccc;
            transition: all 0.2s ease;
        }

        .label strong {
            font-size: 15pt;
            font-weight: bold;
            margin-top: 2mm;
            margin-bottom: 1mm;
            display: block;
            text-align: right;
            transition: all 0.2s ease;
            word-wrap: break-word;
            word-break: keep-all;
            overflow-wrap: break-word;
            line-height: 1.3;
        }

        .label .zipcode {
            font-size: 13pt;
            color: #333;
            margin-top: auto;
            margin-bottom: 0.8mm;
            display: block;
            text-align: right;
            transition: all 0.2s ease;
        }

        .label .zipcode-boxes {
            display: flex;
            gap: 2mm;
            align-items: center;
            justify-content: flex-end;
            margin-top: auto;
            margin-bottom: 0.8mm;
        }

        .label .zipcode-box {
            width: 6mm;
            height: 6mm;
            border: 1.5pt solid #000;
            display: inline-block;
            box-sizing: border-box;
            transition: all 0.2s ease;
        }

        .label .address {
            font-size: 13pt;
            color: #555;
            line-height: 1.4;
            margin-top: 0;
            margin-bottom: 1mm;
            transition: all 0.2s ease;
            word-wrap: break-word;
            word-break: keep-all;
            overflow-wrap: break-word;
        }
    </style>
</head>
<body>

<div class="toolbar no-print">
    <div style="display: flex; flex-wrap: wrap; justify-content: center; gap: 20px; margin-bottom: 15px;">
        <div class="size-control">
            <label>📦 라벨 크기</label>
            <input type="range" id="labelScaleSlider" min="70" max="140" value="100" step="5" oninput="adjustLabelSize()">
            <span class="size-value" id="labelScaleValue">100%</span>
        </div>
        
        <div class="size-control">
            <label>폰트 크기</label>
            <input type="range" id="fontSizeSlider" min="8" max="20" value="13" step="0.5" oninput="adjustLabelSize()">
            <span class="size-value" id="fontSizeValue">13pt</span>
        </div>
        
        <div class="size-control">
            <label>라벨 간격</label>
            <input type="range" id="paddingSlider" min="2" max="10" value="5" step="0.5" oninput="adjustLabelSize()">
            <span class="size-value" id="paddingValue">5mm</span>
        </div>
        
        <div class="size-control">
            <label>행 간격</label>
            <input type="range" id="lineHeightSlider" min="1.0" max="2.0" value="1.5" step="0.1" oninput="adjustLabelSize()">
            <span class="size-value" id="lineHeightValue">1.5</span>
        </div>
    </div>
    
    <div style="text-align: center;">
        <button class="print-button" onclick="resetSize();" style="background: #757575; padding: 10px 20px; font-size: 14px; margin-right: 10px;">
            🔄 초기화
        </button>
        <button class="print-button" onclick="handlePrint();" style="padding: 10px 20px; font-size: 14px;">
            🖨 인쇄하기
        </button>
    </div>
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
                
                // admin_no 추가 (DB 저장을 위해)
                Object adminNoObj = item.get("admin_no");
                if (adminNoObj != null) {
                    customer.put("admin_no", String.valueOf(adminNoObj));
                }
                
                // zipCode 추출 (없으면 null로 설정하여 사각형 표시)
                // zipcode 또는 zipCode 키 모두 확인
                Object zipCodeObj = item.get("zipcode");
                if (zipCodeObj == null) {
                    zipCodeObj = item.get("zipCode");
                }
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
                
                // addr 추출 및 수용가 번호에 따라 구 추가
                Object addrObj = item.get("addr");
                if (addrObj != null) {
                    String addr = String.valueOf(addrObj);
                    
                    // admin_no의 첫 번째 문자에 따라 구 추가
                    String adminNo = customer.get("admin_no");
                    if (adminNo != null && !adminNo.isEmpty()) {
                        String firstChar = adminNo.substring(0, 1);
                        if ("1".equals(firstChar)) {
                            addr = "포항시 북구 " + addr;
                        } else if ("2".equals(firstChar)) {
                            addr = "포항시 남구 " + addr;
                        }
                    }
                    
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
    
    // JavaScript에서 사용할 JSON 데이터 생성
    String printDataJson = new com.fasterxml.jackson.databind.ObjectMapper().writeValueAsString(customers);
    request.setAttribute("printDataJson", printDataJson);
%>

<script type="text/javascript">
    // 출력 데이터를 JavaScript 변수로 저장
    var printData = <%= printDataJson %>;
    var isPrinted = false;  // 중복 저장 방지

    // 컨텍스트 패스 가져오기
    function getContextPath() {
        return '<%= request.getContextPath() %>';
    }

    // 프린트 페이지 자체에서 저장 처리
    function saveLabelPrintHistoryLocal(data) {
        if (!data || data.length === 0) {
            return;
        }

        data.forEach(function(item) {
            if (!item.admin_no) {
                return;
            }

            var params = {
                admin_no: item.admin_no,
                cust_name: item.custName || item.cust_name,
                zipcode: item.zipCode || item.zipcode,
                addr: item.addr
            };

            $.ajax({
                url: getContextPath() + '/api/suspected-leaks/save-label-print-history',
                type: 'POST',
                contentType: 'application/json; charset=UTF-8',
                data: JSON.stringify(params),
                async: false,
                success: function(response) {
                    // 저장 성공
                },
                error: function(xhr, status, error) {
                    // 저장 실패
                }
            });
        });
    }

    // 인쇄 처리 함수
    function handlePrint() {
        if (!isPrinted) {
            try {
                // 1순위: 부모 창의 함수 호출 시도
                if (window.opener && !window.opener.closed && typeof window.opener.saveLabelPrintHistory === 'function') {
                    window.opener.saveLabelPrintHistory(printData);
                    isPrinted = true;
                } 
                // 2순위: 프린트 페이지 자체에서 저장
                else {
                    saveLabelPrintHistoryLocal(printData);
                    isPrinted = true;
                }
            } catch (error) {
                // 저장 오류
            }
        }

        // 인쇄 다이얼로그 열기
        window.print();
    }

    // beforeprint 이벤트 (사용자가 Ctrl+P를 누를 경우)
    window.addEventListener('beforeprint', function() {
        if (!isPrinted) {
            try {
                if (window.opener && !window.opener.closed && typeof window.opener.saveLabelPrintHistory === 'function') {
                    window.opener.saveLabelPrintHistory(printData);
                } else {
                    saveLabelPrintHistoryLocal(printData);
                }
                isPrinted = true;
            } catch (error) {
                // 저장 오류
            }
        }
    });

    // 라벨 크기 조정 함수
    function adjustLabelSize() {
        // 기본 크기 (100%)
        var baseWidth = 99.1;  // mm
        var baseHeight = 33.9; // mm
        
        var scale = document.getElementById('labelScaleSlider').value;
        var fontSize = document.getElementById('fontSizeSlider').value;
        var padding = document.getElementById('paddingSlider').value;
        var lineHeight = document.getElementById('lineHeightSlider').value;
        
        // 스케일에 따라 너비/높이 계산 (비율 유지)
        var labelWidth = (baseWidth * scale / 100).toFixed(1);
        var labelHeight = (baseHeight * scale / 100).toFixed(1);
        
        // 값 표시 업데이트
        document.getElementById('labelScaleValue').textContent = scale + '%';
        document.getElementById('fontSizeValue').textContent = fontSize + 'pt';
        document.getElementById('paddingValue').textContent = padding + 'mm';
        document.getElementById('lineHeightValue').textContent = lineHeight;
        
        // Sheet 그리드 크기 조정
        var sheets = document.querySelectorAll('.sheet');
        sheets.forEach(function(sheet) {
            sheet.style.gridTemplateColumns = 'repeat(2, ' + labelWidth + 'mm)';
            sheet.style.gridTemplateRows = 'repeat(8, ' + labelHeight + 'mm)';
            
            // 라벨 크기에 따라 간격과 패딩 자동 조절
            // A4 너비 210mm, 좌우 패딩 제외한 실제 너비 계산
            var totalLabelWidth = labelWidth * 2; // 2열
            var availableWidth = 210; // A4 너비
            
            // 남은 공간 계산
            var remainingSpace = availableWidth - totalLabelWidth;
            
            if (remainingSpace < 10) {
                // 공간이 부족하면 간격과 패딩 줄이기
                var columnGap = Math.max(0.5, remainingSpace / 4);
                var sidePadding = Math.max(0.5, remainingSpace / 4);
                
                sheet.style.columnGap = columnGap + 'mm';
                sheet.style.padding = '8mm ' + sidePadding + 'mm';
            } else {
                // 여유 있으면 기본값 사용
                sheet.style.columnGap = '1.8mm';
                sheet.style.padding = '8mm 5mm';
            }
        });
        
        // 모든 라벨에 적용
        var labels = document.querySelectorAll('.label');
        labels.forEach(function(label) {
            label.style.fontSize = fontSize + 'pt';
            label.style.padding = '4mm ' + padding + 'mm 9mm ' + padding + 'mm';
            label.style.lineHeight = lineHeight;
            // 점선 테두리는 항상 표시 (조절 불가)
            label.style.border = '1px dashed #cccccc';
        });
        
        // strong 태그 (이름) 폰트 크기 조정
        var strongTags = document.querySelectorAll('.label strong');
        strongTags.forEach(function(strong) {
            strong.style.fontSize = (parseFloat(fontSize) + 2) + 'pt';
        });
        
        // 우편번호와 주소 폰트 크기 조정
        var zipCodes = document.querySelectorAll('.label .zipcode');
        zipCodes.forEach(function(zipcode) {
            zipcode.style.fontSize = parseFloat(fontSize) + 'pt';
        });
        
        var addresses = document.querySelectorAll('.label .address');
        addresses.forEach(function(address) {
            address.style.fontSize = parseFloat(fontSize) + 'pt';
            address.style.lineHeight = lineHeight;
        });
    }
    
    // 초기화 함수
    function resetSize() {
        document.getElementById('labelScaleSlider').value = 100;
        document.getElementById('fontSizeSlider').value = 13;
        document.getElementById('paddingSlider').value = 5;
        document.getElementById('lineHeightSlider').value = 1.5;
        adjustLabelSize();
    }
    
    // 텍스트가 라벨을 벗어나면 폰트 크기 자동 조정
    function autoAdjustFontSize() {
        var labels = document.querySelectorAll('.label');
        
        labels.forEach(function(label) {
            var strong = label.querySelector('strong');
            var address = label.querySelector('.address');
            
            // 주소가 2줄 이상인지 확인
            if (address) {
                var lineHeight = parseFloat(window.getComputedStyle(address).lineHeight);
                var addressHeight = address.scrollHeight;
                var numberOfLines = Math.round(addressHeight / lineHeight);
                
                // 주소가 2줄 이상이면 이름과의 간격을 좁게 조정
                if (strong) {
                    if (numberOfLines >= 2) {
                        strong.style.marginTop = '0.5mm';
                    } else {
                        strong.style.marginTop = '2mm';
                    }
                }
            }
            
            // 이름(strong) 폰트 크기 자동 조정
            if (strong) {
                var maxHeight = 15; // mm 단위로 최대 높이
                var currentFontSize = 15; // 초기 폰트 크기
                
                strong.style.fontSize = currentFontSize + 'pt';
                
                // 텍스트가 두 줄 이상이면 폰트 크기 줄이기
                while (strong.scrollHeight > strong.clientHeight && currentFontSize > 10) {
                    currentFontSize -= 0.5;
                    strong.style.fontSize = currentFontSize + 'pt';
                }
                
                // 또는 텍스트 길이로 판단
                var text = strong.textContent;
                if (text.length > 20) {
                    strong.style.fontSize = '12pt';
                } else if (text.length > 15) {
                    strong.style.fontSize = '13pt';
                }
            }
            
            // 주소 폰트 크기 자동 조정
            if (address) {
                var text = address.textContent.trim();
                if (text.length > 40) {
                    address.style.fontSize = '10pt';
                } else if (text.length > 30) {
                    address.style.fontSize = '11pt';
                }
            }
        });
    }
    
    // 페이지 로드시 초기값 표시 및 자동 조정
    window.addEventListener('load', function() {
        adjustLabelSize();
        setTimeout(autoAdjustFontSize, 100);
    });
</script>

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
                    <strong>${cust.custName} 귀하</strong>
                    <c:choose>
                        <c:when test="${not empty cust.zipCode}">
                            <span class="zipcode">${cust.zipCode}</span>
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
                </div>
            </c:if>
        </c:forEach>
    </div>
</c:forEach>

</body>
</html>


