#!/bin/bash

# 환경 변수 설정
CONF_SRC=$(pwd)/example.conf
CONF_DST=/etc/nginx/conf.d/default.conf
LOG_SRC=$(pwd)/example.log
LOG_DST=/var/log/nginx/custom.host.access.log

# 컨테이너 실행
docker run -d --name diaweb \
  --mount type=bind,src=${CONF_SRC},dst=${CONF_DST} \
  --mount type=bind,src=${LOG_SRC},dst=${LOG_DST} \
  -p 80:80 \
  nginx:latest
