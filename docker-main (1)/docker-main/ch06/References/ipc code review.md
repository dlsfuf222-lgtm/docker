
### 📜 헤더 파일 및 매크로 정의

```c
#include <stdlib.h>     // C 표준 라이브러리 (메모리 할당, 난수 등)
#include <stdio.h>      // 표준 입출력 (printf, sprintf 등)
#include <string.h>     // 문자열 처리 (memset, strncmp 등)
#include <time.h>       // 시간 관련 함수 (time)
#include <unistd.h>     // POSIX 운영체제 API (system call)
#include <sys/stat.h>   // 파일 상태 정보 (stat)
#include <sys/types.h>  // 기본 데이터 타입
#include <errno.h>      // 오류 번호 (errno)
#include <mqueue.h>     // POSIX 메시지 큐 API (mq_open, mq_send 함수등)

#define Q_NAME "/ch6_ipc"     // 메시지 큐 이름
#define MAX_SIZE 1024         // 메시지 최대 크기 (바이트)
#define M_EXIT "done"         // 종료 신호 메시지
#define SRV_FLAG "-producer"  // 프로듀서 역할을 지정하는 명령줄 플래그
```

-----

### 📝 `producer()` 함수 분석

```c
int producer()
{
    mqd_t mq;                // 메시지 큐 디스크립터 변수
    struct mq_attr attr;     // 메시지 큐 속성 구조체
    char buffer[MAX_SIZE];   // 메시지 데이터를 저장할 버퍼
    int msg, i;              // 생성된 난수와 루프 카운터 변수

    attr.mq_flags = 0;       // 큐 속성 플래그 (0: 블로킹 모드)
    attr.mq_maxmsg = 10;     // 큐가 가질 수 있는 최대 메시지 수
    attr.mq_msgsize = MAX_SIZE; // 각 메시지의 최대 크기
    attr.mq_curmsgs = 0;     // 현재 큐에 있는 메시지 수 (설정 시 무시됨)

    mq = mq_open(Q_NAME, O_CREAT | O_WRONLY, 0644, &attr);
    // 큐를 생성하거나 열고, 쓰기 전용으로 설정.
    // O_CREAT: 큐가 없으면 생성. O_WRONLY: 쓰기 전용.
    // 0644: 파일 권한 (읽기/쓰기/읽기/읽기)

    srand(time(NULL));       // 현재 시간을 기준으로 난수 생성기 시드 초기화

    i = 0;                   // 루프 카운터 초기화
    while (i < 500)          // 500번 반복
    {
        msg = rand() % 256;  // 0부터 255까지의 난수 생성
        memset(buffer, 0, MAX_SIZE); // 버퍼를 0으로 초기화
        sprintf(buffer, "%x", msg); // 난수를 16진수 문자열로 버퍼에 저장
        printf("Produced: %s\n", buffer); // 생성된 메시지를 콘솔에 출력
        fflush(stdout);          // 출력 버퍼를 즉시 비움 (콘솔에 바로 표시)
        mq_send(mq, buffer, MAX_SIZE, 0); // 버퍼의 내용을 메시지 큐로 전송
        i = i + 1;               // 카운터 증가
    }
    memset(buffer, 0, MAX_SIZE); // 버퍼를 다시 초기화
    sprintf(buffer, M_EXIT);     // 버퍼에 "done" 문자열 저장
    mq_send(mq, buffer, MAX_SIZE, 0); // 종료 신호를 큐에 전송

    mq_close(mq);            // 메시지 큐 디스크립터 닫기
    mq_unlink(Q_NAME);       // 메시지 큐 객체를 시스템에서 삭제
    return 0;                // 함수 종료
}
```

-----

### 📝 `consumer()` 함수 분석

```c
int consumer()
{
    struct mq_attr attr;     // 메시지 큐 속성 구조체
    char buffer[MAX_SIZE + 1]; // 메시지를 받을 버퍼 (널 문자를 위해 +1)
    ssize_t bytes_read;      // 수신된 바이트 크기를 저장하는 변수
    mqd_t mq = mq_open(Q_NAME, O_RDONLY); // 큐를 읽기 전용으로 열기

    if ((mqd_t)-1 == mq) {   // 큐 열기 실패 시 오류 처리
        printf("Either the producer has not been started or maybe I cannot access the same memory...\n");
        // 오류 메시지 출력
        exit(1);             // 프로그램 비정상 종료
    }
    do {                     // 최소 한 번은 실행되는 do-while 루프
        bytes_read = mq_receive(mq, buffer, MAX_SIZE, NULL);
        // 큐에서 메시지를 받음. 메시지가 없으면 기다림.
        buffer[bytes_read] = '\0'; // 문자열의 끝을 표시하는 널 문자 추가
        printf("Consumed: %s\n", buffer); // 받은 메시지를 콘솔에 출력
    } while (0 != strncmp(buffer, M_EXIT, strlen(M_EXIT)));
    // 버퍼의 내용이 "done"과 같지 않으면 루프를 계속 반복

    mq_close(mq);            // 메시지 큐 디스크립터 닫기
    return 0;                // 함수 종료
}
```

-----

### 📝 `main()` 함수 분석

```c
int main(int argc, char *argv[])
{
    if (argc < 2)            // 커맨드라인 아규먼트가 2개 미만인 경우 (프로그램 이름만)
    {
        producer();          // producer() 함수 실행
    }
    else if (argc >= 2 && 0 == strncmp(argv[1], SRV_FLAG, strlen(SRV_FLAG)))
    // 커맨드라인 아규먼트가 2개 이상이고, 두 번째 아규먼트가 "-producer"와 일치하는 경우
    {
        producer();          // producer() 함수 실행
    }
    else                     // 그 외의 모든 경우 (예: ./a.out any_arg)
    {
        consumer();          // consumer() 함수 실행
    }
    return 0;                // 프로그램 종료
}
```
