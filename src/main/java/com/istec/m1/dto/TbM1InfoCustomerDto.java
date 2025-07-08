package com.istec.m1.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.sql.Timestamp;

@Data
public class TbM1InfoCustomerDto {
    private Integer custSq;              // 수용가정보 SEQ
    private String adminNo;              // 관리번호
    private String custName;             // 수용가 성명
    private String addr;                 // 주소
    private String addrNew;              // 새주소
    private String businessName;         // 상수업종명
    private BigDecimal pipeDiameter;     // 구경
    private String meterNo;              // 계량기번호
    private String mainMeter;            // 주구역계량기
    private String childMeter;           // 부구역계량기
    private Integer genNumber;           // 세대수
    private String readResponsi;         // 검침담당
    private String custPhone;            // 전화번호
    private String setYears;             // 대상년도
    private String remark;               // 비고
    private Timestamp insDt;             // 입력시간
    private Timestamp udtDt;             // 수정시간
    private Integer checkDay;            // 검침일
    private String note;                 // 메모
    private String meterPos;             // 계량기 위치
    private String imgSrcGum;
    private String imgSrcBf;
    private String imgSrcAf;
    private String imgSrcAdd;
    private Boolean receiveConsent;      // 수신동의
    private Timestamp consentDt;         // 수신동의 해제시간
}
