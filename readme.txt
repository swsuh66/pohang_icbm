1. DB 수정내용
    - vi_m1_sv_point_list 에 c.remark 추가
    - tb_m1_meas_raw call_check(var(60)) 필드 추가
    - tb_m1_wizit_modem_info 필드추가
      ALTER TABLE public.tb_m1_wizit_modem_info ADD modem_sub_id varchar(80) NULL;
      COMMENT ON COLUMN public.tb_m1_wizit_modem_info.modem_sub_id IS '단말부번호';   
      ALTER TABLE public.tb_m1_wizit_modem_info ADD modem_control bool NULL;
      ALTER TABLE public.tb_m1_wizit_modem_info ALTER COLUMN modem_control SET STORAGE PLAIN;
      COMMENT ON COLUMN public.tb_m1_wizit_modem_info.modem_control IS '하향 컨트롤 On/Off';

2. 수신동의
    ALTER TABLE public.tb_m1_info_customer ADD receive_consent boolean NULL;
    COMMENT ON COLUMN public.tb_m1_info_customer.receive_consent IS '수신동의';
    ALTER TABLE public.tb_m1_info_customer ADD consent_dt timestamp(6) NULL;
    COMMENT ON COLUMN public.tb_m1_info_customer.consent_dt IS '수신동의해제시간';

3. tb_m1_info_customer
    ALTER TABLE public.tb_m1_info_customer ALTER COLUMN admin_no SET NOT NULL;

// 포항시청 DB 수정할 내용
4. fn_tb_meas_point_his_day_mov 에서  - interval '30 day' 두군데 삭제
5. fn_meas_raw_que 수정(태안참조)
6. fn_meas_proc2 (태안참조)