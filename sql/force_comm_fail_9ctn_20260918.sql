/*
 * 신규 화면에서 아래 9대: accu_iv 가 NULL 인 검침만 웹에서 숨기고 통신장애로 본다.
 * accu_iv 가 있는 행은 그대로 보여준다.
 * client_meas_raw 는 NULL/값 모두 적재한다.
 *
 * 웹 반영: sqlMap1.xml / sqlPopupMap.xml 배포 필요.
 * 끝나면 STEP 8 만 실행.
 *
 *   01253958693  신장길   64418
 *   01253958697  은솔하이츠 64421
 *   01253958738  권오숙   64428
 *   01253958683  김기태   64438
 *   01253958696  김태윤   64439
 *   01253958702  김용암   64415
 *   01253958717  김영곤   64422
 *   01253958687  김정숙   64447
 *   01264697872  최효욱   64441
 */

BEGIN;

-- ============================================================
-- STEP 1: 대상 확인 (기대 9)
-- ============================================================
SELECT cd.dev_no, cc.point_sq, cc.cust_name, cc.last_meas_dt, cm.last_meas_dt AS meter_last_meas_dt
FROM client_device cd
JOIN client_customer cc ON cc.point_sq = cd.point_sq
LEFT JOIN client_meter cm ON cm.point_sq = cd.point_sq
WHERE cd.dev_no IN (
    '01253958693','01253958697','01253958738',
    '01253958683','01253958696','01253958702',
    '01253958717','01253958687','01264697872'
)
ORDER BY cd.dev_no;

-- ============================================================
-- STEP 2: last_meas_dt 는 accu_iv 있는 raw 가 없을 때만 비움
-- ============================================================
UPDATE client_customer cc
SET last_meas_dt = NULL,
    udt_dt = NOW()
WHERE cc.point_sq IN (64415, 64418, 64421, 64422, 64428, 64438, 64439, 64441, 64447)
  AND NOT EXISTS (
      SELECT 1
      FROM client_meas_raw_y2026m09 r
      WHERE r.point_sq = cc.point_sq
        AND r.accu_iv IS NOT NULL
  );

UPDATE client_meter cm
SET last_meas_dt = NULL
WHERE cm.point_sq IN (64415, 64418, 64421, 64422, 64428, 64438, 64439, 64441, 64447)
  AND NOT EXISTS (
      SELECT 1
      FROM client_meas_raw_y2026m09 r
      WHERE r.point_sq = cm.point_sq
        AND r.accu_iv IS NOT NULL
  );

-- ============================================================
-- STEP 3: accu_iv NULL 인 일별만 비움. raw 는 삭제하지 않음
-- ============================================================
DELETE FROM client_meas_day
WHERE point_sq IN (64415, 64418, 64421, 64422, 64428, 64438, 64439, 64441, 64447)
  AND meas_dt >= DATE '2026-09-01'
  AND meas_dt <  DATE '2026-10-01'
  AND accu_iv IS NULL;

-- ============================================================
-- STEP 4: accu_iv NULL 일 때만 meas_day / last_meas_dt 차단
-- ============================================================
CREATE OR REPLACE FUNCTION public.tfn_skip_force_comm_fail_day()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
    IF NEW.point_sq = ANY(ARRAY[
        64415, 64418, 64421, 64422, 64428,
        64438, 64439, 64441, 64447
    ]) AND NEW.accu_iv IS NULL THEN
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.tfn_freeze_force_comm_fail_last_meas()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
    IF NEW.point_sq = ANY(ARRAY[
        64415, 64418, 64421, 64422, 64428,
        64438, 64439, 64441, 64447
    ])
       AND NEW.last_meas_dt IS DISTINCT FROM OLD.last_meas_dt
       AND NOT EXISTS (
            SELECT 1
            FROM public.client_meas_raw r
            WHERE r.point_sq = NEW.point_sq
              AND r.meas_dt = NEW.last_meas_dt
              AND r.accu_iv IS NOT NULL
       ) THEN
        NEW.last_meas_dt := OLD.last_meas_dt;
    END IF;
    RETURN NEW;
END;
$function$;

-- 예전 raw skip 트리거가 남아 있으면 제거 (raw 적재 허용)
DROP TRIGGER IF EXISTS trg_skip_force_comm_fail ON public.client_meas_raw;
DROP TRIGGER IF EXISTS trg_skip_force_comm_fail ON public.client_meas_raw_y2026m09;
DROP FUNCTION IF EXISTS public.tfn_skip_force_comm_fail();

-- ============================================================
-- STEP 5: 트리거 설치 (복제 세션 포함)
-- ============================================================
DROP TRIGGER IF EXISTS trg_skip_force_comm_fail_day ON public.client_meas_day;
CREATE TRIGGER trg_skip_force_comm_fail_day
    BEFORE INSERT OR UPDATE ON public.client_meas_day
    FOR EACH ROW
    EXECUTE FUNCTION public.tfn_skip_force_comm_fail_day();
ALTER TABLE public.client_meas_day
    ENABLE ALWAYS TRIGGER trg_skip_force_comm_fail_day;

DROP TRIGGER IF EXISTS trg_skip_force_comm_fail_day ON public.client_meas_day_y2026m09;
CREATE TRIGGER trg_skip_force_comm_fail_day
    BEFORE INSERT OR UPDATE ON public.client_meas_day_y2026m09
    FOR EACH ROW
    EXECUTE FUNCTION public.tfn_skip_force_comm_fail_day();
ALTER TABLE public.client_meas_day_y2026m09
    ENABLE ALWAYS TRIGGER trg_skip_force_comm_fail_day;

DROP TRIGGER IF EXISTS trg_freeze_force_comm_fail_cust ON public.client_customer;
CREATE TRIGGER trg_freeze_force_comm_fail_cust
    BEFORE UPDATE ON public.client_customer
    FOR EACH ROW
    EXECUTE FUNCTION public.tfn_freeze_force_comm_fail_last_meas();
ALTER TABLE public.client_customer
    ENABLE ALWAYS TRIGGER trg_freeze_force_comm_fail_cust;

DROP TRIGGER IF EXISTS trg_freeze_force_comm_fail_meter ON public.client_meter;
CREATE TRIGGER trg_freeze_force_comm_fail_meter
    BEFORE UPDATE ON public.client_meter
    FOR EACH ROW
    EXECUTE FUNCTION public.tfn_freeze_force_comm_fail_last_meas();
ALTER TABLE public.client_meter
    ENABLE ALWAYS TRIGGER trg_freeze_force_comm_fail_meter;

-- ============================================================
-- STEP 6: 검증
-- ============================================================
SELECT tgrelid::regclass AS tbl, tgname, tgenabled
FROM pg_trigger
WHERE tgname IN (
    'trg_skip_force_comm_fail',
    'trg_skip_force_comm_fail_day',
    'trg_freeze_force_comm_fail_cust',
    'trg_freeze_force_comm_fail_meter'
)
ORDER BY 1;

SELECT cc.point_sq, cc.cust_name, cc.last_meas_dt
FROM client_customer cc
WHERE cc.point_sq IN (64415, 64418, 64421, 64422, 64428, 64438, 64439, 64441, 64447)
ORDER BY cc.point_sq;

SELECT r.point_sq,
       COUNT(*) AS raw_cnt,
       COUNT(*) FILTER (WHERE r.accu_iv IS NULL) AS null_accu_cnt,
       COUNT(*) FILTER (WHERE r.accu_iv IS NOT NULL) AS has_accu_cnt,
       MAX(r.meas_dt) FILTER (WHERE r.accu_iv IS NOT NULL) AS last_valid_dt
FROM client_meas_raw_y2026m09 r
WHERE r.point_sq IN (64415, 64418, 64421, 64422, 64428, 64438, 64439, 64441, 64447)
GROUP BY r.point_sq
ORDER BY r.point_sq;

-- ============================================================
-- STEP 7: 확정
--   정상 → COMMIT;
--   문제 → ROLLBACK;
-- ============================================================
ROLLBACK;

-- ============================================================
-- STEP 8: 해제 (개통 끝나면 이것만 실행)
-- ============================================================
/*
DROP TRIGGER IF EXISTS trg_skip_force_comm_fail_day ON public.client_meas_day;
DROP TRIGGER IF EXISTS trg_skip_force_comm_fail_day ON public.client_meas_day_y2026m09;
DROP TRIGGER IF EXISTS trg_freeze_force_comm_fail_cust ON public.client_customer;
DROP TRIGGER IF EXISTS trg_freeze_force_comm_fail_meter ON public.client_meter;
DROP FUNCTION IF EXISTS public.tfn_skip_force_comm_fail_day();
DROP FUNCTION IF EXISTS public.tfn_freeze_force_comm_fail_last_meas();
DROP TRIGGER IF EXISTS trg_skip_force_comm_fail ON public.client_meas_raw;
DROP TRIGGER IF EXISTS trg_skip_force_comm_fail ON public.client_meas_raw_y2026m09;
DROP FUNCTION IF EXISTS public.tfn_skip_force_comm_fail();
*/
