package com.istec.m1.auth;

import java.io.IOException;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.stereotype.Component;

@Component
public class CustomLoginFailHandler implements AuthenticationFailureHandler {

	@Override
	public void onAuthenticationFailure(HttpServletRequest request, HttpServletResponse response, AuthenticationException authentication) throws IOException, ServletException {
		
		
		HttpSession session = request.getSession();
		
		@SuppressWarnings("unchecked")
		Map<String, Object> failInfo = (Map<String, Object>) (session.getAttribute("login_fail_info"));
		String err = (String) failInfo.get("exception");
		
		
		if(err.equals("password")) 
			response.sendRedirect("login?error=pw=");		
		else 
			response.sendRedirect("login?error=id=");
		
	};

}
