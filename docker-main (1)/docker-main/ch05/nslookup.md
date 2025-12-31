

# 🔍 nslookup

DNS(Domain Name System)는 우리가 **도메인 이름**으로 웹사이트에 접근할 수 있게 해주는 핵심 인프라입니다. 예를 들어 `google.com`이라는 이름이 실제로는 어느 IP 주소로 매핑되는지 궁금할 때, 바로 여기서 **`nslookup`** 명령어가 활약합니다. 🚀

이번 글에서는 `nslookup`의 기본 개념부터 사용법, 고급 옵션까지 한 번에 정리해보겠습니다.

---

## 🧠 1. nslookup이란?

* **nslookup = Name Server Lookup**
* DNS 서버에 직접 질의(Query)하여 **도메인 이름 → IP 주소**, 또는 **IP 주소 → 도메인 이름** 정보를 가져오는 도구입니다.
* 리눅스/유닉스 계열에서는 `dnsutils`(Debian/Ubuntu) 또는 `bind-utils`(RHEL/CentOS) 패키지에 포함되어 있습니다.

> 💡 참고: 최근에는 `dig`, `host` 명령어도 널리 사용되며, 기능이 더 강력합니다. 하지만 `nslookup`은 여전히 단순하고 직관적이라는 장점이 있습니다.

---

## 🛠 2. 기본 사용법

### ✅ 도메인 이름 → IP 주소

```bash
nslookup example.com
```

**결과 예시:**

```
Server:  8.8.8.8
Address: 8.8.8.8#53

Non-authoritative answer:
Name:    example.com
Address: 93.184.216.34
```

---

### ✅ IP 주소 → 도메인 이름 (Reverse Lookup)

```bash
nslookup 8.8.8.8
```

* IP 주소에 해당하는 **PTR 레코드**를 조회합니다.
* 이 레코드는 보통 IP 주소의 호스트명 식별에 사용됩니다.

---

### ✅ 다른 DNS 서버 지정

```bash
nslookup example.com 1.1.1.1
```

* 기본 DNS 대신 **Cloudflare DNS(1.1.1.1)** 로 질의합니다.

---

## ⚡ 3. 인터랙티브 모드 사용하기

단일 명령어 대신, 여러 쿼리를 한 번에 보내고 싶다면 **인터랙티브 모드**를 활용할 수 있습니다.

```bash
nslookup
> server 8.8.8.8
> set type=MX
> google.com
```

* `server`: 사용할 DNS 서버 변경
* `set type`: 조회할 레코드 종류 지정(A, MX, NS, TXT 등)

---

## 🧾 4. 주요 옵션 정리

| 명령어 / 옵션                | 설명                  | 예시                            |
| ----------------------- | ------------------- | ----------------------------- |
| `nslookup <host>`       | A 레코드 조회 (기본)       | `nslookup google.com`         |
| `nslookup <host> <DNS>` | 특정 DNS 서버 지정        | `nslookup google.com 1.1.1.1` |
| `set type=MX`           | 메일 교환 서버 레코드(MX) 조회 | `set type=MX` → `google.com`  |
| `set type=NS`           | 네임서버 레코드(NS) 조회     | `set type=NS` → `example.com` |
| `set debug`             | 상세 질의 정보 출력         | `set debug` → `example.com`   |

---

## 📊 5. ping과 nslookup의 차이

| 명령어        | 동작 원리                     | `/etc/hosts` 참조 | DNS 직접 질의 |
| ---------- | ------------------------- | --------------- | --------- |
| `ping`     | 우선 로컬 호스트 파일 → 없으면 DNS 조회 | ✅ 참조            | 가능        |
| `nslookup` | **DNS 서버에만 직접 질의**        | ❌ 무시            | ✅ 사용      |

그래서 Docker 컨테이너 안에서 `--hostname`만 설정하면

* `ping barker` → 성공 (hosts 파일 기반)
* `nslookup barker` → 실패 (DNS에는 등록 안 됨)

이런 결과가 나오는 겁니다. 😅

---

## 🚀 6. 실전 예시 모음

```bash
# 기본 A 레코드 조회
nslookup github.com

# MX 레코드 조회 (메일 서버)
nslookup -query=MX gmail.com

# 특정 DNS 서버 지정
nslookup openai.com 8.8.8.8

# Reverse Lookup (IP → 도메인)
nslookup 8.8.8.8
```

---

## 📌 7. 마무리

`nslookup`은 단순하지만 DNS 문제를 디버깅할 때 매우 유용한 도구입니다.

* 빠른 질의: `nslookup <domain>`
* 레코드별 확인: `set type=<레코드>`
* DNS 서버 변경: `<domain> <DNS 서버>`

만약 더 정교한 기능이나 다양한 출력이 필요하다면 `dig` 또는 `host` 명령어도 고려해볼 수 있습니다.

