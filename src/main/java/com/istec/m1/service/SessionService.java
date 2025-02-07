package com.istec.m1.service;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import javax.annotation.PostConstruct;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

//import com.istec.m1.controller.LoginController;
import com.istec.m1.dao.QueryDao;
import com.istec.m1.defines.Define;

@Service
public class SessionService {

	private static final Logger logger = LoggerFactory.getLogger(SessionService.class);
	
	private static Map<String, Integer> _sessions = new ConcurrentHashMap<String, Integer>();
	
	private static int _sessions_count = 0;
	
	@Autowired
    private QueryDao queryDao;
	
	@PostConstruct
    public void init() {
		
		Map<String, Object> parmMap = new HashMap<String, Object>();
		
		queryDao.update("mars.icbm.visitelog.cleanupSession", parmMap);
		
    }

	public int openSessionInfo(Map<String, Object> parmMap) {
				
		String ssId = (String) parmMap.get(Define.Session.SESSION_ID);
		boolean isExist = parmMap.containsKey(Define.Session.LOG_SQ);
		String refer = (String)parmMap.get(Define.Session.REFER);

    	int ret = queryDao.insert("mars.icbm.visitelog.openSession", parmMap);
		
		Integer logSq = (Integer)parmMap.get(Define.Session.LOG_SQ);
		
		_sessions.put(ssId, logSq);
		_sessions_count ++;
	
		return ret;

    }
	
	public int closeSessionInfo(Map<String, Object> parmMap) {
		
		String ssId = (String) parmMap.get(Define.Session.SESSION_ID);
		Integer logSq = (Integer)_sessions.get(ssId);
		
		int ret = 0;
		
		if(logSq != null) {
			
			parmMap.put(Define.Session.LOG_SQ, logSq);
			ret = queryDao.insert("mars.icbm.visitelog.closeSession", parmMap);

			logger.info("remove session: {}", ssId);
			
			_sessions.remove(ssId);
			_sessions_count --;
			
		}

		return ret;
    }

	public int loginSessionInfo(Map<String, Object> parmMap) {

    	return openSessionInfo(parmMap);

		
    }
	public int logoutSessionInfo(Map<String, Object> parmMap) {
		return closeSessionInfo(parmMap);
		
		
    }
	public int logoutSessionInfo(String ssId) {
		
		HashMap<String, Object> parmMap = new HashMap<String, Object>();
		
    	parmMap.put(Define.Session.SESSION_ID, ssId);
    	parmMap.put(Define.Session.STAT_CD, "2");
    	
    	return logoutSessionInfo(parmMap);
    	
	}
	
	public int getSessionCount() {
		
		return _sessions_count;
		
	}
}
