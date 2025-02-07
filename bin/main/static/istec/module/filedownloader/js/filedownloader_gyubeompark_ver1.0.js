/*
[ alltoHIM (my nick) ]
@ file Name        : filedownloader_gyubeompark_ver1.0.js
@ title            : filedownloader 모듈
@ desc             : parameters : params / header / fileName / option / fileType / setDoubleQuotes / delimiter / mapperId / timeUnit / uri / loadText / ...
                     - params : json parameters
                     - header : boolean
                     - option : mapper / query / ...
                     - fileType : dat / csv / xlsx / ...
                     - setDoubleQuotes : boolean
                     - delimiter : ,(comma) / .(dot) / | (vertical bar) / ...
                     - mapperId : mapper namespace + mapper tag id
                     - timeUnit : year, month, day, hour, minute, second
@ author           : gyubeom_park (god3se@gmail.com)
@ date             : 2022.03.23
*/

function FileDownloader(e){var t=e||{},n=e.params||{},i=window.CONTEXT_PATH;this.onSuccess=t.onSuccess||{};var a=t.fileName||"DOWNLOAD",o=t.option||"mapper",r=t.header,s=t.setDoubleQuotes,d=t.delimiter,l=t.fileType||"csv",u=t.mapperId||"",e=t.timeUnit||"day",c={default:"/fileDownload.do",mapper:u},p=t.loadText||"Loading...",f=void 0,m=$.extend(!0,{},{fileName:a,header:r,option:o,mapperId:u,fileType:l,setDoubleQuotes:s,delimiter:null==d?",":d,timeUnit:e},n),h={mapper:{parameter:{mapperId:"mapper id parameter is not enough.",fileType:"file type parameter is not enough."},download:{question:"해당 다운로드는 다소 시간이 걸릴 수 있습니다.\n계속 진행하시겠습니까?",success:"다운로드가 완료되었습니다.",fail:"\n다운로드 중 시스템 장애가 발생하였습니다.\n시스템 관리자에게 문의바랍니다."}},query:{parameter:{db:"parameter : database is unset.",lack:"parameters of download method is not enough."},download:{question:"해당 다운로드는 다소 시간이 걸릴 수 있습니다.\n계속 진행하시겠습니까?\n(데이터 개수가 1,048,576행을 초과하는 경우, csv 다운이 진행됩니다.)",success:"다운로드가 완료되었습니다.",fail:"\n다운로드 중 시스템 장애가 발생하였습니다.\n시스템 관리자에게 문의바랍니다."}}},g=this;this.setData=function(e){m=$.extend(!0,m,e||{})},this.getData=function(){return m},this.init=function(){return f=new LoadingBar({parentArea:$("body"),loadText:p}),g.checkEnv()},this.getGuide=function(e,t,n,i){var a={},n=[e,t,n].reduce(function(e,t,n){return gb.isString(t,!0)&&(a=(0!=n?a:h)[t]),gb.isString(a,!0)?a:""},"");return(0==i?"":"[file downloader module guide]")+" "+(gb.isString(n,!0)?n:"")},this.checkEnv=function(){var e=o,t=l,n=[];if("mapper"===e&&(gb.isNot(c[e])?n=[e,"parameter","mapperId"]:gb.isNot(t)&&(n=[e,"parameter","fileType"])),0!=n.length)return console.error(g.getGuide(n[0],n[1],n[2],1)),!1},this.download=function(e){e=(e||{}).message||g.getGuide(o,"download","question",0);swall({icon:"info",text:e,buttons:{cancel:"취소",confirm:{text:"확인",value:"o"}}}).then(function(e){"o"===e&&(f.show(),$.fileDownload(i+"/istec"+c.default,{httpMethod:"POST",data:m,successCallback:function(){g.trigger("success"),f.hide()},failCallback:function(){f.hide()}}))})},this.trigger=function(){var e=arguments,t=e[0],t="on"+t.charAt(0).toUpperCase()+t.slice(1);if(g.hasOwnProperty(t)&&"function"==typeof g[t])return g[t].call(g,e)},g.init()}