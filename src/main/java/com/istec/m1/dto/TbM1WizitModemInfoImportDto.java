package com.istec.m1.dto;

import lombok.Data;

@Data
public class TbM1WizitModemInfoImportDto {
    private String dataSq;  // 순번
    private String modemId;   // 모뎀ID
    private String deviceNo;  // 디바이스주번호
    private String subDeviceNo;  // 디바이스부번호
    private String meterId;  // 계량기ID
    private String IMEI;  // IMEI
    private String IMSI;  // IMSI
}
