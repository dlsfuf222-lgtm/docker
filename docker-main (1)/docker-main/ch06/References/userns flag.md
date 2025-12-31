

# 🐳 Docker `--userns` 플래그

Docker에서 **`--userns`** 옵션은 **컨테이너 실행 시 사용할 User Namespace를 직접 지정**하는 기능입니다.
즉, 컨테이너 내부 UID/GID 공간을 어떤 매핑 규칙으로 적용할지 **컨테이너 단위**에서 정할 수 있습니다.

---

## 1️⃣ 기본 개념: User Namespace

* 컨테이너 내부 사용자(root 포함)의 UID/GID ↔ 호스트 UID/GID 매핑 가능
* 매핑 규칙에 따라 컨테이너 내부 root라도 호스트에선 **비특권 사용자**로 실행됨 → 보안 강화
* 멀티테넌시 환경에서는 고객별 UID 네임스페이스를 달리해 **데이터/권한 격리** 가능

---

## 2️⃣ `--userns` 동작 방식

```bash
docker run --rm -it --userns=<네임스페이스 이름> alpine sh
```

* `<네임스페이스 이름>`은 **미리 UID 매핑이 정의된 User Namespace** 이름
* 이 매핑 정보는 `/etc/subuid`, `/etc/subgid`에 존재

예:

```
remapA:100000:65536
remapB:200000:65536
```

* `remapA` 네임스페이스: 컨테이너 UID 0 → 호스트 UID 100000
* `remapB` 네임스페이스: 컨테이너 UID 0 → 호스트 UID 200000

---

## 3️⃣ 주요 사용 모드

| 모드             | 명령 예시                         | 설명                     |
| -------------- | ----------------------------- | ---------------------- |
| 특정 매핑 사용       | `--userns=remapA`             | remapA 네임스페이스로 UID 매핑  |
| 호스트 UID 공유     | `--userns=host`               | 호스트와 동일 UID 공간 사용      |
| 다른 컨테이너 네임스페이스 | `--userns=container:<컨테이너ID>` | 특정 컨테이너와 UID 네임스페이스 공유 |

---

## 4️⃣ 실습 예시

### ① remapA 네임스페이스 사용

```bash
docker run --rm -it --userns=remapA -v /data:/data alpine sh
/ # touch /data/a.txt
```

* 호스트에서 확인:

  ```bash
  ls -l /data
  -rw-r--r-- 1 100000 100000 0 Sep 19 12:00 a.txt
  ```
* 컨테이너 root → 호스트 UID 100000

---

### ② remapB 네임스페이스 사용

```bash
docker run --rm -it --userns=remapB -v /data:/data alpine sh
/ # touch /data/b.txt
```

* 호스트에서 확인:

  ```bash
  ls -l /data
  -rw-r--r-- 1 200000 200000 0 Sep 19 12:05 b.txt
  ```

이렇게 하면 **A, B 컨테이너 간 UID 공간 완전히 분리** 가능 → 멀티테넌시 환경에서 유용

---

## 5️⃣ `userns-remap` 언급만 잠깐

* `userns-remap`은 **Docker 데몬 전체에 전역 매핑**을 자동 적용하는 방식
* 반면 `--userns`는 **컨테이너 단위로 매핑 지정**이 가능해 멀티테넌시나 개별 보안 정책에서 더 유연함

---

## 6️⃣ 정리

| 옵션             | 적용 범위        | 매핑 제어 방식          | 멀티테넌시 활용 |
| -------------- | ------------ | ----------------- | -------- |
| `--userns`     | 컨테이너 단위      | 실행 시 개별 네임스페이스 선택 | 가능       |
| `userns-remap` | Docker 데몬 전역 | 데몬 설정에서 전역 매핑     | 제한적      |

---
