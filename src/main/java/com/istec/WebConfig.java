package com.istec;

import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.filter.CharacterEncodingFilter;
import com.istec.m1.common.SimpleCORSFilter;

@Configuration
public class WebConfig {
    @Bean
    public FilterRegistrationBean<CharacterEncodingFilter> encodingFilter() {
        FilterRegistrationBean<CharacterEncodingFilter> registrationBean = new FilterRegistrationBean<>();
        CharacterEncodingFilter characterEncodingFilter = new CharacterEncodingFilter();
        characterEncodingFilter.setEncoding("UTF-8");
        characterEncodingFilter.setForceEncoding(true);
        registrationBean.setFilter(characterEncodingFilter);
        registrationBean.addUrlPatterns("/*");
        return registrationBean;
    }

    @Bean
    public FilterRegistrationBean<SimpleCORSFilter> corsFilter() {
        FilterRegistrationBean<SimpleCORSFilter> registrationBean = new FilterRegistrationBean<>();
        registrationBean.setFilter(new SimpleCORSFilter());
        registrationBean.addUrlPatterns("/weather/*");
        return registrationBean;
    }

}
