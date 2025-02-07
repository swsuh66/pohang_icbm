/**
 * 
 */

var olUtil = {};

olUtil.simbolUrl = function(kindCode, meas) {
	//var kindCode = '1';//row.kindCode;
	var state = 'BLACK';
	var opt ='';

	var valid = (meas && meas.obsValid == '1');
	switch(kindCode) {
	case '0':
	case 'Z':
		if(valid)
			state = (meas.obsLvl > 0) ? 'BLUE' : 'GREY';
		opt = 'S2_01_';
		break;
	case '1': 
		if(valid)
			state = (meas.obsRatStat) ? meas.obsRatStat : 'GREY';
		opt = 'S1_01_';
		break;
	}

	return 'Point_' + opt + state +'.png';
}

olUtil.labelValue = function(kindCode, meas) {
	value = '';
	
	if(!meas || meas.obsValid != '1')
		return value;
	
	switch(kindCode) {
	case '0':
	case 'Z':
		if(meas && kutil.isValidNumber(meas.obsLvl))
			value += meas.obsLvl +' m';
		break;
	case '1':
		if(meas)
			value = kutil.v2n(meas.obsRat, 1) +' %, '+ kutil.v2n(meas.obsLvl, 2) +' m';
		break;
	}
	return value;
}
