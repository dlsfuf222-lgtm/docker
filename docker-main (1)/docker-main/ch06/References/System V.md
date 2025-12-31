

# 🏛️ System V

오늘날 우리가 사용하는 리눅스, BSD, macOS 같은 유닉스 계열 운영체제는 모두 **하나의 공통된 역사**에서 비롯됩니다. 그 역사 속 핵심 플레이어 중 하나가 바로 **System V(시스템 파이브)** 입니다.


---

## 🧭 System V란 무엇인가?

System V는 1983년 **AT\&T 벨 연구소(Bell Labs)** 가 상업화 목적으로 발표한 **UNIX 운영체제 표준 계열**입니다.

* 📜 **UNIX Version 7** → 1979년까지의 전통 유닉스
* 🏛️ **UNIX System III** → 1982년, 상업화의 첫 시도
* 🚀 **UNIX System V** → 1983년 등장, 기업용 UNIX 표준 확립

이후 **System V Release 4 (SVR4)** 는 유닉스 역사상 가장 영향력 있는 버전으로 평가받습니다.

---

## 🗂️ System V의 핵심 특징

System V는 당시로선 혁신적이었던 여러 기능들을 도입했습니다.

| 기능 🛠️                   | 설명                               | 현대 OS 영향 🌍             |
| ------------------------ | -------------------------------- | ----------------------- |
| **System V IPC**         | 메시지 큐, 세마포어, 공유 메모리 지원           | 리눅스 IPC의 핵심 유산          |
| **init 프로세스**            | /etc/inittab 기반 런레벨(runlevel) 도입 | SysV init → systemd로 진화 |
| **System V 파일시스템(S5FS)** | 계층적 파일시스템, 장치 파일 지원              | ext 계열, UFS 설계에 영향      |
| **패키지 관리(pkgadd)**       | 초창기 UNIX 소프트웨어 배포 시스템            | RPM, DEB 계열 패키지 관리의 전신  |
| **터미널 인터페이스(termios)**   | 터미널 I/O 관리 표준화                   | POSIX TTY, pty 시스템 기반   |

---

## 🌲 BSD vs System V: 유닉스의 두 줄기

1980년대 UNIX 생태계는 크게 두 계열로 나뉘었습니다:

| 항목      | System V (AT\&T)     | BSD (Berkeley)           |
| ------- | -------------------- | ------------------------ |
| 개발 주체   | AT\&T 벨 연구소          | UC Berkeley              |
| 철학      | 상업적, 표준화 지향          | 학술적, 실험적, 오픈소스 지향        |
| 네트워크 스택 | 초기엔 미흡, 후에 TCP/IP 통합 | TCP/IP 스택 원조             |
| 주요 기능   | SysV IPC, SysV init  | 소켓 API, 가상 메모리 확장        |
| 대표 OS   | Solaris, AIX, HP-UX  | FreeBSD, NetBSD, OpenBSD |

리눅스는 사실상 **System V + BSD 기능을 모두 흡수**한 하이브리드 계열입니다.

---

## 🏗️ System V Release 4 (SVR4): 정점의 순간

1989년 발표된 **SVR4**는 System V 계열의 결정판이자 유닉스 역사상 가장 큰 통합 프로젝트였습니다.

* 🧩 **System V + BSD + Xenix + SunOS** 기능 통합
* 🌐 TCP/IP 네트워크 스택 본격 내장
* 📜 POSIX 표준 호환성 강화
* 🪟 X 윈도 시스템 지원

SVR4는 이후 **Solaris**로 이어졌고, 기업용 UNIX의 사실상 표준이 되었습니다.

---

## 🐧 리눅스와의 관계

리눅스는 초창기부터 **System V의 여러 설계 철학과 API**를 흡수했습니다.

* **SysV IPC**: 메시지 큐, 세마포어, 공유 메모리
* **SysV init 스크립트**: `/etc/init.d/` → 오늘날 systemd 이전까지 사용
* **터미널 인터페이스(termios)**: POSIX TTY 계열로 계승
* **런레벨(runlevel)**: 부팅/셧다운 단계 관리

---

## 🛠️ 현대 리눅스에서 남아 있는 System V 흔적들

| 요소          | 예시 명령어/파일                 | 현재 상황                 |
| ----------- | ------------------------- | --------------------- |
| SysV init   | `/etc/inittab`, `service` | systemd로 대체 중         |
| SysV IPC    | `ipcs`, `ipcrm`           | 여전히 사용 가능             |
| SysV 메시지 큐  | `msgget`, `msgsnd`        | POSIX IPC와 병행 사용      |
| SysV 세마포어   | `semget`, `semop`         | pthread 동기화로 대체 중     |
| SysV 공유 메모리 | `shmget`, `shmat`         | POSIX shm, mmap 사용 증가 |

---

## 📦 대표 System V 기반 운영체제

* **Solaris (Sun Microsystems)** → Oracle 인수 후 Oracle Solaris로 유지
* **AIX (IBM)** → 대규모 엔터프라이즈 시스템용
* **HP-UX (Hewlett-Packard)** → 대형 서버 중심
* **SCO UNIX / Xenix (Microsoft 참여)** → 역사의 뒤안길로 사라짐

---

## 🎯 정리

* **System V = AT\&T UNIX 계열의 상업용 표준 OS**
* 리눅스는 **System V + BSD**의 기술 유산을 흡수한 하이브리드
* SysV IPC, init 스크립트, 파일시스템 구조 등은 지금도 일부 형태로 남아 있음
* 현대 리눅스는 systemd, POSIX IPC, cgroups 등으로 진화했지만, 뿌리는 여전히 System V에 있음


