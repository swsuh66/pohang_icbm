package com.istec.m1.auth;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
//import org.apache.commons.lang.StringUtils;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;
//import com.syaku.rest.commons.ResponseResult;


@Component
public class UnauthorizedEntryPoint implements AuthenticationEntryPoint {
	/*private String loginFormUrl;

	public String getLoginFormUrl() {
		return loginFormUrl;
	}

	public void setLoginFormUrl(String loginFormUrl) {
		this.loginFormUrl = loginFormUrl;
	}

	public UnauthorizedEntryPoint() {
	}

	public UnauthorizedEntryPoint(String loginFormUrl) {
		this.loginFormUrl = loginFormUrl;
	}*/

	@Override
	public void commence(HttpServletRequest request, HttpServletResponse response,
			AuthenticationException authException) throws IOException, ServletException {
		
		//response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
		
		response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
		RestSendError.sendError(response, HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
	}
}
