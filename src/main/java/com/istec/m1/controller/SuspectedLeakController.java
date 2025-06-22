package com.istec.m1.controller;

import com.istec.m1.service.SuspectedLeakService;
import com.istec.m1.dto.SuspectedLeakDto;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/suspected-leaks")
@RequiredArgsConstructor
public class SuspectedLeakController {
    private final SuspectedLeakService suspectedLeakService;

    // 알림톡(누수의심)대상 가져오기
    @GetMapping("/search")
    public List<Map<String, Object>> getSuspectedLeaks(@RequestParam Map<String, Object> param) {
        return suspectedLeakService.getSuspectedLeaks(param);
    }
    // 알림톡 신청 수용가 정보
    @GetMapping("/customer")
    public List<Map<String, Object>> getCustomer(@RequestParam Map<String, Object> param) {
        return suspectedLeakService.getSuspectedLeaks(param);
    }

    // 알림톡 수신 동의 및 해제
    @PutMapping("/agree")
    public ResponseEntity<SuspectedLeakDto> updateReceiveConsent(@RequestBody SuspectedLeakDto alertDto) {
        String phone = alertDto.getCustPhone();

        // 전화번호 유효성 검사 (010-1234-5678 형식)
        if (phone == null || !phone.matches("^010-\\d{4}-\\d{4}$")) {
            return ResponseEntity.badRequest().body(null);
        }
        return ResponseEntity.ok(suspectedLeakService.updateReceiveConsent(alertDto));
    }

    // 알림톡 송신 이력
    // @GetMapping("/send-history")
    // public List<Map<String, Object>> getLeaks(@RequestParam Map<String, Object> param) {
    //     return suspectedLeakService.getSuspectedLeaks(param);
    // }
}
