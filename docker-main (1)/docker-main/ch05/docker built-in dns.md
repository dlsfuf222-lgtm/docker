
Docker의 **내장 DNS 서버**는 Docker 데몬(`dockerd`) 자체에 내장되어 있습니다.

즉, 컨테이너 안에서 보이는 `127.0.0.11` DNS 서버는 별도의 컨테이너 프로세스가 아니라, **Docker 데몬이 제공하는 가상 DNS 서비스**입니다.

---

## 🧠 동작 방식

1. **컨테이너 안에서 DNS 질의 발생**

   * 예: `nslookup barker`
   * `/etc/resolv.conf`에 기본적으로 `nameserver 127.0.0.11`이 설정됨

2. **Docker 데몬이 가상 DNS로 응답**

   * 127.0.0.11:53 주소로 질의가 들어오면 Docker 엔진이 직접 처리
   * 같은 사용자 정의 네트워크에 있는 컨테이너 이름 → IP 매핑 관리

3. **외부 도메인 요청 시**

   * Docker DNS는 `/etc/docker/daemon.json` 또는 시스템 기본 DNS를 통해 외부 DNS 서버로 재질의(Forwarding)

---

## 🔍 확인 예시

```bash
docker run --rm alpine:latest cat /etc/resolv.conf
```

출력 예:

```
nameserver 127.0.0.11
options ndots:0
```

여기서 `127.0.0.11`은 **Docker 데몬 내부 DNS**를 가리키며, 절대 다른 컨테이너가 아닙니다.

---

## 🐳 정리

| 항목            | 설명                        |
| ------------- | ------------------------- |
| 실행 위치         | Docker 데몬 내부              |
| 별도 컨테이너 필요 여부 | ❌ 필요 없음                   |
| 역할            | 컨테이너 이름 해석 + 외부 DNS 포워딩   |
| 동작 범위         | 같은 Docker 네트워크 내 컨테이너에 한정 |

---
