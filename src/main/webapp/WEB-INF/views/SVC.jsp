<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ page language="java" session="false" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<!-- Senser Value Creater-->
<html>
<head>

   <script type="text/javascript" src="${contextPath}/resources/lib/jquery/dist/jquery.js"></script>
   <script type="text/javascript">
      function addVal() {
         $('#dataCnt').append('<input type="text" name="items"><br>');
      }

      function create(){

         $.ajax({
            url : "senserCreate",
            processData : false,
            contentType : false,
            data : new FormData(mainform),
            type : 'POST',
            success : function(data) {
               //$('#log').empty();
               //$('#log').append(data.log);
               $('#value').empty();
               $('#value').val(data.value);
               logCreate();
            },
            error: function(xhr, status, error) {
                  console.error(error);
            }
         });
      }


      function logCreate(){
         var con = $('#value').val();
         $('#con').val(con);
         $.ajax({
            url : "senserLog",
            processData : false,
            contentType : false,
            data : new FormData(mainform),
            type : 'POST',
            success : function(data) {
               $('#log').empty();
               $('#log').append(data.log);
            },
            error: function(xhr, status, error) {
                  console.error(error);
            }
         });
      }
   </script>
	
	
</head>

<body>
   
<div class="container">
      <h3>Senser Value Creater 테스트버전 (A3 만가능)</h3>
      <form action="senserCreate" method="post" id="mainform">
         <input type="text" id="con" name="con" hidden >
         <table>
            <tbody>
               <tr>
                  <td>
                     <ul>
                        <li>
                           <h5>헤더 2byte</h5>
                           <input type="text" id="header" name="header" value="A3">
                        </li>
                        <li>
                           <h5>메시지 길이 2byte</h5>
                           <input type="text" id="conlength" name="conlength" value="3B">
                        </li>
                        <li>
                           <h5>메시지 Command 2byte</h5>
                           <input type="text" id="commd" name="commd" value="70">
                        </li>
                        <li>
                           <h5>imei 16byte</h5>
                           <input type="text" id="imei" name="imei" value="866416042998360F">
                        </li>
                        <li>
                           <h5>imsi 16byte</h5>
                           <input type="text" id="imsi" name="imsi" value="450061235100205F">
                        </li>
                        <li>
                           <h5>수신강도 rssi_iv 2byte</h5>
                           <input type="text" id="rssi_iv" name="rssi_iv" value="3E">
                        </li>
                        <li>
                           <h5>비트에러율 2byte</h5>
                           <input type="text" id="ber" name="ber" value="00">
                        </li>
                        <li>
                           <h5>셀아이디 4byte</h5>
                           <input type="text" id="cid" name="cid" value="6AEF">
                        </li>
                        <li>
                           <h5>무선품질정보 rsrp 4byte</h5>
                           <input type="text" id="rsrp" name="rsrp" value="4100">
                        </li>
                        <li>
                           <h5>무선품질정보 rsrq 4byte</h5>
                           <input type="text" id="rsrq" name="rsrq" value="0A00">
                        </li>
                        <li>
                           <h5>무선품질정보 Snr 4byte</h5>
                           <input type="text" id="Snr" name="Snr" value="1A00">
                        </li>
                        <li>
                           <h5>단말기 정보 번호 10byte</h5>
                           <input type="text" id="ami_type" name="ami_type" value="1235100205">
                        </li>
                        <li>
                           <h5>fw 버전 4byte</h5>
                           <input type="text" id="fwVer" name="fwVer" value="0100">
                        </li>
                        <li>
                           <h5>단말기정보 배터리 전압 2byte</h5>
                           <input type="text" id="bat_iv" name="bat_iv" value="1F">
                        </li>
                        <li>
                           <h5>계량기정보 (기물정보) 8byte</h5>
                           <input type="text" id="met_no" name="met_no" value="11111111">
                        </li>
                        <li>
                           <h5>계량기정보 (계량기형식) 2byte</h5>
                           <input type="text" id="met_type" name="met_type" value="01">
                        </li>
                        <li>
                           <h5>구경 2byte</h5>
                           <input type="text" id="met_gau" name="met_gau" value="71">
                        </li>
                        <li>
                           <h5>계량기정보 상태코드 2byte</h5>
                           <input type="text" id="met_err_code" name="met_err_code" value="00">
                        </li>
                        <li>
                           <h5>검침주기 2byte (실제로쓰는건없고 그냥 있는듯 데이터저장할때만씀.)</h5>
                           <input type="text" id="meter_reading_cycle" name="meter_reading_cycle" value="01">
                        </li>
                        <li>
                           <h5>보고주기 2byte</h5>
                           <input type="text" id="report_cycle" name="report_cycle" value="06">
                        </li>
                        <li>
                           <h5>검침시간 12byte</h5>
                           <input type="text" id="meas_dt" name="meas_dt" value="170518000000">
                        </li>
                        <li>
                           <h5>검침데이터 (검침 주기) 2byte</h5>
                           <input type="text" id="meter_reading_cycle_data" name="meter_reading_cycle_data" value="01">
                        </li>
                        <li>
                           <h5>****중요****데이터개수 2byte</h5>
                           <h5>검침데이터 추가한만큼 숫자늘려줘야댐</h5>
                           <input type="text" id="data_cnt" name="data_cnt" value="01">
                        </li>
                        <li>
                           <h5>검침값 위치 2byte</h5>
                           <input type="text" id="data_pos" name="data_pos" value="00">
                        </li>
                        <li>
                           <h5>데이터 기준값 8byte</h5>
                           <input type="text" id="accu_iv" name="accu_iv" value="00000000">
                        </li>
                        <li>
                           <h5>검침데이터 추가</h5>
                           <button type="button" onclick="addVal();">ADD</button>
                        </li>
                        <h5>검침데이터 각각 4byte</h5>
                        <div id="dataCnt">
                           <input type="text" name="items"><br>
                        </div>
                     </ul>
                  </td>
                  <td style="width: 100%;">
                     <textarea id="log" style="width: 500px; height: 800px; position:fixed; top: 0; left:50%;" disabled></textarea>
                  </td>
               </tr>
            </tbody>
         </table>
        

         <button type="button" onclick="create();">create</button>
         <button type="button" onclick="logCreate();">결과값 로그생성</button>
      </form>
   </div>

   <div>
      <h3> 결과값 </h3>
      <textarea id="value" style="width: 100%; height: 400px;"></textarea>
   </div>
   
</body>
</html>