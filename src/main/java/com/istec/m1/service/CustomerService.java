package com.istec.m1.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.transaction.annotation.Transactional;

import com.istec.m1.mapper.TbM1CmapDeviceMapper;
import com.istec.m1.mapper.TbM1InfoCustomerMapper;
import com.istec.m1.mapper.TbM1InfoPointMapper;

public class CustomerService {

    private final TbM1CmapDeviceMapper tbM1CmapDeviceMapper;
	private final TbM1InfoCustomerMapper tbM1InfoCustomerMapper;
	private final TbM1InfoPointMapper tbM1InfoPointMapper;	

    public CustomerService(TbM1CmapDeviceMapper tbM1CmapDeviceMapper,
                           TbM1InfoCustomerMapper tbM1InfoCustomerMapper,
                           TbM1InfoPointMapper tbM1InfoPointMapper) {
        this.tbM1CmapDeviceMapper = tbM1CmapDeviceMapper;
        this.tbM1InfoCustomerMapper = tbM1InfoCustomerMapper;
        this.tbM1InfoPointMapper = tbM1InfoPointMapper;
    }

    @Transactional(timeout = 900) // 15분
	public void deleteCustomerInfo(List<Map<String, Integer>> pointSqList) throws Exception {
        for (Map<String, Integer> item : pointSqList) {
            Integer custSq = item.get("custSq");
            Integer pointSq = item.get("pointSq");
            if (custSq == null || pointSq == null) {
                throw new IllegalArgumentException("custSq and pointSq must not be null");
            }

            // tb_m1_info_customer 데이터 삭제
            Map<String, Object> customerMap = new HashMap<>();	
            customerMap.put("custSq", custSq); 
            tbM1InfoCustomerMapper.deleteCustomer(customerMap);

            // tb_m1_cmap_device 데이터 삭제
            Map<String, Object> deviceMap = new HashMap<>();
            deviceMap.put("pointSq", pointSq); 
            tbM1CmapDeviceMapper.deleteDevice(deviceMap); 

            // tb_m1_info_point 데이터 삭제
            Map<String, Object> pointMap = new HashMap<>();
            pointMap.put("pointSq", pointSq); 
            tbM1InfoPointMapper.deletePoint(pointMap);
        }
	}
}
