package com.istec.m1.dao;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.ibatis.mapping.BoundSql;
import org.apache.ibatis.mapping.ParameterMapping;
import org.apache.ibatis.session.ResultHandler;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

@Repository
public class QueryDao {

	@Autowired 
	private SqlSessionTemplate sqlsession;
	
	@Autowired
	private SqlSessionFactory sqlSessionFactory;

	private Logger logger = LoggerFactory.getLogger(QueryDao.class);
	
	/**
	 * SQL의 ?를 실제 파라미터 값으로 대체하여 실행 가능한 SQL 반환
	 */
	private String getExecutableSql(String qid, Map<String, Object> paramMap) {
		BoundSql boundSql = sqlsession.getConfiguration().getMappedStatement(qid).getBoundSql(paramMap);
		String sql = boundSql.getSql();
		List<ParameterMapping> paramMappings = boundSql.getParameterMappings();
		
		if (paramMappings != null && !paramMappings.isEmpty() && paramMap != null) {
			for (ParameterMapping pm : paramMappings) {
				String propertyName = pm.getProperty();
				Object value = null;
				
				// 1. paramMap에서 직접 찾기
				if (paramMap.containsKey(propertyName)) {
					value = paramMap.get(propertyName);
				}
				// 2. additionalParameter에서 찾기 (foreach 등에서 사용)
				else if (boundSql.hasAdditionalParameter(propertyName)) {
					value = boundSql.getAdditionalParameter(propertyName);
				}
				// 3. 중첩 프로퍼티 처리 (예: item.name)
				else if (propertyName.contains(".")) {
					String[] parts = propertyName.split("\\.", 2);
					Object parent = paramMap.get(parts[0]);
					if (parent == null) {
						parent = boundSql.getAdditionalParameter(parts[0]);
					}
					if (parent instanceof Map) {
						value = ((Map<?, ?>) parent).get(parts[1]);
					}
				}
				
				String replacement = formatValue(value);
				sql = sql.replaceFirst("\\?", java.util.regex.Matcher.quoteReplacement(replacement));
			}
		}
		return sql;
	}
	
	/**
	 * 값을 SQL에서 사용 가능한 형태로 포맷팅
	 */
	private String formatValue(Object value) {
		if (value == null) {
			return "NULL";
		} else if (value instanceof String) {
			return "'" + value.toString().replace("'", "''") + "'";
		} else if (value instanceof java.util.Date) {
			return "'" + new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(value) + "'";
		} else if (value instanceof Boolean) {
			return (Boolean) value ? "true" : "false";
		} else {
			return value.toString();
		}
	}
	 
	public List<HashMap<String, Object>> select(String qid) {
		logger.debug("[DAO-SELECT] " + qid);
		return sqlsession.selectList(qid);
	}

	public List<HashMap<String, Object>> select(String qid, Map<String, Object> hashMap) {
		logger.debug("[DAO-SELECT] " + qid + ", " + hashMap.toString());
// temp code for sql, bind parameter start ************************************************************************
		// 실행 가능한 SQL 출력 (파라미터 바인딩 완료)
		try {
			BoundSql boundSql = sqlsession.getConfiguration().getMappedStatement(qid).getBoundSql(hashMap);
			String sql = boundSql.getSql();
			List<ParameterMapping> paramMappings = boundSql.getParameterMappings();
			
			// 파라미터 매핑 순서대로 ? 대체
			if (paramMappings != null && hashMap != null) {
				for (ParameterMapping pm : paramMappings) {
					String propName = pm.getProperty();
					Object value = hashMap.get(propName);
					
					// additionalParameter에서 찾기 (foreach, _parameter 등)
					if (value == null && boundSql.hasAdditionalParameter(propName)) {
						value = boundSql.getAdditionalParameter(propName);
					}
					
					// 값 포맷팅
					String replacement;
					if (value == null) {
						replacement = "NULL";
					} else if (value instanceof String) {
						replacement = "'" + value.toString().replace("'", "''") + "'";
					} else {
						replacement = value.toString();
					}
					
					sql = sql.replaceFirst("\\?", java.util.regex.Matcher.quoteReplacement(replacement));
				}
			}
			
			System.out.println("\n/*" + qid + "*/\n" + sql);
		} catch (Exception e) {
			System.out.println("SQL 변환 실패: " + e.getMessage());
			e.printStackTrace();
		}
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

	/**
	 * 스트리밍 조회 - 대용량 엑셀 다운로드용
	 * ResultHandler를 사용하여 한 행씩 처리 (메모리 효율적)
	 * Spring @Transactional(readOnly=true)이 autoCommit=false를 보장하고,
	 * XML의 fetchSize 설정과 결합하여 PostgreSQL 서버사이드 커서 활성화
	 * @param qid 쿼리 ID
	 * @param hashMap 파라미터
	 * @param handler 결과 핸들러
	 */
	public void selectStream(String qid, Map<String, Object> hashMap, ResultHandler<HashMap<String, Object>> handler) {
		logger.debug("[DAO-SELECT-STREAM] " + qid + ", " + hashMap.toString());
		sqlsession.select(qid, hashMap, handler);
	}
}
