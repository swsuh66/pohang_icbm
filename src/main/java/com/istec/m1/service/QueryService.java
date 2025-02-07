package com.istec.m1.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.istec.m1.dao.QueryDao;

@Service
public class QueryService {

	@Autowired
    private QueryDao queryDao;
	
	@Transactional
	public List<HashMap<String, Object>> select(String qid) {
    	return queryDao.select(qid);
    }
	
	@Transactional
	public List<HashMap<String, Object>> select(String qid, Map<String, Object> hashMap) {
    	return queryDao.select(qid, hashMap);
    }

	@Transactional
	public int insert(String qid, Map<String, Object> hashMap) {
    	return queryDao.insert(qid, hashMap);
    }

	@Transactional
	public int update(String qid, Map<String, Object> hashMap) {
    	return queryDao.update(qid, hashMap);
    }
	
	@Transactional
	public int delete(String qid, Map<String, Object> hashMap) {
    	return queryDao.delete(qid, hashMap);
    }


	@Transactional
	public int insert(String qid, List<Map<String, Object>> listMap) {
		return queryDao.insert(qid, listMap);
    }
	@Transactional
	public int update(String qid, List<Map<String, Object>> listMap) {
		return queryDao.update(qid, listMap);
    }
	@Transactional
	public int delete(String qid, List<Map<String, Object>> listMap) {
		return queryDao.delete(qid, listMap);
    }
}
