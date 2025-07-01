package com.istec.m1.service;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletResponse;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.apache.poi.xssf.streaming.SXSSFCell;
import org.apache.poi.xssf.streaming.SXSSFRow;
import org.apache.poi.xssf.streaming.SXSSFSheet;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.apache.poi.xssf.usermodel.XSSFCellStyle;
import org.apache.poi.xssf.usermodel.XSSFDataFormat;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import com.istec.m1.devController;
import com.istec.m1.common.ExcelReader;
import com.istec.m1.defines.Define;
import com.istec.m1.mapper.TbM1CmapDeviceMapper;
import com.istec.m1.mapper.TbM1InfoCustomerMapper;
import com.istec.m1.mapper.TbM1InfoImportMapper;
import com.istec.m1.mapper.TbM1InfoPointMapper;

@Service
public class FileService {
	
	@Autowired
	private QueryService queryService;
	
	@Autowired
	private SqlSessionFactory sqlSessionFactory;
	
	private final TbM1InfoImportMapper tbM1InfoImportMapper;
	private final TbM1CmapDeviceMapper tbM1CmapDeviceMapper;
	private final TbM1InfoCustomerMapper tbM1InfoCustomerMapper;
	private final TbM1InfoPointMapper tbM1InfoPointMapper;	

	@Autowired
	public FileService(
		TbM1InfoImportMapper tbM1InfoImportMapper, 
		TbM1CmapDeviceMapper tbM1CmapDeviceMapper, 
		TbM1InfoCustomerMapper tbM1InfoCustomerMapper, 
		TbM1InfoPointMapper tbM1InfoPointMapper) 
	{
		this.tbM1InfoImportMapper = tbM1InfoImportMapper;
		this.tbM1CmapDeviceMapper = tbM1CmapDeviceMapper;
		this.tbM1InfoCustomerMapper = tbM1InfoCustomerMapper;
		this.tbM1InfoPointMapper = tbM1InfoPointMapper;
	}

	public List<List<String>> excelRead(MultipartFile file)  {
		
		InputStream in = null;
		
		String nm = file.getOriginalFilename();
		
		try {
			in = file.getInputStream();					
			
			if(in == null)
				return null;
			
			return ExcelReader.toList(in, nm);

		} catch (IOException e) {
			
			throw new RuntimeException();
			
		} finally {
			try {
				
				if(in != null) in.close();
				
			} catch (IOException e1) {
				
				throw new RuntimeException();
				
			}
			
		}

	}  
	
	
	/**
	 * ���������� ���ϴ�.  test �ڵ��Դϴ�.
	 * @throws IOException 
	 */	
	public void excelCreateSXSSF(HttpServletResponse response, List<Object> mapping, List<HashMap<String, Object>> data, String fileName ) throws IOException  {
		
		SXSSFWorkbook workbook = null;
		SXSSFRow row = null; 
		SXSSFCell cell = null;
		
		OutputStream outs = null;
		
		List<String> headeres = null;
		
		
		// ���� ���
    	try {
    		
    		headeres = new ArrayList<>();
    		
    		outs = response.getOutputStream();
    		XSSFWorkbook xssfWorkbook = new XSSFWorkbook();
    		workbook = new SXSSFWorkbook(xssfWorkbook); 
    		workbook.setCompressTempFiles(true);

    		SXSSFSheet sheet1 = (SXSSFSheet) workbook.createSheet(); 
    		sheet1.setRandomAccessWindowSize(100); // �޸� �� 100���� ����, �ʰ� �� Disk�� flush
    		
    		//List<Object> mapping = (List<Object>) mappingInfo.get(Define.Key.COL_MAPPING);
			//2024-12-06 김용희 텍스트 타입.
			XSSFDataFormat format = xssfWorkbook.createDataFormat();
			XSSFCellStyle cellStyle = xssfWorkbook.createCellStyle();
			cellStyle.setDataFormat(format.getFormat("@"));
   
    		
    		// ���
    		row = (SXSSFRow) sheet1.createRow(0);
        	
        	int idx = 0;
        	
        	for(Object obj : mapping) {
        		
        		cell = (SXSSFCell) row.createCell(idx);
        		
        		Map<String, Object> objItem = (Map<String, Object>) obj;
    			
    			String key = (String) objItem.get(Define.Key.TB_INFO_TITLE);
    			
                cell.setCellValue(key);
                
                idx++;
                
        	}        	

        	// ������
            for(int i = 0; i < data.size() ; i++) {
            	
            	row = (SXSSFRow) sheet1.createRow(i + 1);
            	
            	Map<String, Object> rowData = data.get(i);
            	
            	idx = 0;
            	
            	for(Object obj : mapping) {
            		
            		cell = (SXSSFCell) row.createCell(idx);
            		
            		Map<String, Object> objItem = (Map<String, Object>) obj;
        			
        			String key = (String) objItem.get(Define.Key.TB_INFO_NAME);
        			
        			Object value = rowData.get(key);

        			if(value != null) 
        				cell.setCellValue( value.toString() );
        			else
        				cell.setCellValue("");
        			
					cell.setCellStyle(cellStyle);
                    idx++;
                    
            	}   
            	
            	
            	
            }
            
            response.reset();
        	response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + ".xlsx\"");
    		
        	workbook.write(outs);
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
        	
        	if(outs != null) outs.close();
            response.getOutputStream().flush();
            response.getOutputStream().close();
            
            //dm.removeDBAccessInfo(sqlId);
        }   

	};

	/**
	 * CSV �Ǵ� Text ������ �н��ϴ�.
	 */
	public List<List<String>> txtRead(MultipartFile file, String delimiter, String charSet) {		

		List<List<String>> result = new ArrayList<List<String>>();

		List<String> colList = null;
		
		InputStream in = null;
		
		try {
			
			String fileNm = file.getOriginalFilename();
			
			if( !fileNm.endsWith(".csv") && !fileNm.endsWith(".txt")) {				
				return null;				
			}			
			
			in = file.getInputStream();

			BufferedReader br = new BufferedReader(new InputStreamReader(in, charSet));

			String tmp = "";
			while ( (tmp = br.readLine()) != null ) {

				String[] data = tmp.split(delimiter);
				
				colList = new ArrayList<String>();

				for (int i = 0; i < data.length; i++) {					
					colList.add(data[i]);
				}

				result.add(colList);

			}
		} catch (IOException e) {
			
			throw new RuntimeException();
			
		} finally {
			try {
				
				if(in != null) in.close();
				
			} catch (IOException e1) {
				
				throw new RuntimeException();
				
			}
			
		}

		return result;
				
    }
	
	public Map<String, Object> xmlRead(String path, String sql) {

		Map<String, Object> result = new HashMap<String, Object>();

		Map<String, Object> map = null;

		List<Object> list = null;

		try {

			DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();

			DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();

			Document doc = dBuilder.parse(new File(path));

			doc.getDocumentElement().normalize();

			NodeList mapList = doc.getElementsByTagName(Define.Key.TB_INFO_MAP);
			
			int lll = mapList.getLength();

			for (int i = 0; i < mapList.getLength(); i++) {
				Node mapNode = mapList.item(i);

				Element mElement = (Element) mapNode;
				
				if( sql != null && sql.equals( mElement.getAttribute(Define.Key.TB_INFO_META_SQL) )) {
					
					NodeList colList = mElement.getElementsByTagName(Define.Key.TB_INFO_COL)	;		

					list = new ArrayList<Object>();

					for (int j = 0; j < colList.getLength(); j++) {
						Node colNode = colList.item(j);

						Element cElement = (Element) colNode;

						map = new HashMap<String, Object>();

						map.put(Define.Key.TB_INFO_NAME,   cElement.getElementsByTagName(Define.Key.TB_INFO_NAME).item(0).getTextContent());
						map.put(Define.Key.TB_INFO_TITLE,  cElement.getElementsByTagName(Define.Key.TB_INFO_TITLE).item(0).getTextContent());

						list.add(map);

					}

					map = new HashMap<String, Object>();

					map.put(Define.Key.TB_INFO_EC_SQL,	  mElement.getAttribute(Define.Key.TB_INFO_EC_SQL));
					map.put(Define.Key.TB_INFO_REFER_SQ,  mElement.getAttribute(Define.Key.TB_INFO_REFER_SQ));
					map.put(Define.Key.TB_INFO_AFTER_SQ,  mElement.getAttribute(Define.Key.TB_INFO_AFTER_SQ));
					map.put(Define.Key.TB_INFO_COLS, 	  list);

					result.put(sql, map);

				}

			}

		} catch (ParserConfigurationException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SAXException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return result;
	}
	
	//	dat
	public void createDat(HttpServletResponse response, List<Object> mapping, List<HashMap<String, Object>> data,
			String fileName, String tempPath) throws IOException {

		SimpleDateFormat sdf = new SimpleDateFormat("yyMM");
		String rootPath = System.getProperty("user.dir");

		// String tempPath = rootPath + "/datFile/";
		Calendar c1 = Calendar.getInstance();
		String yymmdd = sdf.format(c1.getTime());
		String fileday = yymmdd;
		fileName = "result_" + fileday + ".dat";

		Writer out = null;
		FileInputStream fis = null;
		BufferedInputStream bis = null;
		ServletOutputStream so = null;
		BufferedOutputStream bos = null;

		try {

			File realUploadDir = new File(tempPath);

			if (!realUploadDir.exists()) {
				realUploadDir.mkdirs();
			}

			File newFile = new File(realUploadDir + "/" + fileName);

			out = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(newFile), "utf-8"));

			for (int i = 0; i < data.size(); i++) {
				Map<String, Object> rowData = data.get(i);
				String write = "";
				for (Object obj : mapping) {
					Map<String, Object> objItem = (Map<String, Object>) obj;
					String key = (String) objItem.get(Define.Key.TB_INFO_NAME);
					Object value = rowData.get(key);
					if (value == null || value.equals("NULL") || value.equals("null")) {
						value = "";
					}
					write += value;
				}
				out.write(write);
				out.write("\r\n");

			}
			out.close();

			response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

			fis = new FileInputStream(newFile);
			bis = new BufferedInputStream(fis);
			so = response.getOutputStream();
			bos = new BufferedOutputStream(so);

			byte[] dataByte = new byte[2048];
			int input = 0;
			while ((input = bis.read(dataByte)) != -1) {
				bos.write(dataByte, 0, input);
				bos.flush();
			}

		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (out != null) {
				try {
					if (bos != null)
						bos.close();
					if (bis != null)
						bis.close();
					if (so != null)
						so.close();
					if (fis != null)
						fis.close();

				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
	}

	// Brad : 2025.06.29
	private String getString(Row row, int cellIndex) {
		if (row == null) return "";
		Cell cell = row.getCell(cellIndex);
		if (cell == null) return "";
		cell.setCellType(CellType.STRING);
		return cell.getStringCellValue().trim();
	}

	private Integer  getInteger (Row row, int cellIndex) {
		if (row == null) return null;
		Cell cell = row.getCell(cellIndex);
		if (cell == null) return null;

		try {
			String value = cell.getStringCellValue().trim();
			if (value.isEmpty()) return null;
			return Integer.parseInt(value);
		} catch (Exception e) {
			// 필요 시 로그 출력
			return null;
		}
	}

	private BigDecimal getBigDecimal(Row row, int cellIndex) {
		if (row == null) return null;
		Cell cell = row.getCell(cellIndex);
		if (cell == null) return null;

		try {

			String value = cell.getStringCellValue().trim();
			if (value == null || value.isEmpty()) return null;

			return new BigDecimal(value);
		} catch (Exception e) {
			System.err.println("Error converting cell to BigDecimal: " + e.getMessage());
			return null;
		}
	}

	private Double getDouble(Row row, int cellIndex) {
		if (row == null) return null;
		Cell cell = row.getCell(cellIndex);
		if (cell == null) return null;

		try {
			String value = cell.getStringCellValue().trim();
			return value.isEmpty() ? null : Double.parseDouble(value);
		} catch (Exception e) {
			// 필요 시 로그 출력
			return null;
		}
	}

	@Transactional
	public void insertCustomInfoFromExcel(
		MultipartFile file, 
		int upsitesq, 
		String tokenKey, 
		boolean isCheck) throws Exception  
	{
		int rowCount;

		// try-with-resources를 사용하면 InputStream, Workbook 자동 close됨
		try (InputStream in = file.getInputStream();
			Workbook workbook = WorkbookFactory.create(in)) {

			Sheet sheet = workbook.getSheetAt(0);
			rowCount = sheet.getPhysicalNumberOfRows();

			// 헤더는 0번째 행이라 데이터는 1부터 시작
			for (int i = 1; i < rowCount; i++) {
				Row row = sheet.getRow(i);
				int j = 0;
				
				try {
					// TODO: row에서 데이터 추출 후 insert 처리
					// 1. 공통으로 쓸 데이터 추출
					Integer dataSq = getInteger(row, j++);  // 순번
					String custNm = getString(row, j++);   // 수용가명
					String adminNo = getString(row, j++);  // 수용가번호
					String addr = getString(row, j++);  // 구주소
					String addrNew = getString(row, j++);  // 신주소
					BigDecimal locLng = getBigDecimal(row, j++);  // 경도
					BigDecimal locLat = getBigDecimal(row, j++);  // 위도
					String useType = getString(row, j++);  // 업종
					String siteNm = getString(row, j++);   // 소속
					String blkNm = getString(row, j++);  // 블럭
					String custPhone = getString(row, j++);  // 수용가 전화번호
					String setYears = getString(row, j++);  // 수용가 대상 년도
					String readOpr = getString(row, j++);  // 검침원
					Integer checkDay = getInteger(row, j++);  // 검침일
					String meterNo = getString(row, j++);  // 계량기번호
					BigDecimal pipeDia = getBigDecimal(row, j++);   // 구경
					String amiType = getString(row, j++);   // 통신
					String subDevNo = getString(row, j++);   // 단말 부번호
					String devNo = getString(row, j++);   // 단말 주번호
					String companyNm = getString(row, j++);  // 단말회사
					String setDt = getString(row, j++); // 단말설치일
					// String tokenKey = tokenKey; // 토큰 키

					// tb_m1_info_import
					Map<String, Object> importMap = new HashMap<>();
					importMap.put("dataSq", dataSq);
					importMap.put("custNm", custNm);
					importMap.put("adminNo", adminNo);
					importMap.put("addr", addr);
					importMap.put("addrNew", addrNew); 
					importMap.put("locLng", locLng);
					importMap.put("locLat", locLat);
					importMap.put("useType", useType); 
					importMap.put("siteNm", siteNm);
					importMap.put("blkNm", blkNm);
					importMap.put("custPhone", custPhone);
					importMap.put("setYears", setYears);
					importMap.put("readOpr", readOpr);
					importMap.put("checkDay", checkDay);
					importMap.put("meterNo", meterNo);
					importMap.put("pipeDia", pipeDia);
					importMap.put("amiType", amiType);
					importMap.put("subDevNo", subDevNo);
					importMap.put("devNo", devNo);
					importMap.put("companyNm", companyNm);
					importMap.put("setDt", setDt);
					importMap.put("tokenKey", tokenKey);
					
					tbM1InfoImportMapper.insertImport(importMap);

					// tb_m1_info_customer
					Map<String, Object> customerMap = new HashMap<>();					
					customerMap.put("adminNo", adminNo);
					customerMap.put("custName", custNm);
					customerMap.put("addr", addr);
					customerMap.put("addrNew", addrNew);
					customerMap.put("pipeDiameter", pipeDia);
					customerMap.put("meterNo", meterNo);
					customerMap.put("readResponsi", readOpr);
					customerMap.put("custPhone", custPhone);
					customerMap.put("setYears", setYears);
					customerMap.put("checkDay", checkDay);
					
					Long custSq = tbM1InfoCustomerMapper.insertCustomer(customerMap);	
										
					// tb_m1_info_point
					Map<String, Object> pointMap = new HashMap<>();
					pointMap.put("custSq", custSq);  // customer insert 후 키 매핑 필요
					pointMap.put("siteNm", siteNm);
					pointMap.put("blkNm", blkNm);
					pointMap.put("locLng", locLng);
					pointMap.put("locLat", locLat);
					Long pointSq = tbM1InfoPointMapper.insertPoint(pointMap);

					// tb_m1_cmap_device
					Map<String, Object> deviceMap = new HashMap<>();
					deviceMap.put("devNo", devNo);
					deviceMap.put("subDevNo", subDevNo);
					deviceMap.put("pointSq", pointSq); 
					deviceMap.put("companyNm", companyNm);
					deviceMap.put("amiType", amiType); // 통신사 (KT, LG, SK)			
					
					tbM1CmapDeviceMapper.insertDevice(deviceMap);					
					
				} catch (Exception e) {
					throw new Exception("엑셀 " + (i + 1) + "행" + j + " 열 처리 중 오류" + System.lineSeparator() + e.getMessage());
				}
			}

			// 검증모드일 경우 트랜잭션 롤백 유도
			if (isCheck) {
				throw new RuntimeException("엑셀 데이터 검증이 완료되었습니다.");
			}

		} catch (IOException e) {
			throw new Exception("엑셀 파일 처리 실패: " + e.getMessage(), e);
		}
	}

	@Transactional
	public void updateCustomInfoFromExcel(
		MultipartFile file, 
		int upsitesq, 
		String tokenKey) throws Exception  
	{
		int rowCount;

		// try-with-resources를 사용하면 InputStream, Workbook 자동 close됨
		try (InputStream in = file.getInputStream();
			Workbook workbook = WorkbookFactory.create(in)) {

			Sheet sheet = workbook.getSheetAt(0);
			rowCount = sheet.getPhysicalNumberOfRows();

			// 헤더는 0번째 행이라 데이터는 1부터 시작
			for (int i = 1; i < rowCount; i++) {
				Row row = sheet.getRow(i);
				int j = 0;
				
				try {
					// TODO: row에서 데이터 추출 후 insert 처리
					// 1. 공통으로 쓸 데이터 추출
					Integer dataSq = getInteger(row, j++);  // 순번
					String custNm = getString(row, j++);   // 수용가명
					String adminNo = getString(row, j++);  // 수용가번호
					String addr = getString(row, j++);  // 구주소
					String addrNew = getString(row, j++);  // 신주소
					BigDecimal locLng = getBigDecimal(row, j++);  // 경도
					BigDecimal locLat = getBigDecimal(row, j++);  // 위도
					String useType = getString(row, j++);  // 업종
					String siteNm = getString(row, j++);   // 소속
					String blkNm = getString(row, j++);  // 블럭
					String custPhone = getString(row, j++);  // 수용가 전화번호
					String setYears = getString(row, j++);  // 수용가 대상 년도
					String readOpr = getString(row, j++);  // 검침원
					Integer checkDay = getInteger(row, j++);  // 검침일
					String meterNo = getString(row, j++);  // 계량기번호
					BigDecimal pipeDia = getBigDecimal(row, j++);   // 구경
					String amiType = getString(row, j++);   // 통신
					String subDevNo = getString(row, j++);   // 단말 부번호
					String devNo = getString(row, j++);   // 단말 주번호
					String companyNm = getString(row, j++);  // 단말회사
					String setDt = getString(row, j++); // 단말설치일
					// String tokenKey = tokenKey; // 토큰 키

					// tb_m1_info_import
					Map<String, Object> importMap = new HashMap<>();
					importMap.put("dataSq", dataSq);
					importMap.put("custNm", custNm);
					importMap.put("adminNo", adminNo);
					importMap.put("addr", addr);
					importMap.put("addrNew", addrNew); 
					importMap.put("locLng", locLng);
					importMap.put("locLat", locLat);
					importMap.put("useType", useType); 
					importMap.put("siteNm", siteNm);
					importMap.put("blkNm", blkNm);
					importMap.put("custPhone", custPhone);
					importMap.put("setYears", setYears);
					importMap.put("readOpr", readOpr);
					importMap.put("checkDay", checkDay);
					importMap.put("meterNo", meterNo);
					importMap.put("pipeDia", pipeDia);
					importMap.put("amiType", amiType);
					importMap.put("subDevNo", subDevNo);
					importMap.put("devNo", devNo);
					importMap.put("companyNm", companyNm);
					importMap.put("setDt", setDt);
					importMap.put("tokenKey", tokenKey);
					
					//tbM1InfoImportMapper.updateImport(importMap);

					// tb_m1_info_customer
					Map<String, Object> customerMap = new HashMap<>();					
					customerMap.put("adminNo", adminNo);
					customerMap.put("custName", custNm);
					customerMap.put("addr", addr);
					customerMap.put("addrNew", addrNew);
					customerMap.put("pipeDiameter", pipeDia);
					customerMap.put("meterNo", meterNo);
					customerMap.put("readResponsi", readOpr);
					customerMap.put("custPhone", custPhone);
					customerMap.put("setYears", setYears);
					customerMap.put("checkDay", checkDay);
					
					Long custSq = tbM1InfoCustomerMapper.updateCustomer(customerMap);	
										
					// tb_m1_info_point
					Map<String, Object> pointMap = new HashMap<>();
					pointMap.put("custSq", custSq);  // customer insert 후 키 매핑 필요
					pointMap.put("siteNm", siteNm);
					pointMap.put("blkNm", blkNm);
					pointMap.put("locLng", locLng);
					pointMap.put("locLat", locLat);
					Long pointSq = tbM1InfoPointMapper.updatePoint(pointMap);

					// tb_m1_cmap_device
					Map<String, Object> deviceMap = new HashMap<>();
					deviceMap.put("devNo", devNo);
					deviceMap.put("subDevNo", subDevNo);
					deviceMap.put("pointSq", pointSq); 
					deviceMap.put("companyNm", companyNm);
					deviceMap.put("amiType", amiType); // 통신사 (KT, LG, SK)			
					
					tbM1CmapDeviceMapper.updateDevice(deviceMap);					
					
				} catch (Exception e) {
					throw new Exception("엑셀 " + (i + 1) + "행" + j + " 열 처리 중 오류" + System.lineSeparator() + e.getMessage());
				}
			}
		} catch (IOException e) {
			throw new Exception("엑셀 파일 처리 실패: " + e.getMessage(), e);
		}
	}
	
	public List<HashMap<String, Object>> insertRead_f5_2(MultipartFile file, String templetPath, int upsitesq, String tokenKey) throws Exception  {
		
		InputStream in = null;
		
		String nm = file.getOriginalFilename();
		List<HashMap<String, Object>> result = new ArrayList<>();
		HashMap<String, Object> param = new HashMap<>();
		Map<String, Object> tableinfo = new HashMap<>();
		Workbook workbook = null;
		Sheet sheet = null;
		Row row = null;
		int rownum = 0;
		int cellNum = 0;
		
		try {
			tableinfo =  xmlRead_f5_2(templetPath, "f5-import");
		}
		catch(Exception e) {
			throw new Exception("xml read 오류 tableinfo-config 확인.");
		}
        
		try {
			in = file.getInputStream();					
		} catch (IOException e) {
			if(in != null) in.close();
			throw new Exception("파일 읽기 오류 파일확인요");
		} 	
		
		try {
			workbook = WorkbookFactory.create(in);
			
			if (workbook.getNumberOfSheets() > 1) {
			}
			
			sheet = workbook.getSheetAt(0);
			
			rownum = sheet.getPhysicalNumberOfRows();
		}
		catch(Exception e) {
			if(in != null) in.close();
			throw new Exception("엑셀 시트 확인");
		}	
		
		for (int i = 1; i <= rownum; i++) {
			param = new HashMap<>();
			try {
				row = sheet.getRow(i);
				if (row == null) {
					break;
				}
				cellNum = row.getLastCellNum();
				
				boolean checkRow =  ExcelReader.blankCheck(row.getCell(0)); // 첫 컬럼인 data_sq 가 없을경우 없는 행으로 간주한다.
				if (checkRow) {
					break;
				}
			}
			catch(Exception e) {
				throw new Exception("엑셀 행 확인 : " + i);
			}
			
			for (String key : tableinfo.keySet()) { // key 는 int다
				if ("refer-sql".equals(key) || "excute-sql".equals(key) || "after-sql".equals(key)) // 얘넨아님
				{
					continue;
				}
				Map<String, Object> item = (Map<String, Object>)tableinfo.get(key);
				int num = Integer.parseInt(key);
				
				Cell cell = row.getCell(num); // key 와 맞는 cell 을 찾는다.
		    	
		    	//String value = cell.getStringCellValue(); // cell value 
		    	String value = ExcelReader.getValue(cell);
		    	
		    	String name = (String)item.get("name"); // name 값은 null 일수가없다.
		    	
		    	param.put(name, value);
			}
			
			try {
				String sql = (String)tableinfo.get(Define.Key.TB_INFO_EC_SQL);
				param.put("tokenKey", tokenKey); // 토큰키
				param.put(Define.Key.UP_SITE_SQ, upsitesq); // sitesq
				queryService.insert(sql, param);
			}
			catch (Exception e) {
				param.put("msg", e.getMessage());
				result.add(param); // insert 안된 param을 리턴하기위함.
			}
		}
		
		if(in != null) in.close();
		
		return result;
	}

	/**
	 * 종합정보등록 update import 
	 * @param file
	 * @param templetPath
	 * @param upsitesq
	 * @param tokenKey
	 * @return
	 * @throws Exception
	 */
	public List<HashMap<String, Object>> updateRead_f5_2(MultipartFile file, String templetPath, int upsitesq, String tokenKey) throws Exception  {
		
		InputStream in = null;
		
		String nm = file.getOriginalFilename();
		List<HashMap<String, Object>> result = new ArrayList<>();
		HashMap<String, Object> param = new HashMap<>();
		Map<String, Object> tableinfo = new HashMap<>();
		Workbook workbook = null;
		Sheet sheet = null;
		Row row = null;
		int rownum = 0;
		int cellNum = 0;
		
		try {
			tableinfo =  xmlRead_f5_2(templetPath, "f5-2_import_update");
		}
		catch(Exception e) {
			throw new Exception("xml read 오류 tableinfo-config 확인.");
		}
        
		try {
			in = file.getInputStream();					
		} catch (IOException e) {
			if(in != null) in.close();
			throw new Exception("파일 읽기 오류 파일확인요");
		} 	
		
		try {
			workbook = WorkbookFactory.create(in);
			
			if (workbook.getNumberOfSheets() > 1) {
			}
			
			sheet = workbook.getSheetAt(0);
			
			rownum = sheet.getPhysicalNumberOfRows();
		}
		catch(Exception e) {
			if(in != null) in.close();
			throw new Exception("엑셀 시트 확인");
		}	
			
		
		
		for (int i = 1; i <= rownum; i++) {
			param = new HashMap<>();
			try {
				row = sheet.getRow(i);
				if (row == null) {
					break;
				}

				cellNum = row.getLastCellNum();
				
				boolean checkRow =  ExcelReader.blankCheck(row.getCell(0)); // 첫 컬럼인 data_sq 가 없을경우 없는 행으로 간주한다.
				if (checkRow) {
					break;
				}
			}
			catch(Exception e) {
				throw new Exception("엑셀 행 확인 : " + i + "////" + row + "///////" + cellNum + "/////" );
			}
			
			for (String key : tableinfo.keySet()) { // key 는 int다
				if ("refer-sql".equals(key) || "excute-sql".equals(key) || "after-sql".equals(key)) // 얘넨아님
				{
					continue;
				}
				Map<String, Object> item = (Map<String, Object>)tableinfo.get(key);
				int num = Integer.parseInt(key);
				
				Cell cell = row.getCell(num); // key 와 맞는 cell 을 찾는다.
		    	
		    	//String value = cell.getStringCellValue(); // cell value 
		    	String value = ExcelReader.getValue(cell);
		    	
		    	String name = (String)item.get("name"); // name 값은 null 일수가없다.
		    	
		    	param.put(name, value);
			}
			
			try {
				String sql = (String)tableinfo.get(Define.Key.TB_INFO_EC_SQL);
				param.put("tokenKey", tokenKey); // 토큰키
				param.put(Define.Key.UP_SITE_SQ, upsitesq); // sitesq
				queryService.insert(sql, param);
			}
			catch (Exception e) {
				param.put("msg", e.getMessage());
				result.add(param); // insert 안된 param을 리턴하기위함.
			}
		}
		
		if(in != null) in.close();
		
		return result;
	}

	public Map<String, Object> xmlRead_f5_2(String path, String sql) {
	
		Map<String, Object> result = new HashMap<String, Object>();
	
		Map<String, Object> map = null;
	
		List<Object> list = new ArrayList<>();
	
		try {
	
			DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
	
			DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
	
			Document doc = dBuilder.parse(new File(path));
	
			doc.getDocumentElement().normalize();
	
			NodeList mapList = doc.getElementsByTagName(Define.Key.TB_INFO_MAP);
			
			int lll = mapList.getLength();
	
			for (int i = 0; i < mapList.getLength(); i++) {
				Node mapNode = mapList.item(i);
	
				Element mElement = (Element) mapNode;
				
				if( sql != null && sql.equals( mElement.getAttribute(Define.Key.TB_INFO_META_SQL) )) {
					
					NodeList colList = mElement.getElementsByTagName(Define.Key.TB_INFO_COL)	;		
	
					list = new ArrayList<Object>();
	
					for (int j = 0; j < colList.getLength(); j++) {
						Node colNode = colList.item(j);
	
						Element cElement = (Element) colNode;
	
						map = new HashMap<String, Object>();
	
						map.put(Define.Key.TB_INFO_NAME,   cElement.getElementsByTagName(Define.Key.TB_INFO_NAME).item(0).getTextContent());
						map.put(Define.Key.TB_INFO_TITLE,  cElement.getElementsByTagName(Define.Key.TB_INFO_TITLE).item(0).getTextContent());
						if (cElement.getElementsByTagName(Define.Key.TB_INFO_DB_TYPE).item(0) != null) {
							map.put(Define.Key.TB_INFO_DB_TYPE,  cElement.getElementsByTagName(Define.Key.TB_INFO_DB_TYPE).item(0).getTextContent());
						}
						if (cElement.getElementsByTagName(Define.Key.TB_INFO_LENGTH).item(0) != null) {
							map.put(Define.Key.TB_INFO_LENGTH,  cElement.getElementsByTagName(Define.Key.TB_INFO_LENGTH).item(0).getTextContent());
						}
						
						result.put(cElement.getElementsByTagName(Define.Key.TB_INFO_NUM).item(0).getTextContent(),  map);
					}
					
	
					result.put(Define.Key.TB_INFO_EC_SQL,	  mElement.getAttribute(Define.Key.TB_INFO_EC_SQL));
					result.put(Define.Key.TB_INFO_REFER_SQ,  mElement.getAttribute(Define.Key.TB_INFO_REFER_SQ));
					result.put(Define.Key.TB_INFO_AFTER_SQ,  mElement.getAttribute(Define.Key.TB_INFO_AFTER_SQ));
				}
			}
		} catch (ParserConfigurationException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SAXException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return result;
	}
	
	/**
	 * 에러 엑셀다운로드
	 * 하드코딩 언젠가 바꾸겠습니다.
	 */	
	public byte[] errorExcelCreate(List<Map<String, Object>> data) throws IOException  {
		
		SXSSFWorkbook workbook = null;
		SXSSFRow row = null; 
		SXSSFCell cell = null;
		
		OutputStream outs = null;
		
		List<String> headeres = null;
		
		
    	try {
    		
    		headeres = new ArrayList<>();
    		
    		ByteArrayOutputStream outss = new ByteArrayOutputStream();
    				
    		workbook = new SXSSFWorkbook(); 
    		workbook.setCompressTempFiles(true);

    		SXSSFSheet sheet1 = (SXSSFSheet) workbook.createSheet(); 
    		sheet1.setRandomAccessWindowSize(100);
    		
    		//List<Object> mapping = (List<Object>) mappingInfo.get(Define.Key.COL_MAPPING);
    		List<String> mapping = new ArrayList<>();
    		mapping.add("순번");
    		mapping.add("수용가명");
    		mapping.add("수용가번호");
    		mapping.add("구주소");
    		mapping.add("신주소");
    		mapping.add("경도");
    		mapping.add("위도");
    		mapping.add("업종");
    		mapping.add("동");
    		mapping.add("블록");
    		mapping.add("수용가 전화번호");
    		mapping.add("수용가 대상 년도");
    		mapping.add("검침원");
    		mapping.add("검침일");
    		mapping.add("계량기번호");
    		mapping.add("구경");
    		mapping.add("통신");
    		mapping.add("단말 부번호");
    		mapping.add("단말 주번호");
    		mapping.add("단말 회사");
    		mapping.add("단말 설치일");
    		mapping.add("에러메시지");
    		
    		row = (SXSSFRow) sheet1.createRow(0);
        	
        	
        	//cell = (SXSSFCell) row.createCell(0);
        	int idx = 0;
        	for(String obj : mapping) {
        		cell = (SXSSFCell) row.createCell(idx);
                cell.setCellValue(obj);
                idx++;
        	}
        	
        	int idx2 = 1;
        	for (Map<String, Object> obj : data) {
        		row = (SXSSFRow) sheet1.createRow(idx2);
        		
        		for (String key : obj.keySet()) {
        			int idx3 = 0;
        			
        			if ("dataSq".equals(key)) {
        				idx3 = 0;
        			}
        			else if ("custNm".equals(key)) {
        				idx3 = 1;
        			}
        			else if ("adminNo".equals(key)) {
        				idx3 = 2;
        			}
        			else if ("addr".equals(key)) {
        				idx3 = 3;
        			}
        			else if ("addrNew".equals(key)) {
        				idx3 = 4;
        			}
        			else if ("locLng".equals(key)) {
        				idx3 = 5;
        			}
        			else if ("locLat".equals(key)) {
        				idx3 = 6;
        			}
        			else if ("useType".equals(key)) {
        				idx3 = 7;
        			}
        			else if ("siteNm".equals(key)) {
        				idx3 = 8;
        			}
        			else if ("blkNm".equals(key)) {
        				idx3 = 9;
        			}
        			else if ("custPhone".equals(key)) {
        				idx3 = 10;
        			}
        			else if ("setYears".equals(key)) {
        				idx3 = 11;
        			}
        			else if ("readOpr".equals(key)) {
        				idx3 = 12;
        			}
        			else if ("checkDay".equals(key)) {
        				idx3 = 13;
        			}
        			else if ("meterNo".equals(key)) {
        				idx3 = 14;
        			}
        			else if ("pipeDia".equals(key)) {
        				idx3 = 15;
        			}
        			else if ("amiType".equals(key)) {
        				idx3 = 16;
        			}
        			else if ("subDevNo".equals(key)) {
        				idx3 = 17;
        			}
        			else if ("devNo".equals(key)) {
        				idx3 = 18;
        			}
        			else if ("companyNm".equals(key)) {
        				idx3 = 19;
        			}
        			else if ("setDt".equals(key)) {
        				idx3 = 20;
        			}
					else if ("msg".equals(key)) {
        				idx3 = 21;
        			}
        			
        			
        			SXSSFCell cell2 = (SXSSFCell) row.createCell(idx3);
        			Object value = obj.get(key);
        			if(value != null) 
        				cell2.setCellValue( value.toString() );
        			else
        				cell2.setCellValue("");
				}
        		
        		idx2++;
			}
    		
        	workbook.write(outss);
        	return outss.toByteArray();
        	
		} catch (IOException e) {
			e.printStackTrace();
			return null;
		}
    	 

	} 
}
