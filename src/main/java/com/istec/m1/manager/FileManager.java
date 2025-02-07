package com.istec.m1.manager;

import java.util.HashMap;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

public class FileManager {

	private static FileManager sm = null;

	private Map<String, Map<String, Dto>> dataInfo;	
	
	/* [dataInfo format]
	session1:{
		tokenKey1:{
			data: Object,
			timer: Object,
	
		},
		tokenKey2:{
			data: Object,
			timer: Object,
	
		}
	},	
	session2:{
		tokenKey3:{
			data: Object,
			timer: Object,
	
		},
		tokenKey4:{
			data: Object,
			timer: Object,	
		}
	} 
	*/

	private FileManager() {

		dataInfo = new HashMap<String, Map<String, Dto>>();		

	}

	public static FileManager getInstance() {

		if (sm == null) {
			sm = new FileManager();
		}

		return sm;
	}
	
	public Map<String, Map<String, Dto>> getDataInfo() {
		return dataInfo;
	}
	
	public Object getDataInfo(String sessionId, String key) {

		if (dataInfo.containsKey(sessionId)) {

			if (dataInfo.get(sessionId).containsKey(key))
				return dataInfo.get(sessionId).get(key).getData();
			
		}

		return null;
		
	}

	public void setDataInfo(String sessionId, String key, Object data, long interval) {

		Timer timer = new Timer();
		timer.schedule( new FileTask(sessionId, key), interval );
		
		Dto dto = new Dto(data, timer);
		
		if(dataInfo.containsKey(sessionId)) {
			
			dataInfo.get(sessionId).put(key, dto);
			
		} else {
			
			Map<String, Dto> map = new HashMap<String, Dto>();
			map.put(key, dto);
			dataInfo.put(sessionId, map);	
			
		}			
		
	}
	
	public boolean resetTimer(String sessionId, String key, long interval) {
		
		if (dataInfo.containsKey(sessionId)) {
			
			if(dataInfo.get(sessionId).containsKey(key)) {
				
				dataInfo.get(sessionId).get(key).getTimer().cancel();
				
				Timer timer = new Timer();
				timer.schedule( new FileTask(sessionId, key), interval );
				
				dataInfo.get(sessionId).get(key).setTimer(timer);
				
			}
			
			return true;	
		}
		
		return false;			
	}
	
	public boolean cancelTimer(String sessionId, String key) {
		
		if (dataInfo.containsKey(sessionId)) {
			
			if(dataInfo.get(sessionId).containsKey(key)) 
				dataInfo.get(sessionId).get(key).getTimer().cancel();
			
			return true;	
		}
		
		return false;			
	}
	
	public boolean cancelTimer(String sessionId) {
		
		if (dataInfo.containsKey(sessionId)) {
		
			for( String key : dataInfo.get(sessionId).keySet() )
				dataInfo.get(sessionId).get(key).getTimer().cancel();
			
			return true;	
		}
		
		return false;				
	}
	
	public boolean removeData(String sessionId, String key) {
		
		if (dataInfo.containsKey(sessionId)) {
		
			if( dataInfo.get(sessionId).containsKey(key) )
				dataInfo.get(sessionId).remove(key);
			
			return true;	
		}
		
		return false;				
	}
	
	public boolean removeData(String sessionId) {
		
		if (dataInfo.containsKey(sessionId)) {
		
			dataInfo.remove(sessionId);
			
			return true;	
		}
		
		return false;				
	}
		
}

class FileTask extends TimerTask{

	private String key;
	private String sessionId;

	public FileTask(String sessionId, String key) {

		this.sessionId = sessionId;
		this.key = key;		

	}

	@Override
	public void run() {
		
		Map<String,  Map<String, Dto>> dataInfo = FileManager.getInstance().getDataInfo();
		
		if(dataInfo.containsKey(sessionId)) {

			if(dataInfo.get(sessionId).containsKey(key)) 				
				dataInfo.get(sessionId).remove(key);

		}
		
	}

}

class Dto {
	
	private Object data;
	private Timer timer;
	
	public Dto(Object data, Timer timer) {
				
		this.data = data;
		this.timer = timer;
		
	}

	public Object getData() {
		return data;
	}

	public Timer getTimer() {
		return timer;
	}

	public void setData(Object data) {
		this.data = data;
	}

	public void setTimer(Timer timer) {
		this.timer = timer;
	}

}


