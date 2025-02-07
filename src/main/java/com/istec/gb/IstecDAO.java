package com.istec.gb;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface IstecDAO {
	
	public int countDatDownloadList(Map<String, Object> paramMap);
	public List<Object> getDatDownloadList();
	
}
