package com.istec.m1.mapper;

import org.apache.ibatis.annotations.Mapper;
import java.util.Map;

@Mapper
public interface TbM1InfoCustomerMapper {
    Long insertCustomer(Map<String, Object> map);
    Long updateCustomer(Map<String, Object> map);
    Long deleteCustomer(Map<String, Object> map);
}