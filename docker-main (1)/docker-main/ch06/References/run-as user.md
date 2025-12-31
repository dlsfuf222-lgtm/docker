리눅스에서 **run-as user**라는 개념은 말 그대로 **프로세스나 명령을 특정 사용자 권한으로 실행(run as a user)** 한다는 뜻입니다.
보통 **root 계정**이 다른 사용자의 권한으로 프로세스를 실행시킬 때 많이 쓰입니다.

조금 더 깊게 들어가면, 이 개념은 리눅스의 **UID(User ID)** 와 **권한 분리(Privilege Separation)** 메커니즘에 기반합니다.

---

## 1. 핵심 개념: Run-as User

* **기본 아이디어**: 하나의 명령을 실행할 때 해당 명령의 소유자나 지정한 사용자 권한으로 실행되도록 함.
* **목적**:

  1. **보안 강화**: root 권한으로 모든 걸 실행하면 보안상 위험.
  2. **권한 최소화(Least Privilege)**: 필요한 권한만 부여해서 실행.
  3. **멀티 유저 환경 지원**: 각 사용자 환경에서 독립적으로 실행.

---

## 2. 리눅스에서 Run-as User를 구현하는 방법

### (1) `su` 명령

```bash
su - username
```

* `switch user`의 약자.
* 지정한 사용자의 로그인 환경(shell 포함)으로 전환.
* 예:

  ```bash
  su - alice
  ```

---

### (2) `sudo -u` 옵션

```bash
sudo -u username command
```

* root가 아닌 다른 사용자 권한으로 명령 실행.
* 예:

  ```bash
  sudo -u www-data ls /var/www
  ```

---

### (3) `runuser`

```bash
runuser -u username command
```

* `su`의 대체 명령.
* PAM(Pluggable Authentication Module) 인증 없이도 다른 사용자로 명령 실행 가능.

---

### (4) Docker 같은 환경에서의 `--user` 또는 `-u`

```bash
docker run -u nobody busybox id
```

* 컨테이너 내부에서 지정된 사용자 권한으로 프로세스 실행.
* 호스트의 리눅스 권한 모델을 컨테이너 내부에서도 동일하게 적용.

---

### (5) 시스템 서비스에서의 run-as

* `systemd` 서비스 유닛 파일에서:

  ```ini
  [Service]
  User=nobody
  Group=nogroup
  ExecStart=/usr/bin/myapp
  ```
* 서비스 프로세스가 root 권한이 아닌 `nobody` 권한으로 실행됨.

---

## 3. Run-as User의 동작 원리

리눅스 커널은 프로세스를 UID/GID(그룹 ID)로 식별합니다:

* **UID=0** → root
* **UID=1000 이상** → 일반 사용자
* run-as user 실행 시, **프로세스의 UID가 해당 사용자 UID로 바뀜**
* 따라서 접근 권한, 파일 권한 등이 해당 사용자 기준으로 적용됨.

---

## 4. 보안 측면

* **root → 일반 사용자로 실행**: 보안상 가장 많이 쓰이는 패턴.
* 예: 웹 서버(Nginx, Apache) 초기 실행 시 root로 포트(80) 바인딩 → 이후 `nobody` 같은 계정으로 권한 다운그레이드.

---

## 5. 예시: run-as user로 간단 테스트

```bash
sudo useradd testuser
sudo -u testuser touch /tmp/testfile
ls -l /tmp/testfile
```

출력:

```
-rw-r--r-- 1 testuser testuser 0 Sep 17 12:00 /tmp/testfile
```

→ 파일 소유자가 `testuser`로 생성됨.

