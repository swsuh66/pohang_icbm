package com.istec.m1.controller;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.istec.m1.auth.CustomUserDetails;
import com.istec.m1.service.GeoJsonService;
import com.istec.m1.service.QueryService;


@Controller
@RequestMapping(value="/geojson")
public class GeoController {

	@Autowired
    private GeoJsonService geoService;
	
	@Autowired
    private QueryService queryService;
	
	/*@RequestMapping(value="/list", method={RequestMethod.GET}, produces = "application/json; charset=utf-8")
	public @ResponseBody List<Map<String, Object>> getList(HttpServletRequest request, HttpServletResponse response) 
			throws UnsupportedEncodingException, IOException {
		request.setCharacterEncoding("utf-8");
		response.setContentType("application/json; charset=UTF-8");
		
		return getJason(request);
	}*/

	@RequestMapping(value="/base", method={RequestMethod.GET}, produces = "application/json; charset=utf-8")
	public @ResponseBody Map<String, Object> getBase(HttpServletRequest request, HttpServletResponse response) 
			throws UnsupportedEncodingException, IOException {
		request.setCharacterEncoding("utf-8");
		response.setContentType("application/json; charset=UTF-8");
		
		String code = request.getParameter("code");
		return geoService.getBaseGeojson(code);
	}

	@RequestMapping(value="/boundary", method={RequestMethod.GET}, produces = "application/json; charset=utf-8")
	public @ResponseBody Map<String, Object> getBoundary(HttpSession session, HttpServletRequest request, HttpServletResponse response) 
			throws UnsupportedEncodingException, IOException {
		request.setCharacterEncoding("utf-8");
		response.setContentType("application/json; charset=UTF-8");
		
        CustomUserDetails userDetails = (CustomUserDetails)session.getAttribute("userLoginInfo");
        if(userDetails == null)
        	return null;

		List<String> sccoList = new ArrayList<String>();

		String scco = userDetails.getSccocode();
		//String scco = "1101";
		if(scco != null && !scco.isEmpty()) {
			for (int i=0;i<=9; i++) {
				int codeInt = Integer.parseInt(scco) + i;

				sccoList.add("" + codeInt); // 다시 문자열로
			}
		}
		return geoService.getMultiBase(sccoList);
	}

	@RequestMapping(value="/child", method={RequestMethod.GET}, produces = "application/json; charset=utf-8")
	public @ResponseBody Map<String, Object> getChild(HttpServletRequest request, HttpServletResponse response) 
			throws UnsupportedEncodingException, IOException {
		request.setCharacterEncoding("utf-8");
		response.setContentType("application/json; charset=UTF-8");
		
		String code = request.getParameter("code");
		return geoService.getChildGeojson(code);
	}

	/**************************************************************************/
	
	/*protected List<Map<String, Object>> getJason(HttpServletRequest request) throws IOException {
		String code = request.getParameter("code");
		//code = "46150";

		List<Map<String, Object>> result;
		

		result = geoService.getList(code);

		
		return result;
	}*/
	
	/**************************************************************************/

	
}
