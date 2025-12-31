
`/etc/resolv.conf` 파일은 리눅스·유닉스 계열 시스템에서 **DNS 클라이언트 설정**의 핵심 역할을 담당하는 파일입니다. Docker 컨테이너 안에서도 이 파일을 통해 DNS 동작이 제어됩니다.

---

# 📄 /etc/resolv.conf: 리눅스 DNS 설정의 중심

리눅스에서 어떤 도메인(`google.com`)의 IP 주소를 찾으려면, 커널이나 애플리케이션이 DNS 서버에 쿼리를 보내야 합니다.
이때 **어느 DNS 서버에 요청을 보낼지** 알려주는 설정이 바로 `/etc/resolv.conf` 파일입니다. 🧭

---

## 🧠 1. 주요 역할

* **DNS 서버 주소 지정**: 도메인 이름 → IP 주소 변환에 사용될 네임서버 정보 저장
* **검색 도메인 설정**: 짧은 호스트명에 자동으로 붙일 도메인 이름 지정
* **DNS 동작 방식 제어**: 쿼리 타임아웃, 재시도 횟수 등 옵션 지정 가능

즉, 애플리케이션이 `gethostbyname()` 같은 시스템 콜을 쓰면, glibc 등이 이 파일을 읽어서 **어떤 DNS 서버를 쓸지** 결정합니다.

---

## 🛠 2. 기본 예시

```conf
nameserver 8.8.8.8
nameserver 1.1.1.1
search mydomain.local
options ndots:5 timeout:2 attempts:3
```

| 키워드          | 의미                                          |
| ------------ | ------------------------------------------- |
| `nameserver` | 사용할 DNS 서버 IP 주소 (최대 3개)                    |
| `search`     | 호스트명에 자동으로 붙일 검색 도메인 지정                     |
| `options`    | 동작 세부 설정 (`ndots`, `timeout`, `attempts` 등) |

---

## 🔍 3. 주요 옵션 설명

* **nameserver**:

  ```conf
  nameserver 8.8.8.8
  nameserver 1.1.1.1
  ```

  → 먼저 8.8.8.8에 질의, 실패하면 1.1.1.1로 시도

* **search**:

  ```conf
  search example.com corp.local
  ```

  → `host1` 질의 시 `host1.example.com`, `host1.corp.local` 순으로 해석 시도

* **options ndots\:n**:

  * 도메인 이름에 점(.)이 `n`개 미만이면 search 도메인 붙여서 질의
  * `ndots:5` → 점이 5개 미만이면 search 도메인 추가

* **timeout\:n**:

  * DNS 응답 대기 시간 (초)
  * 예: `timeout:2` → 2초 기다림

* **attempts\:n**:

  * 실패 시 재시도 횟수

---

## 🐳 4. Docker 컨테이너에서 /etc/resolv.conf

Docker 컨테이너를 실행하면 Docker 데몬이 자동으로 이 파일을 채워줍니다:

```bash
$ docker run --rm alpine:latest cat /etc/resolv.conf
nameserver 127.0.0.11
options ndots:0
```

* `127.0.0.11`: Docker 내장 DNS 서버
* 컨테이너는 여기에 질의 → Docker 엔진이 실제 호스트 DNS 또는 `--dns`로 지정된 서버에 재질의

---

## ⚡ 5. 요약

| 항목            | 설명                                              |
| ------------- | ----------------------------------------------- |
| **위치**        | `/etc/resolv.conf`                              |
| **주요 역할**     | DNS 서버, 검색 도메인, 타임아웃·재시도 옵션 관리                  |
| **Docker 연동** | 컨테이너 실행 시 Docker가 자동으로 채움                       |
| **커스터마이징**    | `--dns`, `--dns-search`, `--dns-option`으로 수정 가능 |

