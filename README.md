# KLS Music

<div align="center">
<img src="https://github.com/APP-iOS7/KLS-Music/blob/dev/assets/images/splash_logo.png" alt="KLS Music 로고" width="200"/>
<p><em>무료 유튜브 기반 음악 스트리밍 애플리케이션</em></p>
</div>

## 📝 프로젝트 동기

KLS Music은 스포티파이나 멜론과 같은 비싼 스트리밍 서비스에 대한 대안으로 만들어졌습니다. 많은 사람들이 이미 유튜브 플레이리스트로 음악을 듣고 있기 때문에, 유튜브를 음원으로 활용하는 전용 음악 플레이어 앱을 개발했습니다. 이를 통해 사용자들은 비싼 구독료 없이 좋아하는 음악을 즐길 수 있습니다.

## 🛠️ 프로젝트 구성

```
lib/
├── model/       # 인스턴스 객체 OR HIVE
├── screen/         # 애플리케이션 화면 (홈, 검색, 플레이리스트, 설정)
│   ├── HomeScreen.dart
│   ├── dopeScreen.dart
│   └── ...
├── service/        # Provider 상태관리 또는 파일 시스템 기능
├── components/     # 재사용 가능한 UI 컴포넌트
├── theme/          # 테마 설정 (라이트/다크 모드)
└── main.dart       # 애플리케이션 진입점
```

이 앱은 프로바이더 기반 상태 관리 방식을 사용하며 Hive를 통해 로컬 데이터를 관리합니다.

## 📲 설치 방법

### 사전 요구사항

- Flutter SDK (최신 버전, Flutter 3.x 이상)
- Dart SDK (3.6.0 이상)
- Flutter 확장이 설치된 Android Studio 또는 VS Code

### 설치 단계

1. 저장소 복제하기

```bash
git clone https://github.com/yourusername/kls_project.git
cd kls_project
```

2. 의존성 설치하기

```bash
flutter pub get
```

3. build_runner 실행하기 (코드 생성에 필요)

```bash
flutter pub run build_runner build
```

4. 앱 실행하기

```bash
flutter run
```

## 📱 사용 방법

1. **음악 검색**: 검색 아이콘을 탭하고 듣고 싶은 노래나 아티스트 이름을 입력합니다
2. **음악 재생**: 아무 노래나 탭하여 재생을 시작합니다
3. **플레이리스트 생성**: 즐겨 듣는 노래를 플레이리스트에 저장하여 빠르게 접근할 수 있습니다
4. **백그라운드 재생**: 앱이 백그라운드에 있어도 음악은 계속 재생됩니다
5. **다크 모드**: 설정에서 라이트 모드와 다크 모드를 전환할 수 있습니다

## 👨‍💻 개발자 정보

<table>
<tr>
    <td align="center">
    <a href="https://github.com/developer1">
        <img src="https://via.placeholder.com/100" width="100px;" alt="개발자 1"/>
        <br />
        <sub><b>김용해</b></sub>
    </a>
    <br />
    <sub>기획 & 개발</sub>
    </td>
    <td align="center">
    <a href="https://github.com/developer2">
        <img src="https://via.placeholder.com/100" width="100px;" alt="개발자 2"/>
        <br />
        <sub><b>송혁호</b></sub>
    </a>
    <br />
    <sub>개발 & 디자인</sub>
    </td>
    <td align="center">
    <a href="https://github.com/developer3">
        <img src="https://via.placeholder.com/100" width="100px;" alt="개발자 3"/>
        <br />
        <sub><b>이성훈</b></sub>
    </a>
    <br />
    <sub>개발 & 디자인</sub>
    </td>
</tr>
</table>

## 🐛 버그 및 디버그

애플리케이션 사용 중 버그나 문제가 발생하면 [이슈 트래커](https://github.com/yourusername/kls_project/issues)를 통해 제보해 주세요. 버그 리포트 제출 시 다음 사항을 포함해 주세요:

- 문제에 대한 자세한 설명
- 버그를 재현하는 단계
- 기기 정보 및 앱 버전
- 가능하면 스크린샷 첨부

## 🔄 버전 및 업데이트 정보

**현재 버전:** 1.0.0

### 기능:

- 유튜브 비디오 정보를 오디오 형식으로 변환
- 오프라인 재생을 위한 오디오 파일 로컬 저장
- 다크 모드 지원
- 백그라운드 재생 기능
- 플레이리스트 생성
- 노래 및 유튜버 검색
- 첫 실행 튜토리얼

## ⭐ UPDATE 예정 기능

- 이퀄라이저 설정
- 오디오 시각화
- Search API 무한 스크롤
- 커스텀 플레이리스트 생성 및 관리

## ❓ 자주 묻는 질문 (FAQ)

**Q: 이 앱을 사용하는 것이 합법적인가요?**
A: KLS Music은 사용자가 YouTube에서 제공하는 공개 콘텐츠에 접근할 수 있도록 합니다. 그러나 콘텐츠 이용 방식은 사용자의 책임이며, 지역 저작권법 및 YouTube 이용 약관을 준수해야 합니다.

**Q: 앱은 인터넷 연결이 필요한가요?**
A: 음악을 검색하고 다운로드하려면 인터넷 연결이 필요합니다. 다운로드된 노래는 오프라인에서 재생할 수 있습니다.

**Q: iOS에서도 이 앱을 사용할 수 있나요?**
A: 네, 이 앱은 Flutter로 개발되어 Android와 iOS 플랫폼 모두에서 작동합니다.

**Q: 백그라운드 재생은 어떻게 작동하나요?**
A: 이 앱은 JustAudioBackground 패키지를 사용하여 앱이 포그라운드에 없을 때도 연속 재생을 제공합니다.

**Q: 내 데이터가 공유되거나 수집되나요?**
A: KLS Music은 개인 데이터를 수집하거나 공유하지 않습니다. 모든 음악은 기기에 로컬로 저장됩니다.

## 📄 라이선스

이 프로젝트는 MIT 라이선스로 배포됩니다 - 자세한 내용은 LICENSE 파일을 참조하세요.

---

<div align="center">
멋쟁이사자 IOS7기 KLS Music 팀이 ❤️로 만들었습니다
</div>
