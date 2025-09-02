package com.istec.m1.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.poi.EncryptedDocumentException;
import org.apache.poi.openxml4j.exceptions.InvalidFormatException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import com.istec.m1.auth.CustomUserDetails;
import com.istec.m1.common.JacksonParsing;
import com.istec.m1.common.Utils;
import com.istec.m1.defines.Define;
import com.istec.m1.defines.FileType;
import com.istec.m1.defines.StatusCode;
import com.istec.m1.dto.UploadFile;
import com.istec.m1.manager.DBAccessManager;
import com.istec.m1.manager.FileManager;
import com.istec.m1.service.FileService;
import com.istec.m1.service.QueryService;
import com.istec.m1.exception.ExcelProcessingException;

@Controller
public class FileController {

	private Logger logger = LoggerFactory.getLogger(FileController.class);

	@Autowired
	private FileService fileService;
	@Autowired
	private QueryService queryService;
	
	//@Value("#{config['file.expireInterval']}") protected long interval;
	protected long interval = 600000;
	
	/**
	 * 파일 업로드하여 메모리에 저장
	 */	
	//@RequestMapping(value = "/**/file/upload", method = RequestMethod.POST)
	@RequestMapping(value = "/file/upload", method = RequestMethod.POST)
	public @ResponseBody Map<String, Object> fileUpload(UploadFile dto, 
			HttpServletRequest request, HttpServletResponse response) throws Exception {
		HttpSession session = request.getSession(false);		
		Map<String, Object> resData = new HashMap<String, Object>();
		List<List<String>> parData = null;	
		MultipartFile file = dto.getFile_info();	
		try {
			FileType fileType = FileType.valueOf( dto.getFileType() );
			switch (fileType) {	
				case EXCEL:  parData = fileService.excelRead(file);
					break;
				case CSV  : 
				case TXT  :  parData = fileService.txtRead(file, 
										dto.getDelimeter(), dto.getEncodingType());
					break;
			}	
			if(parData == null || parData.size() < 1) {
				response.setStatus(StatusCode.STATUS_UNSUPPORTED_MEDIA_TYPE.getValue());
				return null;
			}	
			String sessionId = session.getId();
			String key = UUID.randomUUID().toString();
			FileManager.getInstance().setDataInfo(sessionId, key, parData, interval);
			int cutIndex = 5;
			if(parData.size() < 5) {
				cutIndex = parData.size();
			}
			resData.put(Define.Key.TOKEN_KEY, key);
			resData.put(Define.Key.DATA, parData.subList(0, cutIndex));
		} catch (RuntimeException e) {
			response.setStatus(StatusCode.STATUS_INTERNAL_SERVER_ERROR.getValue());
			e.printStackTrace();
		}
		return resData;
	}
	
	/**
	 * 파일임포트를 위한 xml 파일을 읽어전달
	 */
	@RequestMapping(value = "/file/dbParams/{sourceID}", method = RequestMethod.GET)	
	public @ResponseBody Map<String, Object> getDBparams(@PathVariable String sourceID, 
			HttpServletRequest request) {
		String templetPath = request.getSession().getServletContext().
				getRealPath("/resources/reftb/tableInfo-config.xml");
		Map<String, Object> dbInfo = fileService.xmlRead(templetPath, sourceID);
		return dbInfo;			
	}
	
	/**
	 * 최종 저장
	 * @throws Exception
	 */
//	@RequestMapping(value = "/**/confirmData", method = RequestMethod.POST)
	@RequestMapping(value = "/confirmData", method = RequestMethod.POST)
	@Transactional(propagation=Propagation.REQUIRED,  rollbackFor=Exception.class)
	public @ResponseBody List<HashMap<String, Object>> confirmData(Model model, 
			HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		logger.info("start confirmData");
		HttpSession session = request.getSession(false);		
		CustomUserDetails userDetails = (CustomUserDetails) session.getAttribute(Define.Key.LOGIN_INFO);
		int siteSq = userDetails.getSiteSq();
		Map<String, Object> siteMap = null;
		DBAccessManager dm = DBAccessManager.getInstance();
		FileManager fm = FileManager.getInstance();
		String sessionId = session.getId();
		String key = null;
		String exSql = null;
		String referSql = null;
		String afterSql = null;
		List<List<String>> data = null;
		Map<String, Object> mappingInfo = null;
		try {
			String body = ControllerHelper.readRequestBody(request);
			if(body == null || body.isEmpty()) {
				return null;
			}
			mappingInfo = JacksonParsing.toList(body).get(0);
			exSql = (String) mappingInfo.get(Define.Key.EX_SQL);
			key = (String) mappingInfo.get(Define.Key.TOKEN_KEY);
			referSql = (String) mappingInfo.get(Define.Key.REFER_SQL);		
			afterSql = (String) mappingInfo.get(Define.Key.AFTER_SQL);
			siteMap = new HashMap<String, Object>();
			siteMap.put(Define.Key.TOKEN_KEY, key);
			if( dm.getDBAccessInfo().contains(exSql) ) {
				response.setStatus(StatusCode.STATUS_METHOD_NOT_ALLOWED.getValue());
				return null;
			}
			dm.setDBAccessInfo(exSql);
			Object tmpData = fm.getDataInfo(session.getId(), key);
			if(tmpData == null) {
				response.setStatus(StatusCode.STATUS_NOT_FOUND.getValue());
				return null;
			}
			data = (List<List<String>>) tmpData;
			List<HashMap<String, Object>> dbTmpData = queryService.select(referSql);
			if(dbTmpData == null || dbTmpData.isEmpty()) {
				response.setStatus(StatusCode.STATUS_NOT_IMPLEMENTED.getValue());
				return null;
			}
			HashMap<String, Object> referData = findReferData(dbTmpData);
			if(referData == null) {
				response.setStatus(StatusCode.STATUS_NOT_IMPLEMENTED.getValue());
				return null;
			}
			List<Map<String, Object>> result = mappingData(data, referData, mappingInfo);
			for (Map<String, Object> item : result) {
	    		item.put(Define.Key.TOKEN_KEY, key);
	    		item.put(Define.Key.UP_SITE_SQ, siteSq);
	    	}
			queryService.insert(exSql, result);
		} catch (Exception e) {
			response.setStatus(StatusCode.STATUS_CUST_ERROR.getValue());
			response.setHeader("errMsg", e.getMessage());
			e.printStackTrace();
			throw e;
		} finally {
			dm.removeDBAccessInfo(exSql);
			fm.resetTimer(sessionId, key, interval);
		}
		if(fm.cancelTimer(sessionId, key)) {
			fm.removeData(sessionId, key);
		}
		response.setStatus(StatusCode.STATUS_OK.getValue());
		return queryService.select(afterSql, siteMap);
	}
	
	/**
	 * 데이터 매핑
	 */
	private List<Map<String, Object>> mappingData(List<List<String>> data, 
			Map<String, Object> dbData, Map<String, Object> mappingInfo) {
		List<Map<String, Object>> result = new ArrayList<Map<String, Object>>();
		List<Object> mapping = (List<Object>) mappingInfo.get(Define.Key.COL_MAPPING);
		int strRow = (int) mappingInfo.get(Define.Key.START_ROW);
		int trim = (int) mappingInfo.get(Define.Key.TRIM);
		Map<String, Object> map = null;
		if(strRow > data.size()) { 
			return null;		
		}
		for(int i=strRow-1; i<data.size(); i++) {
			List<String> item = data.get(i);			
			map = new HashMap<String, Object>();
			for(Object obj : mapping) {
				Map<String, Object> objItem = (Map<String, Object>) obj;
				String key = (String) objItem.get(Define.Key.ID);	
				int index = (Integer) objItem.get(Define.Key.INDEX);
				if(item.size() <= index) break; 
				String val = item.get(index);
				if(val != null) {
					if(dbData.containsKey(key)) {
						Object referDt = dbData.get(key);
						Object dt = Utils.transDataForm(referDt, val);
						if(trim == 1 && dt instanceof String) { 
							dt = ((String)dt).trim();
						}
						map.put(key, dt);
					}
				}
			}
			result.add(map);
		}
		return result;
	}
	
	/**
	 * 참조 데이터 찾기
	 */
	private HashMap<String, Object> findReferData(List<HashMap<String, Object>> data) {
		boolean isOk = true;
		for (HashMap<String, Object> item : data) {
			isOk = true;
			for( String key : item.keySet() ){
				Object val = item.get(key);
				if(val == null) {
					isOk = false;
					break;
				}
			}
			if(isOk) {
				return item;
			}
		}
		return null;
	}
	
	/**
	 * 파일 다운로드 SXSSF
	 */
	//@RequestMapping(value = "/**/file/templeteSXSSF", method= RequestMethod.POST)
	@RequestMapping(value = "/file/templeteSXSSF", method= RequestMethod.POST)
	public void execelTempletSXSSF(Map<String,Object> modelMap , 
			HttpServletRequest request, HttpServletResponse response) throws IOException, EncryptedDocumentException, InvalidFormatException {

		List<Object> mappingList = new ArrayList<Object>();
		List<HashMap<String, Object>> data = null;
		Map<String, Object> mappingInfo = null;		
		Map<String, Object> selMap = makeParames(request);
		String fileName = (String)selMap.get(Define.Key.FILE_NAME);
		String length = (String)selMap.get(Define.Key.LENGTH);
		String qid = (String)selMap.get(Define.Key.QID);		
		String url = (String)selMap.get(Define.Key.URL);
		
		

		for(int i = 0 ; i < Integer.parseInt(length); i++) {
			mappingInfo = new HashMap<>();
			String value = (String)selMap.get("colMapping[" + i + "][name]");
			String title = (String)selMap.get("colMapping[" + i + "][title]");
			mappingInfo.put("name", value);
			mappingInfo.put("title", title);
			mappingList.add(mappingInfo);
		}
		data = queryService.select(qid, selMap);		
		// data = url != null && !url.isEmpty() ?  getAlrimTokData(selMap, url) : queryService.select(qid, selMap);

		fileService.excelCreateSXSSF(response, mappingList, data, fileName);
	}

	public List<HashMap<String, Object>> getAlrimTokData(Map<String, Object> params, String url) {
        System.out.println("getAlrimTokData url : " + url);

        RestTemplate restTemplate = new RestTemplate();

        // 요청 파라미터를 URL 쿼리 스트링으로 만들기 (GET 방식)
        StringBuilder queryString = new StringBuilder("?");
        for (Map.Entry<String, Object> entry : params.entrySet()) {
            queryString.append(entry.getKey()).append("=")
                       .append(entry.getValue()).append("&");
        }

        // 쿼리 스트링에서 마지막 & 제거
        if (queryString.length() > 1) {
            queryString.setLength(queryString.length() - 1);
        }

        String finalUrl = url + queryString;

        ResponseEntity<List> response = restTemplate.exchange(
            finalUrl,
            HttpMethod.GET,
            null,
            List.class
        );

        return response.getBody(); // JSON 배열을 List로 받음
    }

	@RequestMapping(value = "/file/templateAlrimTok", method= RequestMethod.POST)
	public void execelTemplateAlrimTok(
		Map<String,Object> modelMap , 
		HttpServletRequest request, HttpServletResponse response) throws 
		IOException, EncryptedDocumentException, InvalidFormatException {			

		List<Object> mappingList = new ArrayList<Object>();
		List<HashMap<String, Object>> data = null;
		Map<String, Object> mappingInfo = null;		
		Map<String, Object> selMap = makeParames(request);
		String fileName = (String)selMap.get(Define.Key.FILE_NAME);
		String length = (String)selMap.get(Define.Key.LENGTH);
		// String qid = (String)selMap.get(Define.Key.QID);		
		String url = (String)selMap.get(Define.Key.URL);
		
		System.out.println(url);

		data = getAlrimTokData(selMap, url);

		for (int i = 0 ; i < Integer.parseInt(length); i++) {
			mappingInfo = new HashMap<>();
			String value = (String)selMap.get("colMapping[" + i + "][name]");
			String title = (String)selMap.get("colMapping[" + i + "][title]");
			mappingInfo.put("name", value);
			mappingInfo.put("title", title);
			mappingList.add(mappingInfo);
		}
		fileService.excelCreateSXSSF(response, mappingList, data, fileName);
	}
	
	//@RequestMapping("/**/file/downloadDat")
	@RequestMapping("/file/downloadDat")
	public void downloadDat(HttpServletRequest request, HttpServletResponse response) 
			throws IOException, EncryptedDocumentException, InvalidFormatException {
		String filePath = request.getSession().getServletContext().getRealPath("/resources/datFile");
	    List<Object> mappingList = new ArrayList<Object>();
	    List<HashMap<String, Object>> data = null;
	    Map<String, Object> mappingInfo = null;      
	    Map<String, Object> selMap = makeParames(request);
	    String fileName = (String)selMap.get(Define.Key.FILE_NAME);
	    String length = (String)selMap.get(Define.Key.LENGTH);
	    String qid = (String)selMap.get(Define.Key.QID);      
	    for(int i = 0 ; i < Integer.parseInt(length); i++) {
	    	mappingInfo = new HashMap<>();
	    	String value = (String)selMap.get("colMapping[" + i + "][name]");
	    	// String title = (String)selMap.get("colMapping[" + i + "][title]");
	    	mappingInfo.put("name", value);
	        //mappingInfo.put("title", title);
	    	mappingList.add(mappingInfo);
	    }
	    data = queryService.select(qid, selMap);      
	    fileService.createDat(response, mappingList, data, fileName, filePath);
	   }
	
	private Map<String, Object> makeParames(HttpServletRequest request) {
		HttpSession session = request.getSession(false);		
		CustomUserDetails userDetails = (CustomUserDetails) session.getAttribute(Define.Key.LOGIN_INFO);
		Map<String, Object> selMap = new HashMap<String, Object>();
		Enumeration<String> e = request.getParameterNames();
		while (e.hasMoreElements()) {
		    String key = e.nextElement();
		    String value = request.getParameter(key);
		    selMap.put(key, (value == null || value.length() == 0) ? null : value);		
		}
		return selMap;
	}

	private String getSimpleErrorMessage(String msg) {
		
		if (msg == null) return "알 수 없는 오류가 발생했습니다.";

		return msg;

		// if (msg.contains("violates foreign key constraint")) {
		// 	return "연관된 데이터가 존재하지 않습니다.";
		// } else if (msg.contains("duplicate key")) {
		// 	return "이미 등록된 항목입니다.";
		// } else if (msg.contains("Cannot invoke")) {
		// 	return "필수 입력값이 누락되었거나 잘못된 형식입니다.";
		// } else if (msg.contains("Cannot get a STRING value from a NUMERIC cell")) {
		// 	return "엑셀 셀 타입 오류: 숫자 셀에서 문자열을 읽을 수 없습니다.";
		// } else if (msg.contains("NumberFormatException")) {
		// 	return "숫자 형식 오류: 잘못된 숫자 입력입니다.";
		// } else if (msg.contains("null")) {
		// 	return "입력값이 null 입니다.";
		// }

		// 기본 메시지는 앞 100자만 표시
		//return "처리 중 오류 발생: " + msg.substring(0, Math.min(100, msg.length())) + "...";
	}

	@RequestMapping(value = "/file/insert_customers", method = RequestMethod.POST)
	@ResponseBody
	public Map<String, Object> insertCustomInfoFromExcel(
			@RequestParam("file") MultipartFile file,
			@RequestParam(value = "isCheck", defaultValue = "true") boolean isCheck,
			HttpServletRequest request,
			HttpServletResponse response) throws Exception {

		Map<String, Object> result = new HashMap<>();
		String tokenKey = UUID.randomUUID().toString();

		// 사용자 정보 추출
		CustomUserDetails userDetails = (CustomUserDetails) request.getSession(false)
			.getAttribute(Define.Key.LOGIN_INFO);
		int siteSq = userDetails.getSiteSq();

		try {
			// 파일 처리 및 DB 입력
			fileService.insertCustomInfoFromExcel(file, siteSq, tokenKey, isCheck);

			response.setStatus(StatusCode.STATUS_OK.getValue());
			result.put("status", "success");
			result.put("message", isCheck ? "검증 완료" : "신규 정보 입력 성공");
		} catch (ExcelProcessingException  e) {
			// 런타임 예외 처리
			response.setStatus(StatusCode.STATUS_INTERNAL_SERVER_ERROR.getValue());
			result.put("status", "error");
			result.put("errorRow", e.getRow());
			result.put("errorCol", e.getCol());
			result.put("message", e.getMessage() +  ": " + getSimpleErrorMessage(e.getDetailMessage())); 
			e.printStackTrace();

		} catch (Exception e) {
			// 모든 일반 예외 처리
			response.setStatus(StatusCode.STATUS_INTERNAL_SERVER_ERROR.getValue());
			result.put("status", "error");
			result.put("details", getSimpleErrorMessage(e.getMessage())); 
			e.printStackTrace();
		}

		return result;
	}

	@RequestMapping(value = "/file/update_customers", method = RequestMethod.POST)
	@ResponseBody
	public Map<String, Object>updateCustomInfoFromExcel(
			@RequestParam("file") MultipartFile file,
			HttpServletRequest request,
			HttpServletResponse response) throws Exception {

		Map<String, Object> result = new HashMap<>();
		String tokenKey = UUID.randomUUID().toString();

		// 사용자 정보 추출
		CustomUserDetails userDetails = (CustomUserDetails) request.getSession(false)
			.getAttribute(Define.Key.LOGIN_INFO);
		int siteSq = userDetails.getSiteSq();

		try {
			// 파일 처리 및 DB 입력
			fileService.updateCustomInfoFromExcel(file, siteSq, tokenKey);

			response.setStatus(StatusCode.STATUS_OK.getValue());
			result.put("status", "success");
		} catch (ExcelProcessingException e) {
			// 런타임 예외 처리
			response.setStatus(StatusCode.STATUS_INTERNAL_SERVER_ERROR.getValue());
			result.put("status", "error");
			result.put("message", e.getMessage() + ": " + getSimpleErrorMessage(e.getDetailMessage())); 
			e.printStackTrace();

		} catch (Exception e) {
			// 모든 일반 예외 처리
			response.setStatus(StatusCode.STATUS_INTERNAL_SERVER_ERROR.getValue());
			result.put("status", "error");
			result.put("details", getSimpleErrorMessage(e.getMessage())); 
			e.printStackTrace();
		}

		return result;
	}
	
	
	/**
	 * 신규 종합정보등록 
	 */	
	@RequestMapping(value = "/file/insert_f5_2", method = RequestMethod.POST)
	@ResponseBody
	public  Map<String, Object> uploadTest(@RequestParam("file") MultipartFile file, HttpServletRequest request, HttpServletResponse response) throws Exception {
		HttpSession session = request.getSession(false);		
		Map<String, Object> resData = new HashMap<String, Object>();
		List<HashMap<String, Object>>  parData = null;
		List<HashMap<String, Object>>  aftResultData = new ArrayList<>();
		String templetPath = request.getSession().getServletContext().
				getRealPath("/resources/reftb/tableInfo-config.xml");
		CustomUserDetails userDetails = (CustomUserDetails) session.getAttribute(Define.Key.LOGIN_INFO);
		String tokenKey = UUID.randomUUID().toString();
		
		int siteSq = userDetails.getSiteSq();
		try {
			parData = fileService.insertRead_f5_2(file, templetPath, siteSq, tokenKey);
			HashMap<String, Object> param = new HashMap<>();
			param.put("tokenKey", tokenKey);
			
			aftResultData = queryService.select("mars.icbm.map1.importResult2",param);
			parData.addAll(aftResultData); // 마지막 후처리이후  짬밥처리까지			
			resData.put("errParam", parData);
			resData.put("tokenKey", tokenKey);
			response.setStatus(200);
		} catch (RuntimeException e) {
			response.setStatus(StatusCode.STATUS_INTERNAL_SERVER_ERROR.getValue());
			resData.put("errParam", parData);
			resData.put("tokenKey", tokenKey);
			e.printStackTrace();
		}
		return resData;
	}

	/**
	 * 업데이트 종합정보등록 
	 */	
	@RequestMapping(value = "/file/update_f5_2", method = RequestMethod.POST)
	public @ResponseBody Map<String, Object> update_f5_2(@RequestParam("file") MultipartFile file, HttpServletRequest request, HttpServletResponse response) throws Exception {
		HttpSession session = request.getSession(false);		
		Map<String, Object> resData = new HashMap<String, Object>();
		List<HashMap<String, Object>>  parData = null;
		List<HashMap<String, Object>>  aftResultData = new ArrayList<>();
		String templetPath = request.getSession().getServletContext().
				getRealPath("/resources/reftb/tableInfo-config.xml");
		CustomUserDetails userDetails = (CustomUserDetails) session.getAttribute(Define.Key.LOGIN_INFO);
		String tokenKey = UUID.randomUUID().toString();
		
		int siteSq = userDetails.getSiteSq();
		try {
			parData = fileService.updateRead_f5_2(file, templetPath, siteSq, tokenKey);
			HashMap<String, Object> param = new HashMap<>();
			param.put("tokenKey", tokenKey);
			
			aftResultData = queryService.select("mars.icbm.map1.importUpdateResult",param);
			parData.addAll(aftResultData); // 마지막 후처리이후  짬밥처리까지			
			resData.put("errParam", parData);
			resData.put("tokenKey", tokenKey);
			response.setStatus(200);
		} catch (RuntimeException e) {
			response.setStatus(StatusCode.STATUS_INTERNAL_SERVER_ERROR.getValue());
			resData.put("errParam", parData);
			resData.put("tokenKey", tokenKey);
			e.printStackTrace();
		}
		return resData;
	}

	/**
	 * 업데이트 종합정보등록 
	 */	
	@RequestMapping(value = "/file/check_f5_2", method = RequestMethod.POST)
	public @ResponseBody Map<String, Object> check_f5_2(@RequestParam("file") MultipartFile file, HttpServletRequest request, HttpServletResponse response) throws Exception {
		HttpSession session = request.getSession(false);		
		Map<String, Object> resData = new HashMap<String, Object>();
		List<HashMap<String, Object>>  parData = null;
		List<HashMap<String, Object>>  aftResultData = new ArrayList<>();
		String templetPath = request.getSession().getServletContext().
				getRealPath("/resources/reftb/tableInfo-config.xml");
		CustomUserDetails userDetails = (CustomUserDetails) session.getAttribute(Define.Key.LOGIN_INFO);
		String tokenKey = UUID.randomUUID().toString();
		
		int siteSq = userDetails.getSiteSq();
		try {
			parData = fileService.updateRead_f5_2(file, templetPath, siteSq, tokenKey);
			HashMap<String, Object> param = new HashMap<>();
			param.put("tokenKey", tokenKey);
			
			aftResultData = queryService.select("mars.icbm.map1.importCheckResult",param);
			parData.addAll(aftResultData); // 마지막 후처리이후  짬밥처리까지			
			resData.put("errParam", parData);
			resData.put("tokenKey", tokenKey);
			response.setStatus(200);
		} catch (RuntimeException e) {
			response.setStatus(StatusCode.STATUS_INTERNAL_SERVER_ERROR.getValue());
			resData.put("errParam", parData);
			resData.put("tokenKey", tokenKey);
			e.printStackTrace();
		}
		return resData;
	}
	
	/**
	 * 신규종합등록시 에러 파일 다운로드
	 */
	@RequestMapping(value = "/file/errorexcl", method= RequestMethod.POST)
	@ResponseBody
	public ResponseEntity<byte[]> exceldown(@RequestBody Map<String,Object> paramMap ) throws IOException, EncryptedDocumentException, InvalidFormatException {
		byte[] excelContent = fileService.errorExcelCreate((List<Map<String,Object>>)paramMap.get("errparam"));
		
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        headers.setContentDispositionFormData("filename", "example.xlsx");
        headers.setContentLength(excelContent.length);

        // 파일 다운로드 응답 반환
        return ResponseEntity.ok()
            .headers(headers)
            .contentType(MediaType.APPLICATION_OCTET_STREAM)
            .body(excelContent);
	}
}
