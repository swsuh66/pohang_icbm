package com.istec.m1.auth;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.SavedRequestAwareAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import com.istec.m1.service.SessionService;

@Component
public class CustomLoginSuccessHandler extends SavedRequestAwareAuthenticationSuccessHandler {

	private static final Logger logger = LoggerFactory.getLogger(CustomLoginSuccessHandler.class);

	
	@Autowired
    private SessionService sessionService;

	@Override
	public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication authentication) throws ServletException, IOException {
		
        HttpSession session = request.getSession();
        if (session == null) 
        	return;
        	
        CustomUserDetails userDetails = (CustomUserDetails)SecurityContextHolder.getContext().getAuthentication().getDetails();            
        
		session.setAttribute("userLoginInfo", userDetails);

        Map<String, Object> parmMap = new HashMap<String, Object>();
        
        HashMap<String, Object> userInfo = userDetails.getUserInfo();
        
        String userId = (String) userInfo.get("userId");
        
        parmMap.put("statCd", "1");
        parmMap.put("userId", userId);
        parmMap.put("ssId",   session.getId());
        parmMap.put("ipAddr", request.getRemoteAddr());
        parmMap.put("agent",  request.getHeader("User-Agent"));
        parmMap.put("refer",  request.getHeader("referer"));
        
        sessionService.loginSessionInfo(parmMap);
        
        logger.info("Welcome login_success! {}, {}", session.getId(), userDetails.getUsername() + "/" + userDetails.getPassword());
        
        response.sendRedirect("main");  
	};

}
