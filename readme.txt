1. DB 수정내용
    - vi_m1_sv_point_list 에 c.remark 추가
    - tb_m1_meas_raw call_check(var(60)) 필드 추가
2. 수신동의
    ALTER TABLE public.tb_m1_info_customer ADD receive_consent boolean NULL;
    COMMENT ON COLUMN public.tb_m1_info_customer.receive_consent IS '수신동의';
    ALTER TABLE public.tb_m1_info_customer ADD consent_dt timestamp(6) NULL;
    COMMENT ON COLUMN public.tb_m1_info_customer.consent_dt IS '수신동의해제시간';

3. tb_m1_info_customer
    ALTER TABLE public.tb_m1_info_customer ALTER COLUMN admin_no SET NOT NULL;
