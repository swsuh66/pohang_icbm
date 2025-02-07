package com.istec.gb;

import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequestMapping("/istec")
public class IstecController {
	
	@Resource(name="gbService")
	private GbService svc1;
	
	@Resource(name="istecService")
	private IstecService svc2;
	
	final String j = "jsonString"; 
	
	@RequestMapping("/fileDownload.do")
	public void fileDownload(@RequestParam Map<String, Object> paramMap, HttpServletRequest request, HttpServletResponse response) throws Exception{
		svc1.fileDownload(paramMap, request, response);
	}
	
	@RequestMapping("/countDatDownloadList.do")
	public String countDatDownloadList(@RequestParam Map<String, Object> paramMap, ModelMap model) {
		model.addAttribute("result", svc2.countDatDownloadList(paramMap));
		return j;
	}
	
	
}