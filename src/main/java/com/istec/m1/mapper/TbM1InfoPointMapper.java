package com.istec.m1.mapper;

import org.apache.ibatis.annotations.Mapper;
import java.util.Map;

@Mapper
public interface TbM1InfoPointMapper {
    Long insertPoint(Map<String, Object> map);
    Long updatePoint(Map<String, Object> map);
    Long deletePoint(Map<String, Object> map);
}