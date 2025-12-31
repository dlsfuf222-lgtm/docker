# NGINX 서버란? — 아키텍처, 용도, 그리고 실전 설정 가이드

NGINX(엔진엑스)는 **고성능·경량 웹 서버이자 리버스 프록시/로드 밸런서**입니다. 이벤트 기반 아키텍처로 동시접속을 효율적으로 처리해 정적 파일 서빙, API 게이트웨이, 마이크로서비스 앞단 프록시, HTTP/2·HTTP/3(QUIC) 지원 등 현대 웹의 핵심 역할을 맡습니다.

---

## 1) 핵심 개념 한 줄 요약

* **웹 서버**: 정적 자산(HTML/CSS/JS/이미지) 초고속 서빙
* **리버스 프록시**: 백엔드(예: Node/Spring) 앞에서 요청 분배, 보안·캐싱·TLS 종료
* **로드 밸런서**: 라운드로빈, 최소연결 등 다양한 분산 알고리즘
* **게이트웨이**: 경로 기반 라우팅, 헤더 변환, 레이트 리미팅, 캐싱

---

## 2) 왜 빠른가? — 이벤트 기반 워커 모델

* **마스터/워커 프로세스**: 마스터는 설정/수명주기 관리, 워커는 요청 처리.
* **비동기 이벤트 루프**: `epoll`(리눅스)/`kqueue`(BSD, macOS) 등 OS 이벤트 통지로 적은 스레드·컨텍스트 스위칭.
* **소켓 재사용/지연 연결 최적화**: Keep-Alive, HTTP 파이프라이닝(구), HTTP/2 멀티플렉싱, HTTP/3/QUIC.

> 결과: **적은 리소스로 많은 동시접속** 처리(특히 정적/프록시 워크로드에 강함).

---

## 3) 대표 사용 시나리오

1. **정적 웹 호스팅**: CDN 앞 오리진 또는 자체 호스팅
2. **리버스 프록시 & 게이트웨이**: `/api` → Spring, `/app` → Node 등 경로 라우팅
3. **TLS 종료(Offloading)**: 백엔드는 HTTP, 외부는 HTTPS
4. **로드 밸런싱**: 마이크로서비스·멀티 인스턴스 분산
5. **캐싱/압축**: 오리진 보호, 대역 절감, TTFB 개선
6. **레이트 리미팅 & 보안 헤더**: 간단한 DDoS 완화, OWASP 권장 헤더 적용
7. **WebSocket/HTTP 스트리밍 프록시**: 실시간 통신 지원

---

## 4) 최소 설정 예제 (정적 파일 서버)

```nginx
# /etc/nginx/nginx.conf (또는 sites-enabled 파일)
worker_processes auto;
events { worker_connections 10240; }

http {
  include       mime.types;
  sendfile      on;
  keepalive_timeout  65;
  server_tokens off;

  server {
    listen 80;
    server_name example.com;

    root /var/www/html;
    index index.html;

    location / {
      try_files $uri $uri/ =404;
    }
  }
}
```

* `server_tokens off` : 버전 노출 방지
* `try_files` : 존재 파일 우선, 없으면 404 (리라이트 과도 사용보다 안전)

---

## 5) 리버스 프록시 & 로드 밸런서 예제

### (1) 업스트림 정의 + 라운드로빈

```nginx
http {
  upstream api_upstream {
    server 10.0.0.11:8080;
    server 10.0.0.12:8080;
    # least_conn;  # 최소 연결 알고리즘 사용 시
    # ip_hash;     # 클라이언트 IP 기반 세션 고정
  }

  server {
    listen 80;
    server_name api.example.com;

    location / {
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;

      proxy_pass http://api_upstream;
      proxy_read_timeout 60s;
    }
  }
}
```

### (2) 경로 기반 라우팅 (게이트웨이)

```nginx
server {
  listen 80; server_name app.example.com;

  location /app/ {
    proxy_pass http://127.0.0.1:3000/;  # React/Node
  }

  location /api/ {
    proxy_pass http://127.0.0.1:8080/;  # Spring Boot
  }
}
```

---

## 6) HTTPS(TLS) 오프로드 & HTTP/2

```nginx
server {
  listen 443 ssl http2;
  server_name www.example.com;

  ssl_certificate     /etc/ssl/certs/fullchain.pem;
  ssl_certificate_key /etc/ssl/private/privkey.pem;

  add_header Strict-Transport-Security "max-age=31536000" always;
  add_header X-Content-Type-Options nosniff;
  add_header X-Frame-Options SAMEORIGIN;

  location / {
    proxy_pass http://127.0.0.1:8080;
  }
}

server {
  listen 80;
  server_name www.example.com;
  return 301 https://$host$request_uri;  # HTTP→HTTPS 리다이렉트
}
```

* **HTTP/3(QUIC)** 사용 시 별도 빌드/설정 또는 최신 패키지 필요(알파/베타 배포판에서 옵션 제공).

---

## 7) 캐싱·압축·정적 최적화

```nginx
http {
  gzip on; gzip_types text/css application/javascript application/json;
  # brotli on; brotli_types ...;   # 배포판/모듈 필요

  server {
    listen 80; server_name static.example.com;
    root /var/www/static;

    location ~* \.(css|js|png|jpg|svg|woff2)$ {
      expires 7d;
      add_header Cache-Control "public, max-age=604800, immutable";
    }

    # 프록시 캐시(오리진 보호)
    proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=STATIC:10m max_size=1g inactive=1h use_temp_path=off;

    location /api/cache/ {
      proxy_cache STATIC;
      proxy_pass http://127.0.0.1:9000;
      proxy_cache_valid 200 10m;
    }
  }
}
```

---

## 8) 레이트 리미팅(간단한 완화)

```nginx
http {
  limit_req_zone $binary_remote_addr zone=api_ratelimit:10m rate=10r/s;

  server {
    location /api/ {
      limit_req zone=api_ratelimit burst=20 nodelay;
      proxy_pass http://api_upstream;
    }
  }
}
```

---

## 9) 운영 팁 & 모범사례

* **프로세스/리소스**: `worker_processes auto; worker_connections`(부하에 맞게), `ulimit -n`(파일 디스크립터) 조정
* **로그**: `access_log /var/log/nginx/access.log; error_log ...;`

  * JSON 포맷 + 수집기(Fluent Bit/Vector) 연계 추천
* **헬스체크**: `/healthz` 경로 마련(백엔드 200 확인), `proxy_next_upstream` 활용
* **보안**: 최신 TLS, 보안 헤더, 업스트림 타임아웃, 업로드 크기 제한(`client_max_body_size`)
* **리라이트 vs try\_files**: SPA는

  ```nginx
  location / {
    try_files $uri /index.html;
  }
  ```

  로 404를 프론트 라우터에 넘기는 게 안전
* **root vs alias**: `alias`는 경로 끝 슬래시 여부 주의
* **컨테이너/K8s**:

  * Docker: `-v`로 conf/증명서 마운트, **read-only rootfs + tmpfs** 권장
  * 쿠버네티스: **Ingress-NGINX** 컨트롤러(애노테이션으로 레이트리밋, 헤더, 타임아웃), `ConfigMap`로 설정 관리
* **동적 확장**: 오토스케일된 업스트림은 서비스 디스커버리(Consul, DNS SRV, kube-dns)와 함께 사용

---

## 10) NGINX vs Apache(간단 비교)

| 항목      | NGINX               | Apache HTTPD     |
| ------- | ------------------- | ---------------- |
| 처리 모델   | 이벤트 기반, 워커 프로세스     | 프로세스/스레드 기반(MPM) |
| 정적 파일   | 매우 빠름               | 빠름(최적화 필요)       |
| 리버스 프록시 | 1급 시민               | 모듈로 가능           |
| 설정 난이도  | 직관적 블록 구조           | 유연하지만 모듈/디렉티브 많음 |
| 확장      | OpenResty(Lua), njs | mod\_\* 생태계      |

> 대규모 동시접속·프록시·정적 오리진엔 **NGINX**가 흔히 선호됩니다.

---

## 11) Docker로 1분 배포

```bash
# 정적 서버
docker run -d --name web -p 8080:80 -v $PWD/site:/usr/share/nginx/html:ro nginx:stable

# 사용자 conf 적용
docker run -d --name gateway -p 80:80 \
  -v $PWD/nginx.conf:/etc/nginx/nginx.conf:ro \
  nginx:stable
```

* **베스트 프랙티스**: 이미지 read-only, 필요한 경로만 `tmpfs`/`:rw` 마운트, 헬스체크 추가.

---

## 12) 자주 겪는 함정(Quick Fix)

* 502/504: 업스트림 포트/헬스/타임아웃 확인 (`proxy_read_timeout`, 방화벽)
* CORS: 게이트웨이에서 `add_header 'Access-Control-Allow-Origin' ...` 등 사전응답 처리
* 큰 업로드 실패: `client_max_body_size` 상향
* WebSocket 끊김: `proxy_set_header Upgrade $http_upgrade; proxy_set_header Connection "upgrade";`

---

