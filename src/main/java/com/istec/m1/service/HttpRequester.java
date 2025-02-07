package com.istec.m1.service;


import java.util.Map;

import javax.net.ssl.HttpsURLConnection;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

public class HttpRequester {

	
	public static String get(String url) throws Exception {
		StringBuilder response = new StringBuilder();
		HttpURLConnection httpClient = (HttpURLConnection) new URL(url).openConnection();
        httpClient.setRequestMethod("GET");

        int responseCode = httpClient.getResponseCode();
        System.out.println("\nSending 'GET' request to URL : " + url);
        System.out.println("Response Code : " + responseCode);
        BufferedReader in = null;
        try {
        	in = new BufferedReader( new InputStreamReader(httpClient.getInputStream()));
            String line;
            while ((line = in.readLine()) != null) {
                response.append(line);
            }
        } catch (Exception e) {	
        	e.printStackTrace();
		} finally {
			if(in != null) in.close();
		}
        if(response.length() == 0) {
        	return httpClient.getResponseCode() + "";
        }        
        return response.toString();
    }

	// post 요청방법
	public static String post(String url, String urlParameters, String ContentType) throws Exception {
		StringBuilder response = new StringBuilder();
        HttpURLConnection httpClient = (HttpURLConnection) new URL(url).openConnection();
        httpClient.setRequestMethod("POST");
        if(ContentType != null && ContentType.length() > 0) {
        	httpClient.setRequestProperty("Content-Type", ContentType);	
        }
        //String urlParameters = "sn=C02G8416DRJM&cn=&locale=&caller=&num=12345";

        httpClient.setDoOutput(true);
        try (DataOutputStream wr = new DataOutputStream(httpClient.getOutputStream())) {
        	if(urlParameters.length() > 0) wr.writeBytes(urlParameters);
            wr.flush();
        }

        BufferedReader in = null;
        try {
        	in = new BufferedReader( new InputStreamReader(httpClient.getInputStream()));
            String line;
            while ((line = in.readLine()) != null) {
                response.append(line);
            }
        } catch (Exception e) {	
        	e.printStackTrace();
		} finally {
			if(in != null) in.close();
		}
        
        if(response.length() == 0) {
        	return httpClient.getResponseCode() + "";
        }
        return response.toString();
	}
}	