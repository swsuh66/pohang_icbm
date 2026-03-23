package com.istec.m1.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.ResultHandler;
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

	@Transactional(timeout = 300)
	public List<HashMap<String, Object>> selectLongRunning(String qid, Map<String, Object> hashMap) {
		return queryDao.select(qid, hashMap);
	}

	/**
	 * 스트리밍 조회 - 대용량 엑셀 다운로드용
	 * ResultHandler를 사용하여 한 행씩 처리 (메모리 효율적)
	 * @param qid 쿼리 ID
	 * @param hashMap 파라미터
	 * @param handler 결과 핸들러
	 */
	@Transactional(readOnly = true)
	public void selectStream(String qid, Map<String, Object> hashMap, ResultHandler<HashMap<String, Object>> handler) {
		queryDao.selectStream(qid, hashMap, handler);
	}
}
