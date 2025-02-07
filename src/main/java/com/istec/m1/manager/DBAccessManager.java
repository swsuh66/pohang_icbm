package com.istec.m1.manager;

import java.util.ArrayList;
import java.util.List;

public class DBAccessManager {
	
	private static DBAccessManager dm = null;
	private List<String> info;	

	private DBAccessManager() {

		info = new ArrayList<String>();		

	}

	public static DBAccessManager getInstance() {

		if (dm == null) {
			dm = new DBAccessManager();
		}

		return dm;
	}
	
	public List<String> getDBAccessInfo(){
		return info;
	}
	
	public void setDBAccessInfo(String exSql){
		info.add(exSql);
	}
	
	public void removeDBAccessInfo(String exSql){
		
		if(info.contains(exSql))
			info.remove(exSql);
		
	}
	
}

