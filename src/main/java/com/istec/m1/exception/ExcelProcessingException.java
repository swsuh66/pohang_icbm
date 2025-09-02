package com.istec.m1.exception;

public class ExcelProcessingException extends Exception  {
    private final int row;
    private final int col;
    private final String detailMessage;

    public ExcelProcessingException(int row, int col, String message) {
        super("엑셀 " + row + "행 " + col + "열 처리 중 오류");
        this.row = row;
        this.col = col;
        this.detailMessage = message;
    }

    public int getRow() {
        return row;
    }

    public int getCol() {
        return col;
    }

    public String getDetailMessage() {
        return detailMessage;
    }
}
