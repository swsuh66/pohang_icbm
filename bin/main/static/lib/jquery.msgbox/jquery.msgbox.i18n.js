/**
 * Internationalization of jquery.msgbox
 * Add this file to HTML head before jquery.msgbox
 */
 
(function ($) {

	$.msgboxI18N = {};

	$.msgboxI18N.co_KR = {
		OK: '확인',
		Cancel: '취소',
		Loading: '로딩중',
		Next: '다음',
		'Play/Pause': '재쟁/중지',
		Prev: '이전',
		Maximize: '최대화',
		Minimize: '최소화',
		Close: '닫기',
		imgError: '이미지오류',
		xhrError: '데이터로딩오류'
	};
	

	// Simplified Chinese
	$.msgboxI18N.zh_CN = {
		OK: '好',
		Cancel: '取消',
		Loading: '正在加载',
		Next: '下一张',
		'Play/Pause': '播放/暂停',
		Prev: '上一张',
		Maximize: '最大化',
		Minimize: '最小化',
		Close: '关闭',
		imgError: '图片加载失败！',
		xhrError: 'Ajax请求失败！'
	};
	
	// Tranditional Chinese
	$.msgboxI18N.zh_TW = {
		OK: '好',
		Cancel: '取消',
		Loading: '正在加載',
		Next: '下一張',
		'Play/Pause': '播放/暫停',
		Prev: '上一張',
		Maximize: '最大化',
		Minimize: '最小化',
		Close: '關閉',
		imgError: '圖片加載失敗！',
		xhrError: 'Ajax請求失敗！'
	};
	

})(jQuery);