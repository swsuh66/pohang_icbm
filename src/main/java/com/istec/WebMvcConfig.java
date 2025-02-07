package com.istec;

import java.util.Locale;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.support.ResourceBundleMessageSource;
import org.springframework.web.context.request.RequestContextListener;
import org.springframework.web.servlet.LocaleResolver;
import org.springframework.web.servlet.i18n.AcceptHeaderLocaleResolver;
import org.springframework.web.servlet.i18n.LocaleChangeInterceptor;
import org.springframework.web.servlet.view.BeanNameViewResolver;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ViewResolverRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

public class WebMvcConfig implements WebMvcConfigurer  {
    @Bean
    public ResourceBundleMessageSource messageSource() {
        ResourceBundleMessageSource messageSource = new ResourceBundleMessageSource();
        messageSource.setBasename("messages.res-messages");
        messageSource.setDefaultEncoding("UTF-8");
        return messageSource;
    }

    @Bean
    public LocaleResolver localeResolver() {
        AcceptHeaderLocaleResolver localeResolver = new AcceptHeaderLocaleResolver();
        localeResolver.setDefaultLocale(Locale.KOREAN); // 기본 로케일 설정
        // localeResolver.setDefaultLocale(Locale.ENGLISH); // 영어로 설정할 경우
        return localeResolver;
    }

    @Bean
    public LocaleChangeInterceptor localeChangeInterceptor() {
        LocaleChangeInterceptor interceptor = new LocaleChangeInterceptor();
        interceptor.setParamName("language"); // 언어 변경 매개변수 설정
        return interceptor;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(localeChangeInterceptor());
    }

    @Override
    public void configureViewResolvers(ViewResolverRegistry registry) {
        BeanNameViewResolver viewResolver = new BeanNameViewResolver();
        viewResolver.setOrder(0);
        registry.viewResolver(viewResolver);
    }

    @Bean 	
    public RequestContextListener requestContextListener()
    {
        return new RequestContextListener();	
    }

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")  // 모든 요청에 대해 CORS를 활성화
                .allowedOrigins("*")  // 모든 origin을 허용 (실제 운영 환경에서는 필요에 따라 조정)
                .allowedMethods("GET", "POST", "PUT", "DELETE")  // 허용할 HTTP 메서드 지정
                .allowedHeaders("*");
    }
}
