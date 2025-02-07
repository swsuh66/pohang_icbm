package com.istec.m1.service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;

import com.istec.m1.common.JacksonParsing;


@Service
public class GeoJsonService {

	private static final String srcpath_ctp = "geojson/ctp_wgs84.geojson";
	private static final String srcpath_sig = "geojson/sig_wgs84.geojson";
	private static final String srcpath_emd = "geojson/emd_wgs84.geojson";
	private static final String srcpath_ind = "geojson/indonesia.json";
 
	private static Map<String, Map<String, Object>> _container = new HashMap<String, Map<String, Object>>();

	/**************************************************************************/
	/*
	 * 
	 */
	
	public Map<String, Object> getBaseGeojson(String code) throws IOException {
		Map<String, Object> feature = getMatchedObject(code);
		if(feature == null)
			return null;
		
		List<Map<String, Object>> features = new ArrayList<Map<String, Object>>();
		features.add(feature);
		
		return makeGeoObject(features);
	}

	public Map<String, Object> getMultiBase(List<String> sccoList) throws IOException {
		
		List<Map<String, Object>> features = new ArrayList<Map<String, Object>>();
		for(int ix=0; ix<sccoList.size(); ix++) {
			
			Map<String, Object> feature = getMatchedObject(sccoList.get(ix));
			if(feature != null)
				features.add(feature);
		}
		
		return makeGeoObject(features);
	}

	public Map<String, Object> getChildGeojson(String code) throws IOException {
		//code = "46150";
		List<Map<String, Object>> features = getMatchedChilds(code);
	
		return makeGeoObject(features);
    }

	/**************************************************************************/
	

	private Map<String, Object> makeGeoObject(List<Map<String, Object>> features) {
		Map<String, Object> result = new HashMap<String, Object>();
		Map<String, Object> crs = new HashMap<String, Object>();
		Map<String, Object> properties = new HashMap<String, Object>();
		
		properties.put("name", "urn:ogc:def:crs:OGC:1.3:CRS84");
		crs.put("type", "name");
		crs.put("properties", properties);
		
		result.put("type", "FeatureCollection");
		result.put("crs", crs);
		result.put("features", features);
		
		return result;
	}
	
	private Map<String, Object> getMatchedObject(String code) throws IOException {
		String source_id;
		String code_field;
		if(code.length() == 2) {
			source_id = srcpath_ctp;
			code_field = "CTPRVN_CD";
		}
		else if(code.length() == 5) {
			source_id = srcpath_sig;
			code_field = "SIG_CD";
		}
		else if(code.length() == 4) {
			source_id = srcpath_ind;
			code_field = "Code";
		}
		else
			return null;
		
		Map<String, Object> geo_source = getSource(source_id);
		if(geo_source == null) {
			return null;
		}

		@SuppressWarnings("unchecked")
		List<HashMap<String, Object>> features = (List<HashMap<String, Object>>)geo_source.get("features");
		for(int ix=0; ix<features.size(); ix++) {
			Map<String, Object> feature = features.get(ix);
			@SuppressWarnings("unchecked")
			Map<String, Object> properties = (Map<String, Object>)feature.get("properties");
			String sig_cd = properties.get(code_field).toString();
			if(!sig_cd.isEmpty() && sig_cd.equals(code)) {
				return feature;
			}
		}
		
		return null;
    }

	private List<Map<String, Object>> getMatchedChilds(String code) throws IOException {
		String source_id;
		String code_field;
		
		if(code.length() == 2) {
			source_id = srcpath_sig;
			code_field = "SIG_CD";
		}
		else if(code.length() == 5) {
			source_id = srcpath_emd;
			code_field = "EMD_CD";
		}
		else
			return null;
		
		Map<String, Object> geo_source = getSource(source_id);
		if(geo_source == null) {
			return null;
		}

		List<Map<String, Object>> result = new ArrayList<Map<String, Object>>();
		
		@SuppressWarnings("unchecked")
		List<HashMap<String, Object>> features = (List<HashMap<String, Object>>)geo_source.get("features");
		for(int ix=0; ix<features.size(); ix++) {
			Map<String, Object> feature = features.get(ix);
			@SuppressWarnings("unchecked")
			Map<String, Object> properties = (Map<String, Object>)feature.get("properties");
			String sig_cd = properties.get(code_field).toString();
			if(!sig_cd.isEmpty() && sig_cd.substring(0, code.length()).equals(code)) {
				result.add(feature);
			}
		}
		
		return result;
    }

	private Map<String, Object> getSource(String source_id) throws IOException {
		Map<String, Object> geo_source = _container.get(source_id);
		
		if(geo_source == null) {
			String fileLocationInClasspath = source_id;
			geo_source = loadSource(fileLocationInClasspath);
			if(geo_source != null)
				_container.put(source_id, geo_source);
		}

		return geo_source;
	}
	
	private Map<String, Object> loadSource(String fileLocationInClasspath) throws IOException {
		
		Resource resource = new ClassPathResource(fileLocationInClasspath);
        BufferedReader br = new BufferedReader(new InputStreamReader(resource.getInputStream(), "utf-8"),1024);
        StringBuilder stringBuilder = new StringBuilder();
        String line;
        while ((line = br.readLine()) != null) {
            stringBuilder.append(line).append('\n');
        }
        br.close();
        
        return JacksonParsing.toMap(stringBuilder.toString());
	}
}
