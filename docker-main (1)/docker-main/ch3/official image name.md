## 1. Docker 이미지 리포지토리 이름 구조


일반적인 Docker 이미지 이름 구조는 다음과 같습니다.

```
[레지스트리 주소/]네임스페이스/리포지토리:태그
```

| 구성 요소    | 의미                    | 예시                                        |
| -------- | --------------------- | ----------------------------------------- |
| 레지스트리 주소 | 디폴트는 Docker Hub, 생략 가능 | `docker.io`                               |
| 네임스페이스   | user 이름 또는 조직 이름       | `intheeast0305`, `library`                |
| 리포지토리 이름 | 이미지 이름                | `ch2_mailer`, `nginx`                     |
| 태그(Tag)  | 버전 또는 변형 옵션           | `1.0`, `stable-alpine3.21-perl`, `latest` |

---

## 2. 공식 이미지(Official Images) 특징

* `nginx`, `ubuntu`, `alpine` 같은 이미지는 **Docker Hub에서 공식 관리하는 이미지**입니다.

* 이 공식 이미지는 **네임스페이스가 `library`** 로 고정되는데, 편의상 생략됩니다.

  ```
  docker pull library/nginx:latest
  docker pull nginx:latest        # library 생략 가능
  ```

* 따라서 `nginx:stable-alpine3.21-perl`은 내부적으로는

  ```
  docker.io/library/nginx:stable-alpine3.21-perl
  ```

  이런 전체 이름을 가집니다.

---

## 3. 개인/조직 이미지와의 차이

* personal 계정이나 조직 계정에서 만든 이미지는 네임스페이스에 **계정 이름이 반드시 포함**됩니다.

  ```
  docker.io/intheeast0305/ch2_mailer:1.0
  ```
* 이유: 개인/조직 계정마다 같은 이름의 리포지토리를 만들 수 있으므로, **계정 이름이 고유 네임스페이스** 역할을 합니다.
* 반면 공식 이미지는 Docker Hub에서 전역적으로 관리되므로 `library` 네임스페이스가 공용으로 사용됩니다.

---

## 4. 태그 구조 예시

`nginx:stable-alpine3.21-perl` 태그는 다음 정보를 담고 있습니다:

* **stable** → NGINX의 안정화 릴리스 채널
* **alpine3.21** → Alpine 3.21 버전 기반 경량 리눅스 OS
* **perl** → Perl 모듈이 포함된 변형 이미지

하나의 태그에 여러 특성을 조합해 표현한 형태입니다.

---

## 5. 정리 표

| 구분     | 예시                             | 네임스페이스          | 관리 주체             |
| ------ | ------------------------------ | --------------- | ----------------- |
| 공식 이미지 | `nginx:stable-alpine3.21-perl` | `library`(생략됨)  | Docker 공식팀        |
| 개인 이미지 | `intheeast0305/ch2_mailer:1.0` | `intheeast0305` | 개인 계정 소유자         |
| 조직 이미지 | `mycompany/backend-api:2.0`    | `mycompany`     | 조직(Company) 계정 소유 |

---

즉, **공식 이미지는 `library` 네임스페이스에서 전역 관리되고**,
**개인/조직 이미지는 고유 계정 네임스페이스를 반드시 포함**한다는 게 차이입니다.

---
