
package com.istec.m1.defines;

public enum FileType {
	EXCEL(0),
	CSV  (1),
	TXT  (2);
			
	private int value;
	
	private FileType(int value){
		this.value = value;
	}
	
	public int getValue(){
		return this.value;
	}
	
    public String value() {
        return name();
    }
    
    public static FileType valueOf(int value) {
    	switch (value) {
			case 0: return EXCEL;
			case 1: return CSV;
			case 2: return TXT;
			default : 
				return null ; 
    	}    	
    }

    public static FileType intValue(String s) {
        return valueOf(s);
    }
}
