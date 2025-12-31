

# 🛠️ 리눅스 특수 권한 비트: setuid, setgid, sticky bit

리눅스 파일 시스템에는 기본 권한(rwx) 외에도
**특수 권한 비트(Special Permission Bits)** 3종이 있습니다:

* **setuid (Set User ID)**
* **setgid (Set Group ID)**
* **sticky bit**

이들은 **실행 권한(x)** 이나 **쓰기 권한(w)** 과 결합되어
보안·공유·운영 측면에서 중요한 역할을 합니다.

---

## 1️⃣ setuid (Set User ID)

### 📜 개념

* 실행 파일에 **setuid**가 걸려 있으면,
  **해당 프로그램은 실행 시 파일 소유자의 UID 권한**으로 실행됩니다.
* 주로 root 소유 실행 파일에서 사용됨.

### 📌 권한 표시

* 소유자 실행 권한 자리의 `x` → `s` 또는 `S`

  * `s`: 실행 권한 있음 + setuid 걸림
  * `S`: 실행 권한 없음 + setuid 걸림(비정상)

예:

```
-rwsr-xr-x  root root  /usr/bin/passwd
```

* `s` → 소유자 실행 권한 + setuid 설정됨
* 일반 사용자가 실행해도 root 권한으로 동작

---

### 🧪 예제: setuid 실습

```bash
sudo cp /bin/bash /tmp/testbash
sudo chown root:root /tmp/testbash
sudo chmod 4755 /tmp/testbash
```

* `4` → setuid 비트
* 이제 일반 사용자가 실행해도 root 권한 bash 실행됨:

```bash
ls -l /tmp/testbash
-rwsr-xr-x 1 root root ...
```

⚠️ **주의**: 보안상 위험해서 실무에서는 거의 안 씁니다.

---

## 2️⃣ setgid (Set Group ID)

### 📜 개념

* **실행 파일**: 실행 시 **파일 그룹 ID**로 프로세스가 실행됨
* **디렉터리**: 디렉터리에 setgid 걸리면, 그 안에 새로 생성되는 파일·폴더는 **자동으로 디렉터리 그룹 상속**

---

### 📌 권한 표시

* 그룹 실행 권한 자리의 `x` → `s` 또는 `S`

  * `s`: 실행 권한 있음 + setgid 걸림
  * `S`: 실행 권한 없음 + setgid 걸림

예:

```
drwxr-sr-x  root devgroup  /shared
```

* 이 디렉터리 안에 새 파일 → 그룹이 자동으로 devgroup 상속

---

### 🧪 예제: setgid 실습

```bash
sudo mkdir /shared
sudo chown root:devgroup /shared
sudo chmod 2775 /shared
```

* `2` → setgid 비트
* 새 파일 생성:

```bash
touch /shared/file1
ls -l /shared/file1
```

→ 그룹이 `devgroup`으로 상속됨

---

## 3️⃣ sticky bit

### 📜 개념

* **디렉터리에 sticky bit** 걸리면,
  **자기 소유 파일만 삭제 가능**(root 제외).

* 모든 사용자가 쓰기 가능한 디렉터리 공유 시 필수.
  대표 예: `/tmp` 디렉터리.

---

### 📌 권한 표시

* 기타 사용자 실행 권한 자리의 `x` → `t` 또는 `T`

  * `t`: 실행 권한 있음 + sticky bit 걸림
  * `T`: 실행 권한 없음 + sticky bit 걸림

예:

```
drwxrwxrwt  tmp
```

---

### 🧪 예제: sticky bit 실습

```bash
sudo mkdir /sharedtmp
sudo chmod 1777 /sharedtmp
```

* `1` → sticky bit 비트
* 다른 사용자가 만든 파일 → 남이 지울 수 없음

---

## 4️⃣ 특수 권한 비트 요약표

| 권한 비트          | 설정 값 | 적용 대상      | 동작                             | 권한 표시        |
| -------------- | ---- | ---------- | ------------------------------ | ------------ |
| **setuid**     | 4    | 실행 파일      | 실행 시 파일 소유자 권한으로 동작            | `-rwsr-xr-x` |
| **setgid**     | 2    | 실행 파일/디렉터리 | 실행 시 파일 그룹 권한으로 동작, 디렉터리 그룹 상속 | `drwxr-sr-x` |
| **sticky bit** | 1    | 디렉터리       | 자기 파일만 삭제 가능                   | `drwxrwxrwt` |

---

## 5️⃣ 숫자 모드 정리

| 모드   | 의미                       | 예시                |
| ---- | ------------------------ | ----------------- |
| 4xxx | setuid                   | `chmod 4755 file` |
| 2xxx | setgid                   | `chmod 2755 dir`  |
| 1xxx | sticky bit               | `chmod 1777 dir`  |
| 조합   | setuid+setgid+sticky bit | `chmod 7777 file` |

---

## 6️⃣ 실무 활용 예시

| 위치/파일             | 권한 비트      | 이유                     |
| ----------------- | ---------- | ---------------------- |
| `/usr/bin/passwd` | setuid     | 일반 사용자가 비밀번호 변경 가능해야 함 |
| `/tmp` 디렉터리       | sticky bit | 공유 디렉터리에서 남 파일 삭제 방지   |
| 공유 작업 디렉터리        | setgid     | 팀 디렉터리 내 파일 그룹 자동 상속   |

---

## 7️⃣ 시각적 도식

```
        +---------------------+
        | Special Permission  |
        +---------------------+
        | setuid  | 4 | 실행 파일 소유자 권한 실행       |
        | setgid  | 2 | 그룹 권한 실행, 디렉터리 그룹 상속 |
        | sticky  | 1 | 자기 파일만 삭제 가능            |
        +---------------------+
```


