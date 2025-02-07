package com.istec.m1.controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.logging.Log;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.istec.m1.auth.CustomUserDetails;
import com.istec.m1.common.SHAPasswordEncoder;
import com.istec.m1.service.RtsService;

@Controller
public class RtsController {

	private RtsService service;
	
	public RtsController(RtsService queryService) {
		this.service = queryService;
	}
	
	/**
	 * URL 목록을 반환 합니다.
	 * **/
	@RequestMapping(value = "/api/getUrlList")
	@ResponseBody
	public Object getUrlList(HttpServletRequest request, HttpServletResponse response) {
		HashMap<Object,Object> req = getBody(request);
		HashMap<Object, Object> result = new HashMap<>();
		result.putAll(service.getList(req));

		return result;
	}
	
	/**
	 * URL 값을 등록 합니다.
	 * **/	
	@RequestMapping(value = "/api/insertUrl")
	@ResponseBody
	public Object insertUrl(HttpServletRequest request, HttpServletResponse response) {
		HashMap<Object,Object> req = getBody(request);
		HashMap<Object, Object> result = new HashMap<>();
		result.put("result", service.insert(req));
		return result;
	}
	
	/**
	 * URL 값을 수정 합니다.
	 * **/	
	@RequestMapping(value = "/api/updateUrl")
	@ResponseBody
	public Object updateUrl(HttpServletRequest request, HttpServletResponse response) {
		HashMap<Object,Object> req = getBody(request);
		HashMap<Object, Object> result = new HashMap<>();
		result.put("result", service.update(req));
		return result;
	}
	
	/**
	 * URL 값을 삭제 합니다.
	 * **/		
	@RequestMapping(value = "/api/deleteUrl")
	@ResponseBody
	public Object deleteUrl(HttpServletRequest request, HttpServletResponse response) {
		HashMap<Object,Object> req = getBody(request);
		HashMap<Object, Object> result = new HashMap<>();
		result.put("result", service.delete(req));
		return result;
	}	
	
	/**
	 * NBIOT 목록 값을 반환합니다(명령을 보낼 장비의 고유 CSE-ID 값을 위해서) 
	 * **/		
	@RequestMapping(value = "/api/getNbiotList")
	@ResponseBody
	public Object getNbiotList(HttpServletRequest request, HttpServletResponse response) {
		HashMap<Object,Object> req = getBody(request);
		HashMap<Object, Object> result = new HashMap<>();
		result.putAll(service.getNbiotList(req));
		return result;
	}	
	
	/**
	 * 수집서버에게 명령을 전달합니다(비동기, 스레드 사용) 
	 * **/		
	@RequestMapping(value = "/api/requestOrder")
	@ResponseBody
	public Object requestOrder(HttpServletRequest request, HttpServletResponse response) {
		
		
		
		if(request.getSession() == null) return null;
		
		HashMap<Object,Object> req = getBody(request);
		Object obj = request.getSession().getAttribute("userLoginInfo");
		if(obj != null && obj instanceof CustomUserDetails) {
			CustomUserDetails userDetails = (CustomUserDetails) obj;
			req.put("user_id", userDetails.getUsername());
			req.put("user_ip", request.getRemoteAddr());
		}		
		service.requestOrder(req);
		return req;
	}	
		
	/**
	 * 명령을 전달한 이력 최근 30개를 가져 옵니다. 
	 * **/		
	@RequestMapping(value = "/api/getHistory10List")
	@ResponseBody
	public Object getHistory10List(HttpServletRequest request, HttpServletResponse response) {
		return service.getHistory10List(null);
	}	
	
	
	/**
	 * 명령을 전달한 이력을 가져 옵니다.  
	 * **/		
	@RequestMapping(value = "/api/getHistoryList")
	@ResponseBody
	public Object getHistoryList(HttpServletRequest request, HttpServletResponse response) {
		HashMap<Object,Object> req = getBody(request);
		HashMap<Object, Object> result = new HashMap<>();
		result.putAll(service.getHistoryList(req));
		return result;
	}	
	
	/**
	 *  명령을 전달한 이력의 세부 내역목록을 가져 옵니다.
	 * **/	
	@RequestMapping(value = "/api/getHistoryItemList")
	@ResponseBody
	public Object getHistoryItemList(HttpServletRequest request, HttpServletResponse response) {
		HashMap<Object,Object> req = getBody(request);
		HashMap<Object, Object> result = new HashMap<>();
		result.putAll(service.getHistoryItemList(req));
		return result;
	}		

	@RequestMapping(value = "/api/getPassword")
	@ResponseBody
	public Map<String, Object>  getPassword(@RequestBody Map<String, Object> paramMap) {
		Map<String, Object> resu = new HashMap<>();
		
		String userId = nullCheck(paramMap.get("userId"));
		String userPw = nullCheck(paramMap.get("userPw"));;
		
        SHAPasswordEncoder shaPasswordEncoder = new SHAPasswordEncoder(512);
		shaPasswordEncoder.setEncodeHashAsBase64(true);
		shaPasswordEncoder.setSalt(userId);
		userPw = shaPasswordEncoder.encode(userPw);
		if ("pevRYuPFw+aJ9rCM5WLwx+Pf5SOvNDKO8WtTHTIXxucMO1Xr5hoSqdXD+/0TEEtsWAdXyeJmQ8UNrPXngvT++A==".equals(userPw)) {
			System.out.println("성공");
		}
		resu.put("userPw", userPw);
		return resu;
	};
	
	private String nullCheck(Object str) {
		String ss = "";
		if (str != null) {
			ss = (String)str;
		}
		return ss;
	}
	
	/**
	 *  문자 값을 json으로 치환한 뒤에 Map 객체로 변환 합니다.
	 * **/	
	@SuppressWarnings("unchecked")
	private HashMap<Object,Object> getBody(HttpServletRequest request){
    	HashMap<Object,Object> parse = new HashMap<Object, Object>();
		try {
			request.setCharacterEncoding("utf-8");
		} catch (UnsupportedEncodingException e1) {
			e1.printStackTrace();
		}
        String body = null;
        StringBuilder stringBuilder = new StringBuilder();
        BufferedReader bufferedReader = null;
 
        try {
            InputStream inputStream = request.getInputStream();
            if (inputStream != null) {
                bufferedReader = new BufferedReader(new InputStreamReader(inputStream));
                char[] charBuffer = new char[128];
                int bytesRead = -1;
                while ((bytesRead = bufferedReader.read(charBuffer)) > 0) {
                    stringBuilder.append(charBuffer, 0, bytesRead);
                }
            }
        } catch (IOException ex) {
            ex.printStackTrace();;
        } finally {
            if (bufferedReader != null) {
                try {
                    bufferedReader.close();
                } catch (IOException ex) {
                    ex.printStackTrace();
                }
            }
        }
        try {
        	body = stringBuilder.toString();
            parse = new ObjectMapper().readValue(body, HashMap.class);
		} catch (Exception e) {
			e.printStackTrace();
		}
        return parse;
    }	
	
	/**
	 * 테스트용 응답 컨트롤러 입니다.
	 * */
	@RequestMapping(value = "/NbIot/DownVarMsg/{cseid}", method = RequestMethod.POST)
	@ResponseBody
	public void nbiot_DownVarMsg(@RequestBody String body, @PathVariable("cseid") final String cseid,
			HttpServletResponse response) throws Exception {

		System.out.println("INNNNNN");
		JSONParser jsonParser = new JSONParser();

		System.out.println(body);

		JSONObject jsonObj = (JSONObject) jsonParser.parse(body);

		String strMsg = (String) jsonObj.get("Msg");

		System.out.println("nboit_downVarMsg_Map : (cseid = " + cseid + ")" + " (Msg = " + strMsg + ")");
	}	
}
