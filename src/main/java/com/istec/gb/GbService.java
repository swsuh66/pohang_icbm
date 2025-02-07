package com.istec.gb;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.FileUtils;
import org.apache.ibatis.session.ResultContext;
import org.apache.ibatis.session.ResultHandler;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.istec.enums.EnumVar;
import com.istec.util.GbUtil;

/*
[ alltoHIM (my nick) ]
@ file Name : GbService.java
@ title     : GbService
@ desc      : -
@ author    : gyubeom_park (god3se@gmail.com)
@ date      : 2022.03.23
*/

@Service("gbService")
public class GbService {
	
	@Resource(name="sqlSessionFactory")
	private SqlSessionFactory sqlSessionFactory;
	
	@Autowired
	private IstecDAO dao;
	
	private static Logger logger = LoggerFactory.getLogger(GbService.class);
	
	final static String sys_sepa = System.getProperty("file.separator");
	private final static String sepa = "/";
	
	private final String MAPPER_PATH = EnumVar.get("MAPPER_PATH");	
	private final String GRAND_PATH = EnumVar.get("GRAND_PATH");
	private final String TEMP_PATH = EnumVar.get("TEMP_PATH");
	
	private SqlSession sqlSession = null;
	
	
	
	//========== # start of file ==========
	
	public void fileDownload(Map<String, Object> paramMap, HttpServletRequest request, HttpServletResponse response) {
		
		String option = paramMap.get("option").toString();
		
		switch(option) {
			case "mapper":
				this.mapperDownload(paramMap, request, response);
				break;
			case "query":
				// this.queryDownload();
				break;
		}
		
		response.setHeader("Set-Cookie", "fileDownload=true; path=/");
		
	}
	
	@Transactional
	public void mapperDownload(Map<String, Object> paramMap, HttpServletRequest request, HttpServletResponse response) {
		String timeStamp = GbUtil.getTime(paramMap.get("timeUnit").toString());
		String fileName = paramMap.get("fileName").toString()+"_"+timeStamp;		
		String ext = "."+paramMap.get("fileType").toString();
		
		String mapperPath = MAPPER_PATH+"."+paramMap.get("mapperId").toString();
		
		String parentPath = request.getSession().getServletContext().getRealPath(GRAND_PATH).replace("\\", sepa);
		String tempPath = parentPath + sepa + TEMP_PATH;
		String tempFileExt = fileName + ext;
		String tempFilePath = tempPath + sepa + tempFileExt;
	    
	    try {
	    	Files.createDirectories(((Path) Paths.get(tempPath)));
	    }catch(IOException e) {
	    	if(logger.isDebugEnabled()) {
	    		logger.debug(e.getMessage());
	    	}
	    }
	    
	    try(BufferedWriter tempFile = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(new File(tempFilePath)), "EUC-KR"))){
	    	boolean isHeader = Boolean.parseBoolean(paramMap.get("header").toString());
	    	boolean doubleQuotes = Boolean.parseBoolean(paramMap.get("setDoubleQuotes").toString());
	    	String delimiter = paramMap.get("delimiter").toString();
	    	
	    	String fileNameEncoded = "";
	    	String userAgent = request.getHeader("User-Agent");
	    	boolean isIE = userAgent.indexOf("MSIE") != -1 || userAgent.indexOf("Trident") != -1;
	    	
	    	sqlSession = sqlSessionFactory.openSession();
	    	
	    	response.setHeader("Content-Encoding", "UTF-8");
	    	response.setHeader("Content-Type", "text/csv; charset=UTF-8");
	    	response.setHeader("Set-Cookie", "fileDownload=true; path=/");
	       
	    	if(isIE) {
	    		fileNameEncoded = URLEncoder.encode(fileName, "UTF-8").replaceAll("\\+", "%20");
	    		response.setHeader("Content-Disposition", "attachment;filename=" + fileNameEncoded + ext + ";");
	    	} else {
	    		fileNameEncoded = new String(fileName.getBytes("UTF-8"), "ISO-8859-1");
	    		response.setHeader("Content-Disposition", "attachment;filename=\"" + fileNameEncoded + ext + "\"");
	    	}
		   
	    	// header
	    	if(false != isHeader) {
	    		
	    	}else { // not header
	    		
	    	}
	    	
	    	sqlSession.select(mapperPath, paramMap, new ResultHandler<Map<String, Object>>() {
	    		@Override
   				public void handleResult(ResultContext<? extends Map<String, Object>> context) {
	    			StringBuffer row = new StringBuffer();
   					
	    			if(false == doubleQuotes) {
	    				for(Object o : context.getResultObject().values()) {
	   						row.append(o.toString()+delimiter);
	   					}
	    			}else {
	    				for(Object o : context.getResultObject().values()) {
	   						row.append("\"" + o.toString().replaceAll("\"", "\"\"")+"\""+delimiter);
	   					}
	    			}
   					
   					
   					try {
   						tempFile.write(row.toString().replaceAll(delimiter + "$", "\r\n"));
   					} catch (IOException e) {
   						if(logger.isDebugEnabled()) {
   				    		logger.debug(e.getMessage());
   				    	}
   					}
	    		}
	    	});
	    	
	    	tempFile.flush();
	    	
	    	File file = new File(tempFilePath);
	    	FileUtils.copyFile(file, response.getOutputStream());
	    	
	    }catch(FileNotFoundException e) {
	    	GbUtil.deleteFile(tempFilePath);
	    	if(logger.isDebugEnabled()) {
	    		logger.debug(e.getMessage());
	    	}
	    }catch(IOException e) {
	    	GbUtil.deleteFile(tempFilePath);
			if(logger.isDebugEnabled()) {
				logger.debug(e.getMessage());
			}
	    }finally {
	    	if(sqlSession != null) sqlSession.close();
	    }
		
	}
	
	//========== end of file ==========
	
	
	
}
