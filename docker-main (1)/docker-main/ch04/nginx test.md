다음은 Windows 11의 Git Bash를 사용하여 ch04의 bind mounts 테스트하는 절차입니다

-----

### **테스트 환경 준비**

1.  **Windows 11 PC에 Docker Desktop이 설치**되어 있어야 합니다.
2.  **Git Bash 또는 WSL 2 터미널**을 엽니다. (Git Bash를 권장하며, 동일한 절차로 WSL 2에서도 진행 가능합니다.)
3.  **테스트용 작업 디렉토리**를 생성합니다.
    ```bash
    mkdir -p ~/docker-test
    cd ~/docker-test
    ```

-----

### **테스트 절차 1: 기본 바인드 마운트**

**1단계: 로그 및 설정 파일 생성**

`example.conf` 파일은 **반드시 `LF` (Unix) 줄바꿈 형식**으로 저장해야 합니다.

```bash
# 빈 로그 파일 생성
touch example.log

# NGINX 설정 파일 생성 (Git Bash에 직접 붙여넣기 시 CRLF 문제가 발생할 수 있으므로 텍스트 편집기 권장)
# 다음 내용을 example.conf 파일에 복사/붙여넣기하고 EOL을 Unix(LF)로 설정 후 저장
# --- example.conf 시작 ---
# server {
#  listen 80;
#  server_name localhost;
#  access_log /var/log/nginx/custom.host.access.log main;
#  location / {
#  root /usr/share/nginx/html;
#  index index.html index.htm;
#  }
# }
# --- example.conf 끝 ---
```

**2단계: Docker 컨테이너 실행 (기본 모드)**

NGINX 컨테이너를 실행하고 호스트의 파일을 컨테이너에 바인드 마운트합니다.

```bash
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
```

**3단계: 결과 확인**

1.  웹 브라우저를 열고 `http://localhost/`에 접속합니다. NGINX의 기본 "Welcome to nginx\!" 페이지가 보이면 성공입니다.
2.  Git Bash 터미널로 돌아와서 `example.log` 파일의 내용을 확인합니다.
    ```bash
    cat example.log
    ```
3.  웹사이트에 접속했던 기록(액세스 로그)이 파일에 기록되어 있어야 합니다.
4.  컨테이너의 로그 스트림을 확인합니다.
    ```bash
    docker logs diaweb
    ```
5.  콘솔에 아무런 로그도 출력되지 않는 것을 확인합니다. 이는 로그가 컨테이너 내부의 `stdout`이 아닌, 바인드 마운트된 호스트 파일에 기록되기 때문입니다.

-----

### **테스트 절차 2: 읽기 전용 바인드 마운트**

**1단계: 기존 컨테이너 삭제**

새로운 설정을 적용하기 위해 기존에 실행 중인 컨테이너를 강제로 삭제합니다.

```bash
docker rm -f diaweb
```

**2단계: Docker 컨테이너 실행 (읽기 전용 모드)**

`readonly=true` 옵션을 추가하여 `example.conf` 파일을 읽기 전용으로 마운트합니다.

```bash
# 환경 변수는 그대로 사용
CONF_SRC=$(pwd)/example.conf
CONF_DST=/etc/nginx/conf.d/default.conf
LOG_SRC=$(pwd)/example.log
LOG_DST=/var/log/nginx/custom.host.access.log

# 컨테이너 실행 (설정 파일만 읽기 전용)
docker run -d --name diaweb \
  --mount type=bind,src=${CONF_SRC},dst=${CONF_DST},readonly=true \
  --mount type=bind,src=${LOG_SRC},dst=${LOG_DST} \
  -p 80:80 \
  nginx:latest
```

**3단계: 읽기 전용 테스트**

컨테이너 내부에서 설정 파일을 수정하려는 시도를 합니다.

```bash
docker exec diaweb \
  sed -i "s/listen 80/listen 8080/" /etc/nginx/conf.d/default.conf
```

  * **결과 예상:** 이 명령은 **실패**해야 합니다. 터미널에는 "Read-only file system"과 유사한 오류 메시지가 출력됩니다.
  * **이유:** `readonly=true` 옵션 때문에 컨테이너 내부 프로세스는 해당 파일을 수정할 수 없습니다.

**4단계: 정리**

테스트가 완료되면 생성된 컨테이너를 삭제합니다.

```bash
docker rm -f diaweb
```

이 절차를 통해 바인드 마운트의 기본 동작과 `readonly` 옵션의 기능을 명확하게 이해할 수 있습니다.
