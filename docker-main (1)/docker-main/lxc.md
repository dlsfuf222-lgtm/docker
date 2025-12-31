

# 🚀 리눅스 컨테이너 기술
클라우드 네이티브와 DevOps 시대의 핵심 기술 중 하나는 \*\*컨테이너(Container)\*\*입니다. 특히 \*\*리눅스 컨테이너(Linux Containers, LXC)\*\*는 오늘날 Docker, Kubernetes와 같은 오케스트레이션 플랫폼의 기반 기술을 제공합니다. 이번 글에서는 단순한 "컨테이너가 뭔지" 수준을 넘어, **리눅스 커널 레벨에서 컨테이너 기술이 어떻게 작동하는지**를 깊이 있게 파고듭니다.

---

## 1. 컨테이너란 무엇인가?

컨테이너는 가볍고 포터블한 실행 환경으로, **애플리케이션과 그 종속성**을 하나의 패키지로 묶어 **일관성 있는 실행 환경**을 제공합니다.

* **가상머신(VM) vs 컨테이너**

  | 항목       | 가상머신(VM)    | 컨테이너(Container) |
  | -------- | ----------- | --------------- |
  | 가상화 방식   | 하이퍼바이저 기반   | OS 레벨 가상화       |
  | 부팅 시간    | 수십 초 \~ 수 분 | 수 밀리초 \~ 수 초    |
  | OS 필요 여부 | 게스트 OS 필요   | 호스트 OS 공유       |
  | 리소스 사용량  | 무거움         | 가벼움             |
  | 배포 속도    | 느림          | 빠름              |

결국 **컨테이너는 OS 레벨에서 격리된 프로세스**이며, VM보다 훨씬 가볍고 빠릅니다.

---

## 2. 컨테이너의 핵심 리눅스 커널 기술

리눅스 컨테이너가 가능한 이유는 **리눅스 커널의 두 가지 주요 기능** 덕분입니다.

### 2.1 Namespace (네임스페이스): 격리의 핵심

네임스페이스는 커널 리소스를 가상화하여 \*\*프로세스 그룹에 독립적인 뷰(View)\*\*를 제공합니다.

* **주요 네임스페이스**

  | 네임스페이스 | 격리 대상         | 커맨드 예시                      |
  | ------ | ------------- | --------------------------- |
  | `pid`  | 프로세스 ID       | `unshare --pid --fork bash` |
  | `net`  | 네트워크 인터페이스    | `ip netns add test`         |
  | `mnt`  | 마운트 포인트       | `mount --bind`              |
  | `uts`  | 호스트명/도메인 이름   | `hostname test-container`   |
  | `ipc`  | 세마포어, 메시지 큐 등 | `ipcmk`                     |
  | `user` | 사용자 및 그룹 ID   | `unshare --user`            |

컨테이너는 이들 네임스페이스를 조합해 **마치 독립된 OS처럼 동작**합니다.

---

### 2.2 Cgroups (Control Groups): 자원 관리의 핵심

Cgroups는 CPU, 메모리, I/O, 네트워크 등의 **리소스 사용량을 제한·격리·모니터링**하는 기능을 제공합니다.

* **예시: 메모리 제한**

  ```bash
  mkdir /sys/fs/cgroup/memory/demo
  echo 100M > /sys/fs/cgroup/memory/demo/memory.limit_in_bytes
  echo $$ > /sys/fs/cgroup/memory/demo/cgroup.procs
  ```

  → 현재 프로세스의 메모리를 100MB로 제한

이를 통해 컨테이너 간 **리소스 경쟁을 제어**할 수 있습니다.

---

## 3. 현대적 컨테이너 런타임 아키텍처

Docker, containerd, CRI-O 같은 런타임들은 모두 \*\*리눅스 커널 기능(LXC)\*\*을 활용해 컨테이너를 관리합니다.

* **컨테이너 런타임 계층 구조**

  ```
  +------------------------+
  | Kubernetes / Orchestrator |
  +------------------------+
  | containerd, CRI-O (CRI)   |
  +------------------------+
  | runc (OCI Runtime)        |
  +------------------------+
  | Linux Kernel (Namespaces, Cgroups) |
  +------------------------+
  ```

* **핵심 표준**

  * **OCI (Open Container Initiative)**: 컨테이너 이미지 및 런타임 표준
  * **CRI (Container Runtime Interface)**: Kubernetes와 런타임 연동 API

---

## 4. 보안 측면: 컨테이너 vs VM

컨테이너는 커널을 공유하므로 VM보다 **격리 수준이 낮다**는 비판을 받습니다. 이를 보완하기 위해 다음 기술들이 사용됩니다.

* **Seccomp**: 시스템 콜 필터링
* **AppArmor / SELinux**: MAC(Mandatory Access Control)
* **gVisor, Kata Containers**: 경량 VM 기반 격리

특히 클라우드 환경에서는 **멀티 테넌시 보안**이 중요한 만큼, 이 기술들이 함께 사용됩니다.

---

## 5. 산업적 의미와 미래

컨테이너는 단순히 애플리케이션 실행 환경을 넘어서, **클라우드 네이티브 아키텍처**의 핵심이 되었습니다.

* **DevOps**: CI/CD 파이프라인 자동화
* **Microservices**: 서비스 단위 컨테이너화
* **Serverless**: 컨테이너 기반 FaaS(Function-as-a-Service)

앞으로는 **WebAssembly 컨테이너**, **eBPF 보안 기술**, **AI 워크로드 전용 컨테이너** 같은 형태로 진화할 것입니다.

---

## 6. 요약

| 핵심 기술           | 기능              | 활용 사례                     |
| --------------- | --------------- | ------------------------- |
| **Namespaces**  | 격리(Isolation)   | PID, NET, MNT, USER 등     |
| **Cgroups**     | 자원 관리(Resource) | CPU, 메모리, I/O 제한          |
| **OCI Runtime** | 컨테이너 표준화        | Docker, containerd, CRI-O |
| **보안 기술**       | 시스템 콜/권한 제어     | Seccomp, AppArmor, gVisor |


