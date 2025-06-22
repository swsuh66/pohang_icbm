package com.istec.m1.dto;

import lombok.Data;
@Data
public class SuspectedLeakDto {
    private int custSq; // 수용가번호
    private String custName; // 수용가명
    private String custPhone; // 수용가전화번호
    private boolean receiveConsent; // 수신동의여부
}
