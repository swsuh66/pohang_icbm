package com.istec;

import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.ModelAttribute;

@Component
public class AppVersionProvider {

    public String getVersion() {
        Package pkg = getClass().getPackage();
        String version = pkg != null ? pkg.getImplementationVersion() : null;
        return version != null ? version : "unknown";
    }

    @ModelAttribute("systemVersion")
    public String injectSystemVersion() {
        return getVersion();
    }
}
