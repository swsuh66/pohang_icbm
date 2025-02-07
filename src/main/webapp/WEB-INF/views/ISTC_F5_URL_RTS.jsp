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
</head>
<body>
<div role="main" class="sub-content">
    <div class="sub-cont-header">
        <h1>하향 URL 관리</h1>
        <div class="sub-cont-header-area">
            <button type="button" id="showModal" class="btn btn-sm dj-btn-outline-green">URL 등록
            </button>
        </div>
    </div>
    <%--    <h1 style='font-size : 1.3em; float:left;'>하향 URL 관리</h1>--%>

    <%--    <div>--%>
    <%--        <button type='button' class="btn btn-success btn-xs" style='float:right;' id="showModal">URL 등록</button>--%>
    <%--    </div>--%>

    <!-- 데이터를 표기하는 영역 입니다. -->
    <div class="dj-card">
        <div class="dj-table">
            <table>
                <thead>
                <tr>
                    <th class="bgCyon">no</th>
                    <th class="bgCyon">주소값</th>
                    <th class="bgCyon">설명</th>
                    <th class="bgCyon">등록일</th>
                    <th class="bgCyon">수정일</th>
                    <th class="bgCyon">관리</th>
                </tr>
                </thead>
                <tbody id='showTable'></tbody>
            </table>
        </div>
        <nav class="page-align" id="pagination"></nav>
    </div>

    <!-- 데이터를 등록하는 영역 입니다. -->
    <div class="modal" tabindex="-1" role="dialog" id='insertModal'>
        <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">데이터 등록</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <form id='insertForm'>
                        <table class='table table-bordered table-hover'>
                            <thead>
                            <tr>
                                <th>no</th>
                                <th>내용</th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr>
                                <td>1</td>
                                <td><input type='text' id='url_name' name='url_name' placeholder="URL주소"
                                           class='form-control'/></td>
                            </tr>
                            <tr>
                                <td>2</td>
                                <td><input type='text' id='url_name' name='url_desc' placeholder="간단한 설명"
                                           class='form-control'/></td>
                            </tr>
                            </tbody>
                        </table>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" id='insertData'>저장</button>
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">닫기</button>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>

<script>

    $(document).ready(function () {

        const listUrl = 'api/getUrlList';
        const insertUrl = 'api/insertUrl';
        const updateUrl = 'api/updateUrl';
        const deleteUrl = 'api/deleteUrl';

        //조회를 위한 파라미터입니다.
        const param = {
            'pageSize': 10,  //한번에 보여지는 사이즈
            'rowSize': 10,   //하단에 생기는 페이지 수
            'curPage': 0,
            'tail_class_name': 'page-align'
        }

        //테이블 화면을 그리는 함수 입니다.
        function viewer(result) {

            //데이터를 그릴 테이블의 자식노드를 제거하여 줍니다.
            $('#showTable').children().remove();

            //DB에 데이터가 존재한다면 가져온 결과값을 반복문을 통해 테이블에 그려 줍니다.
            if (result?.list) {
                result.list.forEach((data, index) => {  //tr 테그에 td 테그를 append 하여 줍니다.
                    let {idx, url_name, url_desc, reg_date, upd_date} = data;
                    let item = $('<tr/>').append(
                        $('<td/>').addClass('').text(getNumbering(result, index)),
                        $('<td/>').append($('<input type="text">').val(url_name).addClass('url_name form-control')),
                        $('<td/>').append($('<input type="text">').val(url_desc).addClass('url_desc form-control')),
                        $('<td/>').text(reg_date),
                        $('<td/>').text(upd_date),
                        $('<td/>').append(

                            $('<div>').addClass('dj-btn-group-center').append( // .btn-group 부모 요소 추가
                                $('<input type="button">').addClass('btn dj-btn-outline-green btn-sm').val('수정하기').click(function () {
                                    updateData($(this), idx);
                                }),
                                $('<input type="button">').addClass('btn dj-btn-outline-red btn-sm').val('삭제하기').click(function () {
                                    removeDat(idx);
                                })
                            )
                        )

                    );
                    $('#showTable').append(item);  //tr 테그에 append된 td테그객체를 그려줄 tbody에  append합니다.
                });
            }
        }

        //Ajax를 통해 데이터를 받아온 뒤 콜백함수인 viewer를 실행 합니다.
        buildTable(listUrl, param, viewer);
        $(".pagination li:last-child").prev().addClass('next');
        //등록 모달영역을 실행 합니다.
        $('#showModal').click(() => $('#insertModal').modal('show'));

        //모달 영역에서 "저장" 버튼을 누르는 경우 Form테그의 input 값을 가져와 DB에 등록 합니다.
        $('#insertData').click(() => {
            if (!confirm('추가합니까?')) return;
            let form = $('#insertForm').serializeArray();
            let query = {};
            form.forEach(arg => query[arg.name] = arg.value);
            commonAjax(insertUrl, query, res => {
                console.log(res)
                buildTable(listUrl, param, viewer);
            });
        });

        //"수정하기" 버튼을 누르면 동작 합니다.
        function updateData(node, seq) {
            let query = {}
            node.parent().parent().find('input').each(function () {  //input 값을 가져와서
                let name = $(this).attr('class');
                name = name.replace(' form-control', '');  //form-control 클래스이름을 제거한 뒤에
                query[name] = $(this).val();  //해당 클래스의 이름을 key, 해당 테그의 value를 값으로 사용하여줍니다.
            })
            query.idx = seq;  //수정을 위한 고유 인덱스 값을 넣어 줍니다.
            if (!confirm('수정 합니까?')) return;
            commonAjax(updateUrl, query, res => {
                buildTable(listUrl, param, viewer);
            });
        }

        //"삭제하기" 버튼을 누르면 동작 합니다.
        function removeDat(idx) {
            if (!confirm('삭제 합니까?')) return;
            commonAjax(deleteUrl, {idx}, res => {
                buildTable(listUrl, param, viewer);
            });
        }

    });


</script>
