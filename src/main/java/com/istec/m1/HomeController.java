package com.istec.m1;

import java.security.Principal;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.servlet.ModelAndView;

import com.istec.m1.auth.CustomUserDetails;
import com.istec.m1.dao.QueryDao;
import com.istec.m1.service.QueryService;

/**
 * 홈 컨트롤러.
 */
@Controller
public class HomeController {
	
	@Autowired
    private QueryService querysv;

	private static final Logger logger = LoggerFactory.getLogger(HomeController.class);

	/**
	 * 기본 Url.
	 * 
	 */
	@RequestMapping(value = "/", method = RequestMethod.GET)
	public String def(Locale locale, Model model, HttpServletRequest request) {
        
		return "redirect:/main";
		
	}

	@RequestMapping(value = "/test", method = RequestMethod.GET)
	public String test() {
		return "home";
		
	}
	

	
	/**
	 * main URL.
	 * 
	 */
	@RequestMapping(value = "/main", method = RequestMethod.GET)
	public String home(Locale locale, Model model, HttpServletRequest request) {

		setModel(model, request);

		return "ISTC_F0";

	}
	
	/**
	 * sub 페이지.
	 * 
	 */
	@RequestMapping(value = "/{page}", method = RequestMethod.GET)
	public String pages(@PathVariable String page, Locale locale, Model model, HttpServletRequest request) {
		
		setModel(model, request);
       
		return page;
		
	}
	
	/**
	 * sub 페이지 (POST).
	 * 프린트 페이지 등 POST 요청 처리
	 */
	@RequestMapping(value = "/{page}", method = RequestMethod.POST)
	public String pagesPost(@PathVariable String page, Locale locale, Model model, HttpServletRequest request) {
		
		setModel(model, request);
       
		return page;
		
	}
	
	/**
	 * 팝업 페이지.
	 * 
	 */
	@RequestMapping(value = "/popup/{page}", method = RequestMethod.POST)
	public String popupPages(@PathVariable String page, Locale locale, Model model, HttpServletRequest request) {
		
		setModel(model, request);
		
		model.addAttribute("cdParam",      request.getParameter("cdParam"));
		model.addAttribute("fliterType", request.getParameter("fliterType"));
		
		return "/popup/"+page;
	}
	
	
	/**
	 * 모델 세팅.
	 * 
	 */
	protected void setModel(Model model, HttpServletRequest request) {
		
		HttpSession session = request.getSession(false);
		if (session != null) {
			CustomUserDetails userDetails = (CustomUserDetails)session.getAttribute("userLoginInfo");
			
			if(userDetails != null) 
				model.addAttribute("user", userDetails);
        		
		}
        String ctxPath = request.getContextPath();
        if(ctxPath.equals("/")) ctxPath = ""; 
        
        model.addAttribute("contextPath", ctxPath);
	}
	
	


}
