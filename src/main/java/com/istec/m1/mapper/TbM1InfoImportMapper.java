package com.istec.m1.mapper;

import com.istec.m1.dto.TbM1InfoImportDto;
import org.apache.ibatis.annotations.Mapper;

import java.util.Map;
import java.util.List;

@Mapper
public interface TbM1InfoImportMapper {
    List<TbM1InfoImportDto> selectAll();

    int insertImport(Map<String, Object> map);

    TbM1InfoImportDto selectById(Integer dataSq);
}
