package com.istec.m1.auth;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
 
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
 
public class CustomUserDetails implements UserDetails {
 
    private static final long serialVersionUID = -4450269958885980297L;
    private String username;
    private String sitename;
    private String sccocode;
    private String password;
    private int errorCnt;
    private HashMap<String, Object> userinfo;
    
    public CustomUserDetails(String userName, String password)
    {
        this.username = userName;
        this.password = password;
    }
    public CustomUserDetails(HashMap<String, Object> userinfo)
    {
    	this.userinfo = userinfo;
    	if(userinfo.get("userNm") != null)
    		this.username = (String)userinfo.get("userNm");
    	if(userinfo.get("siteNm") != null)
    		this.sitename = (String)userinfo.get("siteNm");
    	if(userinfo.get("sccoCd") != null) {
    		
    		Object obj = userinfo.get("sccoCd");    		
    		if(obj == null)
    			this.sccocode = null;
    		else
    			this.sccocode = (String)userinfo.get("sccoCd");
    			
    	}
    		
    	if(userinfo.get("userPwd") != null)
    		this.password = (String)userinfo.get("userPwd");
    	if(userinfo.get("errCnt") != null)
    		this.errorCnt = (int)userinfo.get("errCnt");
    }
     
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        List<GrantedAuthority> authorities = new ArrayList<GrantedAuthority>();   
        
        authorities.add(new SimpleGrantedAuthority("ROLE_USER"));
        
        int roll = Integer.parseInt((String)this.userinfo.get("rollCd"));
        if(roll > 5) 
        	authorities.add(new SimpleGrantedAuthority("ROLE_ADMIN"));
        
        return authorities;
    }

    public int getUserRoll() {
    	int userRoll = 0;
    	if(userinfo != null)
    		userRoll = Integer.parseInt((String)this.userinfo.get("rollCd"));
        return userRoll;
    }
    
    public String getUserNm() {
    	String userNm = null;
    	if(userinfo != null)
    		userNm = (String)this.userinfo.get("userNm");
        return userNm;
    }

    public int getSiteLv() {
    	int siteLv = 0;
    	
    	if(userinfo != null) {
    		if (this.userinfo.get("siteLv") != null) {
    			siteLv = Integer.parseInt(String.valueOf(this.userinfo.get("siteLv")));
    		}    			
    			
				/*if ( this.userinfo.get("siteSq") instanceof Integer ) 			
					siteSq = (int)this.userinfo.get("siteSq");			
					else 					
					siteSq = Integer.parseInt(String.valueOf(this.userinfo.get("siteSq")));*/
    	}    		
    		//groupSq = Integer.parseInt(String.valueOf(this.userinfo.get("groupSq")));
        //return siteLv;
    	return 1;
        
    }
    public int getSiteSq() {
    	int siteSq = 0;
    	if(userinfo != null)
    		if (this.userinfo.get("siteSq") != null)
    			siteSq = (Integer)this.userinfo.get("siteSq");
    		//groupSq = Integer.parseInt(String.valueOf(this.userinfo.get("groupSq")));
        return siteSq;
    }
    public int getuserSq() {
    	int userSq = 0;
    	if(userinfo != null)
    		if (this.userinfo.get("userSq") != null)
    			userSq = (Integer)this.userinfo.get("userSq");
    		//groupSq = Integer.parseInt(String.valueOf(this.userinfo.get("groupSq")));
        return userSq;
    }

    @Override
    public String getPassword() {
        return password;
    }
  
    @Override
    public String getUsername() {
        return username;
    }
  
    public String getSitename() {
        return sitename;
    }

    public String getSccocode() {
        return sccocode;
    }
      

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }
  
    @Override
    public boolean isAccountNonLocked() {
        return true;
    }
  
    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }
  
    @Override
    public boolean isEnabled() {
        return true;
    }
	public int getErrorCnt() {
		return errorCnt;
	}
	public void setErrorCnt(int errorCnt) {
		this.errorCnt = errorCnt;
	}
	
	
	public HashMap<String, Object> getUserInfo() {
		return userinfo;
	}
    
}
