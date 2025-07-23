# YouTube Data API v3 설정 가이드

## 1. Google Cloud Console에서 API 키 발급

1. [Google Cloud Console](https://console.cloud.google.com/)에 접속
2. 새 프로젝트 생성 또는 기존 프로젝트 선택
3. API 및 서비스 > 라이브러리로 이동
4. "YouTube Data API v3" 검색 및 활성화
5. API 및 서비스 > 사용자 인증 정보로 이동
6. "사용자 인증 정보 만들기" > "API 키" 선택
7. 생성된 API 키 복사

## 2. .env 파일 설정

1. 프로젝트 루트 디렉토리의 `.env` 파일을 열어주세요
2. `YOUTUBE_API_KEY=your_youtube_api_key_here` 부분을 실제 API 키로 교체:
   ```
   YOUTUBE_API_KEY=AIzaSyC4E1Xxxxxxxxxxxxxxxxxxxxxxxxxxxx
   ```
3. 파일을 저장합니다

### .env 파일이 없는 경우:
`.env.example` 파일을 복사하여 `.env` 파일을 생성하세요:
```bash
cp .env.example .env
```

## 3. API 키 제한 설정 (보안)

Google Cloud Console에서 API 키 제한 설정:
- HTTP 리퍼러 제한 (웹)
- Android 앱 제한 (패키지명 및 SHA-1 지문)
- iOS 앱 제한 (번들 ID)

## 4. 할당량 관리

YouTube Data API v3 기본 할당량:
- 하루 10,000 units
- videos.list (chart=mostPopular): 1 unit per request
- 현재 구현: 10분마다 1회 호출 = 하루 144회 (144 units)

## 5. 비용

기본 할당량 내에서는 무료, 초과 시 유료

## 주의사항

- API 키를 절대 코드에 하드코딩하지 마세요
- 환경변수 또는 보안 키 관리 시스템 사용
- 프로덕션에서는 더 강력한 인증 방식 고려