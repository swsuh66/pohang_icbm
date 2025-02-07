package com.istec.m1.auth;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletResponse;

public class RestSendError {

	public static void sendError(HttpServletResponse response, int sc, String msg) throws IOException, ServletException {
		
		
		response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
		
/*		//response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
		
		response.setContentType("application/json");
		response.setCharacterEncoding("utf-8");

		Map<String, Object> message = new HashMap<String, Object>();
		message.put("message", msg);
		message.put("status_code", sc);
		
		ObjectMapper objectMapper = new ObjectMapper();
		String data = objectMapper.writeValueAsString(message);
		PrintWriter out = response.getWriter();
		out.write(data);
		out.flush();
		out.close();*/
	}

}
