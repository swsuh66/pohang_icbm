import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.istec.m1.service.CustomerService;

@RestController
@RequestMapping("/customer")
public class CustomerController {

    private final CustomerService customerService;

    public CustomerController(CustomerService customerService) {
        this.customerService = customerService;
    }

    @DeleteMapping(
        value = "/deleteCustomInfo",
        consumes = "application/json",
        produces = "application/json"
    )
    public ResponseEntity<Map<String, Object>> deleteCustomInfo(
            @RequestBody Map<String, List<Map<String, Integer>>> payload) {

        Map<String, Object> body = new HashMap<>();

        // 1) payload/rowList 검증
        if (payload == null || !payload.containsKey("rowList")) {
            body.put("success", false);
            body.put("message", "요청 본문이 유효하지 않습니다.(rowList 누락)");
            return ResponseEntity.badRequest().body(body);
        }

        List<Map<String, Integer>> rowList = payload.get("rowList");
        if (rowList == null || rowList.isEmpty()) {
            body.put("success", false);
            body.put("message", "rowList가 비어 있습니다.");
            return ResponseEntity.badRequest().body(body);
        }

        // 2) 각 항목 필수키(pointSq, custSq) 검증
        for (int i = 0; i < rowList.size(); i++) {
            Map<String, Integer> row = rowList.get(i);
            if (row == null || row.get("pointSq") == null || row.get("custSq") == null) {
                body.put("success", false);
                body.put("message", "custSq 또는 pointSq 누락 항목이 있습니다. (index=" + i + ")");
                return ResponseEntity.badRequest().body(body);
            }
        }

        try {
            customerService.deleteCustomerInfo(rowList);

            body.put("success", true);
            body.put("deletedCount", rowList.size());
            return ResponseEntity.ok(body);

        } catch (Exception e) {
            body.put("success", false);
            body.put("message", "삭제 처리 중 오류가 발생했습니다.");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(body);
        }
    }
}
