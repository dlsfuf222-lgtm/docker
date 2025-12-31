Docker Desktop의 **백엔드(backend)** 란, Windows와 macOS에서 Docker를 실행하기 위해 **실제 Docker Engine과 Linux 환경이 동작하는 가상화된 영역**을 말합니다. 이 백엔드가 없으면 Windows 자체에서 바로 Docker Engine을 실행할 수 없기 때문에 필수적입니다.

---

## **백엔드의 구성 요소**

1. **WSL2(Windows Subsystem for Linux 2)** 또는 **Lightweight VM**

   * Windows에서는 리눅스 커널이 없으므로, Docker Desktop은 **WSL2를 활용해 리눅스 커널과 파일시스템을 실행**합니다.
   * Docker 명령이 실행되면 내부적으로 WSL2 VM 안에서 `dockerd`(Docker Engine 데몬)가 실행되어 컨테이너를 관리합니다.
   * 이 환경이 바로 `docker-desktop`이라는 WSL 배포본에 해당합니다.

2. **Docker Engine(dockerd) & containerd**

   * 컨테이너 생성·관리·네트워크 설정·스토리지 관리를 담당하는 핵심 서비스입니다.
   * Windows에서 실행되는 Docker CLI는 백엔드 안에 있는 이 Docker Engine과 통신해 실제 작업을 처리합니다.

3. **데이터 영역(docker-desktop-data)**

   * Docker 이미지, 볼륨, 컨테이너 데이터가 저장되는 전용 배포본입니다.
   * 이 영역은 보통 WSL2의 가상 디스크(VHDX) 파일에 저장되며, 경로는 대개

     ```
     C:\Users\<사용자>\AppData\Local\Docker\wsl\data\ext4.vhdx
     ```
   * 데이터 정리는 Docker 명령어(`docker system prune`, `docker image rm`)로만 관리해야 합니다.

---

## **동작 방식**

1. **Windows → Docker CLI**
   사용자가 `docker run`, `docker ps` 같은 명령 실행
2. **CLI → 백엔드(WSL2 VM)**
   명령이 백엔드의 `dockerd`에 전달
3. **백엔드 → 컨테이너 실행**
   실제 컨테이너 생성, 네트워크 설정, 데이터 관리 수행

즉, 백엔드는 **Windows와 Linux 컨테이너 실행 환경 사이의 브리지** 역할을 합니다.

---

## **관련 배포본과 상태**

* `docker-desktop`: Docker Engine이 실행되는 런타임 환경
* `docker-desktop-data`: 데이터(이미지, 볼륨 등)를 보관하는 전용 환경
* 둘 다 WSL2 기반이며 자동 실행/관리됩니다.

---

```
# wsl --list --verbose
NAME                   STATE     VERSION
docker-desktop-data    Running   2
docker-desktop         Running   2
```

## 컬럼 의미

* **NAME**: WSL 배포본 이름
* **STATE**: 현재 상태 (Running/Stopped)
* **VERSION**: WSL 버전 (1 또는 **2**)

여기선 두 배포본 모두 **WSL2** 위에서 **실행 중(Running)** 입니다.

---

## 두 항목의 정체와 역할

### 1) `docker-desktop`

* **Docker Engine(dockerd)와 containerd**가 돌아가는 **실제 리눅스 호스트** 역할의 배포본입니다.
* Windows에서 `docker` CLI를 쓰면, Docker Desktop이 이 배포본 내부의 `dockerd`로 요청을 포워딩합니다.
* 리눅스 쪽 소켓 경로는 `/var/run/docker.sock`이고, Windows에선 `\\.\pipe\docker_engine` 네임드 파이프를 통해 연결됩니다.
* **주의**: 여기서 임의로 패키지 설치/설정 변경은 권장되지 않습니다. Docker Desktop 업데이트 시 상태가 초기화될 수 있습니다(설정이 날아갈 수 있음).

### 2) `docker-desktop-data`

* **이미지·컨테이너·볼륨 등 Docker 데이터가 저장**되는 전용 배포본입니다.
* 실체는 Windows 파일 시스템의 **VHDX 가상 디스크**로 존재하며 기본 경로는 대개:

  ```
  C:\Users\<사용자>\AppData\Local\Docker\wsl\data\ext4.vhdx
  ```
* 탐색기에서 `\\wsl$\docker-desktop-data\` 경로로 일부를 볼 수 있지만, **직접 파일을 수정/삭제하면 데이터 손상** 위험이 있습니다. 정리는 `docker system prune`, `docker image rm`, `docker volume rm`처럼 **Docker CLI로** 하세요.

---

## 왜 둘 다 WSL **2**인가?

* Docker가 쓰는 **네임스페이스, cgroups, 유니온 FS** 등은 **리눅스 커널 기능**이 필요합니다.
* **WSL2**는 실제 리눅스 커널을 가벼운 VM 위에 올리므로, Docker가 **네이티브에 가깝게 동작**합니다(WSL1은 커널 기능이 부족해 Docker 엔진 구동 불가).

---

## 자주 쓰는 관리/점검 팁

* **상태 보기**

  ```powershell
  wsl -l -v
  ```

* **해당 배포본 셸로 진입**

  ```powershell
  wsl -d docker-desktop
  wsl -d docker-desktop-data
  ```

* **커널/디스트로 정보 확인(진입 후)**

  ```bash
  uname -r   # WSL2 커널 버전
  cat /etc/os-release
  ```

* **재시작/종료**

  ```powershell
  wsl --terminate docker-desktop
  wsl --terminate docker-desktop-data
  wsl --shutdown            # 모든 WSL 배포본 종료
  ```

  *Docker Desktop 앱이나 `docker` 명령을 다시 사용하면 자동으로 다시 올라옵니다.*

* **디스크 용량 줄이기(권장 루트)**

  * 불필요한 리소스 삭제:

    ```powershell
    docker system prune -a    # 사용 주의: 필요 이미지까지 지울 수 있음
    ```
  * 그 후 Docker Desktop에서 “Clean / Compact” 기능 사용(있을 경우)으로 VHDX 축소

* **데이터 배포본 위치 이동(고급/주의)**

  * 백업/이동은 WSL의 export/import로 가능합니다. (모든 Docker 데이터가 사라질 수 있으니 충분히 이해 후 수행)

    ```powershell
    wsl --export docker-desktop-data D:\backup\ddd.tar
    wsl --unregister docker-desktop-data
    wsl --import docker-desktop-data D:\WSL\docker-data D:\backup\ddd.tar --version 2
    ```
  * 이후 Docker Desktop을 재시작하면 새 위치를 사용합니다.

---

## 요약

* `docker-desktop` = **엔진이 돌아가는 런타임 배포본** (손대지 말 것)
* `docker-desktop-data` = **이미지/컨테이너가 들어있는 데이터 배포본** (정리는 Docker CLI로)
* 둘 다 **WSL2** 기반이며, Windows에서 Docker를 쓰기 위한 **백엔드 리눅스 환경**입니다.

---

```

PS C:\Users\inthe> wsl --list --verbose
  NAME                   STATE           VERSION
  docker-desktop-data    Running         2
  docker-desktop         Running         2

```

```
PS C:\Users\inthe> wsl -d docker-desktop
```

```

DESKTOP-R0081LK:/tmp/docker-desktop-root/run/desktop/mnt/host/c/Users/inthe# cd /
DESKTOP-R0081LK:/# ls -al
total 20488
drwxr-xr-x   20 root     root          4096 Sep  4 10:28 .
drwxr-xr-x   20 root     root          4096 Sep  4 10:28 ..
drwxr-xr-x    2 root     root          4096 Dec  3  2024 bin
drwxr-xr-x   11 root     root          3100 Sep  4 10:28 dev
-rwxr-xr-x    1 root     root      18971760 Nov 13  2024 docker-desktop-user-distro
drwxr-xr-x   20 root     root          4096 Sep  4 10:37 etc
drwxr-xr-x    2 root     root          4096 May 22  2024 home
-rwxrwxrwx    1 root     root       1928824 Mar 11  2024 init
drwxr-xr-x    8 root     root          4096 Dec  3  2024 lib
drwx------    2 root     root         16384 Dec  3  2024 lost+found
drwxr-xr-x    5 root     root          4096 May 22  2024 media
drwxr-xr-x    3 root     root          4096 Dec  3  2024 mnt
drwxr-xr-x    2 root     root          4096 May 22  2024 opt
dr-xr-xr-x  276 root     root             0 Sep  4 10:28 proc
drwx------    3 root     root          4096 Sep  4 10:32 root
drwxr-xr-x   10 root     root           240 Sep  4 10:28 run
drwxr-xr-x    2 root     root          4096 Dec  3  2024 sbin
drwxr-xr-x    2 root     root          4096 May 22  2024 srv
dr-xr-xr-x   11 root     root             0 Sep  4 10:28 sys
drwxrwxrwt    5 root     root          4096 Dec  3  2024 tmp
drwxr-xr-x    7 root     root          4096 Oct 28  2024 usr
drwxr-xr-x   12 root     root          4096 May 22  2024 var

```


```
DESKTOP-R0081LK:/tmp/docker-desktop-root/run/desktop/mnt/host/c/Users/inthe# ps -ef
PID   USER     TIME  COMMAND
    1 root      0:00 {init(docker-des} /init
    4 root      0:00 {init} plan9 --control-socket 5 --log-level 4 --server-fd 6 --pipe-fd 8 --log-truncate
   17 root      0:00 {SessionLeader} /init
   18 root      0:00 {Relay(19)} /init
   19 root      0:00 wsl-bootstrap run --base-image /c/Program Files/Docker/Docker/resources/docker-desktop.iso --cli-i
   38 root      0:00 unshare -muinpf --propagation=unchanged --kill-child /usr/local/bin/wsl-bootstrap jump
   39 root      0:00 /init
   45 root      0:00 {Relay(46)} /init
   46 root      0:00 /usr/bin/vpnkit-bridge --pid-file=/run/vpnkit-bridge.pid guest
   61 root      0:02 /init services
   76 root      0:00 /bin/sh /usr/bin/rungetty.sh
   77 root      0:00 /bin/login -f -- root
   81 root      0:00 /usr/bin/devenv-server -socket /run/guest-services/devenv-volumes.sock
   90 root      0:00 -sh
  103 root      0:00 /usr/bin/runc run --preserve-fds=3 01-docker
  115 root      0:00 /usr/libexec/docker/docker-init /usr/bin/entrypoint.sh
  121 root      0:00 {entrypoint.sh} /bin/sh /usr/bin/entrypoint.sh
  125 root      0:00 /usr/bin/lifecycle-server
  136 root      0:04 /usr/local/bin/containerd --config /etc/containerd/containerd.toml
  158 100       0:00 /sbin/rpcbind -w
  174 root      0:00 /sbin/rpc.statd
  186 root      0:00 /usr/sbin/rpc.idmapd
  187 root      0:01 /usr/local/bin/dockerd --config-file /run/config/docker/daemon.json --containerd /run/containerd/c
  447 root      0:00 {SessionLeader} /init
  448 root      0:00 {Relay(449)} /init
  449 root      0:00 -sh
  450 root      0:00 ps -ef

```


```

DESKTOP-R0081LK:/# uname -r
5.15.146.1-microsoft-standard-WSL2

```

```
DESKTOP-R0081LK:/# exit
PS C:\Users\inthe>
```
