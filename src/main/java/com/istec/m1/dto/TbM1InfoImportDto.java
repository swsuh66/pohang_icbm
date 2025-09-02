package com.istec.m1.dto;

import lombok.Data;

@Data
public class TbM1InfoImportDto {
    private String dataSq;  // 순번
    private String custNm;   // 수용가명
    private String adminNo;  // 수용가번호
    private String addr;  // 구주소
    private String addrNew;  // 신주소
    private String locLng;  // 경도
    private String locLat;  // 위도
    private String useType;  // 업종
    private String siteNm;   // 소속
    private String blkNm;  // 블럭
    private String custPhone;  // 수용가 전화번호
    private String setYears;  // 수용가 대상 년도
    private String readOpr;  // 검침원
    private String checkDay;  // 검침일
    private String meterNo;  // 계량기번호
    private String pipeDia;   // 구경
    private String amiType;   // 통신
    private String subDevNo;   // 단말 부번호
    private String devNo;   // 단말 주번호
    private String companyNm;  // 단말회사
    private String setDt; // 단말설치일
    private String tokenKey; // 토큰 키
}
