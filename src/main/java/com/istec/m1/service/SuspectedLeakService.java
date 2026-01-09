package com.istec.m1.service;

import com.istec.m1.mapper.SuspectedLeakMapper;
import com.istec.m1.dto.SuspectedLeakDto;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class SuspectedLeakService {

    private final SuspectedLeakMapper suspectedLeakMapper;

    public List<Map<String, Object>> getSuspectedLeaks(Map<String, Object> param) {
        return suspectedLeakMapper.suspectedLeaks(param);
    }

    public SuspectedLeakDto updateReceiveConsent(SuspectedLeakDto dto) {
        suspectedLeakMapper.agreeReceive(dto);
        return dto;
    }

    /**
     * 라벨 프린트 히스토리 저장 (UPSERT)
     * @param params admin_no, cust_name, zipcode, addr
     */
    public void saveLabelPrintHistory(Map<String, Object> params) {
        suspectedLeakMapper.insertLabelPrintHistory(params);
    }
}
