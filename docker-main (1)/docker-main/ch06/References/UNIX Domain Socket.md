

# 🖧 UNIX 도메인 소켓(Unix Domain Socket, UDS)

현대 리눅스·유닉스 시스템에서 **프로세스 간 통신(IPC: Inter-Process Communication)** 은 필수적이다. 이 중에서도 **UNIX 도메인 소켓(UDS)** 은 고성능·보안성·단순성을 동시에 만족시키는 핵심 기술이다. 본 문서에서는 UDS의 개념부터 내부 동작, 네트워크 소켓과의 차이, 실무 활용까지 심도 있게 다룬다.

---

## 1. 🧐 UNIX 도메인 소켓이란?

**UNIX 도메인 소켓(UDS)** 은 동일한 호스트 내부에서 실행되는 프로세스 간에 **고속 데이터 통신**을 가능하게 하는 **소켓 기반 IPC** 메커니즘이다.

* 네트워크 소켓과 유사한 API(`socket()`, `bind()`, `listen()`, `accept()`)를 사용하지만
* 데이터가 네트워크 스택을 거치지 않고 **커널 내부에서 직접 전달**됨
* 따라서 **TCP/IP 헤더 처리 없이** 매우 빠르고 효율적이다

---

## 2. 🔍 UDS와 네트워크 소켓의 차이

| 구분    | UNIX 도메인 소켓(UDS)         | 네트워크 소켓(TCP/IP)     |
| ----- | ------------------------ | ------------------- |
| 통신 범위 | 동일 호스트 내부                | 로컬 + 원격 호스트         |
| 주소 체계 | 파일 시스템 경로(`/tmp/socket`) | IP 주소 + 포트번호        |
| 속도    | 매우 빠름 (커널 내부 데이터 복사)     | 상대적으로 느림 (네트워크 스택)  |
| 보안    | 파일 권한 기반                 | 방화벽, TLS 등 별도 설정 필요 |
| 사용 사례 | DB 연결, 로컬 IPC            | 웹 서버, 원격 서비스        |

---

## 3. 🧩 UNIX 도메인 소켓의 주소 체계

UDS는 **파일 경로**를 소켓 주소로 사용한다. 예:

```bash
/tmp/myapp.sock
```

* 이 경로는 **특수한 소켓 파일**로 생성되며
* 접근 권한(`chmod`, `chown`)을 통해 클라이언트 인증도 가능

---

## 4. ⚡ 작동 원리

UDS는 크게 두 가지 유형으로 나뉜다:

1. **SOCK\_STREAM** → TCP와 유사, 연결 지향, 안정적 바이트 스트림
2. **SOCK\_DGRAM** → UDP와 유사, 비연결성, 메시지 단위 전송

통신 흐름은 다음과 같다:

1. 서버: `socket()` → `bind()` → `listen()` → `accept()`
2. 클라이언트: `socket()` → `connect()`
3. 데이터 송수신: `send()`, `recv()`

---

## 5. 🛠️ 실무 예시

### 5.1 서버 측 코드 (Python)

```python
import socket
import os

server_path = "/tmp/uds_socket"
if os.path.exists(server_path):
    os.remove(server_path)

# UDS 소켓 생성
server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
server.bind(server_path)
server.listen(1)

print("UDS 서버 대기 중...")
conn, _ = server.accept()
print("클라이언트 연결 완료")

data = conn.recv(1024)
print("수신 데이터:", data.decode())
conn.sendall(b"Hello from server")
conn.close()
```

### 5.2 클라이언트 측 코드 (Python)

```python
import socket

client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
client.connect("/tmp/uds_socket")
client.sendall(b"Hello from client")
data = client.recv(1024)
print("서버 응답:", data.decode())
client.close()
```

---

## 6. 🧠 고급 주제: 보안과 성능

* **보안**:
  소켓 파일 권한(`chmod 600 /tmp/uds_socket`)으로 접근 사용자 제한 가능
* **성능**:
  네트워크 스택을 거치지 않으므로 DB 연결(Localhost) 등에서 성능 최적화에 자주 사용

예: MySQL, PostgreSQL은 로컬 연결 시 기본적으로 UDS를 사용

---

## 7. 📦 Docker & Kubernetes 환경에서 UDS

* Docker 컨테이너 간 통신 시 **볼륨 마운트**를 통해 UDS 공유 가능
* Kubernetes에서는 **Unix Domain Socket**을 **HostPath 볼륨**으로 마운트해 Pod 간 IPC 가능

---

## 8. 🚀 결론

UNIX 도메인 소켓은 **동일 호스트 내 IPC에서 사실상 표준**으로 자리 잡았다.

* TCP/IP 대비 **빠르고 가볍고 안전**하며
* 데이터베이스, 로컬 서비스, 컨테이너 간 통신에서 널리 사용된다.

