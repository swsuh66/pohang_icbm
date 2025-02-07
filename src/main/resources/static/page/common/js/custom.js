$(document).ready(function () {
    // .nav-link를 클릭했을 때
    $(".nav-link").click(function () {
        // .custom-sidebar에 .collapsed 클래스가 있는지 확인
        var isCollapsed = $(".custom-sidebar").hasClass("collapsed");

        // .collapsed 클래스가 있을 경우
        if (isCollapsed) {
            // 하위 메뉴를 펼치지 않음
            return;
        }

        // .custom-nav-navbar를 토글
        var subMenu = $(this).next(".custom-nav-navbar");
        if (subMenu.length > 0) {
            subMenu.toggle();
            $(this).toggleClass("active");
        }
    });

    // 사이드바 토글 버튼 클릭 시
    $(".btn-toggle-sidebar").click(function () {
        // .custom-sidebar에 .collapsed 클래스를 토글
        $(".custom-sidebar").toggleClass("collapsed");

        // .collapsed 클래스의 유무에 따라 하위 메뉴 동작을 조정
        if ($(".custom-sidebar").hasClass("collapsed")) {
            // .collapsed 클래스가 추가된 경우, 모든 하위 메뉴를 닫음
            $(".custom-nav-navbar").hide();
            $(".nav-link").removeClass("active");
        }
    });

    // 아코디언
    // 처음에 열리는 아코디언 아이템을 활성화
    $(".accordion-item.active .accordion-content").slideDown();
    // 나머지 아코디언 아이템에 대한 클릭 이벤트 처리
    $(".accordion-header").click(function () {
        var accordionItem = $(this).parent();

        // $(".accordion-item")
        //     .not(accordionItem)
        //     .find(".accordion-content")
        //     .slideUp();
        // $(".accordion-item").not(accordionItem).removeClass("active");

        accordionItem.find(".accordion-content").slideToggle();
        accordionItem.toggleClass("active");
    });

});

