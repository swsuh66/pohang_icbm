/*
 * 웹만 수정한다. 이 스크립트는 실행할 필요 없다.
 *
 * 16대는 mapper 에서 accu_iv IS NULL 행만 숨긴다.
 * client_meas_raw 에는 NULL/값 모두 그대로 쌓인다.
 * last_meas_dt, client_meas_day 트리거는 건드리지 않는다.
 *
 * 웹: sqlMap1.xml / sqlPopupMap.xml 배포 필요.
 *
 * 예전에 이 파일로 트리거를 설치했다면 STEP 1 만 실행해 제거.
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
 *   01264698259  곽말수   62261
 *   01264697988  문윤해   62687
 *   01264697995  강민석   64456
 *   01253958686  이순애   64417
 *   01264697840  이상복   64533
 *   01253958734  서영자   64599
 *   01264697948  이봉규   64598
 */

BEGIN;

-- ============================================================
-- STEP 1: 이전에 설치한 DB 트리거가 있으면 제거
-- ============================================================
DROP TRIGGER IF EXISTS trg_skip_force_comm_fail ON public.client_meas_raw;
DROP TRIGGER IF EXISTS trg_skip_force_comm_fail ON public.client_meas_raw_y2026m09;
DROP FUNCTION IF EXISTS public.tfn_skip_force_comm_fail();

DROP TRIGGER IF EXISTS trg_skip_force_comm_fail_day ON public.client_meas_day;
DROP TRIGGER IF EXISTS trg_skip_force_comm_fail_day ON public.client_meas_day_y2026m09;
DROP FUNCTION IF EXISTS public.tfn_skip_force_comm_fail_day();

DROP TRIGGER IF EXISTS trg_freeze_force_comm_fail_cust ON public.client_customer;
DROP TRIGGER IF EXISTS trg_freeze_force_comm_fail_meter ON public.client_meter;
DROP FUNCTION IF EXISTS public.tfn_freeze_force_comm_fail_last_meas();

SELECT tgrelid::regclass AS tbl, tgname
FROM pg_trigger
WHERE tgname IN (
    'trg_skip_force_comm_fail',
    'trg_skip_force_comm_fail_day',
    'trg_freeze_force_comm_fail_cust',
    'trg_freeze_force_comm_fail_meter'
)
ORDER BY 1;

-- ============================================================
-- STEP 2: 확정
--   정상 → COMMIT;
--   문제 → ROLLBACK;
-- ============================================================
ROLLBACK;
