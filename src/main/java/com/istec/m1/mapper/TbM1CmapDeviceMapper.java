package com.istec.m1.mapper;

import org.apache.ibatis.annotations.Mapper;
import java.util.Map;

@Mapper
public interface TbM1CmapDeviceMapper {
    int insertDevice(Map<String, Object> map);
    int updateDevice(Map<String, Object> map);
}
