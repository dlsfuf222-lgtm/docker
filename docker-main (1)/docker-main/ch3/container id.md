Docker 이미지의 **IMAGE ID**는 여러 방법으로 확인할 수 있는데, 가장 대표적인 방법은 `docker images` 명령어를 사용하는 것입니다. 

---

## **1. 로컬 이미지 ID 확인 (docker images)**

```bash
docker images
```

예시 출력:

```
REPOSITORY                 TAG       IMAGE ID       CREATED          SIZE
intheeast0305/ch2_mailer    v2        a1b2c3d4e5f6   2 hours ago      120MB
intheeast0305/ch2_mailer    latest    a1b2c3d4e5f6   2 hours ago      120MB
ubuntu                      20.04     3b418d7b466c   3 days ago       72.9MB
```

* **IMAGE ID** 열에 나오는 값이 바로 해당 이미지의 고유 ID입니다.
* 같은 이미지(내용 동일)에 여러 태그를 붙이면 ID는 동일하게 나옵니다.

---

## **2. 특정 이미지에 대해 상세 정보 보기**

```bash
docker inspect <이미지이름>:<태그>
```

예:

```bash
docker inspect intheeast0305/ch2_mailer:v2
```

출력 JSON 안의 `Id` 항목에서 IMAGE ID를 확인할 수 있습니다:

```
"Id": "sha256:a1b2c3d4e5f6..."
```

---

## **3. Digest와의 차이**

| 구분        | IMAGE ID              | Manifest Digest                 |
| --------- | --------------------- | ------------------------------- |
| 로컬 고유 식별자 | 로컬 시스템에서 이미지 구분용      | 레지스트리(Docker Hub 등)에서의 고유 해시    |
| 형식        | 짧게 표시: `a1b2c3d4e5f6` | 길게 표시: `sha256:abcdef123456...` |
| 생성 시점     | 로컬에서 이미지 빌드/다운로드할 때   | 이미지 Push 시 Manifest 생성 후 계산됨    |

---

## **4. 사용 예시: 태그 없는 이미지에 태그 부여**

빌드 후 태그 없는 이미지에 새 태그를 붙일 때 IMAGE ID가 필요합니다:

```bash
docker tag a1b2c3d4e5f6 intheeast0305/ch2_mailer:v1
```

