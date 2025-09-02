package com.istec.m1.dto;

import lombok.Data;

@Data
public class TbM1CmapDeviceDto {
    private String devNo;         // 단말주번호
    private String subDevNo;      // 단말부번호
    private String pointSq;       // 장비번호 (nullable)
    private String companySq;     // 단말제조사 코드 (nullable)
    private String amiType;       // 통신사 (KT, LG, SK)
    private String insDt;         // 입력일자 (문자열 → ::timestamp 처리)
    private String updDt;         // 수정일자
}