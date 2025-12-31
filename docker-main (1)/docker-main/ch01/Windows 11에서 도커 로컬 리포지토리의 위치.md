# 🐳 Windows 11에서 Docker 로컬 이미지 저장 위치 제대로 이해하기

Docker Desktop을 쓰다 보면 “이미지들이 도대체 어디에 저장되나?”가 궁금해집니다. Windows 11 기준으로 **로컬 리포지토리(이미지 저장소) 기본 위치**와 주의할 점을 설명합니다.

---

## 📦 기본 저장 위치 요약

### 1) 레거시(네이티브 서비스가 관리하는 경우)

```
C:\ProgramData\Docker\image\overlay2
```

-   Docker가 **컨테이너 이미지 레이어(overlay2)** 를 저장하는 경로입니다.
-   `C:\ProgramData`는 **숨김 폴더**일 수 있어 탐색기에서 표시를 켜야 보여요.

### 2) Docker Desktop + WSL 2 백엔드(요즘 기본)

Docker Desktop이 WSL 2를 사용하면, 실제 데이터는 **WSL 2 가상 디스크**에 들어갑니다:

```
C:\Users\<YourUsername>\AppData\Local\Docker\wsl\data\ext4.vhdx
```

-   이 **ext4.vhdx** 파일 안에 **이미지/컨테이너/볼륨 등 모든 Docker 데이터**가 들어있습니다.
-   대부분의 최신 Docker Desktop 설치는 이 방식을 사용합니다.

> 🧠 한 줄 정리: 경로가 보이든 말든, **Docker Desktop + WSL2**라면 “진짜 저장소”는 **ext4.vhdx** 내부라고 생각하면 됩니다.

---

## 🔎 내 환경이 어떤 방식인지 확인하기

터미널(PowerShell)에서:

```
# Docker Desktop이 WSL 2 백엔드를 쓰는지 대략 확인
wsl -l -v           # Docker Desktop WSL 배포(예: docker-desktop)와 버전 2 확인

# Docker 엔진 저장 드라이버/루트 디렉터리 확인
docker info | Select-String -Pattern "Storage Driver|Docker Root Dir"

# 도커 컨텍스트 / 빌더도 체크(선택)
docker context ls
docker buildx ls
```

---

## ⚠️ 절대 하면 안 되는 것

-   **위 경로의 파일/폴더를 직접 수정·삭제 금지**  
    특히 **`ext4.vhdx`** 는 WSL2 가상 디스크이며, 임의로 건드리면 **데이터 손상** 위험이 큽니다.
-   이미지/컨테이너 정리는 반드시 **Docker 명령어**로:
-   `docker images docker rmi <이미지:태그> # 이미지 삭제 docker system prune -a # 사용하지 않는 리소스 대청소(주의)`

---

## 🧭 탐색기에서 숨김 폴더 보이게 하기

1.  탐색기 열기 → **보기(View)**
2.  **표시(Show)** → **숨김 항목(Hidden items)** 체크

---

## 💡 자주 하는 질문(Quick FAQ)

**Q. `C:\ProgramData\Docker\image\overlay2`가 비어 있는데요?**  
A. Docker Desktop이 **WSL2 백엔드**를 쓰면 실제 데이터는 **`ext4.vhdx`** 내부에만 있으며, `ProgramData` 쪽은 비어 있을 수 있어요.

**Q. `ext4.vhdx` 용량이 점점 커져요. 줄일 수 없나요?**  
A. Docker 안에서 **불필요 이미지/컨테이너/볼륨**을 정리한 뒤, WSL 배포판에서 **정리/압축** 절차를 따를 수 있습니다(WSL 디스크 옵티마이즈). 단, 정확한 순서와 안전한 절차를 꼭 확인하세요.

**Q. 이미지 백업은 어떻게 하나요?**  
A. 파일 직접 복사 대신 **공식 명령**을 사용하세요:

```
docker save -o myimage.tar <이미지:태그>
docker load -i myimage.tar
```

---

## ✅ 결론

-   Windows 11에서 Docker 데이터는 **환경에 따라**
    -   `C:\ProgramData\Docker\image\overlay2` (레거시/서비스형) **혹은**
    -   `C:\Users\<You>\AppData\Local\Docker\wsl\data\ext4.vhdx` (Docker Desktop + WSL2, **요즘 기본**)  
        에 저장됩니다.
-   **직접 편집/삭제는 금물**, 반드시 **`docker` 명령**으로 관리하세요.
-   숨김 폴더를 확인하고, 필요 시 `docker info`와 `wsl -l -v`로 현재 구성을 파악하면 끝! 🚀
