package com.istec.m1.controller;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.istec.m1.common.JacksonParsing;
import com.istec.m1.common.PasswordEncoding;
import com.istec.m1.common.SHAPasswordEncoder;
import com.istec.m1.service.QueryService;


@Controller
@RequestMapping(value="/query")
public class QueryConroller {

	private Logger logger = LoggerFactory.getLogger(QueryConroller.class);
	private Logger logger2 = LoggerFactory.getLogger("userlog");	
	
	@Autowired
    private QueryService queryService;
	
	@RequestMapping(value="/json", method={RequestMethod.GET}, produces = "application/json; charset=utf-8")
	//public @ResponseBody String queryGet(HttpServletRequest request, HttpServletResponse response) throws UnsupportedEncodingException {
	public @ResponseBody List<HashMap<String, Object>> 
	queryGet(HttpServletRequest request, HttpServletResponse response) throws IOException, UnsupportedEncodingException {
		request.setCharacterEncoding("utf-8");
		//response.setContentType("application/json; charset=UTF-8");
		
		return getJason(request, false);
	}

	@RequestMapping(value="/json", method={RequestMethod.POST}, produces = "application/json; charset=utf-8")
	public @ResponseBody List<HashMap<String, Object>> 
	queryPost(HttpServletRequest request, HttpServletResponse response) throws IOException, UnsupportedEncodingException {
		request.setCharacterEncoding("utf-8");
		//response.setContentType("application/json; charset=UTF-8");

		return getJason(request, true);
	}

	@RequestMapping(value="/json/insert", method={RequestMethod.POST}, produces = "text/html; charset=utf-8")
	public @ResponseBody String 
	executeInsert(HttpServletRequest request, HttpServletResponse response) throws IOException, UnsupportedEncodingException {
		return executeQuery(request, "insert");
	}
	@RequestMapping(value="/json/update", method={RequestMethod.POST}, produces = "text/html; charset=utf-8")
	public @ResponseBody String 
	executeUpdate(HttpServletRequest request, HttpServletResponse response) throws IOException, UnsupportedEncodingException {
		return executeQuery(request, "update");
	}
	@RequestMapping(value="/json/delete", method={RequestMethod.POST}, produces = "text/html; charset=utf-8")
	public @ResponseBody String 
	executeDelete(HttpServletRequest request, HttpServletResponse response) throws IOException, UnsupportedEncodingException {
		return executeQuery(request, "delete");
	}
	
	private String now() {
		
		Date today = new Date();    
	    SimpleDateFormat date = new SimpleDateFormat("yyyy/MM/dd hh:mm:ss a");    
	    return date.format(today);

	};
	
	protected String executeQuery(HttpServletRequest request, String method) throws IOException {
		
		String qid = request.getParameter("qid");

		List<Map<String, Object>> listMap = ControllerHelper.makeListParameters(request);
		
		if(listMap != null) {
			
			int result = 0;
			
			switch(method) {
			
				case "insert":
					
					if(qid.equals("mars.icbm.map1.insertUser"))						
						enCodingPw(listMap);
					
					result = queryService.insert(qid, listMap);
					break;
					
				case "update":
					
					if(qid.equals("mars.icbm.map1.updatePwd"))						
						enCodingPw(listMap);
					
					result = queryService.update(qid, listMap);
					break;
					
				case "delete":
					result = queryService.delete(qid, listMap);
					break;
					
			}
			
		
			
			return JacksonParsing.toString(listMap);
			
		}
		else {
			
			listMap = new ArrayList<Map<String, Object>>();
			
		}
		
		
			
		return JacksonParsing.toString(listMap);		
	}
	
	protected void enCodingPw(List<Map<String, Object>> listMap) {

		for (Map<String, Object> item : listMap) {
			
			String passwd = (String) item.get("userPwd");
			String userId = (String) item.get("userId");
			
			if(passwd != null) {
				
				SHAPasswordEncoder shaPasswordEncoder = new SHAPasswordEncoder(512);
				shaPasswordEncoder.setEncodeHashAsBase64(true);
				shaPasswordEncoder.setSalt(userId);
				
				PasswordEncoding passwordEncoding = new PasswordEncoding(shaPasswordEncoder);			
				String dbpw = passwordEncoding.encode(passwd);
	    		item.put("userPwd", dbpw);	  
	    		
			}
			
			      		
    	}
		
	};
		
	protected List<HashMap<String, Object>> getJason(HttpServletRequest request, boolean isPost) throws IOException { 
	
		String qid = request.getParameter("qid");
		
		Map<String, Object> parmMap = ControllerHelper.makeParameters(request, true);
		parmMap.put("searchParamList", new String[]{});
		
		if (parmMap.containsKey("searchParam") && !"".equals(nullCheck(parmMap.get("searchParam")))) {
			String ser = nullCheck(parmMap.get("searchParam"));
			parmMap.put("searchParamList", ser.split(","));
		}
		
		List<HashMap<String, Object>> result;
		
		if(parmMap != null) {
			
			result = queryService.select(qid, parmMap);
			
		} else {
			
			result = queryService.select(qid);
			
		}

		return result;
	}
	
	private String nullCheck(Object obj) {
		String str = "";
		if (obj != null) {
			str = (String)obj;
		}
		return str;
	}
}
