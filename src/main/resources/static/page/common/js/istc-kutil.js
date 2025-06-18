/**
 * @function dateFormat
 * @param {date} date
 * @param {string} mask format string
 * @param {boolean} utc
 * @description date-format class
 * (c) 2007-2009 Steven Levithan <stevenlevithan.com>
 * MIT license
 *
 * Includes enhancements by Scott Trenda <scott.trenda.net>
 * and Kris Kowal <cixar.com/~kris.kowal/>
 *
 * Accepts a date, a mask, or a date and a mask.
 * Returns a formatted version of the given date.
 * The date defaults to the current date/time.
 * The mask defaults to dateFormat.masks.default.
 */

var dateFormat = (function () {
	var token = /d{1,4}|m{1,4}|yy(?:yy)?|([HhMsTt])\1?|[LloSZ]|"[^"]*"|'[^']*'/g,
		timezone = /\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g,
		timezoneClip = /[^-+\dA-Z]/g,
		pad = function (val, len) {
			val = String(val);
			len = len || 2;
			while (val.length < len) val = '0' + val;
			return val;
		};

	// Regexes and supporting functions are cached through closure
	return function (date, mask, utc) {
		var dF = dateFormat;

		// You can't provide utc if you skip other args (use the "UTC:" mask prefix)
		if (arguments.length == 1 && Object.prototype.toString.call(date) == '[object String]' && !/\d/.test(date)) {
			mask = date;
			date = undefined;
		}

		// Passing date through Date applies Date.parse, if necessary
		date = date ? new Date(date) : new Date();
		if (isNaN(date)) return '-'; //throw SyntaxError("invalid date");

		mask = String(dF.masks[mask] || mask || dF.masks['default']);

		// Allow setting the utc argument via the mask
		if (mask.slice(0, 4) == 'UTC:') {
			mask = mask.slice(4);
			utc = true;
		}

		var _ = utc ? 'getUTC' : 'get',
			d = date[_ + 'Date'](),
			D = date[_ + 'Day'](),
			m = date[_ + 'Month'](),
			y = date[_ + 'FullYear'](),
			H = date[_ + 'Hours'](),
			M = date[_ + 'Minutes'](),
			s = date[_ + 'Seconds'](),
			L = date[_ + 'Milliseconds'](),
			o = utc ? 0 : date.getTimezoneOffset(),
			flags = {
				d: d,
				dd: pad(d),
				ddd: dF.i18n.dayNames[D],
				dddd: dF.i18n.dayNames[D + 7],
				m: m + 1,
				mm: pad(m + 1),
				mmm: dF.i18n.monthNames[m],
				mmmm: dF.i18n.monthNames[m + 12],
				yy: String(y).slice(2),
				yyyy: y,
				h: H % 12 || 12,
				hh: pad(H % 12 || 12),
				H: H,
				HH: pad(H),
				M: M,
				MM: pad(M),
				s: s,
				ss: pad(s),
				l: pad(L, 3),
				L: pad(L > 99 ? Math.round(L / 10) : L),
				t: H < 12 ? 'a' : 'p',
				tt: H < 12 ? 'am' : 'pm',
				T: H < 12 ? 'A' : 'P',
				//TT:   H < 12 ? "AM" : "PM",
				TT: H < 12 ? '오전' : '오후',
				Z: utc ? 'UTC' : (String(date).match(timezone) || ['']).pop().replace(timezoneClip, ''),
				o: (o > 0 ? '-' : '+') + pad(Math.floor(Math.abs(o) / 60) * 100 + (Math.abs(o) % 60), 4),
				S: ['th', 'st', 'nd', 'rd'][d % 10 > 3 ? 0 : (((d % 100) - (d % 10) != 10) * d) % 10],
			};

		return mask.replace(token, function ($0) {
			return $0 in flags ? flags[$0] : $0.slice(1, $0.length - 1);
		});
	};
})();

// Some common format strings
dateFormat.masks = {
	default: 'ddd mmm dd yyyy HH:MM:ss',
	shortDate: 'm/d/yy',
	mediumDate: 'mmm d, yyyy',
	longDate: 'mmmm d, yyyy',
	fullDate: 'dddd, mmmm d, yyyy',
	shortTime: 'h:MM TT',
	mediumTime: 'h:MM:ss TT',
	longTime: 'h:MM:ss TT Z',
	isoDate: 'yyyy-mm-dd',
	isoTime: 'HH:MM:ss',
	isoDateTime: "yyyy-mm-dd'T'HH:MM:ss",
	isoUtcDateTime: "UTC:yyyy-mm-dd'T'HH:MM:ss'Z'",
};

// Internationalization strings
dateFormat.i18n = {
	dayNames: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
	monthNames: [
		'Jan',
		'Feb',
		'Mar',
		'Apr',
		'May',
		'Jun',
		'Jul',
		'Aug',
		'Sep',
		'Oct',
		'Nov',
		'Dec',
		'January',
		'February',
		'March',
		'April',
		'May',
		'June',
		'July',
		'August',
		'September',
		'October',
		'November',
		'December',
	],
};

// For convenience...
/*Date.prototype.format = function (mask, utc) {
	return dateFormat(this, mask, utc);
};
*/
String.prototype.trim = function () {
	return this.replace(/(^\s*)|(\s*$)/gi, '');
};

/**
 * @namespace {object} kutil
 * @description 공용 Functions
 */
var kutil = {};

/**
 * @method kuti.addHours
 * @param {Date} date
 * @param {Number} hours
 * @returns {Date}
 */
kutil.addHours = function (date, hours) {
	var dat = new Date(date.valueOf());
	dat.setTime(dat.getTime() + hours * 60 * 60 * 1000);
	return dat;
};

/**
 * @method kutil.addDays
 * @description Date 에 일(day)을 더하거나 빼서 반환합니다.
 * @param {Date} date
 * @param {Number} days
 * @returns {Date}
 */
kutil.addDays = function (date, days) {
	var dat = new Date(date.valueOf());
	dat.setDate(dat.getDate() + days);
	return dat;
};

/**
 * @method kutil.addDays
 * @description Date 에 월(month)를 더하거나 빼서 반환합니다.
 * @param {Date} date
 * @param {Number} days
 * @returns {Date}
 */
kutil.addMonth = function (date, days) {
	var dat = new Date(date.valueOf());
	dat.setMonth(dat.getMonth() + days);
	return dat;
};

/**
 * @method kutil.truncDate
 * @description Date 를 년/월/일/시간 단위로 절사해서 반환.
 * @param {Date} date
 * @param {String} val 절사 단위 ('y'/'m'/'d'/'h') *소문자*
 * @returns {Date}
 */
kutil.truncDate = function (date, val) {
	var d = new Date(date.valueOf());
	switch (val) {
		case 'y':
			d.setHours(0, 0, 0, 0);
			d.setDate(1);
			d.setMonth(0);
			break;
		case 'm':
			d.setHours(0, 0, 0, 0);
			d.setDate(1);
			break;
		case 'd':
			d.setHours(0, 0, 0, 0);
			break;
		case 'h':
			d.setHours(date.getHours(), 0, 0, 0);
			break;
	}
	return d;
};

/**
 * @method kutil.lpad
 * @description 문자열(pad)을 마스크(str) 오른쪽에 overlay(대입)하여 반환
 * @param {String} pad left-padding 할 문자열
 * @param {String} str 마스크 문자열
 * @example kutil.lpad('abc', '00000') -> '00abc'
 * @returns {String}
 */
kutil.lpad = function (pad, str) {
	return (pad + str).slice(-pad.length);
};
kutil.rpad = function (pad, str) {
	return (str + pad).substring(0, pad.length);
};

kutil.isValidNumber = function (val) {
	return val == null || !isFinite(val) ? false : true;
};

kutil.v2n = function (value, decimal, def) {
	return value == null || !isFinite(value) ? def || '-' : kutil.numberFormat(value.toFixed(decimal));
};

kutil.numberFormat = function (x) {
	var parts = x.toString().split('.');
	parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
	return parts.join('.');
};

kutil.isValidDate = function (dateString) {
	var regEx = /^\d{4}-\d{1,2}-\d{1,2}$/;
	if (!dateString.match(regEx)) return false; // Invalid format
	var d = new Date(dateString);
	if (!d.getTime()) return false; // Invalid date (or this could be epoch)
	return d.toISOString().slice(0, 10) === dateString;
};

var _MS_PER_DAY = 1000 * 60 * 60 * 24;

// a and b are javascript Date objects
kutil.dateDiffInDays = function (a, b) {
	// Discard the time and time-zone information.
	var utc1 = Date.UTC(a.getFullYear(), a.getMonth(), a.getDate());
	var utc2 = Date.UTC(b.getFullYear(), b.getMonth(), b.getDate());

	return Math.floor(Math.abs(utc2 - utc1) / _MS_PER_DAY);
};

kutil.dateFormat = function (x, y, z) {
	if (!x) return '-';
	if (typeof x === 'number') x = new Date(x);
	return dateFormat(x, y, z);
};

kutil.formatDate = function (tm) {
	if (tm) return tm.substr(0, 4) + '.' + tm.substr(4, 2) + '.' + tm.substr(6, 2);
	return tm;
};
kutil.formatDateTime = function (tm) {
	var ret = kutil.formatDate(tm);
	if (!ret) return ret;
	if (tm.length > 8) ret += ' ' + tm.substr(8, 2);
	if (tm.length > 10) ret += ':' + tm.substr(10, 2);
	if (tm.length > 12) ret += ':' + tm.substr(12, 2);
	return ret;
};

kutil.findItem = function (list, prop, value) {
	if (list && prop) {
		for (var i = 0; i < list.length; i++) {
			if (list[i][prop] == value) return list[i];
		}
	}
	return null;
};

kutil.countSub = function (list, fields, index) {
	var cnt = 1;
	var vals = [];
	for (var f = 0; f < fields.length; f++) {
		vals.push(list[index][fields[f]]);
	}
	for (var i = index + 1; i < list.length; i++) {
		for (var f = 0; f < fields.length; f++) {
			if (list[i][fields[f]] != vals[f]) return cnt;
		}
		cnt++;
	}
	return cnt;
};

kutil.repeat = function (str, repeat) {
	var rst = '';
	while (repeat-- > 0) {
		rst += str;
	}
	return rst;
};

kutil.iframeWindow = function (iframe_object) {
	var doc;

	if (iframe_object.contentWindow) {
		return iframe_object.contentWindow;
	}

	if (iframe_object.window) {
		return iframe_object.window;
	}

	if (!doc && iframe_object.contentDocument) {
		doc = iframe_object.contentDocument;
	}

	if (!doc && iframe_object.document) {
		doc = iframe_object.document;
	}

	if (doc && doc.defaultView) {
		return doc.defaultView;
	}

	if (doc && doc.parentWindow) {
		return doc.parentWindow;
	}

	return undefined;
};

//Data DownLoad
function templetDownLoad(data, pCallback, sCallback, fCallback) {
	var con = {
		httpMethod: 'post',
		data: data,
		contentType: 'application/json;charset=UTF-8',
		successCallback: function (url) {
			if (sCallback) sCallback();

			console.log(data.downloadFileName + ' 다운로드 완료');
			//jLoading.stop();
		},
		prepareCallback: function (url) {
			if (pCallback) pCallback();

			console.log(data.downloadFileName + ' 다운로드 시작');
		},
		failCallback: function (responseHtml, url, err) {
			if (fCallback) fCallback(err);

			console.log(data.downloadFileName + ' 다운로드 중 장애발생');
		},
	};

	var path = getContextPath() + '/file/templeteSXSSF';
	console.log('path', path);
	$.fileDownload(path, con);
}

//Data DownLoad
function templetDownLoadDat(data, pCallback, sCallback, fCallback) {
	var con = {
		httpMethod: 'post',
		data: data,
		contentType: 'application/json;charset=UTF-8',
		successCallback: function (url) {
			if (sCallback) sCallback();

			console.log(data.downloadFileName + ' 다운로드 완료');
			//jLoading.stop();
		},
		prepareCallback: function (url) {
			if (pCallback) pCallback();

			console.log(data.downloadFileName + ' 다운로드 시작');
		},
		failCallback: function (responseHtml, url, err) {
			if (fCallback) fCallback(err);

			console.log(data.downloadFileName + ' 다운로드 중 장애발생');
		},
	};

	var path = getContextPath() + '/file/downloadDat';
	console.log('path', path);
	$.fileDownload(path, con);
}

// AlrimTok DownLoad
function alrimtokDownLoad(data, pCallback, sCallback, fCallback) {
	var con = {
		httpMethod: 'post',
		data: data,
		contentType: 'application/json;charset=UTF-8',
		successCallback: function (url) {
			if (sCallback) sCallback();

			console.log(data.downloadFileName + ' 다운로드 완료');
			//jLoading.stop();
		},
		prepareCallback: function (url) {
			if (pCallback) pCallback();

			console.log(data.downloadFileName + ' 다운로드 시작');
		},
		failCallback: function (responseHtml, url, err) {
			if (fCallback) fCallback(err);

			console.log(data.downloadFileName + ' 다운로드 중 장애발생');
		},
	};

	var path = getContextPath() + '/file/templateAlrimTok';
	console.log('path', path);
	$.fileDownload(path, con);
}
