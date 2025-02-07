package com.istec.m1.controller;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.istec.m1.service.QueryService;

import java.util.HashMap;
import java.util.Map;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;


@RestController
@RequestMapping("/icbm/api")
public class MainRestController {

    @Autowired
    QueryService queryService;

    @GetMapping("/hello")
    public String hello() {
        return "Hello, World!";
    }


    @PostMapping("/test2")
    @ResponseBody
    public Map<String, Object> postMethodName(@RequestBody Map<String, Object> entity) {
        Map<String, Object> result = new HashMap<String, Object>();
        
        return result;
    }

    
}
