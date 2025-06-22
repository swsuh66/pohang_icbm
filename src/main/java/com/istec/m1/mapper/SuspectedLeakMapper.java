package com.istec.m1.mapper;

import com.istec.m1.dto.SuspectedLeakDto;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Map;

@Mapper
public interface SuspectedLeakMapper {

    // 알림톡(누수의심)대상 가져오기
    List<Map<String, Object>> suspectedLeaks(Map<String, Object> param);

    // 알림톡 수신동의 /해제
    int agreeReceive(SuspectedLeakDto dto);
}