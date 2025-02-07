package com.istec.m1.auth;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;

import org.springframework.stereotype.Component;
import org.springframework.web.context.WebApplicationContext;
import org.springframework.web.context.support.WebApplicationContextUtils;

import com.istec.m1.defines.Define;
import com.istec.m1.service.SessionService;

@Component
public class CustomHttpSessionListener implements HttpSessionListener {
	
	//private static Map<String, HttpSession> _sessions = new ConcurrentHashMap<String, HttpSession>();
	//private static int _sessions_count = 0;
	
	@Override
    public void sessionCreated(HttpSessionEvent event){
		openSession(event);
    }
    
	@Override
    public void sessionDestroyed(HttpSessionEvent event){
		//_sessions_count --;
		closeSession(event);
    }

	private void openSession(HttpSessionEvent event) {
        
	}

	private void closeSession(HttpSessionEvent event) {
		
        HttpSession session = event.getSession();
        
        Map<String, Object> parmMap = new HashMap<String, Object>();
        
        parmMap.put(Define.Session.SESSION_ID, session.getId());
        parmMap.put(Define.Session.STAT_CD, "3");
        
        WebApplicationContext wac = WebApplicationContextUtils.getRequiredWebApplicationContext(session.getServletContext());
        SessionService ss = (SessionService)wac.getBean(SessionService.class);
        ss.closeSessionInfo(parmMap);
	}
}
