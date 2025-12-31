
# 🐳 Docker UID 네임스페이스(User Namespace) 실전 가이드

컨테이너에서 **root 권한을 그대로 공유**하는 것은 보안상 큰 문제를 야기할 수 있습니다.
특히 `-v` 옵션으로 호스트 디렉토리를 마운트할 때, 컨테이너 내부 root는 호스트에서도 root 권한을 그대로 행사할 수 있습니다.

여기서는 **UID 네임스페이스 전후 비교**를 통해 이 문제를 해결하는 방법을 단계별로 알아봅니다.

---

## 1. 실습 준비

호스트 디렉토리 하나 생성:

```bash
mkdir -p /tmp/testns
ls -ld /tmp/testns
```

출력 예시:

```
drwxrwxr-x 2 ubuntu ubuntu 4096 Sep 18 06:47 /tmp/testns/
```

---

## 2. UID 네임스페이스 없이 실행 (기본 모드)

### 컨테이너 실행

```bash
docker run --rm -it \
  -v /tmp/testns:/data \
  alpine sh
```

컨테이너 내부에서:

```bash
touch /data/rootfile.txt
ls -l /data/rootfile.txt
```

출력 예시:

```
-rw-r--r--    1 root     root             0 Sep 18 12:05 rootfile.txt
```

---

### 호스트에서 확인

```bash
ls -l /tmp/testns
```

출력 예시:

```
-rw-r--r-- 1 root root 0 Sep 18 06:49 rootfile.txt
```

🚨 **문제점**:

* 컨테이너 내부 root = 호스트 root → 호스트에 root 권한 그대로 적용

---

## 3. UID 네임스페이스 활성화

### Docker 데몬 설정

`/etc/docker/daemon.json` 파일 수정: 원래 daemon.json은 존재하지 않기 때문에 `sudo touch /etc/docker/daemon.json` 커맨드로 daemon.json 파일을 만들어야 합니다

```json
{
  "userns-remap": "default"
}
```

Docker 재시작:

```bash
sudo systemctl restart docker
```

확인:

```bash
# userns-remap 켜졌는지
docker info | grep -i "userns"

# 디렉터리 소유/권한 확인
ls -ld /tmp/testns
stat -c "%n  ->  owner=%u:%g  mode=%a" /tmp/testns

# 매핑 범위 확인(기본 remap이면 dockremap가 뜸)
cat /etc/subuid
cat /etc/subgid
```
> 보통 dockremap:100000:65536 같은 줄이 보입니다.
> 이 뜻: 컨테이너 UID 0 → 호스트 UID 100000, UID 1 → 100001 … 로 매핑.


---

## 4. UID 네임스페이스 활성화 후 실행
디렉터리를 누구나 쓸 수 있게 열어두면 바로 됩니다. (보안상 테스트에만 권장)

```bash
sudo chmod 1777 /tmp/testns    # /tmp 처럼 sticky bit 포함
```

```bash
docker run --rm -it \
  -v /tmp/testns:/data \
  alpine sh
```

컨테이너 내부에서:

```bash
touch /data/mappedfile.txt
ls -l /data/mappedfile.txt
```

출력 예시:

```
-rw-r--r--    1 root     root             0 Sep 18 12:15 mappedfile.txt
```

---

### 호스트에서 확인

```bash
ls -l /tmp/testns
```

출력 예시:

```
-rw-r--r-- 1 100000 100000 0 Sep 18 12:15 mappedfile.txt
```

🚀 **결과**:

* 컨테이너 내부 root → 호스트 UID 100000으로 매핑
* 더 이상 호스트 root가 아님 → 보안 강화

---

## 5. UID 매핑 테이블 예시

| 컨테이너 내부 UID | 호스트 UID | 설명        |
| ----------- | ------- | --------- |
| 0(root)     | 100000  | 일반 사용자 권한 |
| 1           | 100001  | 일반 사용자 권한 |
| 2           | 100002  | 일반 사용자 권한 |

---

## 6. 멀티테넌시 환경 예시

```bash
# 고객 A 컨테이너
docker run --rm -it --userns=remapA alpine sh

# 고객 B 컨테이너
docker run --rm -it --userns=remapB alpine sh
```

* remapA: UID 0 → 호스트 UID 100000
* remapB: UID 0 → 호스트 UID 200000
* 서로 다른 UID 매핑 → 데이터 격리 강화

---

## 7. 정리

| 실행 모드             | 컨테이너 내부 UID | 호스트 UID   | 보안성          |
| ----------------- | ----------- | --------- | ------------ |
| 기본 모드             | 그대로 공유      | 동일 UID    | 낮음 (root 위험) |
| User Namespace 모드 | 매핑된 UID 사용  | 일반 UID 매핑 | 높음 (격리 보장)   |

