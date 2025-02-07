package com.istec.test;

import java.util.Timer;
import java.util.TimerTask;

import java.io.PrintWriter;
import java.io.IOException;
import javax.servlet.ServletException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/test")
public class TestController {
	
	final String j = "jsonString"; 
	
	public static int i = 0;
	
	long delay = 0L;
	long period = 1000L;
	
	TimerTask task = new TimerTask() {
		public void run() {
			if(10 == i) {
				cancel();
			}
		}
	};
	
	Timer timer = new Timer("Timer");
	
	@RequestMapping("/test")
	public String test() {
		return "test/test";
	}
	
	@RequestMapping("/sseTest.do")
	public String sse(HttpServletRequest request, HttpServletResponse response, ModelMap model) 
	throws ServletException, IOException{
		
		response.setContentType("text/event-stream");
		response.setCharacterEncoding("UTF-8");
		
		PrintWriter writer = response.getWriter();
		
		for (int i = 1; i <= 10; i++) {
			
			writer.write("data: { \"message\" : \"number : " + i + "\" }\n\n");
			
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
		
		writer.close();
		
//		timer.schedule(task, delay, period);
		
		model.addAttribute("result", 1);
		
		return j;
		
	}
	
}