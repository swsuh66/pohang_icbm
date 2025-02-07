package com.istec.m1.controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import com.istec.m1.auth.CustomUserDetails;
import com.istec.m1.common.JacksonParsing;
import com.istec.m1.defines.Define;

public class ControllerHelper {
	
protected static List<Map<String, Object>> makeListParameters(HttpServletRequest request) throws IOException {
		
		List<Map<String, Object>> listMap = null;
		
		String data = ControllerHelper.readRequestBody(request);
		
		if(data != null && !data.isEmpty()) {
			
			listMap = JacksonParsing.toList(data);
			
		}
		
		HttpSession session = request.getSession(false);
		
		if(session != null) {
			
			CustomUserDetails userDetails = (CustomUserDetails)session.getAttribute("userLoginInfo");
			
	        if(userDetails != null) {
	        	
        		for (Map<String, Object> item : listMap) {
	        		
	        		if( !item.containsKey("masterSiteSq") ) {
	        			
	        			int lv = userDetails.getSiteLv();
		        		if(lv == 1) 
		        			item.put("masterSiteSq", userDetails.getSiteSq()); 
		        		
		        		
	        		}
	        			
	        	}

	        }
	
		}
		
		return listMap;		
	}
	
	protected static Map<String, Object> makeParameters(HttpServletRequest request, boolean isPost) throws IOException {
		
		Map<String, Object> parmMap = null;
		
		if(isPost) {
			
			String data = ControllerHelper.readRequestBody(request);
			
			if(data != null && !data.isEmpty()) {
				
				parmMap = JacksonParsing.toMap(data);
				
			}
			
		}
		
		if (parmMap == null) {
			
			parmMap = new HashMap<String, Object>();
			
		}

		@SuppressWarnings("unchecked")
		Enumeration<String> parameterNames = request.getParameterNames();
		
		while (parameterNames.hasMoreElements()) {
			
			String key = (String) parameterNames.nextElement();
			
			if (key.equals("qid") || key.equals("groupSeq"))
				continue;

			String val = request.getParameter(key);
			
			if (key.endsWith("Sq")) {
				parmMap.put(key, Integer.parseInt(val));
			} else {
				parmMap.put(key, val);
			}			
			
		}

		HttpSession session = request.getSession(false);
		
		if(session != null) {
			
			CustomUserDetails userDetails = (CustomUserDetails)session.getAttribute("userLoginInfo");
			
	        if(userDetails != null) {
	        	
	        	if( !parmMap.containsKey("masterSiteSq") ) {
	        		
	        		int lv = userDetails.getSiteLv();
	        		if(lv == 1) 	        			
	        			parmMap.put("masterSiteSq", userDetails.getSiteSq());
	        		
	        		
	        	}
	        	
	        }
	        
		}
		
		return parmMap;
	}

	
	public static String readRequestBody(HttpServletRequest request) throws IOException {
		
		InputStream in = null;
		
		String body = null;
		
		BufferedReader bufferedReader = null;
		
		String charSet = request.getCharacterEncoding();
		
		StringBuilder stringBuilder = new StringBuilder();

		if (charSet == null) {
			
			charSet = Define.Encoding.UTF8;
			
		}			

		try {
			
			in = request.getInputStream();

			if (in != null) {

				bufferedReader = new BufferedReader(new InputStreamReader(in, charSet));

				char[] charBuffer = new char[128];

				int bytesRead = -1;

				while ((bytesRead = bufferedReader.read(charBuffer)) > 0) {
					
					stringBuilder.append(charBuffer, 0, bytesRead);
					
				}

			}
		} catch (IOException e) {

			e.printStackTrace();

		} finally {

			if (bufferedReader != null) {
				try {
					bufferedReader.close();
				} catch (IOException ex) {
					throw ex;
				}
			}

		}

		body = stringBuilder.toString();

		return body;
	}

}
