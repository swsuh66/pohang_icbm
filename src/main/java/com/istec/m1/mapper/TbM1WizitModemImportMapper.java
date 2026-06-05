package com.istec.m1.mapper;

import com.istec.m1.dto.TbM1WizitModemInfoImportDto;
import org.apache.ibatis.annotations.Mapper;

import java.util.Map;
import java.util.List;

@Mapper
public interface TbM1WizitModemImportMapper {
    List<TbM1WizitModemInfoImportDto> selectAll();

    int insertImport(Map<String, Object> map);
    int updateWizitModem(Map<String, Object> map);

    TbM1WizitModemInfoImportDto selectById(String modemId);

    int existsModemId(String modemId);
    String selectModemIdByDevNo(String devNo);
}
