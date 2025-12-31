Docker Hub에서 보이는 **Manifest Digest**는 사실상 해당 이미지의 **유일하고 불변(Immutable)한 ID**입니다.
다만 로컬에서 보는 **Image ID**와는 기준이 조금 다릅니다. 
---

## 1. Manifest와 Digest의 관계

* **Manifest**

  * Docker 이미지 하나를 설명하는 JSON 문서입니다.
  * 이 안에는 어떤 레이어(Layers)로 이미지가 구성됐는지, 환경 변수, 실행 명령(Entrypoint) 등이 들어 있습니다.
  * Docker Hub는 태그(tag) 하나당 이 Manifest를 갖고 있습니다.

* **Manifest Digest**

  * 이 Manifest JSON 자체를 **SHA256 해시**한 값입니다.
  * 예:

    ```
    sha256:d9184cc6e4942f88c183327eec1fe35ddb40c99b08972bea957424733ddc929e
    ```

즉, Digest = Manifest 내용을 해시한 결과 → **이미지 내용이 바뀌면 Digest도 바뀜**

---

## 2. 태그(Tag)와 Digest의 차이

| 항목        | 태그(Tag)                  | Manifest Digest                   |
| --------- | ------------------------ | --------------------------------- |
| 의미        | 사람이 붙이는 이름               | 레지스트리에서 생성한 불변 해시                 |
| 변경 가능 여부  | 새 버전으로 재지정 가능            | 이미지 내용이 바뀌지 않는 한 절대 변하지 않음        |
| 예시        | `myapp:latest`           | `sha256:d9184cc6e4942f88c1833...` |
| 운영 환경 안정성 | 낮음 (latest는 언제든 바뀔 수 있음) | 높음 (동일 Digest는 항상 동일 이미지)         |

---

## 3. Manifest Digest 확인 방법

### 로컬에서

```bash
docker pull ubuntu:20.04
docker inspect --format='{{index .RepoDigests 0}}' ubuntu:20.04
```

출력 예:

```
ubuntu@sha256:3b418d7b466c4973e39d9e7c6f08c5...
```

### Docker Hub UI에서

* 리포지토리 → 태그 탭 → 태그 클릭 → **Manifest Digest** 항목 확인 가능

---

## 4. Digest 기반으로 이미지 사용

운영 환경에서 특정 버전을 **절대 변하지 않게** 고정하려면 태그 대신 Digest를 사용합니다:

```bash
docker pull ubuntu@sha256:d9184cc6e4942f88c183327eec1fe35ddb40c99b08972bea957424733ddc929e
```

→ 태그가 나중에 바뀌어도 이 Digest는 항상 같은 이미지를 가리킵니다.

---

## 5. 정리

* **Manifest Digest = 레지스트리에서 불변의 이미지 ID**
* 태그는 사람이 편하게 쓰라고 만든 이름이고, Digest는 실제 레지스트리에서 버전을 보장하는 기준입니다.
* 프로덕션 환경에서는 Digest를 쓰는 게 **재현성(Repeatability)** 측면에서 안전합니다.

