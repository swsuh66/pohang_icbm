package com.istec.m1.service;


import java.util.HashMap;
import java.util.Random;
import java.util.function.BiConsumer;
import java.util.function.BiFunction;


/***
 * 페이징 처리를 위한 공통 컴포넌트<br>
 * 갯수를 토대로 페이징과 관련된 값을 리턴한다.
 * */
public class PageUtilBean {
	
	public static final String CURPAGE = "curPage";
	public static final String PAGESIZE = "pageSize";
	public static final String ROWSIZE = "ROWSIZE";

	

	public static int checkData(Object obj){
		try{
			int num = Integer.parseInt(obj.toString()) - 1;
			return num <0 ? 1 : num;
		}catch(Exception e){
			
		}
		return 0;
	}	

	/*param 확장(페이지 정보 추가) 함수인터페이스<br>
	 * HashMap<Object,Object> param 기본 요청 정보가 담긴 HashMap<br>
	 * Float total param 정보를 통해 얻은 데이터의 총 개수 
	 * */
	public static BiFunction<Object,Float,Float> FLOAT_NVL = (str,value) -> str != null&&str.toString().trim().length() > 0?Float.parseFloat(str.toString()):value;
	public static BiFunction<Object,Integer,Integer> INTEGER_NVL = (str,value) -> str != null&&str.toString().trim().length() > 0?Integer.parseInt(str.toString()):value;
	
	
	
	public static BiConsumer<HashMap<Object,Object>,Integer> EXTEND_PARAM = (param,total) ->{
		float pageSize = FLOAT_NVL.apply(param.get("pageSize"), 10f);	// 한 페이지에서 보여줄 개수
		int rowSize = INTEGER_NVL.apply(param.get("rowSize"), 10);	// 한 페이지에서 보여줄 개수
		float curPage = FLOAT_NVL.apply(param.get("curPage"), 0f);	// 한 페이지에서 보여줄 개수
		int pgCnt = (int) Math.ceil(total / pageSize);  //페이지 갯수  
		if(rowSize > pgCnt){  //총 갯수 오버 방지
			rowSize = pgCnt;
		}
		int devide = (int) Math.ceil(((float)(curPage+1)/(float)rowSize));  //기준체크		
		int start = ((devide)*rowSize) - (rowSize-1); // 해당페이지에서 시작번호(step2) 
		int end = (devide)*rowSize; // 해당페이지에서 끝번호(step2)		
		if(end > pgCnt){  //최종 넘어가는 갯수 오버 방지
			end = pgCnt;
		}
		
		param.put("firstPage", (int)(curPage * pageSize));
		param.put("pgCnt", pgCnt);
		param.put("curPage", curPage);
		param.put("pageSize", (int)pageSize);
		param.put("start",start);
		param.put("end", end);
		param.put("totCnt", total);
	};
	
	/**
	 * 유니크한 문자를 생성 합니다.
	 * **/
	public static String getUniqueIdx(int targetStringLength) {
		if(targetStringLength <= 0 || targetStringLength > 51) targetStringLength = 50;
		int leftLimit = 48; // numeral '0'
		int rightLimit = 122; // letter 'z'
		Random random = new Random();

		String generatedString = random.ints(leftLimit,rightLimit + 1)
		  .filter(i -> (i <= 57 || i >= 65) && (i <= 90 || i >= 97))
		  .limit(targetStringLength)
		  .collect(StringBuilder::new, StringBuilder::appendCodePoint, StringBuilder::append)
		  .toString();		
		return generatedString;
	}		
}
