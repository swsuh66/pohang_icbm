package com.istec.enums;

import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import com.fasterxml.jackson.annotation.JsonValue;

public enum EnumVar {
	
	GRAND_PATH("/resources/GRAND_FOLDER")
	, TEMP_PATH("TEMP")
	
	, MAPPER_PATH("com.istec.gb.IstecDAO")
	
	
	;
	
	private String v;
	
	private EnumVar(String val){
		this.v = val;
	}
	
	@JsonValue
	public String toString() {return v;}
	public static Map<String, String> krasMap = Stream.of(EnumVar.values()).collect(Collectors.toMap(EnumVar::name, EnumVar::toString));
	public static String get(String k) {return krasMap.get(k).trim();}
	
}
