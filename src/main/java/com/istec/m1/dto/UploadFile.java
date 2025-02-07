package com.istec.m1.dto;

import org.springframework.web.multipart.MultipartFile;

public class UploadFile {

	/**
	 * 첨부 파일
	 */
	private MultipartFile file_info;	// 실제 파일

	private int fileType; 				// Excel, CSV
	private String encodingType; 		// 인코딩 방법
	private String delimeter; 			// 딜리미터

	

	public MultipartFile getFile_info() {
		return file_info;
	}

	public void setFile_info(MultipartFile file_info) {
		this.file_info = file_info;
	}

	public int getFileType() {
		return fileType;
	}

	public void setFileType(int fileType) {
		this.fileType = fileType;
	}

	public String getEncodingType() {
		return encodingType;
	}

	public void setEncodingType(String encodingType) {
		this.encodingType = encodingType;
	}

	public String getDelimeter() {
		return delimeter;
	}

	public void setDelimeter(String delimeter) {
		this.delimeter = delimeter;
	}


}