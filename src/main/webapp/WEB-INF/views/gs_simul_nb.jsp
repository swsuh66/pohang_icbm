<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page language="java" session="false" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<%@include file="/resources/inc/meta.inc"%>
	<title>스마트수도미터원격검침시스템</title>
	
	<%@include file="/resources/inc/base.inc"%>	
	<%@include file="/resources/inc/jsgrid.inc"%>
	
		
	
	<script type="text/javascript">
	
		function getContextPath() {
			
		   return "${contextPath}";
		   
		}

		var ConvertBase = function (num) {
	        return {
	            from : function (baseFrom) {
	                return {
	                    to : function (baseTo) {
	                        return parseInt(num, baseFrom).toString(baseTo);
	                    }
	                };
	            }
	        };
	    };
	        
	    // binary to decimal
	    ConvertBase.bin2dec = function (num) {
	        return ConvertBase(num).from(2).to(10);
	    };
	    
	    // binary to hexadecimal
	    ConvertBase.bin2hex = function (num) {
	        return ConvertBase(num).from(2).to(16);
	    };
	    
	    // decimal to binary
	    ConvertBase.dec2bin = function (num) {
	        return ConvertBase(num).from(10).to(2);
	    };
	    
	    // decimal to hexadecimal
	    ConvertBase.dec2hex = function (num) {
	        return ConvertBase(num).from(10).to(16);
	    };
	    
	    // hexadecimal to binary
	    ConvertBase.hex2bin = function (num) {
	        return ConvertBase(num).from(16).to(2);
	    };
	    
	    // hexadecimal to decimal
	    ConvertBase.hex2dec = function (num) {
	        return ConvertBase(num).from(16).to(10);
	    };
	    
	    this.ConvertBase = ConvertBase;

		$(function() {
			
			
			/*
			 * 페이지 리싸이징
			 */
			$(window).resize(function() {
				layoutSize();
			});
			layoutSize();
			
			/* jsGrid 초기화 */
			grid = initGrid('grid_container');
					
			/*
			 * 초기 데이터 로드
			 */
			loadNowData();

		});

		function layoutSize() {

			var ht1 = $(window).innerHeight();
			var off = $("#mainContainer").offset();

			if (off) {

				var ht = ht1 - off.top;
				$("#mainContainer").height(ht);

			}

		};

		function loadNowData() {
			
			ajaxSelect({
				sql : 'mars.icbm.map1.gsNb',
				data : null,	
				success : function(result) {

					rawList = result;				
					grid.command('refreshData', rawList);	

				},
				error : function(error) {

					alert('에러');

				}
			});

		};
		
		function postData(idx, item) {
			
			var getDateCon = function(date) {
				
				var noErr = true;
				
				/* var Now = new Date(); 
				var a = Now.getFullYear(); */
				
				var attr = date.split(' ');
				if( attr.length != 6 ) 
					noErr = false;
								
				attr.forEach(function(item) {
					if(item.length != 2)
						noErr = false;
				});
				
				if(!noErr) {
					alert('날짜형식에 오류가 있습니다.');
					return noErr;
				}
									
				
				var a = ConvertBase.dec2hex(attr[0]); // 년
				var b = ConvertBase.dec2hex(attr[1]); // 달
				var c = ConvertBase.dec2hex(attr[2]); // 일
				var d = ConvertBase.dec2hex(attr[3]); // 시
				var e = ConvertBase.dec2hex(attr[4]); // 분
				var f = ConvertBase.dec2hex(attr[5]); // 초
				
				if(a.length == 1) b = '0'+a;
				if(b.length == 1) b = '0'+b;				
				if(c.length == 1) c = '0'+c;
				if(d.length == 1) d = '0'+d;
				if(e.length == 1) e = '0'+e;
				if(f.length == 1) f = '0'+f;
			
				var date = a+b+c+d+e+f;
						  
				return date;
			};
			
			var count = $('input[id="' + item.cseId + '_count"]').val();		
			if(!count) {
				alert('전송개수를 적으세요.');
				return;
			}
			
			var date = $('input[id="' + item.cseId + '_time"]').val();			
					
		
			
			var getAccuIv =  function(value) {
				
				if(!value || value.lenght == 0) {
					alert('지침값을 적으세요.');
					return;
				}
				
				var hex = kutil.lpad('00000000', ConvertBase.dec2hex(value));
				
				
				return hex.substring(6, 8) + hex.substring(4, 6) + hex.substring(2, 4) + hex.substring(0, 2); 
				
			
				
			};
			
			
			var con  = 'A15170450061222990774F359369080204700F610000000000000000001800000001010024900000010113' + idx + '0106';
			
			var hCount = ConvertBase.dec2hex(count);
			if(hCount.length == 1) 
				hCount = '0'+ hCount;
			
			var gap = '0';
			while(true) {
				
				gap += '0';
				
				if(gap.length == hCount*4) 
					break;				
			}
			
			var chkSum = '85';			
			var dateF = getDateCon(date);
			if(!dateF) return;
			
			var value = $('input[id="' + item.cseId + '"]').val(); 	
			var accuIv = getAccuIv(value);
			if(!accuIv) return;
			
			con = con + dateF + '01' + hCount + '00' + accuIv + gap + chkSum;
			var cseId = item.cseId;
			if(!cseId || cseId.length == 0) {
				alert('NbIoT가 매핑되어 있지 않습니다.');
				return;
			}
				
			
			var data = new Object();
			data.cr = cseId;
			data.con = con;
			
			
			ajaxInsert({
				sql: 'mars.icbm.nbiot.insertNbiotRaw',
				async: true,
				data: data,
				success: function(result) {
					
					jAlert.success('저장', '추가한 정보를 저장 완료하였습니다.');
				},
				error: function(result) {
					jAlert.error('저장', '정보를 저장하지 못하였습니다.<br><br>'+ (result.error?result.error.statusText:'서버에서 오류가 발생하였습니다.'));
				}
			}); 
			
			
			/* 0224 변경 */
			return;
			con = Base64.encode(con);
			
			 
			/* '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' + 
			'<m2m:cin xmlns:m2m="http://www.onem2m.org/xml/protocols" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' + 
			'<ty>4</ty>' + 
			'<ri>CI00000000001973655865</ri>' + 
			'<rn>CI00000000001973655865</rn>' + 
			'<pi>CT00000000000000209541</pi>' + 
			'<ct>2018-04-16T12:29:19+09:00</ct>' + 
			'<lt>2018-04-16T12:29:19+09:00</lt>' + 
			'<sr>/' + item.app_eui + '/v1_0/remoteCSE-' + item.app_eui.substr(8, item.app_eui.length) + item.dev_eui + '/container-LoRa/subscription-istec_subscription</sr>' +
			'<et>2018-04-17T12:29:19+09:00</et>' + 
			'<st>214</st>' + 
			'<cr>RC00000000000000215954</cr>' + 
			'<cnf>LoRa/Sensor</cnf>' + 
			'<cs>96</cs>' + 
			'<con>' + con + '</con>' +
			'</m2m:cin>'; */
			//con = 'oVFwRQBhIimQd081k2kIAgRwD2EAAAAAAAAAAAAYAAAAAQEAJJAAAAEBEwABBhIBCQ4AAAEYAIOUAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACF';
			var data =
			'<?xml version="1.0" encoding="UTF-8"?>' +
			'<m2m:sgn xmlns:m2m="http://www.onem2m.org/xml/protocols">' +
			    '<nev>' +
			        '<rep>' +
			            '<m2m:cin>' +
			                '<et>99991231T000000</et>' +
			                '<cnf>application/octet-stream</cnf>' +
			                '<con>' + con  + '</con>' +
			            '</m2m:cin>' +
			        '</rep>' +
			    '</nev>' +
			    '<vrq>false</vrq>' +
			    '<sud>false</sud>' +
			    '<cr>' + item.cseId + '</cr>' +
			'</m2m:sgn>';
			//return;
			$.ajax({
			    /* beforeSend: function(req) {
			        req.setRequestHeader("Accept", "application/xml");
			        req.setRequestHeader("X-M2M-RI", "ThingPlug_00001");
			        req.setRequestHeader("X-M2M-Origin", "ThingPlug");
			        req.setRequestHeader("Content-Type", "application/xml");
			        req.setRequestHeader("dKey", "TGxSTjRWcG1RZGtuT3RJWVBaeHZyRTZGclRlOGhFZ2VXT0xpcmg0dGRCeU55TkpsN2JVMWJpZG9lQUh0SlhHYg==");			        
			    }, */			    
			    type: "POST",
			    url: "http://211.53.249.235:9600/mars_s1/" + item.cseId + '/10250/0/0',
			    /* url: "http://14.37.38.150:9610/mars_s1/" + item.cseId + '/10250/0/0', */			    
			    data: data,
			    contentType: "application/xml",
			    dataType: "xml",			                                   
			    success: function(data) {
			    	
			    	alert('성공');
			      
			    }              
			});

		};

		function initGrid(container) {

			var fields = [     
				{ name: "custNm",  				title: "이름", 			type: "text", 		align: "center", 	width: 140},
				{ title: "전송시간", 				
			    	  align: "center",		    	
					  width: 80,
				      itemTemplate: function(_, item) {				    	
				    	return $('<input>').attr('type', 'text')
				    					   .attr('id', item.cseId + '_time').val('21 01 14 13 00 00')
				    					   				    					 				    					 				    					 				    						
				    	}
				 },
				 { title: "전송개수", 				
			    	  align: "center",		    	
					  width: 80,
				      itemTemplate: function(_, item) {				    	
				    	return $('<input>').attr('type', 'text')
				    					   .attr('id', item.cseId + '_count').val('1')
				    					   				    					 				    					 				    					 				    						
				    	}
				 },
				{ title: "검침값(계량기 지시값)", 				
			    	  align: "center",		    	
					  width: 80,
				      itemTemplate: function(_, item) {				    	
				    	return $('<input>').attr('type', 'number')				    					   
				    					   .attr('id', item.cseId)
				    					   //.prop('readonly', true)
				    					   //.val(103555)
				    					   				    					 				    					 				    					 				    						
				    	}
				 },
				 { title: "정상", 				
			    	  align: "center",		    	
					  width: 50,
				      itemTemplate: function(_, item) {
				    	var iconEl = '<span class="glyphicon glyphicon-download-alt"></span>';
				    	return $('<div>').attr('type', 'button')
				    					 .attr('class', 'btn btn-primary form-button')
				    					 .text('실행')
				    					 //.click(function() { fileDown(item) })
				    					 .click(function(evt) { 
				    						 postData('00', item);
				    					 });				    	
				    	}
				 },
				{ title: "동파", 				
			    	  align: "center",		    	
					  width: 50,
				      itemTemplate: function(_, item) {
				    	var iconEl = '<span class="glyphicon glyphicon-download-alt"></span>';
				    	return $('<div>').attr('type', 'button')
				    					 .attr('class', 'btn btn-primary form-button')
				    					 .text('실행')
				    					 //.click(function() { fileDown(item) })
				    					 .click(function(evt) { 
				    						 postData('02', item);
				    					 });
				    						 
				    	}
				 },
				 { title: "배터리 장애", 				
			    	  align: "center",		    	
					  width: 50,
				      itemTemplate: function(_, item) {
				    	var iconEl = '<span class="glyphicon glyphicon-download-alt"></span>';
				    	return $('<div>').attr('type', 'button')
				    					 .attr('class', 'btn btn-primary form-button')		    					 
				    					 .text('실행')
				    					 //.click(function() { fileDown(item) })
				    					 .click(function(evt) { 
				    						 postData('04', item);
				    					 });
				    						 
				    	}
				 },
				 { title: "파손", 				
			    	  align: "center",		    	
					  width: 50,
				      itemTemplate: function(_, item) {
				    	var iconEl = '<span class="glyphicon glyphicon-download-alt"></span>';
				    	return $('<div>').attr('type', 'button')
				    					 .attr('class', 'btn btn-primary form-button')		    					 
				    					 .text('실행')
				    					 //.click(function() { fileDown(item) })
				    					 .click(function(evt) { 
				    						 postData('08', item);
				    					 });
				    						 
				    	}
				 },
				 
				 
				 { title: "비만관", 				
			    	  align: "center",		    	
					  width: 50,
				      itemTemplate: function(_, item) {
				    	var iconEl = '<span class="glyphicon glyphicon-download-alt"></span>';
				    	return $('<div>').attr('type', 'button')
				    					 .attr('class', 'btn btn-primary form-button')		    					 
				    					 .text('실행')
				    					 //.click(function() { fileDown(item) })
				    					 .click(function(evt) { 
				    						 postData('10', item);
				    					 });
				    						 
				    	}
				 },
				 
				 { title: "누수", 				
			    	  align: "center",		    	
					  width: 50,
				      itemTemplate: function(_, item) {
				    	var iconEl = '<span class="glyphicon glyphicon-download-alt"></span>';
				    	return $('<div>').attr('type', 'button')
				    					 .attr('class', 'btn btn-primary form-button')		    					 
				    					 .text('실행')
				    					 //.click(function() { fileDown(item) })
				    					 .click(function(evt) { 
				    						 postData('20', item);
				    					 });
				    						 
				    	}
				 },
				 
				 { title: "역류", 				
			    	  align: "center",		    	
					  width: 50,
				      itemTemplate: function(_, item) {
				    	var iconEl = '<span class="glyphicon glyphicon-download-alt"></span>';
				    	return $('<div>').attr('type', 'button')
				    					 .attr('class', 'btn btn-primary form-button')		    					 
				    					 .text('실행')
				    					 //.click(function() { fileDown(item) })
				    					 .click(function(evt) { 
				    						 postData('40', item);
				    					 });
				    						 
				    	}
				 },
				 
				 { title: "Q4초과", 				
			    	  align: "center",		    	
					  width: 50,
				      itemTemplate: function(_, item) {
				    	var iconEl = '<span class="glyphicon glyphicon-download-alt"></span>';
				    	return $('<div>').attr('type', 'button')
				    					 .attr('class', 'btn btn-primary form-button')		    					 
				    					 .text('실행')
				    					 //.click(function() { fileDown(item) })
				    					 .click(function(evt) { 
				    						 postData('80', item);
				    					 });
				    						 
				    	}
				 }
				 
				 /*,
				 { title: "통신장애", 				
			    	  align: "center",		    	
					  width: 50,
				      itemTemplate: function(_, item) {
				    	var iconEl = '<span class="glyphicon glyphicon-download-alt"></span>';
				    	return $('<div>').attr('type', 'button')
				    					 .attr('class', 'btn btn-primary form-button')		    					 
				    					 .text('실행')
				    					 //.click(function() { fileDown(item) })
				    					 .click(function(evt) { 
				    						 postData('80', item);
				    					 });
				    						 
				    	}
				 }*/
				
			];

		    var opt = {
		        height: "100%",
		        width: "100%",
		        sorting: true,
		        fields: fields,
		        rowClick : function(evt) {
				},
				onRefreshed: function (args) {
				$.each(args.grid._headerGrid[0].rows[0].cells, function (i, obj) {
					$(args.grid._bodyGrid[0].rows[0].cells[i]).css("width", $(obj).css("width"));
				});
				$("table").colResizable({
					onResize: function () {
						$.each(args.grid._headerGrid[0].rows[0].cells, function (i, obj) {
							$(args.grid._bodyGrid[0].rows[0].cells[i]).css("width", $(obj).css("width"));
						});
					}
				});
   			 }
		    };
		    
			return new DataGrid(container, opt);
		};

	</script>
	
	<style type="text/css">
		
</style>
</head>

<body>

	<div id="mainContainer">
		
		<div id="grid_container" class="data-list" >		
		</div>
			
	</div>

</body>
</html>