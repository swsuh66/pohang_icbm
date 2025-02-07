package com.istec.m1.auth;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
//import org.springframework.security.core.context.SecurityContextHolder;
//import org.springframework.security.web.authentication.WebAuthenticationDetails;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestAttributes;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

//import com.istec.m1.common.PasswordEncoding;
import com.istec.m1.common.SHAPasswordEncoder;
import com.istec.m1.service.QueryService;
//import com.istec.m1.service.SessionService;

@Component
public class CustomAuthenticationProvider implements AuthenticationProvider { 

	@Autowired
    private QueryService queryService;

	private static final Logger logger = LoggerFactory.getLogger(CustomAuthenticationProvider.class);
     
    @Override
    public boolean supports(Class<?> authentication) {
        return authentication.equals(UsernamePasswordAuthenticationToken.class);
    }
  
    @Override
    public Authentication authenticate(Authentication authentication) throws AuthenticationException {
    	
        String user_id = (String)authentication.getPrincipal();    
        String user_pw = (String)authentication.getCredentials();
        
        if (user_id.isEmpty()) {
        	
			logger.info("Fail LogIn: empty login-id.");
			throw new BadCredentialsException("Bad credentials");
			
		}
      
        HttpServletRequest request = null;
        RequestAttributes attribs = RequestContextHolder.getRequestAttributes();
        if (attribs != null) {
            request = ((ServletRequestAttributes) attribs).getRequest();
        }
        
        if(request == null) {
        	
        	logger.info("Fail Auto-LogIn.");
			throw new BadCredentialsException("Bad credentials");
			
        }
        
        String loginType = request.getParameter("loginType");
        HttpSession session = request.getSession();
        HashMap<String, Object> userInfo = null;
        
        userInfo = authenticateLogin(session, user_id, user_pw, loginType);
        
        if(userInfo == null) 
        	return null;
   
        userInfo.put("loginType", loginType);
        CustomUserDetails userDetails = new CustomUserDetails(userInfo);

		List<GrantedAuthority> roles = new ArrayList<GrantedAuthority>();
		roles.add(new SimpleGrantedAuthority("ROLE_USER"));
		
		UsernamePasswordAuthenticationToken authReq = new UsernamePasswordAuthenticationToken(user_id, user_pw, roles);
		authReq.setDetails(userDetails);

		return authReq;
    }

	
	protected HashMap<String, Object> authenticateLogin(HttpSession session, String userId, String userPw, String loginType) {
		
		HashMap<String, Object> userInfo = getUserinfo(userId);
		
		@SuppressWarnings("unchecked")
		HashMap<String, Object> failInfo = (HashMap<String, Object>) (session.getAttribute("login_fail_info"));
		if(failInfo == null) failInfo = new HashMap<String, Object>(); 

		
		if(userInfo == null) {
			
			failInfo.put("exception", "userid");			
			session.setAttribute("login_fail_info", failInfo);
			
			logger.info("Fail LogIn: UserId" + userId);
			
			return null;
		}

		
		String dbPw = (String)userInfo.get("userPwd");
		
        SHAPasswordEncoder shaPasswordEncoder = new SHAPasswordEncoder(512);
		shaPasswordEncoder.setEncodeHashAsBase64(true);
		shaPasswordEncoder.setSalt(userId);
		userPw = shaPasswordEncoder.encode(userPw);
		
		if(!userPw.equals(dbPw)) {

			failInfo.put("exception", "password");			
			session.setAttribute("login_fail_info", failInfo);

			logger.info("Fail LogIn: Password" + userPw);
			
			return null;
		}

		session.removeAttribute("login_fail");

		return userInfo;
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

