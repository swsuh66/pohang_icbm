package com.istec.m1.service;

import java.util.List;

import com.istec.m1.dto.AlertDto;
import com.istec.m1.mapper.AlertMapper;

public class AlertService {

    private final AlertMapper alertMapper;
    
    public AlertService(AlertMapper alertMapper) {
        this.alertMapper = alertMapper; 
    }   

    public List<AlertDto> getUsers() {   
        // 알림톡(누수의심)대상 가져오기
        return alertMapper.getUsers();
     }

     public AlertDto createAlertHistory(AlertDto alertDto) {
        // 알림톡 전송 기록 저장
        alertMapper.createAlertHistory();
        return alertDto;
     }
}
