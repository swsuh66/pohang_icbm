package com.istec.m1.manager;

import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;

public class SessionManager implements HttpSessionListener {

	@Override
	public void sessionCreated(HttpSessionEvent se) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void sessionDestroyed(HttpSessionEvent se) {
		
		String sessionId = se.getSession().getId();
		
		FileManager fm = FileManager.getInstance();
		
		if( fm.cancelTimer(sessionId) ) 
			fm.removeData(sessionId);
						
	}
	
}


