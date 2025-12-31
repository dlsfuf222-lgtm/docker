

# 🚀 쉘 스크립트(Shell Script) : 자동화와 효율성의 시작

리눅스와 유닉스 계열 시스템을 쓰다 보면, 반복되는 명령어 작업을 매번 수동으로 입력하는 것이 꽤 번거롭다는 걸 느끼실 겁니다.
이럴 때 **쉘 스크립트(Shell Script)**를 활용하면, 단순 반복 업무를 자동화하고 시스템 관리 효율성을 극대화할 수 있습니다.

이번 글에서는 **쉘 스크립트의 개념부터 문법, 실무 활용 예시**까지 단계적으로 다뤄보겠습니다.

---

## 1. 쉘 스크립트란 무엇인가?

쉘 스크립트는 **리눅스/유닉스 환경에서 명령어를 순차적으로 실행하는 스크립트 파일**입니다.

* **쉘(Shell)**: 사용자와 운영체제 커널을 연결하는 인터페이스
  예: Bash, Zsh, Ksh
* **스크립트(Script)**: 미리 작성한 명령어 집합

즉, 쉘 스크립트는 **쉘이 해석하여 실행하는 명령어 묶음**이라 할 수 있습니다.

---

## 2. 쉘 스크립트 기본 구조

```bash
#!/bin/bash
# 이 줄은 주석입니다

echo "Hello, Shell Script!"
```

* `#!/bin/bash` → **쉘 인터프리터** 지정 (Bash 사용)
* `#` → 주석(Comment)
* `echo` → 문자열 출력 명령어

---

## 3. 실행 방법

쉘 스크립트를 실행하려면 두 가지 방법이 있습니다.

### (1) 실행 권한 부여 후 직접 실행

```bash
chmod +x myscript.sh
./myscript.sh
```

### (2) 해석기를 명시적으로 호출

```bash
bash myscript.sh
```

---

## 4. 기본 문법 요소

### 4.1 변수

```bash
#!/bin/bash
name="Alice"
echo "Hello, $name!"
```

* 변수 선언 시 `=` 양쪽에 공백이 없어야 합니다.
* `$변수명` 형태로 값을 참조합니다.

---

### 4.2 조건문

```bash
#!/bin/bash
if [ -f "/etc/passwd" ]; then
  echo "파일이 존재합니다"
else
  echo "파일이 없습니다"
fi
```

* `-f` → 파일 존재 여부 체크
* 조건식은 **대괄호 \[ ]** 로 감쌉니다.

---

### 4.3 반복문

```bash
#!/bin/bash
for i in 1 2 3; do
  echo "Number: $i"
done
```

* `for` 구문을 이용해 순회 처리 가능
* `while`, `until` 같은 반복문도 지원됩니다.

---

### 4.4 함수

```bash
#!/bin/bash
greet() {
  echo "Hello, $1!"
}

greet "Bob"
```

* `$1`, `$2`, ... → 함수 인자 접근
* 재사용성 높은 스크립트 작성 가능

---

## 5. 파이프와 리다이렉션

쉘 스크립트는 리눅스 명령어의 장점을 그대로 활용할 수 있습니다.

```bash
ps -ef | grep nginx > result.txt
```

* `|` → 파이프: 앞 명령어 출력 → 뒤 명령어 입력
* `>` → 리다이렉션: 결과를 파일에 저장

---

## 6. 실무 활용 예시

### 6.1 로그 자동 백업 스크립트

```bash
#!/bin/bash
src="/var/log/nginx"
dst="/backup/logs_$(date +%Y%m%d).tar.gz"

tar -czf $dst $src
echo "백업 완료: $dst"
```

* 매일 로그를 자동으로 백업
* 크론탭(Cron)과 연계 시 자동화 가능

---

### 6.2 서버 상태 모니터링

```bash
#!/bin/bash
echo "Disk Usage:"
df -h

echo "Memory Usage:"
free -m

echo "Top 5 Processes:"
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6
```

* 서버 리소스 상태를 한눈에 확인
* 주기적으로 실행하여 리포트 생성 가능

---

## 7. 디버깅과 최적화

* **디버깅 모드**:

  ```bash
  bash -x myscript.sh
  ```

  실행 과정 추적 가능

* **Strict 모드**:

  ```bash
  set -euo pipefail
  ```

  오류 발생 시 즉시 종료, 안전성 확보

---

## 8. 정리

| 주제      | 핵심 포인트                                 |
| ------- | -------------------------------------- |
| 스크립트 시작 | `#!/bin/bash` 해더 필수                    |
| 변수      | `$변수명` 형태 사용                           |
| 조건문/반복문 | `[ 조건 ]` 구문, `for`, `while` 지원         |
| 함수      | 재사용성 높은 코드 작성 가능                       |
| 자동화 활용  | 백업, 모니터링, 배포 자동화에 필수적                  |
| 디버깅     | `bash -x`, `set -euo pipefail`로 안전성 확보 |

---

## 9. 예시


---

### 1. 쉘스크립트 코드

```bash
for i in amazon google microsoft; \
do \
  docker run --rm \
    --mount type=volume,src=$i,dst=/tmp \
    --entrypoint /bin/sh \
    alpine:latest -c "nslookup $i.com > /tmp/results.txt"; \
done
```

---

### 2. 실행 흐름

1. **for 반복문 시작**

   * `amazon`, `google`, `microsoft` 세 문자열을 순회하면서 `i` 변수에 대입됩니다.

2. **Docker 컨테이너 실행**

   * 각 반복마다 `docker run`으로 `alpine:latest` 이미지를 실행합니다.
   * 컨테이너 내부에서 `nslookup $i.com` 실행 → 결과를 `/tmp/results.txt`에 저장.

3. **결과 저장**

   * `/tmp` 경로는 도커 **볼륨 마운트**(`--mount`)로 연결돼 있으므로, 결과 파일이 컨테이너 종료 후에도 **호스트에 유지**됩니다.

4. **컨테이너 종료**

   * `--rm` 옵션으로 컨테이너가 종료되면 자동 삭제됩니다.

---

### 3. 명령어 상세 분석

| 구문                                              | 설명                                        |
| ----------------------------------------------- | ----------------------------------------- |
| `for i in amazon google microsoft; do ... done` | Bash 반복문 구문, 세 개의 값을 차례대로 `i`에 대입         |
| `docker run`                                    | 컨테이너 실행 명령어                               |
| `--rm`                                          | 컨테이너 실행 후 자동 삭제                           |
| `--mount type=volume,src=$i,dst=/tmp`           | 이름이 `$i`인 볼륨을 컨테이너의 `/tmp`에 마운트           |
| `--entrypoint /bin/sh`                          | 컨테이너 시작 시 `/bin/sh`를 엔트리포인트로 변경           |
| `alpine:latest`                                 | 가벼운 Alpine 리눅스 이미지 사용                     |
| `-c "nslookup $i.com > /tmp/results.txt"`       | `/bin/sh -c` 모드로 nslookup 실행 후 결과를 볼륨에 저장 |

---

### 4. 실제 실행 예시

* 첫 번째 반복: `i=amazon`

  ```bash
  docker run --rm \
    --mount type=volume,src=amazon,dst=/tmp \
    --entrypoint /bin/sh \
    alpine:latest -c "nslookup amazon.com > /tmp/results.txt"
  ```

* 두 번째 반복: `i=google`

* 세 번째 반복: `i=microsoft`

결과적으로 각 볼륨(`amazon`, `google`, `microsoft`) 안에 `results.txt` 파일이 생성됩니다.

---

### 5. 주요 포인트 & 주의사항

1. **볼륨 단위로 결과 저장**

   * `src=$i` 때문에 amazon, google, microsoft라는 **각각의 볼륨**이 생성됩니다.
   * 볼륨 경로를 호스트로 마운트하지 않으면 `docker volume inspect $i`로 실제 경로를 찾아야 합니다.

2. **--entrypoint vs CMD**

   * Alpine 이미지의 기본 CMD는 `/bin/sh`가 아니라서, `--entrypoint /bin/sh`로 명시한 뒤 `-c` 옵션으로 스크립트를 실행하는 구조입니다.

3. **컨테이너는 일회성**

   * `--rm` 덕분에 컨테이너는 실행 후 바로 삭제됩니다.
   * 결과는 볼륨에 저장되므로 컨테이너 삭제와 무관하게 유지됩니다.

---

### 6. 개선 예시 (호스트 경로에 결과 저장)

볼륨 대신 **호스트 디렉토리 마운트**를 쓰면 결과 확인이 더 편리합니다.

```bash
for i in amazon google microsoft; do
  docker run --rm \
    --mount type=bind,src=$(pwd)/results/$i,dst=/tmp \
    alpine:latest /bin/sh -c "nslookup $i.com > /tmp/results.txt"
done
```

이렇게 하면 실행 후 `./results/amazon/results.txt` 같은 식으로 호스트에서 바로 결과를 확인할 수 있습니다.

---


## 10. 마무리

쉘 스크립트는 **시스템 자동화의 핵심 도구**입니다.
단순 반복 작업부터 대규모 배포 자동화까지, 활용 범위는 매우 넓습니다.

특히 DevOps 환경에서 CI/CD 파이프라인, 로그 관리, 모니터링 자동화 등에 빠질 수 없는 존재이죠.


