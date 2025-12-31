

# 🐧 리눅스 IPC Namespace: 프로세스 간 통신 격리의 핵심 🌐

리눅스 컨테이너 기술(Docker, Kubernetes)의 핵심은 바로 **Namespace**입니다. 이 중에서도 **IPC Namespace**는 프로세스 간 통신 리소스를 **격리**하여 컨테이너마다 독립된 IPC 환경을 제공하는 필수 요소입니다.


---

## 🧭 IPC Namespace란?

**IPC Namespace**는 리눅스의 Namespace 기능 중 하나로, 다음과 같은 IPC 리소스를 **프로세스 그룹 단위로 격리**합니다.

* 📨 **System V IPC**: 메시지 큐(Message Queues), 세마포어(Semaphores), 공유 메모리(Shared Memory)
* 📬 **POSIX Message Queues**: `/dev/mqueue` 경로를 통해 접근

즉, IPC Namespace를 사용하면 **하나의 컨테이너에서 만든 메시지 큐나 공유 메모리가 다른 컨테이너에선 보이지 않게** 됩니다.

---

## ⚙️ 내부 동작 원리

리눅스 커널은 IPC 객체(예: 메시지 큐, 세마포어)를 생성할 때 **Namespace ID**를 함께 관리합니다.

1. 프로세스가 새로운 IPC Namespace를 생성하면 → 커널은 고유 ID 부여
2. 해당 프로세스와 그 자식 프로세스는 같은 Namespace 내 IPC 리소스만 접근 가능
3. 다른 Namespace에선 해당 리소스를 전혀 볼 수 없음

→ 결과적으로, 컨테이너마다 **독립된 IPC 공간**이 생깁니다.

---


## 🛠️ 실습 예제: IPC Namespace 생성

리눅스에서는 `unshare` 명령어를 사용하여 새 IPC Namespace를 쉽게 생성할 수 있습니다.

```bash
# 새로운 IPC Namespace 생성
sudo unshare --ipc --fork --pid bash

# IPC 리소스 확인
ipcs -q   # 메시지 큐
ipcs -m   # 공유 메모리
ipcs -s   # 세마포어
```

* 🐳 Docker에서는 `--ipc` 옵션을 활용

```bash
docker run -it --rm --ipc=private ubuntu bash
```

* `--ipc=host` : 호스트와 IPC 공간 공유
* `--ipc=private` : 독립된 IPC Namespace 사용 (기본값)

---

## 📦 컨테이너 환경에서의 IPC Namespace

* Kubernetes Pod 내 컨테이너들은 기본적으로 **동일한 IPC Namespace**를 공유 → 컨테이너 간 메시지 큐·세마포어 사용 가능
* Pod 간 IPC 격리를 위해선 **별도 Namespace** 필요

이 방식 덕분에 컨테이너들은 **마치 독립된 OS처럼 보이면서도**, 실제 커널을 공유하여 가벼운 가상화가 가능합니다.

---

## 🛡️ 보안 & 성능 고려 사항

| 이슈 ⚠️     | 설명               | 해결책 💡              |
| --------- | ---------------- | ------------------- |
| 데이터 유출 위험 | 호스트 IPC와 공유 시 위험 | `--ipc=private` 사용  |
| 성능 저하     | IPC 객체 접근 시 오버헤드 | 공유 메모리 + 세마포어 조합 사용 |
| 컨테이너 간 격리 | 잘못된 설정 시 격리 실패   | 올바른 Namespace 정책 설정 |

---

## 🏗️ 활용 예시

1. **고성능 애플리케이션**

   * 공유 메모리 + 세마포어 기반 IPC 사용
   * 컨테이너별 격리로 보안 확보

2. **멀티 컨테이너 시스템**

   * Pod 단위 IPC 공유 → 컨테이너 간 빠른 데이터 교환

3. **보안 민감 환경**

   * 완전 독립 IPC Namespace → 다른 컨테이너 접근 차단

---

## 🎯 정리

* 🏠 IPC Namespace = **컨테이너별 독립 IPC 공간**
* 🔒 보안 강화 + 🏎️ 성능 제어 가능
* 🐳 Docker, Kubernetes에서 필수적으로 사용됨

| 요구사항         | 설정 옵션            | 설명              |
| ------------ | ---------------- | --------------- |
| 성능 + 보안 균형   | `--ipc=private`  | 기본값, 컨테이너별 격리   |
| 고속 Pod 내부 통신 | 공유 IPC Namespace | Pod 내 컨테이너끼리 통신 |
| 디버깅 목적       | `--ipc=host`     | 호스트와 IPC 공간 공유  |


