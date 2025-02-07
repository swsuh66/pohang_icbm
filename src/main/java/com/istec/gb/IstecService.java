package com.istec.gb;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.ibatis.session.SqlSessionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service("istecService")
public class IstecService {
	
	@Resource(name="sqlSessionFactory")
	private SqlSessionFactory sqlSessionFactory;
	
	@Autowired
	private IstecDAO dao;
	
	private static Logger logger = LoggerFactory.getLogger(IstecService.class);
	
	public int countDatDownloadList(Map<String, Object> paramMap) {
		return (int) dao.countDatDownloadList(paramMap);
	}
	
	public List<Object> getDatDownloadList(){
		return (List<Object>) dao.getDatDownloadList();
	}
	
	
	
}
