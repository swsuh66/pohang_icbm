FROM java:openjdk-8u111-alpine

#타임존 우리나라
ENV TZ=Asia/Seoul

# 호스트 시스템에 있는 JAR 파일을 이미지로 복사합니다.

COPY config /var/config
COPY webapps /usr/local/tomcat/webapps