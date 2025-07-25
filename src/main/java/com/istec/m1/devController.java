package com.istec.m1;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.http.ResponseEntity;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import com.istec.m1.service.QueryService;

/**
 * 홈 컨트롤러.
 */
@Controller
public class devController {
	
	@Autowired
    private QueryService querysv;
	
	@Value("${vLicense}")
	private String vlicense;

	@Value("${spring.web.resources.static-locations}")
	private String imgPath;

	private Logger logger = LoggerFactory.getLogger(devController.class);

	
	/**
	 * test 업로드
	 * 
	 */
	@RequestMapping(value = "/upload", method = RequestMethod.POST)
	public String upload(Locale locale, Model model, HttpServletRequest request) {
		
		return "test_upload";
	}
	
	/**
	 * test select
	 * 
	 */
	@RequestMapping(value = "/sqlTest", method = RequestMethod.POST)
	public String sqlTest(@RequestParam Map<String, Object> paramMap, Model model) { //name 이 key값으로 들어온다.
		
		//setModel(model, request);
		
		try {
			Map<String, Object> param = new HashMap<String,Object >();
			param.put("sql", paramMap.get("testsql"));
			
			List<HashMap<String, Object>> data = querysv.select("mars.icbm.devSqlMapper.sqlTest", param);
			/* 
			for (HashMap<String,Object> item : data) {
				for (String key : item.keySet()) {
					String value = nullCheck(item.get(key));
					
					value = value.replaceAll("\r\n", "<br><br>");
					item.put(key, value);
				}
			}
*/
			model.addAttribute("data", data);
		} catch (Exception e) {
			
			model.addAttribute("msg", e.getMessage());
		}
       
		return "DSC";
	}
	
	/**
	 * test update
	 * 
	 */
	@RequestMapping(value = "/sqlTest1", method = RequestMethod.POST)
	public String sqlTest1(@RequestParam Map<String, Object> paramMap, Model model) { //name 이 key값으로 들어온다.
		
		//setModel(model, request);
		try {
			Map<String, Object> param = new HashMap<String,Object >();
			param.put("sql", paramMap.get("testsql"));
			
			int count = querysv.update("mars.icbm.devSqlMapper.sqlTest1", param);
			model.addAttribute("count", count);
		} catch (Exception e) {
			model.addAttribute("msg", e.getMessage());
		}
       
		return "DSC";
	}
	
	/**
	 * 브이로그 라이센스 key값 가져오기
	 * 
	 */
	@RequestMapping(value = "/getLicense", method = RequestMethod.POST)
	@ResponseBody
	public Map<String, Object> getLicense(@RequestParam Map<String, Object> paramMap, Model model) { //name 이 key값으로 들어온다.
		Map<String, Object> result = new HashMap<>();
		try {
			result.put("isSucces", "Y");
			result.put("license", vlicense);
		} catch (Exception e) {
			result.put("msg", e.getMessage());
			result.put("isSucces", "N");
		}
       
		return result;
	}


	/*
	 * 이미지 파일 초기화
	 */
	@RequestMapping(value = "/file/image_reset", method = RequestMethod.POST)
	@ResponseBody
	public ResponseEntity<Map<String, Object>> image_reset(
			@RequestParam("imgFile") MultipartFile[] imgfile, 
			@RequestParam Map<String, Object> paramMap, 
			Model model) //name 이 key값으로 들어온다.
	{ 
		Map<String, Object> result = new HashMap<>();
		try {
			//File staticDir = ResourceUtils.getFile("classpath:static/meter_img");
			logger.debug("=======================================");
			File targetDir = new ClassPathResource("static/meter_img").getFile();
			logger.debug("targetDir: "+ targetDir );

			if (!targetDir.exists()) {
				boolean created = targetDir.mkdirs();
				if (!created) {
					throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "폴더 생성 실패");
				}
			}
			
			for (MultipartFile imgf : imgfile) {
				Path path = Paths.get(targetDir.getAbsolutePath(), imgf.getOriginalFilename());
				Files.write(path, imgf.getBytes());
			}

			result.put("msg", "이미지 저장 성공");
			result.put("isSucces", "Y");
			return ResponseEntity.ok(result);

		} catch (ResponseStatusException e) {
			logger.warn("ResponseStatusException 발생: {}", e.getReason());
			result.put("msg", e.getReason());
			result.put("isSucces", "N");
			return ResponseEntity.status(e.getStatus()).body(result);

		} catch (Exception e) {
			logger.error("이미지 저장 중 예외 발생", e);
			result.put("msg", "서버 오류: " + e.getMessage());
			result.put("isSucces", "N");
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
		}
	}

	/*
	 * 이미지 파일 초기화
	 */
	@RequestMapping(value = "/file/image_clear", method = RequestMethod.POST)
	@ResponseBody
	public Map<String, Object> image_clear( @RequestParam Map<String, Object> paramMap, Model model) { //name 이 key값으로 들어온다.
		Map<String, Object> result = new HashMap<>();
		try {
			Map<String, Object> param = new HashMap<>();
			int count = querysv.update("mars.icbm.devSqlMapper.img_file_reset", param);
		} catch (Exception e) {
			result.put("msg", e.getMessage());
			result.put("isSucces", "N");
		}
       
		return result;
	}

	/*
	 * 종합정보등록 수용가 삭제
	 */
	@RequestMapping(value = "/data/adminclear", method = RequestMethod.POST)
	@ResponseBody
	public Map<String, Object> adminclear( @RequestBody Map<String, Object> paramMap, Model model) { //name 이 key값으로 들어온다.
		Map<String, Object> result = new HashMap<>();
		try {
			Map<String, Object> param = new HashMap<>();
			String accessKey =  nullCheck(paramMap.get("acKey"));

			List<HashMap<String, Object>> chkData = querysv.select("mars.icbm.devSqlMapper.selectdeletecode", paramMap);
			
			if (chkData.size() > 0) {
				Map<String, Object> data = chkData.get(0);
				int chkCnt = Integer.parseInt(nullCheck(data.get("cnt")));
				if (chkCnt > 0) {
					int count = querysv.update("mars.icbm.devSqlMapper.deleteCustomerInfo", paramMap);
					result.put("isSuccess", "Y");
				}
				else {
					result.put("isSuccess", "N");
					result.put("msg", "Key 값이 적합하지않습니다. 개발팀에게 문의하세요.");
					return result;
				}
			}
			else {
				result.put("isSuccess", "N");
				result.put("msg", "Key 값이 적합하지않습니다. 개발팀에게 문의하세요.");
				return result;
			}

			/*
			if ("*istec*cs*9304&&".equals(accessKey)) { //cs팀
				result.put("isSuccess", "Y");
				
			}
			else if ("*****123*****".equals(accessKey)){ //주무관//개발팀
				result.put("isSuccess", "Y");
			}
			else if ("*2*3*fc*$*%*".equals(accessKey)){ // 타사
				result.put("isSuccess", "Y");
			}
			else if ("**&**dev**@**".equals(accessKey)){ // 개발팀
				result.put("isSuccess", "Y");
			}
			else {
				result.put("isSuccess", "N");
				result.put("msg", "Key 값이 적합하지않습니다. 개발팀에게 문의하세요.");
				return result;

			}
 			*/
			
		} catch (Exception e) {
			result.put("msg", e.getMessage());
			result.put("isSucces", "N");
		}
       
		return result;
	}


	/**
	 * 센서값 생성
	 * 
	 */
	@RequestMapping(value = "/senserCreate", method = RequestMethod.POST)
	@ResponseBody
	public Map<String, Object> senserCreate(@RequestParam("items") List<String> items,@RequestParam Map<String, Object> paramMap, Model model) { //name 이 key값으로 들어온다.
		Map<String, Object> result = new HashMap<>();
		StringBuilder logInfo = new StringBuilder();
		StringBuilder value = new StringBuilder();
		try {
			Map<String, Object> params = new HashMap<>();
			//메시지 헤더 
			String header =  nullCheck(paramMap.get("header"));
			logInfo.append("header = " + header + "\r\n");
			value.append(header);
			//메시지 길이
			String conlength = nullCheck(paramMap.get("conlength"));
			logInfo.append("메시지길이 = " + conlength + "\r\n");
			value.append(conlength);
			//메시지 커맨드
			String commd = nullCheck(paramMap.get("commd"));
			logInfo.append("메시지커멘드 = " + commd + "\r\n");
			value.append(commd);
			//imei
			String imei = nullCheck(paramMap.get("imei"));
			String realimei = imei.substring(0, imei.length() - 1);
			logInfo.append("imei 정보 = " + realimei + "\r\n");
			value.append(imei);
			//imsi
			String imsi = nullCheck(paramMap.get("imsi"));
			String realimsi = imsi.substring(0, imsi.length() - 1);
			logInfo.append("imsi 정보 = " + realimsi + "\r\n");
			value.append(imsi);
			//수신강도 
			String rssi_iv = nullCheck(paramMap.get("rssi_iv"));
			int rssi_iv_log = Integer.parseInt(nullCheck(paramMap.get("rssi_iv")), 16) * - 1;
			logInfo.append("수신강도 = " + rssi_iv_log + "\r\n");
			value.append(rssi_iv);
			//비트에러율
			String ber = nullCheck(paramMap.get("ber"));
			int ber_log = Integer.parseInt(nullCheck(paramMap.get("ber")), 16);
			if (ber_log > 127) {
				ber_log = (Integer.parseInt(bitReversal(Integer.toBinaryString(ber_log).substring(1,7)), 2) + 1) * -1;
				//ber = (~((1 << 7) - 1 - ber)) * -1;
				logInfo.append("비트에러율 = " + ber_log + "\r\n");
			}
			value.append(ber);

			//셀아이디
			String cid = nullCheck(paramMap.get("cid"));
			int cid_log = fn_hexstring_to_littleendian2(nullCheck(paramMap.get("cid")));
			if (cid_log > 32767) {
				cid_log = (Integer.parseInt(bitReversal(Integer.toBinaryString(cid_log).substring(1,16)), 2) + 1) * -1;
				logInfo.append("셀아이디 = " + cid_log + "\r\n");
			}
			value.append(cid);
			// rsrp
			String rsrp = nullCheck(paramMap.get("rsrp"));
			int rsrp_log = fn_hexstring_to_littleendian2(nullCheck(paramMap.get("rsrp")));
			if (rsrp_log > 32767) {
				rsrp_log = (Integer.parseInt(bitReversal(Integer.toBinaryString(rsrp_log).substring(1,16)), 2) + 1) * -1;
				logInfo.append("rsrp = " + rsrp_log + "\r\n");
			}
			value.append(rsrp);
			//rsrq
			String rsrq = nullCheck(paramMap.get("rsrq"));
			int rsrq_log = fn_hexstring_to_littleendian2(nullCheck(paramMap.get("rsrq")));
			if (rsrq_log > 32767) {
				rsrq_log = (Integer.parseInt(bitReversal(Integer.toBinaryString(rsrq_log).substring(1,16)), 2) + 1) * -1;
				logInfo.append("rsrq = " + rsrq_log + "\r\n");
			}
			value.append(rsrq);
			//SNR
			String Snr = nullCheck(paramMap.get("Snr"));
			int Snr_log = fn_hexstring_to_littleendian2(nullCheck(paramMap.get("Snr")));
			if (Snr_log > 32767) {
				Snr_log = (Integer.parseInt(bitReversal(Integer.toBinaryString(Snr_log).substring(1,16)), 2) + 1) * -1;
				logInfo.append("Snr = " + Snr_log + "\r\n");
			}
			value.append(Snr);
			//단말기 정보 번호
			String ami_type = nullCheck(paramMap.get("ami_type"));
			logInfo.append("단말기 정보 번호 = " + ami_type + "\r\n");
			value.append(ami_type);
			//fw 버전
			String fwVer_log = Integer.parseInt(nullCheck(paramMap.get("fwVer")).substring(0, 2), 16) + "." + Integer.parseInt(nullCheck(paramMap.get("fwVer")).substring(2, 4), 16);
			String fwVer = nullCheck(paramMap.get("fwVer"));
			logInfo.append("fw 버전 = " + fwVer_log + "\r\n");
			value.append(fwVer);
			//단말기정보 배터리 전압
			double bat_iv_log = Integer.parseInt(nullCheck(paramMap.get("bat_iv")), 16) / (double)10;
			String bat_iv =nullCheck(paramMap.get("bat_iv"));
			logInfo.append("단말기정보 배터리 전압 = " + bat_iv_log + "\r\n");
			value.append(bat_iv);

			//계량기정보 (기물정보)
			String met_no_log = nullCheck(paramMap.get("met_no")).substring(0, 2) + "-" + nullCheck(paramMap.get("met_no")).substring(2, 8);
			String met_no = nullCheck(paramMap.get("met_no"));
			logInfo.append("계량기정보 (기물정보) = " + met_no_log + "\r\n");
			value.append(met_no);

			//계량기정보 (계량기형식)
			String met_type_log = String.format("%d",Integer.parseInt( nullCheck(paramMap.get("met_type")), 16));
			String met_type = nullCheck(paramMap.get("met_type"));
			logInfo.append("계량기정보 (계량기형식) = " + met_type_log + "\r\n");
			value.append(met_type);
			// 구경 
			int hash_hex_int = Integer.parseInt(nullCheck(paramMap.get("met_gau")), 16) & 240;
			//String bit_hash_int = Integer.toBinaryString(hash_hex_int).substring(0,4);
			String bit_hash_int = String.format("%08d", Integer.parseInt(Integer.toBinaryString(hash_hex_int))).substring(0,4);
			int hash_int = Integer.parseInt(bit_hash_int, 2); // 10진수숫자로 변환

			String real_met_gau = nullCheck(paramMap.get("met_gau"));
			value.append(real_met_gau);
			String met_gau = "";
			switch (hash_int) {
				case 1:
					met_gau = "15";
					break;
				case 2:
					met_gau = "20";
					break;
				case 3:
					met_gau = "25";
					break;
				case 4:
					met_gau = "32";
					break;
				case 5:
					met_gau = "40";
					break;
				case 6:
					met_gau = "50";
					break;
				case 7:
					met_gau = "80";
					break;
				case 8:
					met_gau = "100";
					break;
				case 9:
					met_gau = "150";
					break;
				case 10:
					met_gau = "200";
					break;
				case 11:
					met_gau = "250";
					break;
				case 12:
					met_gau = "300";
					break;
				default:
					met_gau = "ER";
					break;
			}
			logInfo.append("구경  = " + met_gau + "\r\n");

			//계량기정보 (소수점 위치)
			int hash_hex_int2 = Integer.parseInt(nullCheck(paramMap.get("met_gau")), 16) & 15;
			String bit_hash_int2 = String.format("%04d", Integer.parseInt(Integer.toBinaryString(hash_hex_int2))).substring(0,4);
			int data_dec_pos_log = Integer.parseInt(bit_hash_int2, 2); // 10진수숫자로 변환

			logInfo.append("계량기정보 (소수점 위치)  = " + data_dec_pos_log + "\r\n");

			//계량기정보 상태코드
			int hash_hex_int3 = Integer.parseInt(nullCheck(paramMap.get("met_err_code")),16);
			String met_err_code_log = String.format("%08d", Integer.parseInt(Integer.toBinaryString(hash_hex_int3)));
			String met_err_code = nullCheck(paramMap.get("met_err_code"));
			logInfo.append("계량기정보 (상태코드)  = " + met_err_code_log + "\r\n");
			value.append(met_err_code);
			//검침주기
			int meter_reading_cycle_log = Integer.parseInt(nullCheck(paramMap.get("meter_reading_cycle")),16);
			String meter_reading_cycle = nullCheck(paramMap.get("meter_reading_cycle"));
			logInfo.append("검침주기  = " + meter_reading_cycle_log + "\r\n");
			params.put("meter_reading_cycle", meter_reading_cycle_log);
			value.append(meter_reading_cycle);
			//보고주기
			int report_cycle_log = Integer.parseInt(nullCheck(paramMap.get("report_cycle")),16);
			String report_cycle = nullCheck(paramMap.get("report_cycle"));
			logInfo.append("보고주기  = " + report_cycle_log + "\r\n");
			value.append(report_cycle);
			
			String meas_dt = "";
			int years= Integer.parseInt(String.format("%02d",Integer.parseInt(nullCheck(paramMap.get("meas_dt")).substring(0,2),16))) + 2000;
			String year = "" + years;
			String month = String.format("%02d",Integer.parseInt(nullCheck(paramMap.get("meas_dt")).substring(2,4),16));
			String day = String.format("%02d",Integer.parseInt(nullCheck(paramMap.get("meas_dt")).substring(4,6),16));
			String hour = String.format("%02d",Integer.parseInt(nullCheck(paramMap.get("meas_dt")).substring(6,8),16));
			String min = String.format("%02d",Integer.parseInt(nullCheck(paramMap.get("meas_dt")).substring(8,10),16));
			String sec = String.format("%02d",Integer.parseInt(nullCheck(paramMap.get("meas_dt")).substring(10,12),16));

			meas_dt = year + month + day + hour + min + sec;
			String meas_dt_real= nullCheck(paramMap.get("meas_dt"));
			value.append(meas_dt_real);
			logInfo.append("검침데이터 (검침 시간)  = " + meas_dt + "\r\n");


			int meter_reading_cycle_data_log = Integer.parseInt(nullCheck(paramMap.get("meter_reading_cycle_data")),16);
			String meter_reading_cycle_data = nullCheck(paramMap.get("meter_reading_cycle_data"));
			logInfo.append("검침데이터 (검침 주기)  = " + meter_reading_cycle_data_log + "\r\n");
			value.append(meter_reading_cycle_data);

			int data_cnt_log = Integer.parseInt(nullCheck(paramMap.get("data_cnt")),16);
			String data_cnt = nullCheck(paramMap.get("data_cnt"));
			logInfo.append("데이터 개수  = " + data_cnt_log + "\r\n");
			value.append(data_cnt);

			int data_pos_log = Integer.parseInt(nullCheck(paramMap.get("data_pos")),16);
			String data_pos = nullCheck(paramMap.get("data_pos"));
			logInfo.append("검침값 위치  = " + data_pos_log + "\r\n");
			params.put("data_pos", data_pos_log);
			value.append(data_pos);

			long temp_num =Long.parseLong( rpad("1", data_dec_pos_log + 1, "0")); // 소수점위치에따라변환
			logInfo.append("temp_num  = " + temp_num + "\r\n");

			String accu_iv_char = nullCheck(paramMap.get("accu_iv"));
			value.append(accu_iv_char);
			String accu_iv = "";
			if ("FFFFFFFF".equals(accu_iv_char.toUpperCase())) {
				accu_iv = "0";
			}
			else {
				accu_iv = "" + fn_hexstring_to_littleendian(accu_iv_char);
			}

			logInfo.append("데이터 기준값  = " + accu_iv + "\r\n");
			logInfo.append("데이터 기준 날짜  = " + meas_dt + "\r\n");

			double accu_iv_cal = fn_hexstring_to_littleendian(accu_iv_char);

			long data_val_temp = 0;


			for (int i = items.size()-1; i >= 0; i--) {
				String item = items.get(i);
				data_val_temp = fn_hexstring_to_littleendian(item);
				if (data_val_temp == 65535) {
					data_val_temp = 0;
				}
				logInfo.append("data_val_temp = " + data_val_temp + "\r\n");

				accu_iv_cal = accu_iv_cal - data_val_temp;
			}
			/* 
			for (int i = 1; i <= data_cnt_log; i++) {
				int index = 118 + (4 * (i-1) );
				data_val_temp = fn_hexstring_to_littleendian(con.substring(index, index + 4));
				if (data_val_temp == 65535) {
					data_val_temp = 0;
				}

				logInfo.append("data_val_temp = " + data_val_temp + "\r\n");

				accu_iv_cal = accu_iv_cal - data_val_temp;
			}
*/
			String ami_err_code ="";
			String dev_un_insdb = "";
			String met_type_insdb = "";
			String met_gau_insdb = "";
			String met_err_code_insdb="";
			String accu_iv_temp = "";
			String stat_cd = "00000000";

			String meas_dt_temp = meas_dt;

			logInfo.append("********************데이터 시작********************\r\n");
			//for (String item : items) {
			for (int i = items.size()-1; i >= 0; i--) {
				logInfo.append("\r\n");
				logInfo.append("********************" + i +"차" +"데이터 시작********************\r\n");
				String item = items.get(i);
				value.append(item);
				data_val_temp = fn_hexstring_to_littleendian(item);

				if (data_val_temp == 65535) {
					ami_err_code = "10000000";
					dev_un_insdb = null;
					met_type_insdb = null;
					met_gau_insdb = null;
					met_err_code_insdb = null;
					accu_iv_temp = null;
					data_val_temp = 0;
				}
				else {
					ami_err_code = "00000000";
					dev_un_insdb = met_no;
					met_type_insdb = met_type;
					met_gau_insdb = met_gau;
					met_err_code_insdb = met_err_code;
					accu_iv_temp = String.format("%.3f", accu_iv_cal / temp_num);

					accu_iv_cal = accu_iv_cal + (double)data_val_temp;
				}

				if ("00010000".equals(met_err_code_insdb)) {
					stat_cd = "00000000";
				}
				else {
					stat_cd = met_err_code_insdb;
				}

				String log_accu_cal = String.format("%.3f", accu_iv_cal);
				params.put("stat_cd", stat_cd);

				params.put("accu_iv_cal", accu_iv_cal);
				//params.put("datapos_temp", datapos_temp);
				params.put("accu_iv_temp", accu_iv_temp);

				SimpleDateFormat transFormat = new SimpleDateFormat("yyyyMMddHHmmss");
				Date date = transFormat.parse(meas_dt);
				Calendar cal1 = Calendar.getInstance();
				cal1.setTime(date);
				if (meter_reading_cycle_data_log == 0) {
					cal1.add(Calendar.MINUTE,  -1);
				}
				else {
					int time_date = (meter_reading_cycle_data_log * i); 
					cal1.add(Calendar.HOUR,  -time_date);
				}
				meas_dt_temp = transFormat.format(new Date(cal1.getTimeInMillis()));
				params.put("meas_dt_temp", meas_dt_temp);
				
				logInfo.append("accu_iv_cal= " + log_accu_cal + "     data_val_temp=" + data_val_temp+ "\r\n");
				//logInfo.append("데이터측정 위치= " + datapos_temp + "\r\n");
				logInfo.append("최종데이터값 (accu_iv_temp)= " + accu_iv_temp + "\r\n");
				logInfo.append("계산후 데이터날짜= " + meas_dt_temp + "\r\n" );
				logInfo.append("데이터측정 기준값= " + accu_iv + "\r\n" );
				logInfo.append("데이터측정차이 데이터값= " + data_val_temp + "\r\n" );
				//logInfo.append("최종데이터 값= " + String.format("%.3f", accu_iv_temp * temp_num) + "\r\n" );
			}
			//마지막 체크썸.
			value.append("00");
		}
		catch(Exception e){
		}

		try {
			result.put("log", logInfo.toString());
			result.put("value", value.toString());
		} catch (Exception e) {
			result.put("msg", e.getMessage());
			result.put("isSucces", "N");
		}
       
		return result;
	}

	/**
	 * 센서값 로그변환
	 * 
	 */
	@RequestMapping(value = "/senserLog", method = RequestMethod.POST)
	@ResponseBody
	public Map<String, Object> senserLog(@RequestParam Map<String, Object> paramMap, Model model) { //name 이 key값으로 들어온다.
		Map<String, Object> result = new HashMap<>();
		StringBuilder logInfo = new StringBuilder();
		String con = nullCheck(paramMap.get("con")).replaceAll(" ", "");
		try {
			Map<String, Object> params = new HashMap<>();
			//메시지 헤더 
			String header = con.substring(0, 2);
			logInfo.append("header = " + header + "\r\n");
			params.put("header", header);
			//메시지 길이
			String conlength =  ""+ Integer.parseInt(con.substring(2, 4), 16);
			logInfo.append("메시지길이 = " + conlength + "\r\n");
			params.put("conlength", conlength);
			//메시지 커맨드
			String commd = con.substring(4, 6);
			logInfo.append("메시지커멘드 = " + commd + "\r\n");
			params.put("commd", commd);
			//imei
			String imei = con.substring(6, 8) + "-" + con.substring(8, 14) + "-" + con.substring(14, 20) +  con.substring(20, 22);
			String realimei = imei.substring(0, imei.length() - 1);
			logInfo.append("imei 정보 = " + realimei + "\r\n");
			params.put("imei", realimei);
			//imsi
			String imsi = con.substring(22, 24) + "-" + con.substring(24, 30) + "-" + con.substring(30, 36) +  con.substring(36, 38);
			String realimsi = imsi.substring(0, imsi.length() - 1);
			logInfo.append("imsi 정보 = " + realimsi + "\r\n");
			params.put("imsi", realimsi);
			//수신강도 
			int rssi_iv = Integer.parseInt(con.substring(38, 40), 16) * -1;
			logInfo.append("수신강도 = " + rssi_iv + "\r\n");
			params.put("rssi_iv", rssi_iv);
			//비트에러율
			int ber = Integer.parseInt(con.substring(40, 42), 16);
			if (ber > 127) {
				ber = (Integer.parseInt(bitReversal(Integer.toBinaryString(ber).substring(1,7)), 2) + 1) * -1;
				//ber = (~((1 << 7) - 1 - ber)) * -1;
				logInfo.append("비트에러율 = " + ber + "\r\n");
			}
			params.put("ber", ber);

			//셀아이디
			int cid = fn_hexstring_to_littleendian2(con.substring(42, 46));
			if (cid > 32767) {
				cid = (Integer.parseInt(bitReversal(Integer.toBinaryString(cid).substring(1,16)), 2) + 1) * -1;
				logInfo.append("셀아이디 = " + cid + "\r\n");
			}
			params.put("cid", cid);

			// rsrp
			int rsrp = fn_hexstring_to_littleendian2(con.substring(46, 50));
			if (rsrp > 32767) {
				rsrp = (Integer.parseInt(bitReversal(Integer.toBinaryString(rsrp).substring(1,16)), 2) + 1) * -1;
				logInfo.append("rsrp = " + rsrp + "\r\n");
			}
			params.put("rsrp", rsrp);
			//rsrq
			int rsrq = fn_hexstring_to_littleendian2(con.substring(50, 54));
			if (rsrq > 32767) {
				rsrq = (Integer.parseInt(bitReversal(Integer.toBinaryString(rsrq).substring(1,16)), 2) + 1) * -1;
				logInfo.append("rsrq = " + rsrq + "\r\n");
			}
			params.put("rsrq", rsrq);
			//SNR
			int Snr = fn_hexstring_to_littleendian2(con.substring(54, 58));
			if (Snr > 32767) {
				Snr = (Integer.parseInt(bitReversal(Integer.toBinaryString(Snr).substring(1,16)), 2) + 1) * -1;
				logInfo.append("Snr = " + Snr + "\r\n");
			}
			params.put("Snr", Snr);
			//단말기 정보 번호
			String ami_type = con.substring(58, 68);
			logInfo.append("단말기 정보 번호 = " + ami_type + "\r\n");
			params.put("ami_type", ami_type);
			//fw 버전
			String fwVer = Integer.parseInt(con.substring(68, 70), 16) + "." + Integer.parseInt(con.substring(70, 72), 16);
			logInfo.append("fw 버전 = " + fwVer + "\r\n");
			params.put("fwVer", fwVer);
			//단말기정보 배터리 전압
			double bat_iv = Integer.parseInt(con.substring(72, 74), 16) / (double)10;
			logInfo.append("단말기정보 배터리 전압 = " + bat_iv + "\r\n");
			params.put("bat_iv", bat_iv);
			//계량기정보 (기물정보)
			String met_no = con.substring(74, 76) + "-" + con.substring(76, 82);
			logInfo.append("계량기정보 (기물정보) = " + met_no + "\r\n");
			params.put("met_no", met_no);
			//계량기정보 (계량기형식)
			String met_type = String.format("%d",Integer.parseInt(con.substring(82, 84), 16));
			logInfo.append("계량기정보 (계량기형식) = " + met_type + "\r\n");
			params.put("met_type", met_type);
			// 구경 
			int hash_hex_int = Integer.parseInt(con.substring(84, 86), 16) & 240;
			//String bit_hash_int = Integer.toBinaryString(hash_hex_int).substring(0,4);
			String bit_hash_int = String.format("%08d", Integer.parseInt(Integer.toBinaryString(hash_hex_int))).substring(0,4);
			int hash_int = Integer.parseInt(bit_hash_int, 2); // 10진수숫자로 변환

			String met_gau = "";
			switch (hash_int) {
				case 1:
					met_gau = "15";
					break;
				case 2:
					met_gau = "20";
					break;
				case 3:
					met_gau = "25";
					break;
				case 4:
					met_gau = "32";
					break;
				case 5:
					met_gau = "40";
					break;
				case 6:
					met_gau = "50";
					break;
				case 7:
					met_gau = "80";
					break;
				case 8:
					met_gau = "100";
					break;
				case 9:
					met_gau = "150";
					break;
				case 10:
					met_gau = "200";
					break;
				case 11:
					met_gau = "250";
					break;
				case 12:
					met_gau = "300";
					break;
				default:
					met_gau = "ER";
					break;
			}
			logInfo.append("구경  = " + met_gau + "\r\n");
			params.put("met_gau", met_gau);

			//계량기정보 (소수점 위치)
			int hash_hex_int2 = Integer.parseInt(con.substring(84, 86),16) & 15;
			String bit_hash_int2 = String.format("%04d", Integer.parseInt(Integer.toBinaryString(hash_hex_int2))).substring(0,4);
			int data_dec_pos = Integer.parseInt(bit_hash_int2, 2); // 10진수숫자로 변환

			logInfo.append("계량기정보 (소수점 위치)  = " + data_dec_pos + "\r\n");
			params.put("data_dec_pos", data_dec_pos);

			//계량기정보 상태코드
			int hash_hex_int3 = Integer.parseInt(con.substring(86, 88),16);
			String met_err_code = String.format("%08d", Integer.parseInt(Integer.toBinaryString(hash_hex_int3)));
			logInfo.append("계량기정보 (상태코드)  = " + met_err_code + "\r\n");
			params.put("met_err_code", met_err_code);

			//검침주기
			int meter_reading_cycle = Integer.parseInt(con.substring(88, 90),16);
			logInfo.append("검침주기  = " + meter_reading_cycle + "\r\n");
			params.put("meter_reading_cycle", meter_reading_cycle);
			//보고주기
			int report_cycle = Integer.parseInt(con.substring(90, 92),16);
			logInfo.append("보고주기  = " + report_cycle + "\r\n");
			params.put("report_cycle", report_cycle);

			String time_err = con.substring(92, 98);
			
			String meas_dt = "";
			if ("FFFFFF".equals(time_err.toUpperCase())) {
				LocalDate currentDate = LocalDate.now();
				String hour = String.format("%02d",Integer.parseInt(con.substring(98, 100),16));
				String min = String.format("%02d",Integer.parseInt(con.substring(100, 102),16));
				String sec = String.format("%02d",Integer.parseInt(con.substring(102, 104),16));
				meas_dt = "" + currentDate + hour+ min + sec;
				meas_dt = meas_dt.replaceAll("-", "");
			}
			else {
				int years= Integer.parseInt(String.format("%02d",Integer.parseInt(con.substring(92, 94),16))) + 2000;
				String year = "" + years;
				String month = String.format("%02d",Integer.parseInt(con.substring(94, 96),16));
				String day = String.format("%02d",Integer.parseInt(con.substring(96, 98),16));
				String hour = String.format("%02d",Integer.parseInt(con.substring(98, 100),16));
				String min = String.format("%02d",Integer.parseInt(con.substring(100, 102),16));
				String sec = String.format("%02d",Integer.parseInt(con.substring(102, 104),16));

				meas_dt = year + month + day + hour + min + sec;
			}
			logInfo.append("검침데이터 (검침 시간)  = " + meas_dt + "\r\n");
			params.put("meas_dt", meas_dt);

			int meter_reading_cycle_data = Integer.parseInt(con.substring(104, 106),16);
			logInfo.append("검침데이터 (검침 주기)  = " + meter_reading_cycle_data + "\r\n");
			params.put("meter_reading_cycle_data", meter_reading_cycle_data);

			int data_cnt = Integer.parseInt(con.substring(106, 108),16);
			logInfo.append("데이터 개수  = " + data_cnt + "\r\n");
			params.put("data_cnt", data_cnt);
			
			int data_pos = Integer.parseInt(con.substring(108, 110),16);
			logInfo.append("검침값 위치  = " + data_pos + "\r\n");
			params.put("data_pos", data_pos);

			long temp_num =Long.parseLong( rpad("1", data_dec_pos + 1, "0")); // 소수점위치에따라변환
			logInfo.append("temp_num  = " + temp_num + "\r\n");
			params.put("temp_num", temp_num);

			String accu_iv_char = con.substring(110, 118);
			String accu_iv = "";
			if ("FFFFFFFF".equals(accu_iv_char.toUpperCase())) {
				accu_iv = "0";
			}
			else {
				accu_iv = "" + fn_hexstring_to_littleendian(accu_iv_char);
			}

			logInfo.append("데이터 기준값  = " + accu_iv + "\r\n");
			logInfo.append("데이터 기준 날짜  = " + meas_dt + "\r\n");
			params.put("accu_iv", accu_iv);

			double accu_iv_cal = fn_hexstring_to_littleendian(accu_iv_char);

			long data_val_temp = 0;

			for (int i = 1; i <= data_cnt; i++) {
				int index = 118 + (4 * (i-1) );
				data_val_temp = fn_hexstring_to_littleendian(con.substring(index, index + 4));
				if (data_val_temp == 65535) {
					data_val_temp = 0;
				}

				logInfo.append("data_val_temp = " + data_val_temp + "\r\n");

				accu_iv_cal = accu_iv_cal - data_val_temp;
			}

			String ami_err_code ="";
			String dev_un_insdb = "";
			String met_type_insdb = "";
			String met_gau_insdb = "";
			String met_err_code_insdb="";
			String accu_iv_temp = "";
			String stat_cd = "00000000";

			String meas_dt_temp = meas_dt;
			int datapos_temp = 118 + ((data_cnt - 1) * 4);
			logInfo.append("********************데이터 시작********************\r\n");
			for (int i = data_cnt - 1; i >= 0; i--) {
				logInfo.append("\r\n");
				logInfo.append("********************" + i +"차" +"데이터 시작********************\r\n");
				data_val_temp = fn_hexstring_to_littleendian(con.substring(datapos_temp, datapos_temp + 4));

				if (data_val_temp == 65535) {
					ami_err_code = "10000000";
					dev_un_insdb = null;
					met_type_insdb = null;
					met_gau_insdb = null;
					met_err_code_insdb = null;
					accu_iv_temp = null;
					data_val_temp = 0;
				}
				else {
					ami_err_code = "00000000";
					dev_un_insdb = met_no;
					met_type_insdb = met_type;
					met_gau_insdb = met_gau;
					met_err_code_insdb = met_err_code;
					accu_iv_temp = String.format("%.3f", accu_iv_cal / temp_num);

					accu_iv_cal = accu_iv_cal + (double)data_val_temp;
				}
				params.put("dev_un_insdb", dev_un_insdb);
				params.put("met_type_insdb", met_type_insdb);
				params.put("met_gau_insdb", met_gau_insdb);
				params.put("met_err_code_insdb", met_err_code_insdb);
				params.put("ami_err_code", ami_err_code);

				//존나쓸모없는로직. 00010000 이란 스탯코드도 정상이란것
				if ("00010000".equals(met_err_code_insdb)) {
					stat_cd = "00000000";
				}
				else {
					stat_cd = met_err_code_insdb;
				}
				String log_accu_cal = String.format("%.3f", accu_iv_cal);
				params.put("stat_cd", stat_cd);

				params.put("accu_iv_cal", accu_iv_cal);
				params.put("datapos_temp", datapos_temp);
				params.put("accu_iv_temp", accu_iv_temp);

				SimpleDateFormat transFormat = new SimpleDateFormat("yyyyMMddHHmmss");
				Date date = transFormat.parse(meas_dt);
				Calendar cal1 = Calendar.getInstance();
            	cal1.setTime(date);
				if (meter_reading_cycle_data == 0) {
					cal1.add(Calendar.MINUTE,  -1);
				}
				else {
					int time_date = (meter_reading_cycle_data * i);
					cal1.add(Calendar.HOUR,  -time_date);
				}
				meas_dt_temp = transFormat.format(new Date(cal1.getTimeInMillis()));
				params.put("meas_dt_temp", meas_dt_temp);
				
				logInfo.append("accu_iv_cal= " + log_accu_cal + "     data_val_temp=" + data_val_temp+ "\r\n");
				logInfo.append("데이터측정 위치= " + datapos_temp + "\r\n");
				logInfo.append("최종데이터 (accu_iv_temp)= " + accu_iv_temp + "\r\n");
				logInfo.append("계산후 데이터날짜= " + meas_dt_temp + "\r\n" );
				logInfo.append("데이터측정 기준값= " + accu_iv + "\r\n" );
				logInfo.append("데이터측정차이 데이터값= " + data_val_temp + "\r\n" );
				//logInfo.append("최종데이터 값= " + String.format("%.3f", accu_iv_temp * temp_num) + "\r\n" );
				datapos_temp -= 4;

			}

			result.put("log", logInfo.toString());
		}
		catch(Exception e){
			result.put("error", logInfo.toString() + "<br>" + e.getMessage());
		}

		return result;
	}





	private String nullCheck(Object obj) {
		String str = "";
		if (obj != null) {
			str = (String)obj;
		}
		return str;
	}

	// 자바에 rpad 가 없어서 만듦 병신같음
    public static String rpad(String input, int length, String padChar) {
        if (input.length() >= length) {
            return input; // 이미 길이가 충분한 경우 원래 문자열 반환
        } else {
            StringBuilder sb = new StringBuilder(input);
            while (sb.length() < length) {
                sb.append(padChar);
            }
            return sb.toString();
        }
    }

	// long 용 바이트 반전
	public long fn_hexstring_to_littleendian(String hexValue) {
		int length = hexValue.length() - 2;
		String result = "";
		while (length >= 0) {
			result = result + hexValue.substring(length, length + 2);
			length -= 2;
		}

		return Long.parseLong(result, 16);
    }

	// int 용 바이트반전
	public int fn_hexstring_to_littleendian2(String hexValue) {
		int length = hexValue.length() - 2;
		String result = "";
		while (length >= 0) {
			result = result + hexValue.substring(length, length + 2);
			length -= 2;
		}

		return Integer.parseInt(result, 16);
    }

	// 자바에 비트 반전연산이 병신같아서 만듦
	public String bitReversal(String con ) {
        StringBuilder str = new StringBuilder();
        for (char conval : con.toCharArray()) {
            char val = ' ';
            if ('0' == conval) {
                val = '1';
            }
            else {
                val = '0';
            }
            str.append(val);
        }
        return str.toString();
    }

}
