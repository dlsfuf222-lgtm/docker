
`docker load` 명령은 **Docker Hub 같은 레지스트리에서 직접 다운로드하지 않은 Docker 이미지**를 로컬에 불러올 때 사용합니다.

즉, **이미지가 tar 아카이브 형태로 로컬에 있거나 외부에서 전달받았을 때** 필요합니다.

아래에 자세히 정리해 드리겠습니다.

---

## 1. `docker load`가 필요한 경우

* 인터넷이 안 되는 환경에서 Docker 이미지를 **파일 형태로 전달**받았을 때
* `docker save`로 백업해 둔 이미지를 다시 복원할 때
* 사내 폐쇄망 환경에서 USB, 내부 스토리지 등을 통해 이미지 배포할 때
* 다른 서버에서 Docker Hub에 푸시하지 않고 직접 이미지 파일을 옮길 때

---

## 2. 기본 사용법

```bash
docker load -i <이미지파일.tar>
```

예:

```bash
docker load -i myapp_image.tar
```

실행하면 해당 이미지가 로컬 Docker 데몬에 로드되고, `docker images` 명령어로 확인 가능합니다.

---

## 3. 반대 명령: `docker save`

이미지를 파일로 내보낼 때는 `docker save`를 사용합니다.

```bash
docker save -o myapp_image.tar myapp:1.0
```

이렇게 만든 `myapp_image.tar` 파일을 다른 환경에서 `docker load`로 불러올 수 있습니다.

---

## 4. `docker load` vs `docker pull`

| 명령            | 소스                      | 용도                    |
| ------------- | ----------------------- | --------------------- |
| `docker pull` | Docker Hub, ECR 등 레지스트리 | 레지스트리에서 직접 다운로드       |
| `docker load` | 로컬 tar 파일               | 네트워크 없이 파일에서 이미지 불러오기 |

---

## 5. 실제 시나리오 예시

1. **서버 A** (인터넷 연결 O)

   ```bash
   docker pull ubuntu:20.04
   docker save -o ubuntu_20.04.tar ubuntu:20.04
   ```
2. `ubuntu_20.04.tar` 파일을 **서버 B**(인터넷 연결 X)로 옮김
3. **서버 B**

   ```bash
   docker load -i ubuntu_20.04.tar
   docker run -it ubuntu:20.04 /bin/bash
   ```

---

즉, `docker load`는 **도커 레지스티 없이도 도커 이미지를 로컬에 등록**해 주는 도구입니다.

