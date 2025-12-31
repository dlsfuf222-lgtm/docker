Docker 이미지에 태그(tag)를 다는 방법은 **`docker tag` 명령어** 또는 **`docker build` 시 `-t` 옵션**을 사용하면 됩니다. 
태그는 이미지의 버전이나 목적을 구분하기 위해 붙이는 이름표 같은 역할을 합니다.

아래에 태그를 지정하는 방법을 단계별로 정리해 드리겠습니다.

---

## 1. `docker tag` 명령어 사용

이미 존재하는 이미지에 새로운 태그를 붙일 때 사용합니다.

```bash
docker tag <기존이미지이름>:<기존태그> <새이름>:<새태그>
```

예시:

```bash
docker tag ubuntu:20.04 mydockerid/myubuntu:1.0
```

* `ubuntu:20.04` → 로컬에 있는 기존 이미지
* `mydockerid/myubuntu:1.0` → 새롭게 지정할 이름과 태그
* 이렇게 하면 **기존 이미지에 추가 이름표를 붙이는 것**일 뿐, 이미지 복사가 일어나지 않습니다.

---

## 2. `docker build` 시 태그 붙이기

이미지를 새로 빌드하면서 바로 태그를 붙일 수도 있습니다.

```bash
docker build -t <이미지이름>:<태그> <Dockerfile위치>
```

예시:

```bash
docker build -t mydockerid/myapp:1.0 .
```

* `-t` = tag 옵션
* `.` = 현재 디렉토리에 있는 Dockerfile을 사용

빌드 후 바로 태그가 적용된 상태로 로컬에 저장됩니다.

---

## 3. 태그 생략 시 디폴트 태그값

* 태그를 생략하면 자동으로 `latest` 태그가 붙습니다.

예시:

```bash
docker build -t mydockerid/myapp .
docker push mydockerid/myapp
```

→ 내부적으로는 `mydockerid/myapp:latest` 로 처리됩니다.

---

## 4. 다중 태그 예시

하나의 이미지에 여러 개의 태그를 붙일 수도 있습니다.

```bash
docker tag mydockerid/myapp:1.0 mydockerid/myapp:stable
docker tag mydockerid/myapp:1.0 mydockerid/myapp:prod
```

→ 동일한 이미지에 `1.0`, `stable`, `prod`라는 3개의 태그가 붙게 됩니다.

---

Docker에서는 도커 이미지를 직접 "이름 바꾸기(rename)"하는 명령은 없고, **`docker tag`** 명령어를 사용해서 새 태그를 붙인 뒤 필요하다면 기존 태그를 삭제하는 방식으로 태그를 변경합니다. 
즉, 사실상 **"복사 후 기존 태그 제거"** 방식입니다.

아래에 단계별로 정리해 드리겠습니다.

---

## 1. 새 태그 붙이기 (변경용)

```bash
docker tag <기존이미지>:<기존태그> <이미지이름>:<새태그>
```

예시:

```bash
docker tag myapp:1.0 myapp:2.0
```

* `myapp:1.0` → 기존 이미지 이름과 태그
* `myapp:2.0` → 새로 붙일 태그

이렇게 하면 **동일한 이미지에 1.0, 2.0 두 개의 태그가 공존**하게 됩니다.

---

## 2. 기존 태그 삭제 (선택 사항)

기존 태그를 더 이상 사용하지 않을 경우 삭제합니다:

```bash
docker rmi <이미지이름>:<기존태그>
```

예시:

```bash
docker rmi myapp:1.0
```

> **주의**: 태그를 지운다고 해서 이미지 자체가 바로 사라지는 건 아닙니다.
> 해당 이미지에 걸린 모든 태그가 제거될 때에만 실제 이미지 레이어가 삭제됩니다.

---

## 3. 태그 변경 한 번에 정리

예를 들어 기존 태그 `1.0`을 `2.0`으로 바꾸려면:

```bash
docker tag myapp:1.0 myapp:2.0
docker rmi myapp:1.0
```

이 과정을 거치면 이제 `myapp:2.0`만 남게 됩니다.

---

## 4. 빌드 시 바로 새로운 태그 부여

이미지를 새로 빌드하는 경우는 `-t` 옵션을 사용해 바로 태그를 붙이면 됩니다.

```bash
docker build -t myapp:2.0 .
```

---

### 5. 실제 예
#### intheeast0305/ch2_mailer 이미지를 업데이함(mailer.sh 파일을 수정함). 

그래서 version 2 도커이미지를 생성하기로 함.
```
$ docker build -t docker.io/intheeast0305/ch2_mailer:2.0 .
```

#### 새 도커이미지를 도커허브에 push
```
$ docker push docker.io/intheeast0305/ch2_mailer:2.0
```
#### 로컬에 intheeast0305/ch2_mailer:latest 도커이미지가 없다면 도커허브로부터 pull
```
$ docker pull intheeast0305/ch2_mailer:latest
```

#### 기존의 intheeast0305/ch2_mailer:latest 도커미지의 tag를 1.0으로 변경
```
$ docker tag intheeast0305/ch2_mailer:latest intheeast0305/ch2_mailer:1.0
```

#### 변경후, intheeast0305/ch2_mailer:1.0 도커이미지를 도커허브에 push
```
$ docker push intheeast0305/ch2_mailer:1.0
```

#### intheeast0305/ch2_mailer:2.0 도커이미지에 latest 태그 지정
```
$ docker tag intheeast0305/ch2_mailer:2.0 intheeast0305/ch2_mailer:latest
```

#### 도커허브에 intheeast0305/ch2_mailer:latest 이미지 push
```
$ docker push intheeast0305/ch2_mailer:latest
```


