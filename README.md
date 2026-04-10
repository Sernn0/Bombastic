# 💣 Bombastic (봄바스틱)

2명~10명이 폭탄을 돌리는 장기전 소셜 게임.

---

## 시작하기 전에

```bash
# 1. 저장소 클론 후 세팅 스크립트 실행 (의존성 설치 + 코드 생성 자동화)
bash setup.sh

# 2. Firebase 연결 (각자 로컬에서 1회 실행)
dart pub global activate flutterfire_cli
flutterfire configure --project=likelion-holycow
```

> `flutterfire configure` 실행 시 `lib/firebase_options.dart`가 자동 생성됩니다.
> 이 파일은 `.gitignore`에 포함되어 있으므로 **팀원 각자 로컬에서 생성**해야 합니다.

### Firebase 파일 배치

| 파일 | 위치 |
|------|------|
| `google-services.json` | `android/app/` |
| `GoogleService-Info.plist` | `ios/Runner/` |

두 파일 모두 Firebase Console → 프로젝트 설정에서 다운로드.

---

## 앱 실행

```bash
flutter run
```

---

할 일 및 논의 사항 → [`NOTES.md`](./NOTES.md)
