package com.istec.m1.defines;
 
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.util.Map;
 
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
 
import org.springframework.stereotype.Component;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.view.AbstractView;
 

public class FileDownloadView extends AbstractView {
//  파일 다운로드
    
    public FileDownloadView(){

        //content type을 지정. 

        setContentType("apllication/download; charset=utf-8");

    }

        

    @Override

    protected void renderMergedOutputModel(Map<String, Object> model,

            HttpServletRequest req, HttpServletResponse res) throws Exception {

        // TODO Auto-generated method stub

        

        

        File file = (File) model.get("downloadFile");

        

        res.setContentType(getContentType());

        res.setContentLength((int) file.length());

        res.setHeader("Content-Disposition", "attachment; filename=\"" + 

                java.net.URLEncoder.encode(file.getName(), "utf-8") + "\";");

        res.setHeader("Content-Transfer-Encoding", "binary");

        

        OutputStream out = res.getOutputStream();

        FileInputStream fis = null;

        

        try {

            

            fis = new FileInputStream(file);

            FileCopyUtils.copy(fis, out);

            

        } catch (Exception e) {

            e.printStackTrace();

        } finally {

            if(fis != null) {

                try { 

                    fis.close(); 

                }catch (IOException e) {

                    e.printStackTrace();

                }

            }

        }

        

        out.flush();

    }

};


