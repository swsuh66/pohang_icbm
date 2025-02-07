package com.istec.m1.auth;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Service;

import com.istec.m1.service.QueryService;

@Service
public class CustomLoginHandler {
	
	@Autowired
    private QueryService queryService;

	private static final Logger logger = LoggerFactory.getLogger(CustomAuthenticationProvider.class);

	public Authentication authenticateLogin(String userId, String userPw, String loginType) {
		
		HashMap<String, Object> userInfo = getUserinfo(userId); 
		if(userInfo != null) {
			
			userInfo.put("tmpUserPwd", userPw);
			userInfo.put("loginType", loginType);			
			
			return getToken(userInfo);
			
		} else {
		
			logger.info("Fail Auto-LogIn.");
			throw new BadCredentialsException("Bad credentials");
			
		}		
				
	};
	
	protected UsernamePasswordAuthenticationToken getToken(HashMap<String, Object> userInfo) {
		
		String userId = (String)userInfo.get("userId");
		String userPw = null;
		
		if(userInfo.containsKey("userPwd"))
			userPw = (String)userInfo.get("userPwd");
		
		List<GrantedAuthority> roles = new ArrayList<GrantedAuthority>();
		roles.add(new SimpleGrantedAuthority("ROLE_USER"));
		UsernamePasswordAuthenticationToken authReq = new UsernamePasswordAuthenticationToken(userId, userPw, roles);
		authReq.setDetails(new CustomUserDetails(userInfo));

		return authReq;
		
	};


	protected HashMap<String, Object> getUserinfo(String user_id) {
    	
    	List<HashMap<String, Object>> result;
    	
    	String qid = "mars.icbm.map1.userInfo";
    	
		Map<String, Object> parmMap = new HashMap<String, Object>();
		parmMap.put("userId", user_id);
		
		result = queryService.select(qid, parmMap);
		
		if(result != null && result.size() == 1) 								
			return result.get(0);
		
		return null;
    };
    
}