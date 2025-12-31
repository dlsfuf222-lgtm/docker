# 프로세스 격리와 환경 독립 실행: Docker로 배우는 컨테이너 운영 기초 🚀

> 이 글은 *프로세스 격리(process isolation)* 와 *환경 독립(environment-agnostic)* 관점에서 컨테이너를 이해하고, Docker로 그것을 **어떻게 제어**하는지를 단계별 예제로 설명합니다.
> 목표: **재사용성, 자원 효율성, 운영 단순화**를 실전 감각으로 체득하기.

---

## 왜 “격리(Isolation)”인가?

* **문제**: 서로 다른 프로그램(웹서버, DB, 패키지매니저, 컴파일러 등)은 **다른 요구사항**을 가집니다. 포트·파일·라이브러리 버전·환경변수 충돌은 흔합니다.
* **해결**: 컨테이너는 **네임스페이스(PID, NET, MNT, UTS, IPC)**, **cgroups**, **루트파일시스템**을 가상화/분리하여 **격리된 실행공간**을 만듭니다.
* **효과**: 동일 호스트에서도 **충돌 없이 여러 버전/인스턴스**를 병행 실행. 배포/회수도 단 몇 개의 커맨드로.

---

## 이 장에서 다루는 것

* 대화형/데몬 컨테이너 실행
* 핵심 Docker 작업(`run/ps/logs/stop/start/exec`)
* **프로세스 격리**와 **구성 주입(Env)**
* 한 컨테이너에서 **여러 프로세스** 다루기
* **내구성 있는 컨테이너**와 재시작 정책
* 안전한 **정리(Clean-up)**

---

## 1) 첫 프로젝트: 웹사이트 모니터링 미니 스택

아키텍처(컨테이너 3개):

* `web` : NGINX 웹서버 (백그라운드)
* `mailer` : 알림 발송기 (백그라운드)
* `agent` : 웹 헬스체크 → 다운 시 메일러 호출 (대화형 시작 후 분리)

### 1-1. 데몬 컨테이너 실행

```bash
docker run --detach --name web nginx:latest
docker run -d --name mailer dockerinaction/ch2_mailer
```

* `-d/--detach`: **터미널 미연결** 백그라운드 실행. 서버/에이전트 등 데몬에 적합.
* 출력되는 긴 해시는 **컨테이너 ID**.

### 1-2. 대화형 컨테이너로 점검

```bash
# Linux/macOS 예시
docker run --interactive --tty \
  --link web:web \
  --name web_test \
  busybox:1.29 /bin/sh

# 컨테이너 셸에서
/ # wget -O - http://web:80/
```

* `-i/-t`: 표준입력 유지 + TTY 할당 → **대화형 셸**.
* `Ctrl+P, Ctrl+Q`: **분리(detach)**. 프로세스는 계속 동작.

> **Windows 팁**
> Git Bash(MSYS2)에서는 `\` 라인 연장이 깨지거나 `/bin/sh`가 호스트 경로로 변환될 수 있습니다.
>
> * PowerShell을 쓰고 백틱(\`\`\`)으로 라인 연장을 사용
> * 혹은 Git Bash에서 **경로 변환 끄기**:
>
>   ```bash
>   MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL="*" docker run ...
>   ```

### 1-3. 상태·로그·제어

```bash
docker ps
docker logs web
docker stop web && docker restart web
docker attach agent         # 다시 붙기
# 분리: Ctrl+P, Ctrl+Q
```

* `docker logs -f`: tail-follow. Ctrl+C로 탈출.
* 로그는 기본 “json-file” 드라이버 → **로테이션 고려** 필요(운영 시).

---

## 2) PID 네임스페이스로 보는 “격리”

컨테이너는 기본적으로 **자기만의 PID 공간**을 가집니다.

```bash
docker run -d --name namespaceA busybox:1.29 /bin/sh -c "sleep 30000"
docker run -d --name namespaceB busybox:1.29 /bin/sh -c "nc -l 0.0.0.0 -p 80"

docker exec namespaceA ps
# PID 1이 sleep
docker exec namespaceB ps
# PID 1이 nc
```

* 각 컨테이너의 **PID 1**은 서로 다릅니다(진짜 격리).
* 필요 시 **호스트 PID 네임스페이스 공유**도 가능:

  ```bash
  docker run --pid host busybox:1.29 ps
  ```

  → 호스트 프로세스를 컨테이너에서 관찰/관리하는 도구 제작에 유용.

### 포트 충돌? 격리로 회피

호스트에서 같은 포트(80)를 두 번 바인드하면 충돌.
컨테이너는 **서로 다른 네임스페이스**라 내부 포트는 겹쳐도 OK.
외부로 노출할 땐 호스트 포트 매핑으로 조정.

```bash
docker run -d --name webA nginx:latest
docker run -d --name webB nginx:latest
# 둘 다 내부 80 사용. 필요하면 -p 8080:80, -p 8081:80 등으로 외부 포트 분리
```

---

## 3) 컨테이너 식별과 이름 전략

* **이름 충돌**:

  ```bash
  docker run -d --name web nginx
  docker run -d --name web nginx # ❌ 충돌
  ```
* 해결책

  * 자동 생성 이름 사용(기본)
  * `docker rename web web-old`
  * **ID 사용** (앞 12자리로 충분)
  * **CID 파일**:

    ```bash
    docker create --cidfile /tmp/web.cid nginx
    cat /tmp/web.cid
    ```

---

## 4) 상태(state)와 의존성 순서

* 주요 상태: `created → running → exited` (+ restarting/paused/removing)
* `docker ps`는 기본 **running만** 표시, `-a`로 전체 보기.
* **링크/네트워크 의존성**은 **역순 시작** 필요:

  * DB → WEB → AGENT

> `--link`는 레거시. **사용자 정의 브리지 네트워크**(권장)로 전환을 고려하세요.

---

## 5) 환경 독립(agnostic) 설계 3요소

1. **읽기 전용(rootfs read-only)**
2. **환경 변수(Env)로 구성 주입**
3. **볼륨(Volume)으로 데이터/상태 분리**

### 5-1. 읽기 전용 RootFS + 필요한 쓰기 경로만 예외

```bash
# 읽기 전용으로 WordPress 실행 (실패 예시)
docker run -d --name wp --read-only wordpress:6.4.3-php8.1-apache
docker logs wp  # 잠금/임시 파일 생성 불가 에러 확인

# 쓰기 위치 파악
docker run -d --name wp_writable wordpress:6.4.3-php8.1-apache
docker container diff wp_writable   # /run/apache2/* 등 변경 경로 확인

# 예외 부여(쓰기 가능 볼륨 + tmpfs)
docker run -d --name wp2 \
  --read-only \
  -v /run/apache2/ \
  --tmpfs /tmp \
  wordpress:6.4.3-php8.1-apache
```

> 운영 팁
>
> * **이미지/컨테이너 변형 없이** 동작 보장 → 재현성↑, 보안면에서도 긍정적(파일 변조 난이도↑).

### 5-2. 환경 변수로 DB 연결/자격 주입

```bash
docker run --env MY_ENVIRONMENT_VAR="this is a test" busybox:1.29 env

# WordPress가 인식하는 대표 변수
WORDPRESS_DB_HOST
WORDPRESS_DB_USER
WORDPRESS_DB_PASSWORD
WORDPRESS_DB_NAME
# (Key/Salt도 필히 설정: 운영 필수)
```

* 링크 해제(물리 종속 ↓), **외부 DB/클러스터**로 손쉽게 전환.

```bash
docker create \
  -e WORDPRESS_DB_HOST=db.example.com \
  -e WORDPRESS_DB_USER=site_admin \
  -e WORDPRESS_DB_PASSWORD=MeowMix42 \
  -e WORDPRESS_DB_NAME=client_a_wp \
  wordpress:5.0.0-php7.2-apache
```

### 5-3. 볼륨(4장에서 상세) 요약

* **영속 데이터** 별도 보관(컨테이너 생명주기와 분리)
* **성능**(overlay보다 호스트 직접 I/O), **공유**, **백업 용이**

---

## 6) 내구성 있는 컨테이너: 장애 자동 복구

### 6-1. 재시작 정책

```bash
# 항상 재시작 (지수 백오프)
docker run -d --name backoff-detector --restart always busybox:1.29 date
docker logs -f backoff-detector
```

* 정책: `no | on-failure[:N] | unless-stopped | always`
* 재시작 대기시간은 **지수 백오프**.
* **주의**: 재시작 중(`restarting`)에는 `docker exec` 불가(진단 곤란).

### 6-2. PID 1과 경량 init

* 여러 프로세스/자식 처리/시그널 포워딩/좀비 수거가 필요하면 **init 사용**:

  * `tini`, `dumb-init`, `runit`, `supervisord` 등
* 엔트리포인트 스크립트로 **사전 조건 확인/기본값 주입** → 실패를 **조기에 명확화**.

```bash
# WordPress 엔트리포인트 스크립트 보기
docker run --entrypoint="cat" wordpress:5.0.0-php7.2-apache /usr/local/bin/docker-entrypoint.sh
```

---

## 7) 정리(Clean-up) 루틴

* 컨테이너는 **디스크/네임스페이스 리소스**를 점유 → 주기적 정리 권장
* 원칙:

  1. 먼저 **정상 중지** `docker stop` (SIGTERM/유예)
  2. 제거 `docker rm`
  3. 짧은 실험엔 `--rm`로 자동 제거

```bash
docker rm wp
docker run --rm --name auto-exit-test busybox:1.29 echo Hello
# 일괄 제거(주의!):
docker rm -vf $(docker ps -a -q)
```

---

## 8) 실전 스니펫: 멀티 테넌트 WordPress + 모니터링

```bash
#!/bin/sh
# 선행: 공유 DB/Mailer
export DB_CID=$(docker run -d -e MYSQL_ROOT_PASSWORD=ch2demo mysql:5.7)
export MAILER_CID=$(docker run -d dockerinaction/ch2_mailer)

# 고객별 프로비저닝
CLIENT_ID=$1
[ -z "$CLIENT_ID" ] && echo "Client ID missing" && exit 1

WP_CID=$(docker create \
  --link $DB_CID:mysql \
  --name wp_${CLIENT_ID} \
  -p 80 \
  --read-only -v /run/apache2/ --tmpfs /tmp \
  -e WORDPRESS_DB_NAME=${CLIENT_ID} \
  wordpress:5.0.0-php7.2-apache)
docker start $WP_CID

AGENT_CID=$(docker create \
  --name agent_${CLIENT_ID} \
  --link $WP_CID:insideweb \
  --link $MAILER_CID:insidemailer \
  dockerinaction/ch2_agent)
docker start $AGENT_CID
```

> 운영시 권장: `--restart unless-stopped` 등을 추가하고, `--link` 대신 **사용자 정의 네트워크**로 전환.

---

## 마무리: 운영자가 꼭 기억할 체크리스트 ✅

* [ ] 내부 포트는 겹쳐도 OK, **호스트 포트 매핑** 충돌만 피하면 됨
* [ ] **읽기 전용 rootfs**를 기본값으로, 꼭 필요한 경로만 쓰기 허용
* [ ] **환경변수로 구성 주입**(주소/자격/이름/솔트/키)
* [ ] **볼륨**으로 상태/데이터 분리(백업/성능/수명주기 독립)
* [ ] **재시작 정책** + (필요시) **경량 init**으로 내구성 강화
* [ ] **로그 로테이션**과 **정리 전략**(stop/rm/—rm) 준비
* [ ] Windows 개발환경이라면 **Git Bash 경로변환 이슈**에 주의하고 PowerShell 병행

---

컨테이너는 “한 번의 설치/설정 → 어디서나 동일하게 실행”을 현실로 만듭니다. 오늘 다룬 격리·구성 주입·재시작·정리 루틴만 익혀도, **재사용 가능한 운영 템플릿**을 손에 넣게 됩니다.

