package com.istec;

import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Import;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;
import org.springframework.boot.SpringApplication;

@SpringBootApplication()
//@EnableWebMvc
@Import({SecurityConfig.class, WebMvcConfig.class, AppConfig.class, WebConfig.class})
//@Import({SecurityConfig.class, WebMvcConfig.class,})
public class SpringBootRunApplication extends SpringBootServletInitializer {
    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(SpringBootRunApplication.class);
    }

    public static void main(String[] args) {
        SpringApplication.run(SpringBootRunApplication.class, args);
    }

}
