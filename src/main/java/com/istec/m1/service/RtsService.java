package com.istec.m1.service;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Service;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@Service
public class RtsService {
	
	private SqlSessionTemplate sql;
	private ExecutorService thread;
	
	public RtsService(SqlSessionTemplate sqlsession) {
		this.sql = sqlsession;
		thread = Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors());
	}

	/**
	 * url 목록을 가져 옵니다.
	 * **/
	public HashMap<Object, Object> getList(HashMap<Object, Object> param){
		PageUtilBean.EXTEND_PARAM.accept(param, sql.selectOne("rts.mapper.count", param));  //데이터 페이징 처리
		param.put("list", sql.selectList("rts.mapper.selectList", param));
		return param;
	}

	/**
	 * url 값을 등록 합니다.
	 * **/
	public int insert(HashMap<Object, Object> param) {
		param.put("idx", PageUtilBean.getUniqueIdx(40));
		return sql.insert("rts.mapper.insert", param);
	}
	
	/**
	 * url 값을 수정 합니다.
	 * **/	
	public int update(HashMap<Object, Object> param) {
		return sql.update("rts.mapper.update", param);
	}
	
	/**
	 * url 값을 삭제 합니다.
	 * **/	
	public int delete(HashMap<Object, Object> param) {
		return sql.delete("rts.mapper.delete", param);
	}
	
	/**
	 * nbiot 목록을 가져 옵니다.
	 * **/
	public HashMap<Object, Object> getNbiotList(HashMap<Object, Object> param){
		PageUtilBean.EXTEND_PARAM.accept(param, sql.selectOne("rts.mapper.countNbiot", param));  //데이터 페이징 처리
		param.put("list", sql.selectList("rts.mapper.selectNbiotList", param));
		return param;
	}	
	
	/**
	 * 전송한 이력을 단순하게 30개만 가져 옵니다. 
	 * **/
	public List<HashMap<Object, Object>> getHistory10List(HashMap<Object, Object> param){
		return sql.selectList("rts.mapper.selectHistory10List", param);
	}	
		
	
	/**
	 * http 요청을 보냅니다<br>
	 * 비동기 방식으로 전송합니다. 동기방식으로 하는 경우에 브라우저 대기상태가 길어지기 때문 입니다.
	 * **/
	public void requestOrder(HashMap<Object,Object> param) {
		thread.execute(()->{
			
			String history_idx = PageUtilBean.getUniqueIdx(48);
			param.put("idx", history_idx);
			int result = sql.insert("rts.mapper.insertHistory", param);  //전송 이력을 기록 합니다.
			
			if(result > 0) {
				String url = param.get("url_name").toString();
				String tail = "";
				String Msg = "";
				String type = null;
				if(param.get("meterread_cycle") != null) {  //URL 전송 규칙에 따라 추가 쿼리를 붙여 줍니다. 
					tail = "/" + param.get("meterread_cycle") + "/" + param.get("send_cycle");
				} else if(param.get("servicecode") != null) {
					tail = "/" + param.get("servicecode");
				}
				
				if(param.get("msg") != null) {
					Msg = "{\"Msg\": \"" + param.get("msg") + "\"}";
					type = "application/json";
				}
				
				String cseids[] = param.get("cseids").toString().split(",");  //보낼 대상의 CSE-ID  값 입니다.
				for(String cseid : cseids) {
					param.clear();
					try {
						
						System.out.println(url+ "/" + cseid );
						String working_result=  HttpRequester.post(url+ "/" + cseid + tail, Msg, type);  //받은 URL을 바탕으로 HTTP통신을 진행 합니다.
						param.put("working_result", working_result);
					} catch (Exception e) {
						e.printStackTrace();
						param.put("working_result", "error");
					} finally {
						param.put("history_idx", history_idx);
						param.put("idx", PageUtilBean.getUniqueIdx(48));
						param.put("url_name", url+ "/" + cseid + tail);
						sql.insert("rts.mapper.insertHistoryItem", param);  //결과를 기록 합니다.
					}
					
					try { Thread.sleep(250); } catch (InterruptedException e) { }  //슬립을 통해 트래픽을 관리 합니다.
				}
				param.clear();
				param.put("idx", history_idx);
				param.put("working_status", "END");  //작업 종료가 되었는 경우 최종 END 상태로 처리 합니다.
				sql.update("rts.mapper.updateHistory", param);
			}
		});
	}
	
	
	/**
	 * 이력 목록을 가져 옵니다.
	 * **/
	public HashMap<Object, Object> getHistoryList(HashMap<Object, Object> param){
		PageUtilBean.EXTEND_PARAM.accept(param, sql.selectOne("rts.mapper.countHistory", param));  //데이터 페이징 처리
		param.put("list", sql.selectList("rts.mapper.selectHistoryList", param));
		return param;
	}	
	
	
	/**
	 * 이력 목록의 세부 목록을 가져 옵니다.
	 * **/
	public HashMap<Object, Object> getHistoryItemList(HashMap<Object, Object> param){
		PageUtilBean.EXTEND_PARAM.accept(param, sql.selectOne("rts.mapper.countHistoryItem", param));  //데이터 페이징 처리
		param.put("list", sql.selectList("rts.mapper.selectHistoryItemList", param));
		return param;
	}	
		
}
