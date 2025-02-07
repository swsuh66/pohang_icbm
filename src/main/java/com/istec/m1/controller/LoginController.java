package com.istec.m1.controller;

import java.security.Principal;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.savedrequest.HttpSessionRequestCache;
import org.springframework.security.web.savedrequest.RequestCache;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

//import com.fasterxml.jackson.databind.ObjectMapper;
import com.istec.m1.auth.CustomUserDetails;

@Controller
public class LoginController {

	private static final Logger logger = LoggerFactory.getLogger(LoginController.class);

	@RequestMapping(value = "/login", method = RequestMethod.GET)
	public String login(HttpServletRequest request) {
		return "/ISTC_DEF_LOGIN";
	};

	@RequestMapping(value = "/autoLogin", method = RequestMethod.GET)
	public String loginTmp(HttpServletRequest request) {
		return "/ISTC_AUTO_LOGIN";
	};

	@RequestMapping(value = "/logout", method = RequestMethod.GET)
	public String logout(HttpServletRequest request, HttpServletResponse response) {

		HttpSession session = request.getSession(false);
		CustomUserDetails userDetails = (CustomUserDetails) session.getAttribute("userLoginInfo");

		RequestCache requestCache = new HttpSessionRequestCache();
		requestCache.removeRequest(request, response);

		session.removeAttribute("userLoginInfo");
		session.invalidate();

		return "redirect:/login";
	}

	@RequestMapping(value = "/auth/fail", method = RequestMethod.GET)
	public String login_failure(HttpServletRequest request, HttpSession session) {

		logger.info("Fail login! {}", session.getId());

		String accept = request.getHeader("accept");

		if (accept.indexOf("html") > -1) {
			return "redirect:/login?error";
		} else {
			return "redirect:/auth/fail_json";
		}

	}

	@RequestMapping(value = "/auth/denied", method = RequestMethod.GET)
	public String login_denied(HttpServletRequest request, HttpSession session, Principal user) {

		logger.info("Access denied! {}", session.getId());

		String accept = request.getHeader("accept");

		if (accept.indexOf("html") > -1) {
			return "redirect:/login?error";
		} else {
			return "redirect:/auth/fail_json";
		}

	}

	@RequestMapping(value = "/auth/fail_json", method = RequestMethod.GET, produces = "application/json; charset=utf-8")
	@ResponseBody
	public Map<String, Object> login_fail_json(HttpServletRequest request, HttpServletResponse response) {

		logger.info("login_fail_json!");
		response.setContentType("application/json");
		response.setCharacterEncoding("utf-8");

		// ResponseResult responseError = new ResponseResult();
		Map<String, Object> message = new HashMap<String, Object>();

		String accept = request.getHeader("accept");

		// if (StringUtils.indexOf(accept, "json") > -1) {
		if (accept.indexOf("json") > -1) {
			response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
			/*
			 * responseError.setMessage("Unauthorized");
			 * responseError.setStatus_code("401");
			 */
			message.put("message", "Unauthorized");
			message.put("status_code", "401");
		} else {
			response.setStatus(HttpServletResponse.SC_UNSUPPORTED_MEDIA_TYPE);
			// responseError.setMessage("415 Unsupported Media Type");
			message.put("message", "415 Unsupported Media Type");
			message.put("status_code", "415");
		}

		return message;

		/*
		 * ObjectMapper objectMapper = new ObjectMapper(); //String data =
		 * objectMapper.writeValueAsString(responseError); String data =
		 * objectMapper.writeValueAsString(message); PrintWriter out =
		 * response.getWriter(); out.print(data); out.flush(); out.close();
		 */
	}

	/*
	 * @RequestMapping(value = "/auth/success", method = RequestMethod.GET) public
	 * String login_success(HttpSession session) { CustomUserDetails userDetails =
	 * (CustomUserDetails)SecurityContextHolder.getContext().getAuthentication().
	 * getDetails(); session.setAttribute("userLoginInfo", userDetails);
	 * 
	 * logger.info("Welcome login_success! {}, {}", session.getId(),
	 * userDetails.getUsername() + "/" + userDetails.getPassword());
	 * 
	 * return "redirect:/main"; }
	 */

	@RequestMapping(value = "auth/duplicate", method = RequestMethod.GET)
	public void login_duplicate() {
		logger.info("Welcome login_duplicate!");
	}

}
