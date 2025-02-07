package com.istec.m1.auth;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.stereotype.Component;

@Component
public class CustomAccessDeniedHandler implements AccessDeniedHandler {

	private static final Logger logger = LoggerFactory.getLogger(CustomAccessDeniedHandler.class);
	
	private String errorPage;

    public void setErrorPage(String errorPage) {
        this.errorPage = errorPage;
    }

    @Override
    public void handle(HttpServletRequest req, HttpServletResponse resp, AccessDeniedException e)
            throws IOException, ServletException {
        
    	logger.info("CustomAccessDeniedHandler!");
    	
        req.getRequestDispatcher(errorPage).forward(req, resp);
    }

}
