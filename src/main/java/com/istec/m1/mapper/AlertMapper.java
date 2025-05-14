package com.istec.m1.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import com.istec.m1.dto.AlertDto;

@Mapper
public interface AlertMapper {

    // 알림톡(누수의심)대상 가져오기
    List<AlertDto> getUsers();

    // 알림톡 전송 기록 저장
    int createAlertHistory();
}