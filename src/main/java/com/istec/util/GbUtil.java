package com.istec.util;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Calendar;

/*
[ alltoHIM (my nick) ]
@ file Name      : GbUtil.java
@ title          : 개발팀 사용 util class
@ desc           : -
@ author         : gyubeom_park (god3se@gmail.com)
@ date           : 2022.03.31
*/
public class GbUtil {
	
	
	
	//========== # file : start ==========
	
	/*
	 * @param : filePath
	 * */
	public static void deleteFile(String filePath) {
		(new File(filePath)).delete();
	}
	
	//========== file : end ==========
	
	
	
	//========== # common : start ==========
	
	/*
	 * @param : 
	 * - timeUnit : year, month, day, hour, minute, second
	 * */
	public static String getTime(String timeUnit) {
		String unit = "";
		
		switch(timeUnit) {
			case "year":
				unit = "yyyy";
				break;
			case "month":
				unit = "yyyyMM";
				break;
			case "day":
				unit = "yyyyMMdd";
				break;
			case "hour":
				unit = "yyyyMMddHH";
				break;
			case "minute":
				unit = "yyyyMMddHHmm";
				break;
			case "second":
			default:
				unit = "yyyyMMddHHmmss";
				break;
		}
		
		return new SimpleDateFormat(unit).format(Calendar.getInstance().getTime());
		
	}
	
	//========== common : end ==========
	
	
	
}
