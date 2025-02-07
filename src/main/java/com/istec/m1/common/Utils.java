package com.istec.m1.common;

import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

/////////////////////////////////////////////
/// @class Utils
///com.istec.m1.wmeter.util \n
///   ㄴ Utils.java
/// @section 클래스작성정보
///    |    항  목       |      내  용       |
///    | :-------------: | -------------   |
///    | Company | ISTEC |    
///    | Author | Mona Park |
///    | Date | Jul 27, 2017 6:02:40 PM |
///    | Class Version | v1.0 |
///    | 작업자 | Mona Park, Others... |
/// @section 공통 유틸리티 클래스 
/// - 공통 라이브러리 클래스
///   -# ㅇㅇ
/////////////////////////////////////////////
public class Utils {

	public static String getToday() {
		Date now = new Date();
		SimpleDateFormat simpleFormat = new SimpleDateFormat("yyyyMMdd");
		return simpleFormat.format(now);
	}
	
	public static String getTime() {
		/*Date now = new Date();		
		SimpleDateFormat simpleFormat = new SimpleDateFormat("HH");
		return simpleFormat.format(now)+"00";*/
		
		Calendar cal = Calendar.getInstance();
		int hh = cal.get(Calendar.HOUR_OF_DAY);
		int mm = cal.get(Calendar.MINUTE);
		if (mm < 30) --hh;
		
		return ""+hh;
	}
	
	public static String rightPadWithZeros(String str) {
		return ("00" + str).substring((""+str).length())+"00";
	}
	
	public static Object transDataForm(Object r, String v) {	

		if ( r instanceof Integer ) {			
			return Integer.parseInt(v);			
		}	
		else if( r instanceof Long ) {			
			return Long.parseLong(v);			
		}
		else if( r instanceof Float ) {			
			return Float.parseFloat(v);			
		}
		else if( r instanceof Double ) {		
			return Double.parseDouble(v);			
		}
		/*else if( r instanceof BigDecimal ) {	
			BigDecimal n = (BigDecimal)r;
			return n.signum() == 0 ? 1 : n.precision() - n.scale();
		}*/
		else if( r instanceof BigDecimal ) {	
			return  new BigDecimal(v);			
		}
		
		return v;		
	}
	
	public static Object transDataForm(Object r, Object v) {	

		if ( r instanceof Integer ) {			
			return (Integer) v;			
		}	
		else if( r instanceof Long ) {			
			return (Long) v;			
		}
		else if( r instanceof Float ) {			
			return (Float) v;	
		}
		else if( r instanceof Double ) {		
			return (Double) v;		
		}
		/*else if( r instanceof BigDecimal ) {	
			BigDecimal n = (BigDecimal)r;
			return n.signum() == 0 ? 1 : n.precision() - n.scale();
		}*/
		else if( r instanceof BigDecimal ) {	
			return (BigDecimal) v;		
		}

		
		return v;		
	}
	
	public static Object trim(Object v) {

		if ( v instanceof String ) {
			
			String str = (String) v;
			
			return str.replaceAll("\\p{Z}", "");					
		}	
				
		return v;		
	}

}
