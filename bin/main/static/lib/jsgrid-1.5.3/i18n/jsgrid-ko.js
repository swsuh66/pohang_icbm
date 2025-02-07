(function(jsGrid) {

    jsGrid.locales.es = {
        grid: {
            noDataContent: "데이터가 없습니다.",
            deleteConfirm: "삭제하시겠습니까?",
            pagerFormat: "{first} {prev} {pages} {next} {last} &nbsp;&nbsp; {pageIndex} de {pageCount}",
            pagePrevText: "이전",
            pageNextText: "다음",
            pageFirstText: "처음",
            pageLastText: "마지막",
            loadMessage: "데이터 읽는 중",
            invalidMessage: "데이터 오류"
        },

        loadIndicator: {
            message: "읽는중..."
        },

        fields: {
            control: {
                searchModeButtonTooltip: "검색모드",
                insertModeButtonTooltip: "추가모드",
                editButtonTooltip: "수정",
                deleteButtonTooltip: "삭제",
                searchButtonTooltip: "검색",
                clearFilterButtonTooltip: "필터리셋",
                insertButtonTooltip: "추가",
                updateButtonTooltip: "지우기",
                cancelEditButtonTooltip: "취소"
            }
        },

        validators: {
            required: { message: "필수입력입니다." },
            rangeLength: { message: "글자 길이가 범위를 벗어 났습니다." },
            minLength: { message: "최소 글자길이보다 작습니다." },
            maxLength: { message: "최대 글자길이보다 큽니다." },
            pattern: { message: "입력 ㄱ밧 패턴에 맞지 않습니다." },
            range: { message: "입력 값의 범위를 벗어 났습니다." },
            min: { message: "최소값보다 더 작습니다." },
            max: { message: "최대값보다 더 큽니다." }
        }
    };

}(jsGrid, jQuery));
