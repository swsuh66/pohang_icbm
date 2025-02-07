package com.istec.m1.controller;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.istec.m1.auth.CustomUserDetails;
import com.istec.m1.service.QueryService;

@Controller
@RequestMapping("/user")
public class UserMgmtController {

	private Logger logger = LoggerFactory.getLogger(UserMgmtController.class);
	private Logger logger2 = LoggerFactory.getLogger("userlog");
	
	@Autowired
	QueryService queryService;

	@RequestMapping(value = "/info", method = RequestMethod.GET)
	public String userInfo(Locale locale, Model model, HttpSession session, HttpServletRequest req) throws IOException {
        CustomUserDetails userDetails = (CustomUserDetails)session.getAttribute("userLoginInfo");
        if(userDetails != null)
        	model.addAttribute("user", userDetails);

		Map<String, Object> infoMap = ControllerHelper.makeParameters(req, true);
		model.addAttribute("selectedUser", infoMap);
		
		return "userInfo";
	}

	@RequestMapping(value = "/add", method = RequestMethod.GET)
	@ResponseBody
	public Map addUserGet(Model model, HttpSession session, HttpServletRequest req ) throws IOException {
		Map ret = new HashMap();
		ret.put("result", "success"); 
		return ret;
	}

	@ResponseBody
	@RequestMapping(value = "/add", method = RequestMethod.POST)
	public Map<String, Object> addUser(Model model, HttpSession session, HttpServletRequest req ) throws IOException {
        CustomUserDetails userDetails = (CustomUserDetails)session.getAttribute("userLoginInfo");
        if(userDetails != null)
        	model.addAttribute("user", userDetails);
        
		String qid = req.getParameter("qid");
		Map<String, Object> paramMap = ControllerHelper.makeParameters(req, true);
		
		logger.debug("user add : " + paramMap);
		int res = queryService.insert(qid, paramMap);
		
		logger2.debug(qid + " : " + paramMap.toString() + " " + now() + "\n");
				
		// executing select query
		/*List<HashMap<String, Object>> result = new ArrayList<HashMap<String,Object>>(); 
        result = queryService.select("selectUser");*/

		Map<String, Object> result = new HashMap<String, Object>();
		if (res > 0 )
			result.put("result", "successed");
		else 
			result.put("result", "failed");
		
		return result; 
	}

	@ResponseBody
	@RequestMapping(value = "/delete", method = RequestMethod.POST)
	public Map<String, Object> deleteUser(HttpSession session, HttpServletRequest req ) throws IOException {
		/*        CustomUserDetails userDetails = (CustomUserDetails)session.getAttribute("userLoginInfo");
        if(userDetails != null)
        	model.addAttribute("user", userDetails);*/
        
		String qid = req.getParameter("qid");
		Map<String, Object> paramMap = ControllerHelper.makeParameters(req, true);
		
		logger.debug("user delete : " + paramMap);
		// executing delete query
		int res = queryService.delete(qid, paramMap);
		
		logger2.debug(qid + " : " + paramMap.toString() + " " + now() + "\n");
        
		// executing select query
		/*List<HashMap<String, Object>> result = new ArrayList<HashMap<String,Object>>(); 
        result = queryService.select("selectUser");*/

		Map<String, Object> result = new HashMap<String, Object>();
		if (res > 0 )
			result.put("result", "successed");
		else 
			result.put("result", "failed");
		return result; 
	}
	
	private String now() {
		
		Date today = new Date();    
	    SimpleDateFormat date = new SimpleDateFormat("yyyy/MM/dd hh:mm:ss a");    
	    return date.format(today);

	};

	@ResponseBody
	@RequestMapping(value = "/update", method = RequestMethod.POST)
	public Map<String, Object> updateUser(Model model, HttpSession session, HttpServletRequest req ) throws IOException {
        CustomUserDetails userDetails = (CustomUserDetails)session.getAttribute("userLoginInfo");
        if(userDetails != null)
        	model.addAttribute("user", userDetails);
        
		String qid = req.getParameter("qid");
		Map<String, Object> paramMap = ControllerHelper.makeParameters(req, true);
		
		logger.debug("user update : " + paramMap);
		// executing delete query
		int res = queryService.update(qid, paramMap);
        
		
		//Map<String, Object> item = iterator.next();				 
		logger2.debug(qid + " : " + paramMap.toString() + " " + now() + "\n");
		
		// executing select query
		/*List<HashMap<String, Object>> result = new ArrayList<HashMap<String,Object>>(); 
        result = queryService.select("selectUser");*/
		
		Map<String, Object> result = new HashMap<String, Object>();
		if (res > 0 )
			result.put("result", "successed");
		else 
			result.put("result", "failed");
		return result; 
	}

	@RequestMapping(value = "/search", method = {RequestMethod.GET, RequestMethod.POST})
	@ResponseBody
	public List<HashMap<String, Object>> search(Model model, HttpSession session, HttpServletRequest req ) throws IOException {
        CustomUserDetails userDetails = (CustomUserDetails)session.getAttribute("userLoginInfo");
        if(userDetails != null)
        	model.addAttribute("user", userDetails);
        
        List<HashMap<String, Object>> result = new ArrayList<HashMap<String,Object>>(); 
        		
		String qid = req.getParameter("qid");
		Map<String, Object> paramMap = ControllerHelper.makeParameters(req, true);
		
		logger.debug("qid : " + qid);
		logger.debug("user search : " + paramMap);
		result = queryService.select(qid, paramMap);
		
		return result; 
	}
}
