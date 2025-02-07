package com.istec.m1.controller;

import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class TestControllerRts {

	@RequestMapping(value = "/NbIot/CommercialChange/{cseid}/{servicecode}", method = RequestMethod.POST)
	@ResponseBody
	public void nbiot_CommercialChange(@PathVariable("cseid") final String cseid,
			@PathVariable("servicecode") final String servicecode, HttpServletResponse response) throws Exception {
		System.out.println(cseid + "   |||   " + servicecode);
	}
	
	@RequestMapping(value = "/NbIot/DevReset/{cseid}", method = RequestMethod.POST)
	@ResponseBody
	public void nbiot_resetmessage(@PathVariable("cseid") final String cseid, HttpServletResponse response)
			throws Exception {
		System.out.println(cseid);
	}	
	

	@RequestMapping(value = "/NbIot/Cycle/{cseid}/{meterread_cycle}/{send_cycle}", method = RequestMethod.POST)
	@ResponseBody
	public void nbiot_cyclemessage(@PathVariable("cseid") final String cseid,
			@PathVariable("meterread_cycle") final String meterread_cycle,
			@PathVariable("send_cycle") final String send_cycle, HttpServletResponse response) throws Exception {
		System.out.println(cseid + "   |||   " + meterread_cycle+ "   |||   " + send_cycle);
	}	
}
