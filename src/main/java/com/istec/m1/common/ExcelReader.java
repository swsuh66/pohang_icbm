package com.istec.m1.common;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

 import org.apache.poi.hssf.usermodel.HSSFWorkbook;
 import org.apache.poi.ss.usermodel.Cell;
 import org.apache.poi.ss.usermodel.Row;
 import org.apache.poi.ss.usermodel.Sheet;
 import org.apache.poi.ss.usermodel.Workbook;
 import org.apache.poi.xssf.usermodel.XSSFWorkbook;
 
public class ExcelReader {
	
	/**
     * 엑셀파일을 읽습니다.
     */
	public static List<List<String>> toList(InputStream in, String nm)  {
	       
        List<List<String>> result = new ArrayList<List<String>>();
        
        List<String> colList = null;
     
        try {
        
        	Workbook wb = getWorkbook(in, nm);
        	
        	if(wb == null) 
        		return null;        
        	
            Sheet sheet = wb.getSheetAt(0);

            Row row = null;
  
            for(int i = 0; i < sheet.getPhysicalNumberOfRows(); i++) {
       
                row = sheet.getRow(i);
                                
                if(row != null) {
                	
                	colList = new ArrayList<String>();
                	
                	//int cellNum = row.getPhysicalNumberOfCells();
                	int j = 0;
                	boolean isContain = true;
                	
                	while(true) {

                        String data = getValue(row.getCell(j));
                        
                        if(data.length() > 0)
                        	colList.add(data);
                        else
                        	colList.add(null);
                        
                        j ++;
                        
                        if(j > 100) break; 
                        		
                    }
                	
                	for(int ix=(colList.size()-1); 0<=ix ;ix--) {
                		
                		if(colList.get(ix) == null) 
                			colList.remove(ix);
                		else 
                			break;
                		
                		if(ix == 0) isContain = false;
                	}
                	
                    if(isContain) result.add(colList);                
                }
                
            }  
            
		} catch (Exception e) {
			
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
		
	/**
     * 엑셀파일을 읽어서 Workbook 객체에 리턴한다.
     * XLS와 XLSX 확장자를 비교한다.
     */
	public static Workbook getWorkbook(InputStream in, String fileNm) {

    	Workbook wb = null;
    	
    	try {

    		if( fileNm.endsWith(".xls") ) {
				
				wb = new HSSFWorkbook(in);
					
			} else if ( fileNm.endsWith(".xlsx") ) {
				
				wb = new XSSFWorkbook(in);
				
			}

		} catch (FileNotFoundException  e) {   
        	
        	throw new RuntimeException();
        	        		
		} catch (IOException e) {   
        	e.printStackTrace();
			throw new RuntimeException();
        	        		
		} finally {
			
			try {
				
				if(in != null) in.close();
				
			} catch (IOException e1) {
				
				throw new RuntimeException();
				
			}
			
		}

        return wb;
        
    }
	
	public static String getValue(Cell cell) {
		
		String value = "";

		if (cell == null) {
			return value;
		}
		
		switch (cell.getCellType()) {
		case Cell.CELL_TYPE_FORMULA:
			value = cell.getCellFormula();
			break;

		case Cell.CELL_TYPE_NUMERIC:
			double f = cell.getNumericCellValue();
			
			if(f == (int)f) 
				value = String.format("%d", (int)f);
		    else
				value = String.format("%f", f).replaceAll("0*$", "");

			break;

		case Cell.CELL_TYPE_STRING:
			value = cell.getStringCellValue();
			break;

		case Cell.CELL_TYPE_BOOLEAN:
			value = cell.getBooleanCellValue() + "";
			break;

		case Cell.CELL_TYPE_BLANK:
			value = "";
			break;

		case Cell.CELL_TYPE_ERROR:
			value = cell.getErrorCellValue() + "";
			break;
		default:
			value = cell.getStringCellValue();
		}

		return value;
	}

	/**
	 * 블랭크 체크
	 * @param cell
	 * @return
	 */
	public static boolean blankCheck(Cell cell) {
		if (cell == null) {
			return true;
		}
		
		return (cell.getCellType() == Cell.CELL_TYPE_BLANK);
	}

}