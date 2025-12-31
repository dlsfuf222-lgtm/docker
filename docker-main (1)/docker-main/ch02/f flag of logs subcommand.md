`docker logs -f` 에서 **`-f` 플래그**는 **follow**를 의미합니다.
즉, 컨테이너의 로그를 **실시간 스트리밍 모드**로 계속 출력하게 해줍니다.

---

### 동작 방식

* `-f` 옵션이 없으면:
  컨테이너에서 지금까지 쌓인 로그를 한 번만 출력하고 종료됩니다.
* `-f` 옵션이 있으면:
  로그가 추가될 때마다 터미널에 **스트리밍** 형태로 새 로그를 계속 표시합니다.
  마치 `tail -f` 명령과 비슷하게 동작합니다.

```bash
# 지금까지의 로그만 출력
docker logs backoff-detector

# 실시간 로그 모니터링 (Ctrl+C로 종료)
docker logs -f backoff-detector
```

---

### 자주 쓰는 조합

```bash
# 가장 최근 로그 100줄만 실시간으로 보기
docker logs -f --tail 100 backoff-detector

# 로그에 타임스탬프 추가
docker logs -f --timestamps backoff-detector
```

