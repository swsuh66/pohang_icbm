package com.istec.m1.auth;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
 
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
 
public class CustomUserDetails_bk implements UserDetails {
 
    private static final long serialVersionUID = -4450269958885980297L;
    private String username;
    private String sitename;
    private String sccocode;
    private String password;
    private HashMap<String, Object> userinfo;
    
    public CustomUserDetails_bk(String userName, String password)
    {
        this.username = userName;
        this.password = password;
    }
    public CustomUserDetails_bk(HashMap<String, Object> userinfo)
    {
    	this.userinfo = userinfo;
        this.username = (String)userinfo.get("userNm");
        this.sitename = (String)userinfo.get("siteNm");
        this.sccocode = (String)userinfo.get("sccoCd");
        this.password = (String)userinfo.get("userPwd");
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
    public int getSiteSq() {
    	int siteSq = 0;
    	if(userinfo != null) {
    		if (this.userinfo.get("siteSq") != null)
    			siteSq = Integer.parseInt(String.valueOf(this.userinfo.get("siteSq")));
    	}    		
    		//groupSq = Integer.parseInt(String.valueOf(this.userinfo.get("groupSq")));
        return siteSq;
    }
    public int getuserSq() {
    	int userSq = 0;
    	if(userinfo != null) {
    		if (this.userinfo.get("userSq") != null)    			
    			userSq = Integer.parseInt(String.valueOf(this.userinfo.get("userSq")));
    	}
    		
    		//userSq = (Integer)this.userinfo.get("userSq");
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
}
