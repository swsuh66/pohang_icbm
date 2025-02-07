package com.istec.m1.defines;


public enum StatusCode {
	NONE(0),
	STATUS_OK(200),
	STATUS_CREATED(201),
	STATUS_ACCEPTED(202),
	STATUS_DELETED(200),  //TBD
	STATUS_CHANGED(204),
	STATUS_CONTENT(205),
	STATUS_BAD_REQUEST(400),
	STATUS_UNAUTHORIZED(401),
	STATUS_FORBIDDEN(403),
	STATUS_NOT_FOUND(404),
	STATUS_METHOD_NOT_ALLOWED(405),
	STATUS_NOT_ACCEPTABLE(406),
	STATUS_REQUEST_TIMEOUT(408),
	STATUS_CONFLICT(409),
	STATUS_REQUEST_ENTITY_TOO_LARGE(413),
	STATUS_UNSUPPORTED_MEDIA_TYPE(415),
	STATUS_INTERNAL_SERVER_ERROR(500),
	STATUS_NOT_IMPLEMENTED(501),
	STATUS_CUST_ERROR(-20001);
	
	private int value;
	
	private StatusCode(int value){
		this.value = value;
	}
	
	public int getValue(){
		return this.value;
	}
	
    public String value() {
        return name();
    }

    public static StatusCode intValue(String s) {
        return valueOf(s);
    }
}
