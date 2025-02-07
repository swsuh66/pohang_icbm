package com.istec.m1.auth;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
//import org.apache.commons.lang.StringUtils;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;
//import com.syaku.rest.commons.ResponseResult;

import com.istec.m1.controller.LoginController;


@Component
public class CustomAuthEntryPoint implements AuthenticationEntryPoint {
	
    private static final Logger logger = LoggerFactory.getLogger(CustomAuthEntryPoint.class);

    private String errorPage;
    
    public void setErrorPage(String errorPage) {
        this.errorPage = errorPage;
    }
    
	@Override
	public void commence(HttpServletRequest request, HttpServletResponse response,
			AuthenticationException authException) throws IOException, ServletException {
		
		logger.info("AuthenticationException!");
		
		request.getRequestDispatcher(errorPage).forward(request, response);
	
	}
}
