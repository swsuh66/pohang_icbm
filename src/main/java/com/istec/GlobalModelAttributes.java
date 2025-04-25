package com.istec;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

@ControllerAdvice
public class GlobalModelAttributes {

    @Autowired
    private AppVersionProvider versionProvider;

    @ModelAttribute("systemVersion")
    public String injectSystemVersion() {
        return versionProvider.getVersion();
    }
}