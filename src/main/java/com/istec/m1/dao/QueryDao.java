package com.istec.m1.dao;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.ibatis.mapping.ParameterMapping;
import org.mybatis.spring.SqlSessionTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

@Repository
public class QueryDao {

	@Autowired 
	//@Resource(name="sqlSession") 
	private SqlSessionTemplate sqlsession;

	private Logger logger = LoggerFactory.getLogger(QueryDao.class);
	 
	public List<HashMap<String, Object>> select(String qid) {
		logger.debug("[DAO-SELECT] " + qid);
		return sqlsession.selectList(qid);
	}

	public List<HashMap<String, Object>> select(String qid, Map<String, Object> hashMap) {
		logger.debug("[DAO-SELECT] " + qid + ", " + hashMap.toString());
// temp code for sql, bind parameter start ************************************************************************
		// 이부분은 커밋하면 안됨..
		String sql = sqlsession.getConfiguration().getMappedStatement(qid).getBoundSql(hashMap).getSql();
		System.out.println(sql);
// temp code for sql, bind parameter end ************************************************************************
		return sqlsession.selectList(qid, hashMap);
		
	}

	public int insert(String qid, Map<String, Object> hashMap) {
		logger.debug("[DAO-INSERT] " + qid + ", " + hashMap);
		return sqlsession.insert(qid, hashMap);
	}

	public int delete(String qid, Map<String, Object> hashMap) {
		logger.debug("[DAO-DELETE] " + qid + ", " + hashMap);
		return sqlsession.delete(qid, hashMap);
	}

	public int update(String qid, Map<String, Object> hashMap) {
		logger.debug("[DAO-UPDATE] " + qid + ", " + hashMap);
		return sqlsession.update(qid, hashMap);
	}

	/**************************************************************************/

	public int insert(String qid, List<Map<String, Object>> listMap) {
		logger.debug("[DAO-INSERT-LIST] " + qid + ", " + listMap);
		int result = 0;
		for (Map<String, Object> item : listMap) {
			result += sqlsession.insert(qid, item);
		}
		return result;
	}

	public int delete(String qid, List<Map<String, Object>> listMap) {
		logger.debug("[DAO-DELETE-LIST] " + qid + ", " + listMap);
		int result = 0;
		for (Map<String, Object> item : listMap) {
			result += sqlsession.delete(qid, item);			
		}
		return result;
	}

	public int update(String qid, List<Map<String, Object>> listMap) {
		logger.debug("[DAO-UPDATE-LIST] " + qid + ", " + listMap);
		int result = 0;
		for (Map<String, Object> item : listMap) {			
			result += sqlsession.update(qid, item);
		}		
		return result;
	}
}
