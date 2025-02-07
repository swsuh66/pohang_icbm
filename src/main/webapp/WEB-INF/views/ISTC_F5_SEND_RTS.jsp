<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="EUC-KR">
    <title>스마트수도미터원격검침시스템</title>
    <link rel="shortcut icon" type="image/png" href="resources/img/logo-checkall-mk1.png">
    <link rel="stylesheet" type="text/css" href="${contextPath}/resources/lib/bootstrap/dist/css/bootstrap.css">
    <link rel="stylesheet" type="text/css"
          href="${contextPath}/resources/lib/@fortawesome/fontawesome-free/css/fontawesome.css">
    <link rel="stylesheet" type="text/css"
          href="${contextPath}/resources/lib/@fortawesome/fontawesome-free/css/regular.css">
    <link rel="stylesheet" type="text/css"
          href="${contextPath}/resources/lib/@fortawesome/fontawesome-free/css/brands.css">
    <link rel="stylesheet" type="text/css"
          href="${contextPath}/resources/lib/@fortawesome/fontawesome-free/css/solid.css">
    <link rel="stylesheet" type="text/css" href="${contextPath}/resources/page/common/css/ace-themes.css">
    <script type="text/javascript" src="${contextPath}/resources/lib/jquery/dist/jquery.js"></script>
    <script type="text/javascript" src="${contextPath}/resources/rts.js"></script>
    <script src="${contextPath}/resources/lib/bootstrap/dist/js/bootstrap.js"></script>
    <link rel="stylesheet" type="text/css"
          href="${contextPath}/resources/page/common/css/custom.css">
    <script src="${contextPath}/resources/page/common/js/custom.js"></script>
    <style>
        .bgCyon {
            background: #29a3cc;
            color: white;
        }

        .rtsTable {
            border-collapse: collapse;
        }

        .tableWrap {
            height: 573px;
            width: 100%;
            overflow: auto;
        }

        .rtsTable thead tr th {
            position: sticky;
            top: 0;
        }

        .rtsTable th {
            border-left: 1px dotted rgba(200, 209, 224, 0.6);
            border-bottom: 1px solid #e8e8e8;
            box-shadow: 0px 0px 0 2px #e8e8e8;
        }

        .rtsTable {
            width: 100%;
        }

        .rtsTable tr {
            border-bottom: 2px solid #e8e8e8;
        }

        .rtsTable thead {
            font-weight: 500;
            color: rgba(0, 0, 0, 0.85);
        }

        .rtsTable tbody tr:hover {
            background: #e6f7ff;
        }

        .bd {
            padding-top: 1.85rem !important;
            padding-bottom: 1.85rem !important;
            padding-left: 1.85rem !important;
            padding-right: 1.85rem !important;
        }

        .bxsw {
            box-shadow: 2px 1px 1px #ececec;
            margin-top: 2.38%;
            border-radius: 2px;
        }

        table td, table th {
            text-align: center;
            vertical-align: middle !important;
        }
    </style>
</head>
<body>
<div role="main" class="sub-content">
    <!-- 데이터가 표출되는 영역의 가장 상위부분 입니다. -->
    <div class="row">
        <div class='col-md-8'>
            <div class="sub-cont-header">
                <h1>장비 설정</h1>
                <div class="sub-cont-header-area">
                    <form id='searchForm'>
                        <input type="text" placeholder="CSE-ID/CTN" name='search_data' class='form-control'
                               style='display: inline-block;width: 200px'>
                        <select name='search_data2' class='form-control' style='display: inline-block;width: 30%'>
                            <option value=''>전체</option>
                            <option value='000000000'>정상</option>
                            <option value='100000000'>장애</option>
                        </select>
                        <button name="search" id='search' type='button' class='btn btn-sm dj-btn-primary'>검색실행</button>
                    </form>

                </div>
            </div>
        </div>
        <div class='col-md-4'>
            <div class="sub-cont-header">
                <h1>작업현황(TOP 10)</h1>
            </div>
        </div>
    </div>
    <div class='row'>

        <!-- 장비 설정 영역 입니다. -->
        <div class='col-md-8'>
            <div class="dj-card">

                <!-- 검색 영역 입니다. -->
                <div class="table-top">
                    <button type='button' class="btn dj-btn-outline-gray btn-sm" id='showMsgModal'>메시지
                    </button>
                    <button type='button' class="btn dj-btn-outline-primary btn-sm"
                            id='showResetModal'>장비리셋
                    </button>
                    <button type='button' class="btn dj-btn-gray btn-sm"
                            id='showServiceModal'>서비스 아이디
                    </button>
                    <button type='button' class="btn dj-btn-primary btn-sm"
                            id='showCycleModal'>주기변경
                    </button>
                </div>

                <!-- nbiot 데이터가 나오는 부분 입니다. -->
                <div class='tableWrap dj-table'>
                    <table class="rtsTable">
                        <thead>
                        <tr>
                            <th class="bgCyon">no</th>
                            <th class="bgCyon">
                                <input type="checkbox" id='selectAll'/>
                            </th>
                            <th class="bgCyon">관리번호</th>
                            <th class="bgCyon">이름</th>
                            <th class="bgCyon">CSE-ID</th>
                            <th class="bgCyon">CTN</th>
                            <th class="bgCyon">상태</th>
                            <th class="bgCyon">최종검침일</th>
                        </tr>
                        </thead>
                        <tbody id='showTable' style='font-size : 13px !important;'></tbody>
                    </table>
                </div>
                <nav class="page-align" id="pagination"></nav>
            </div>
        </div>

        <!-- 작업 현황 영역 입니다. -->
        <div class='col-md-4'>
            <div class="dj-card">
                <%--                <h1 style='font-size : 1.3em;'>--%>
                <%--                    ※ 작업 현황<small> (Top 10)</small>--%>
                <%--                </h1>--%>
                <div class="dj-table">
                    <!-- 이력과 관련된 데이터가 나오는 부분 입니다. -->
                    <table>
                        <thead>
                        <tr>
                            <th class="bgCyon">시간</th>
                            <th class="bgCyon">URL설명</th>
                            <th class="bgCyon">URL</th>
                            <th class="bgCyon">상태</th>
                            <th class="bgCyon">대상</th>
                        </tr>
                        </thead>
                        <tbody id='workingHistory' style='font-size : 13px !important;'>
                        <tr>
                        </tr>
                        </tbody>
                    </table>
                </div>
                <nav class="page-align2" id="pagination"></nav>
            </div>
        </div>

    </div>

</div>
<!-- 장비 리셋 모달 입니다 -->
<div class="modal" tabindex="-1" role="dialog" id='resetModal'>
    <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">장비 리셋</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <form id='insertForm'>
                    <table class='table table-bordered table-hover table-sm'>
                        <thead>
                        <tr>
                            <th>no</th>
                            <th>이름</th>
                            <th>CSE-ID</th>
                        </tr>
                        </thead>
                        <tbody id='modalTbody1'>

                        </tbody>
                    </table>
                    <div>
                        <select id='urlList1' class='form-control'>

                        </select>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary" id='requestOrderBtn1'>전송</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>

<!-- 서비스 아이디 모달 입니다 -->
<div class="modal" tabindex="-1" role="dialog" id='serviceModal'>
    <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">서비스 아이디 <small style='color : red'> [경고!] 해당 기능은 전문 지식이 필요합니다.</small></h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <form id='insertForm'>
                    <table class='table table-bordered table-hover table-sm'>
                        <thead>
                        <tr>
                            <th>no</th>
                            <th>이름</th>
                            <th>CSE-ID</th>
                        </tr>
                        </thead>
                        <tbody id='modalTbody2'>

                        </tbody>
                    </table>
                    <div>
                        <select id='urlList2' class='form-control'>

                        </select>
                    </div>
                    <div style='margin-top: 10px'>
                        <input type="text" placeholder="서비스 아이디를 적어주세요" id='serviceId' class='form-control'>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary" id='requestOrderBtn2'>전송</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>

<!-- "close" 모달 입니다 -->
<div class="modal" tabindex="-1" role="dialog" id='cycleModal'>
    <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">주기변경</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <form id='insertForm'>
                    <table class='table table-bordered table-hover table-sm'>
                        <thead>
                        <tr>
                            <th>no</th>
                            <th>이름</th>
                            <th>CSE-ID</th>
                        </tr>
                        </thead>
                        <tbody id='modalTbody3' style="max-height: 400px;overflow-y: auto">

                        </tbody>
                    </table>
                    <div>
                        <select id='urlList3' class='form-control'>

                        </select>
                    </div>
                    <div style='margin-top: 10px'>
                        <div>검침 주기</div>
                        <select id='checkCycle' class='form-control'>
                            <option value="0" selected="selected">변경없음</option>
                            <option value="1">1시간</option>
                            <option value="2">2시간</option>
                            <option value="3">3시간</option>
                            <option value="4">4시간</option>
                            <option value="6">6시간</option>
                            <option value="12">12시간</option>
                        </select>
                    </div>
                    <div style='margin-top: 10px'>
                        <div>보고 주기</div>
                        <select id='requestCycle' class='form-control'>
                            <option value="0" selected="selected">변경없음</option>
                            <option value="1">1시간</option>
                            <option value="2">2시간</option>
                            <option value="3">3시간</option>
                            <option value="4">4시간</option>
                            <option value="6">6시간</option>
                            <option value="12">12시간</option>
                        </select>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary" id='requestOrderBtn3'>전송</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>


<!-- MSG  모달 입니다 -->
<div class="modal" tabindex="-1" role="dialog" id='msgModal'>
    <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">하향 메시지 전송</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <form id='insertForm'>
                    <table class='table table-bordered table-hover table-sm'>
                        <thead>
                        <tr>
                            <th>no</th>
                            <th>이름</th>
                            <th>CSE-ID</th>
                        </tr>
                        </thead>
                        <tbody id='modalTbody4'>

                        </tbody>
                    </table>
                    <div>
                        <select id='urlList4' class='form-control'>

                        </select>
                    </div>
                    <div style='margin-top: 10px'>
                        <input type="text" placeholder="보낼 메시지를 입력하여주세요" id='msg' class='form-control'>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary" id='requestOrderBtn4'>전송</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>


</body>
</html>

<script>
    $(document).ready(function () {
        const listUrl = 'api/getNbiotList';  //장비 데이터를 가져오는 주소 입니다.
        const getUrlListUrl = 'api/getUrlList';  //전송해야되는 URL 목록 데이터를 가져오는 주소 입니다.
        const orderUrl = 'api/requestOrder';  //명령 전달을 실행하는 주소 입니다.
        const getHistory10ListUrl = 'api/getHistory10List';  //최근 작업현황 데이터를 반환 합니다.

        //장비 데이터를 가져오는 파라미터입니다.
        const param = {
            'pageSize': 50,
            'rowSize': 10,
            'curPage': 0,
            'tail_class_name': 'page-align'
        }

        //URL 데이터 목록값을 가져 옵니다.
        commonAjax(getUrlListUrl, {pageSize: 500, rowSize: 10, curPage: 0}, result => {
            if (result?.list) {
                //데이터가 존재하면 select 박스에 option 테그를 생성하여 줍니다.
                result.list.forEach((data, index) => {
                    $('#urlList1, #urlList2, #urlList3, #urlList4').append(  //장비리셋, 서비스 아이디, 주기변경 모달의 select 테그에 각각 append 하여 줍니다.
                        $('<option>').val(data.url_name).text('[' + data.url_desc + '] ' + data.url_name).attr('url_desc', data.url_desc)
                    )
                });
            }
        });

        let dataArray = {};  //장비 데이터를 가지고 있는 Object 입니다.
        let target = null;  //사용자가 checkbox를 통해 선택한 데이터의 목록이 존재하는 Array 입니다.


        //장비 목록 테이블 화면을 그리는 함수 입니다.
        function viewer(result) {

            $('#showTable').children().remove();
            dataArray = {};
            if (result?.list) {
                result.list.forEach((data, index) => {
                    let {admin_id, cust_nm, sub_dev_no, dev_no, status, meas_dt} = data;
                    let item = $('<tr/>').append(
                        $('<td/>').addClass('').text(getNumbering(result, index)),
                        $('<td/>').append(
                            $('<input type="checkbox"/>').addClass('targets').val(admin_id)
                        ),
                        $('<td/>').text(admin_id),
                        $('<td/>').text(cust_nm),
                        $('<td/>').text(sub_dev_no),
                        $('<td/>').text(dev_no),
                        $('<td/>').append(status == '000000000' ? '<span style="color : green">정상</span>' : '<span style="color : #ff6565">장애</span>'),
                        $('<td/>').text(meas_dt != null ? new Date(meas_dt).yyyymmddhhmmss() : '')
                    );
                    $('#showTable').append(item);  //위의 객체를 append합니다.
                    dataArray[admin_id] = data;
                });

            }
        }

        //Ajax를 통해 데이터를 받아온 뒤 콜백함수인 viewer를 실행 합니다.
        buildTable(listUrl, param, viewer);

        //검색용 함수 입니다.
        $('#search').click(() => {
            let form = $('#searchForm').serializeArray();
            param.curPage = 0;
            $('#showTable').children().remove();  //기존 테이블 데이터를 제거 합니다.
            form.forEach(arg => param[arg.name] = arg.value);
            buildTable(listUrl, param, viewer);  //화면을 그립니다.
        });

        //장비설정 화면에서 테이블 헤더의 체크박스를 누르는 경우 모든 체크박스가 눌러지도록 기능을 부여 합니다.
        $('#selectAll').change(function () {
            let that = $(this);
            $('.targets').each(function () {
                if (that.is(':checked')) {
                    $(this).prop('checked', true);
                } else {
                    $(this).prop('checked', false);
                    checkedArray = [];
                }
            });
        });

        // "장비리셋", "서비스 아이디", "주기변경" 버튼을 누르는 경우 각각의 모달 영역의 테이블에 대상을 그려주고,
        // 체크박스로 선택한 장비데이터를 배열에 추가하여 반환 합니다.
        // 파라미터 num 값은 그려줄 테이블 아이디의 뒷 숫자 값 입니다.
        function addTargetList(num) {
            let checkedArray = [];
            let index = 0;
            $('#modalTbody' + num).children().remove();
            $('.targets').each(function () {
                if ($(this).is(':checked')) {
                    let data = dataArray[$(this).val()];
                    checkedArray.push(data);
                    $('#modalTbody' + num).append(
                        $('<tr>').append(
                            $('<td>').text(index + 1),
                            $('<td>').text(data.cust_nm),
                            $('<td>').text(data.sub_dev_no)
                        )
                    );
                    index += 1;
                }
            });
            return checkedArray;
        }

        //"장비리셋" 버튼을 누르는 경우 동작 합니다.
        $('#showResetModal').click(() => {
            let data = addTargetList(1);
            if (data.length != 0) {
                $('#resetModal').modal('show');
                target = data;
            } else {
                alert('선택된 대상이 없습니다!');
            }
        });

        //"서비스 아이디" 버튼을 누르는 경우 동작 합니다.
        $('#showServiceModal').click(() => {
            let data = addTargetList(2);
            if (data.length != 0) {
                $('#serviceModal').modal('show');
                target = data;
            } else {
                alert('선택된 대상이 없습니다!');
            }
        });

        //"주기변경" 버튼을 누르는 경우 동작 합니다.
        $('#showCycleModal').click(() => {
            let data = addTargetList(3);
            if (data.length != 0) {
                $('#cycleModal').modal('show');
                target = data;
            } else {
                alert('선택된 대상이 없습니다!');
            }
        });


        $('#showMsgModal').click(() => {
            let data = addTargetList(4);
            if (data.length != 0) {
                $('#msgModal').modal('show');
                target = data;
            } else {
                alert('선택된 대상이 없습니다!');
            }
        });

        //장비리셋 모달에서 "전송" 버튼의 기능 입니다.
        $('#requestOrderBtn1').click(() => _requestOrder(1));

        //서비스 아이디 모달에서 "전송" 버튼의 기능 입니다.
        $('#requestOrderBtn2').click(() => {
            if (!confirm('해당 작업을 하면 원래대로 되돌릴 수 없습니다.\n명령을 전달하시겠습니까?')) return;
            _requestOrder(2)
        });

        //주기변경 모달에서 "전송" 버튼의 기능 입니다.
        $('#requestOrderBtn3').click(() => _requestOrder(3));

        //하향 메시지 전송 모달에서 "전송" 버튼의 기능 입니다.
        $('#requestOrderBtn4').click(() => _requestOrder(4));

        //위 3개의 버튼이 사용하는 공통함수 입니다.
        function _requestOrder(num) {
            if (!confirm('명령을 전달합니까?')) return;
            if (!target || target.length == 0) return;
            let cseids = '';  //대상 cseid값을 콤마단위로 붙입니다.
            target.forEach(tar => {
                cseids += tar.sub_dev_no + ",";
            })
            cseids = cseids.substring(0, cseids.length - 1);

            let query = {};
            //숫자에 따라 가져오는 select 박스와 input 테그 값을 정의하여 줍니다.
            if (num == 1) {
                query.url_name = $('#urlList1 option:selected').val();
                query.url_desc = $('#urlList1 option:selected').attr('url_desc');
            } else if (num == 2) {
                query.url_name = $('#urlList2 option:selected').val();
                query.url_desc = $('#urlList2 option:selected').attr('url_desc');
                query.servicecode = $('#serviceId').val();
            } else if (num == 3) {
                query.url_name = $('#urlList3 option:selected').val();
                query.url_desc = $('#urlList3 option:selected').attr('url_desc');
                query.meterread_cycle = $('#checkCycle').val();
                query.send_cycle = $('#requestCycle').val();
            } else {
                query.url_name = $('#urlList4 option:selected').val();
                query.url_desc = $('#urlList4 option:selected').attr('url_desc');
                query.msg = $('#msg').val();
            }
            query.cseids = cseids;
            commonAjax(orderUrl, query, result => {
                alert('완료하였습니다.');
                buildTable(getHistory10ListUrl, param, viewer2);
                $('#serviceModal, #cycleModal, #resetModal, #msgModal').modal('hide');
            });
        }


        //작업현황 화면을 그리는 함수 입니다.
        function viewer2(result) {
            $('#workingHistory').children().remove();
            if (result) {
                result.forEach((data, index) => {
                    let {idx, url_name, working_status, reg_date, size, url_desc} = data;
                    let item = $('<tr/>').addClass('tr').append(
                        $('<td/>').text(reg_date != null ? new Date(reg_date).yyyymmddhhmmss() : ''),
                        $('<td/>').text(url_desc),
                        $('<td/>').text(url_name),
                        $('<td/>').text(working_status),
                        $('<td/>').text(size + '개')
                    );
                    $('#workingHistory').append(item);  //위의 객체를 append합니다.
                });
            }
        }

        //Ajax를 통해 데이터를 받아온 뒤 콜백함수인 viewer2를 실행 합니다(작업현황 화면)
        buildTable(getHistory10ListUrl, {}, viewer2);

        //2초마다 데이터를 가져와 변경사항에 대해서 작업현황 테이블 데이터를 최신화 하여 줍니다.
        setInterval(() => {
            buildTable(getHistory10ListUrl, {}, viewer2);
        }, 2000);
    });

</script>
