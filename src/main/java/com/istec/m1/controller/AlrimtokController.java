package com.istec.m1.controller;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestTemplate;

import com.istec.m1.service.QueryService;

import javax.servlet.http.HttpServletResponse;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

/**
 * 알림톡 프록시 컨트롤러 (Spring Boot 2.7)
 * 브라우저 → (동일오리진) /api/alrimtok/* → (서버 내부) Node API 로 중계
 */
@Controller
@RequestMapping("/api/alrimtok")
public class AlrimtokController {

    private static final Logger log = LoggerFactory.getLogger(AlrimtokController.class);
    private static final ObjectMapper MAPPER = new ObjectMapper();

    @Autowired(required = false)
    private RestTemplate restTemplate; // 프로젝트에 Bean 없으면 fallback 생성

    @Autowired
    private QueryService queryService;

    // ===== Node API 주소/경로 (기본값: 같은 서버의 127.0.0.1:3000) =====
    @Value("${alrimtok.api.base-url:http://127.0.0.1:3000}")
    private String baseUrl;

    @Value("${alrimtok.api.test-path:/api/v1/message/test}")
    private String testPath;

    @Value("${alrimtok.api.send-path:/api/v1/message/send}")
    private String sendPath;

    @Value("${alrimtok.api.history-path:/api/v1/message/history}")
    private String historyPath;

    // 전화번호 형식: 010-1234-1234
    private static final Pattern PHONE_PATTERN = Pattern.compile("^010-\\d{4}-\\d{4}$");

    private RestTemplate rt() {
        return (restTemplate != null) ? restTemplate : new RestTemplate();
    }

    @PostMapping("/test")
    @ResponseBody
    public ResponseEntity<?> test(@RequestBody Map<String, Object> body, HttpServletResponse resp) {
        try {
            // 호환: userName -> tgtNm 변환
            String tgtNm   = strOr(body.get("tgtNm"), strOr(body.get("userName"), ""));
            String phone   = strOr(body.get("phoneNum"), "");

            // 간단 검증 + 보정
            if (!isValidPhone(phone)) {
                String fixed = hyphenizePhone(phone);
                if (isValidPhone(fixed)) phone = fixed;
            }
            if (tgtNm.isEmpty() || !isValidPhone(phone)) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(json(false, "phoneNum(010-1234-1234) / tgtNm 필수"));
            }

            Map<String, Object> forward = new HashMap<>();
            forward.put("tgtNm", tgtNm);
            forward.put("phoneNum", phone);

            ResponseEntity<String> r = postJson(baseUrl + testPath, forward);
            return passthrough(r);

        } catch (HttpStatusCodeException e) {
            return ResponseEntity.status(e.getRawStatusCode()).body(nvl(e.getResponseBodyAsString(), "TEST API 오류"));
        } catch (ResourceAccessException e) {
            return ResponseEntity.status(HttpStatus.BAD_GATEWAY).body(json(false, "TEST API 접속 실패: " + e.getMessage()));
        } catch (Exception e) {
            log.error("test proxy error", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(json(false, "TEST 프록시 오류: " + e.getMessage()));
        }
    }

    @PostMapping("/send")
    @ResponseBody
    public ResponseEntity<?> send(@RequestBody Object body) {
        try {
            // body 타입 유연 처리
            // - 배열(List/ArrayNode): 그대로
            // - {"items":[...]}: items만 추출
            // - 단일 객체: [obj] 로 감싸기
            Object payload = normalizeToArrayPayload(body);

            ResponseEntity<String> r = postJson(baseUrl + sendPath, payload);
            return passthrough(r);

        } catch (HttpStatusCodeException e) {
            return ResponseEntity.status(e.getRawStatusCode()).body(nvl(e.getResponseBodyAsString(), "SEND API 오류"));
        } catch (ResourceAccessException e) {
            return ResponseEntity.status(HttpStatus.BAD_GATEWAY).body(json(false, "SEND API 접속 실패: " + e.getMessage()));
        } catch (Exception e) {
            log.error("send proxy error", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(json(false, "SEND 프록시 오류: " + e.getMessage()));
        }
    }

    @GetMapping("/history")
    @ResponseBody
    public ResponseEntity<?> history(@RequestParam Map<String, String> params) {
        try {
            // 허용 파라미터만 전달(기입 순서도 유지)
            List<String> order = Arrays.asList("tgt_nm", "phone_num", "msg_contents", "startDate", "endDate");
            String qs = order.stream()
                    .filter(params::containsKey)
                    .map(k -> enc(k) + "=" + enc(nvl(params.get(k), "")))
                    .collect(Collectors.joining("&"));

            String url = baseUrl + historyPath + (qs.isEmpty() ? "" : "?" + qs);
            ResponseEntity<String> r = rt().getForEntity(url, String.class);
            return passthrough(r);

        } catch (HttpStatusCodeException e) {
            return ResponseEntity.status(e.getRawStatusCode()).body(nvl(e.getResponseBodyAsString(), "HISTORY API 오류"));
        } catch (ResourceAccessException e) {
            return ResponseEntity.status(HttpStatus.BAD_GATEWAY).body(json(false, "HISTORY API 접속 실패: " + e.getMessage()));
        } catch (Exception e) {
            log.error("history proxy error", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(json(false, "HISTORY 프록시 오류: " + e.getMessage()));
        }
    }

    /**
     * 알림톡 발신 결과 업데이트 API
     * 외부 서버에서 호출하여 발신 상태와 결과 메시지를 업데이트
     * 
     * @param body 요청 본문 (insertId, stateCd, resultMsg)
     * @return 업데이트 결과
     */
    @PostMapping("/update")
@ResponseBody
public ResponseEntity<?> updateHistory(@RequestBody List<Map<String, Object>> bodyList) {
    try {
        if (bodyList == null || bodyList.isEmpty()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(json(false, "업데이트할 데이터가 없습니다."));
        }

        int totalUpdated = 0;
        List<Map<String, Object>> results = new ArrayList<>();

        for (Map<String, Object> body : bodyList) {
            Object insertIdObj = body.get("insertId");
            Object stateCdObj = body.get("stateCd");
            Object resultMsgObj = body.get("resultMsg");

            if (insertIdObj == null) {
                // 개별 레코드 에러는 리스트에 기록만 하고 넘어가기
                Map<String, Object> oneResult = new HashMap<>();
                oneResult.put("insertId", null);
                oneResult.put("success", false);
                oneResult.put("message", "insertId는 필수 파라미터입니다.");
                results.add(oneResult);
                continue;
            }

            Map<String, Object> params = new HashMap<>();
            params.put("insertId", insertIdObj);
            if (stateCdObj != null) params.put("stateCd", stateCdObj);
            if (resultMsgObj != null) params.put("resultMsg", resultMsgObj);

            int updatedRows = queryService.update("mars.icbm.map1.updateAlrimtokHistory", params);

            Map<String, Object> oneResult = new HashMap<>();
            oneResult.put("insertId", insertIdObj);
            oneResult.put("success", updatedRows > 0);
            oneResult.put("updatedRows", updatedRows);
            oneResult.put("message", updatedRows > 0 ? "업데이트 성공" : "업데이트된 행이 없습니다.");
            results.add(oneResult);

            totalUpdated += updatedRows;
        }

        Map<String, Object> res = new HashMap<>();
        res.put("success", true);
        res.put("totalUpdated", totalUpdated);
        res.put("results", results);

        return ResponseEntity.ok(res);

    } catch (Exception e) {
        log.error("update history error", e);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(json(false, "업데이트 오류: " + e.getMessage()));
    }
}


    /* ============================ 내부 유틸 ============================ */

    private ResponseEntity<String> postJson(String url, Object body) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        return rt().postForEntity(url, new HttpEntity<>(body, headers), String.class);
    }

    private ResponseEntity<?> passthrough(ResponseEntity<String> r) {
        // Node의 상태코드/바디 그대로 전달
        return ResponseEntity.status(r.getStatusCode()).body(r.getBody());
    }

    private static String enc(String s) {
        try {
        return URLEncoder.encode(nvl(s, ""), StandardCharsets.UTF_8.name());
    } catch (Exception e) {
        // UTF-8은 항상 지원되므로 여기로 올 일은 거의 없지만,
        // 혹시 예외가 발생해도 원문을 그대로 사용하도록 fallback
        return nvl(s, "");
    }
    }

    private static String nvl(String s, String def) {
        return (s == null) ? def : s;
    }

    private static String strOr(Object a, String def) {
        return (a == null) ? def : String.valueOf(a).trim();
    }

    private static boolean isValidPhone(String s) {
        return s != null && PHONE_PATTERN.matcher(s).matches();
    }

    // "010########" → "010-####-####" 보정
    private static String hyphenizePhone(String s) {
        if (s == null) return "";
        String digits = s.replaceAll("\\D", "");
        if (digits.length() == 11 && digits.startsWith("010")) {
            return digits.replaceFirst("^(\\d{3})(\\d{4})(\\d{4})$", "$1-$2-$3");
        }
        return s;
    }

    // body를 "배열"로 정규화
    private Object normalizeToArrayPayload(Object body) {
        // 이미 리스트 형태일 때
        if (body instanceof List) return body;

        // Map 형태인 경우: items 키 확인
        if (body instanceof Map) {
            Map<?,?> m = (Map<?,?>) body;
            Object items = m.get("items");
            if (items instanceof List) return items;      // {"items":[...]} → [...]
            if (items != null) return items;              // 배열이 아닌 타입이면 그대로 전달 시도

            // 단일 객체라고 보고 [obj] 로 감싸서 1건 전송
            return Collections.singletonList(m);
        }

        // 문자열이면 파싱 시도
        if (body instanceof String) {
            String json = (String) body;
            try {
                // 배열로 파싱 시도
                List<Map<String,Object>> list = MAPPER.readValue(json, new TypeReference<List<Map<String,Object>>>() {});
                return list;
            } catch (Exception ignore) {
                try {
                    // 객체로 파싱 후 [obj]
                    Map<String,Object> obj = MAPPER.readValue(json, new TypeReference<Map<String,Object>>() {});
                    Object items = obj.get("items");
                    if (items instanceof List) return items;
                    return Collections.singletonList(obj);
                } catch (Exception ignore2) {
                    // 파싱 불가 → 원문 전달 (노드에서 에러 핸들)
                    return body;
                }
            }
        }

        // 알 수 없는 타입 → 그대로 전달 (노드에서 에러 핸들)
        return body;
    }

    // 🔧 누락되어 발생한 컴파일 에러를 해결하기 위한 헬퍼
    private static Map<String, Object> json(boolean ok, String msg) {
        Map<String, Object> map = new HashMap<>();
        map.put("success", ok);
        map.put("message", msg);
        return map;
    }
}
