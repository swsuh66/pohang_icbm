package com.istec;

import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.security.web.header.writers.StaticHeadersWriter;

import com.istec.m1.auth.CustomAccessDeniedHandler;
import com.istec.m1.auth.CustomAuthEntryPoint;
import com.istec.m1.auth.CustomAuthenticationProvider;
import com.istec.m1.auth.CustomLoginSuccessHandler;
import com.istec.m1.auth.RestLoginFailureHandler;
import com.istec.m1.auth.RestLoginSuccessHandler;
import com.istec.m1.auth.RestLogoutSuccessHandler;
import com.istec.m1.auth.UnauthorizedEntryPoint;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.ImportResource;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;

@Configuration
@EnableWebSecurity
@ImportResource({"classpath:config/security-context.xml"})
public class SecurityConfig extends WebSecurityConfigurerAdapter  {

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        /* 
         * 
        
        http
        .authorizeRequests()

        http
        .authorizeRequests()
            .antMatchers("/query/json/**").hasRole("USER")
            .and()
        .httpBasic()
            .and()
        .formLogin()
            .loginProcessingUrl("/loginProcess")
            .usernameParameter("username")
            .passwordParameter("password")
            .successHandler(restLoginSuccessHandler())
            .failureHandler(restLoginFailureHandler())
            .and()
        .logout()
            .logoutUrl("/logout")
            .deleteCookies("JSESSIONID")
            .logoutSuccessHandler(restLogoutSuccessHandler());

        http
            .authorizeRequests()
                .antMatchers("/autoLogin", "/login", "/auth/fail", "/resources/**", "/echo/**").permitAll()
                .antMatchers("/admin").hasRole("ADMIN")
                .antMatchers("/test").hasRole("ADMIN")
                .anyRequest().hasRole("USER")
                .and()
            .formLogin()
                .loginPage("/login")
                .loginProcessingUrl("/loginProcess")
                .usernameParameter("id")
                .passwordParameter("pw")
                .defaultSuccessUrl("/main")
                .failureUrl("/auth/fail")
                .successHandler(customLoginSuccessHandler())
                .and()
            .exceptionHandling()
                .accessDeniedHandler(customAccessDeniedHandler())
                .authenticationEntryPoint(unauthorizedEntryPoint())
                .and()
            .sessionManagement()
                .maximumSessions(1000)
                .expiredUrl("/auth/duplicate");
                */
    }

    @Bean
    public RestLoginSuccessHandler restLoginSuccessHandler() {
        return new RestLoginSuccessHandler();
    }

    @Bean
    public RestLoginFailureHandler restLoginFailureHandler() {
        return new RestLoginFailureHandler();
    }

    @Bean
    public RestLogoutSuccessHandler restLogoutSuccessHandler() {
        return new RestLogoutSuccessHandler();
    }

    @Bean
    public CustomAuthEntryPoint customAuthEntryPoint() {
        return new CustomAuthEntryPoint();
    }

    @Bean
    public CustomAuthenticationProvider customAuthenticationProvider() {
        return new CustomAuthenticationProvider();
    }

    @Bean
    public AuthenticationSuccessHandler customLoginSuccessHandler() {
        CustomLoginSuccessHandler handler = new CustomLoginSuccessHandler();
        handler.setDefaultTargetUrl("/main");
        return handler;
    }
    
    @Bean
    public AccessDeniedHandler customAccessDeniedHandler() {
        CustomAccessDeniedHandler handler = new CustomAccessDeniedHandler();
        handler.setErrorPage("err403");
        return handler;
    }
    
    @Bean
    public UnauthorizedEntryPoint unauthorizedEntryPoint() {
        UnauthorizedEntryPoint entryPoint = new UnauthorizedEntryPoint();
        return entryPoint;
    }
}
