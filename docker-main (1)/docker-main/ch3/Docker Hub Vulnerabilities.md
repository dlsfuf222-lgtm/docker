Docker Hub의 **Vulnerabilities** 항목은
**Docker Hub가 제공하는 보안 취약점 스캐닝 결과**를 의미합니다.
즉, 해당 이미지 안에 포함된 OS 패키지나 라이브러리에서 알려진 보안 취약점(CVE)이 있는지 분석해 보여주는 기능입니다.

---

## 1. Vulnerabilities의 의미

* Docker Hub는 **이미지의 레이어**를 분석해서 이미지 내부에 포함된 소프트웨어 목록을 추출합니다.
* 그런 다음, 공개된 **취약점 데이터베이스(CVE: Common Vulnerabilities and Exposures)** 와 대조해 보안 이슈가 있는지 알려줍니다.
* 여기서 발견되는 취약점이 바로 **Vulnerabilities**에 표시됩니다.

예를 들어, `ubuntu:20.04` 이미지를 스캔했는데 `libssl1.1` 패키지에 CVE가 발견되면:

```
CVE-2023-4567  HIGH  OpenSSL 패키지에서 임의 코드 실행 가능성
```

이런 식으로 Docker Hub UI에 나타납니다.

---

## 2. 취약점의 심각도(Severity)

Docker Hub는 취약점을 보통 다음 4단계로 구분합니다.

| 심각도          | 설명                               |
| ------------ | -------------------------------- |
| **Critical** | 즉시 패치하지 않으면 심각한 피해를 유발할 수 있는 취약점 |
| **High**     | 공격자가 쉽게 악용할 수 있는 높은 위험도 취약점      |
| **Medium**   | 특정 조건에서만 악용 가능한 보통 수준의 취약점       |
| **Low**      | 거의 영향이 없거나 악용이 어려운 취약점           |

---

## 3. 스캐닝 기술

* Docker Hub의 **Vulnerability Scanning**은 과거에는 *Snyk* 엔진을 사용했고, 현재는 Docker 자체 스캐닝 엔진(Docker Scout) 또는 Snyk를 선택적으로 쓸 수 있습니다.
* 대표적인 취약점 DB 소스:

  * NVD (National Vulnerability Database)
  * Debian, Ubuntu, Alpine Security Tracker
  * Red Hat Security Data 등

---

## 4. 실제 활용

* 이미지 빌드 파이프라인에 CI/CD 스캐닝을 통합해 **배포 전 자동 취약점 검사**를 수행할 수 있습니다.
* 예: GitHub Actions + Docker Hub + Snyk 통합
* 취약점이 발견되면 Docker Hub UI에서 **업데이트된 패키지 버전**이나 **패치 권고**를 바로 확인 가능

---

## 5. 정리

**Docker Hub Vulnerabilities = 이미지 안에 있는 OS·라이브러리 패키지의 보안 취약점 스캐닝 결과**
→ 운영 환경에서는 반드시 모니터링하고, 필요 시 **패치된 베이스 이미지**로 재빌드하는 것이 중요합니다.

---
