package com.istec.m1.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.istec.m1.dto.AlertDto;
import com.istec.m1.service.AlertService;

@RestController
@RequestMapping("/api/alerts")
public class AlertController {
    private final AlertService alertService;

    public AlertController(AlertService alertService) {
        this.alertService = alertService;
    }

    // 알림톡(누수의심)대상 가져오기
    @GetMapping("/users")
    public ResponseEntity<List<AlertDto>> getUsers() {
        return ResponseEntity.ok(alertService.getUsers());
    }

    // 알림톡 전송 기록 저장
    @PostMapping
    public ResponseEntity<AlertDto> createAlertHistory(@RequestBody AlertDto alertDto) {
        return ResponseEntity.ok(alertService.createAlertHistory(alertDto));
    }
}
