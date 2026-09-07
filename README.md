# 스마트랩 앱 — Play에 올리는 법

웹 화면을 앱으로 포장한 프로젝트입니다.  
할 일은 **파일 하나 만들고, Play Console에 그 파일을 올리는 것**뿐입니다.

제출하는 파일 이름: `app-release.aab` (App Bundle)

---

## 올리기 전에 숫자 2개만 맞추기

Play Console에서 스마트랩 앱을 연 다음:

1. 화면 위에 있는 **패키지 이름** (`com.` 으로 시작)을 메모
2. **테스트 및 출시 → 프로덕션**에서 **버전 코드** 숫자를 메모  
   (예: 15)

그다음 이 프로젝트에서:

- `android/key.properties.example` 을 복사해서 `android/key.properties` 로 저장
- `applicationId=` 뒤에 메모한 패키지 이름을 넣기
- `pubspec.yaml` 의 `version: 2.0.0+200` 에서 `200` 을 **프로덕션 숫자보다 큰 수**로 바꾸기

---

## 서명 키 (처음 한 번만)

예전에 쓰던 `.jks` 파일이 있으면 `android/upload-keystore.jks` 로 넣고,  
`key.properties` 에 비밀번호만 적으면 됩니다.

없으면 Play에서 **업로드 키 재설정**을 한 뒤, 터미널에서 새 키를 만듭니다.

```bash
cd /Users/mac_yhj/GOSCA/smartlab_application/android
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

물어보는 비밀번호를 `key.properties` 의 `storePassword` / `keyPassword` 에 그대로 넣습니다.

그리고 공개 인증서만 만듭니다.

```bash
keytool -export -rfc -keystore upload-keystore.jks -alias upload -file upload_cert.pem
```

Play Console → 앱 무결성 → 앱 서명 → **업로드 키 재설정 요청**에 `upload_cert.pem` 을 올립니다.  
`.jks` 는 올리지 마세요.

---

## 제출용 파일 만들기

터미널에 이것만 입력합니다.

```bash
export PATH="$PATH:/Users/mac_yhj/flutter/bin"
cd /Users/mac_yhj/GOSCA/smartlab_application
flutter pub get
flutter build appbundle --release
```

끝나면 이 파일이 생깁니다.

`/Users/mac_yhj/GOSCA/smartlab_application/build/app/outputs/bundle/release/app-release.aab`

---

## Play Console에 제출

1. Play Console → 스마트랩 앱
2. **테스트 및 출시 → 프로덕션** (또는 내부 테스트)
3. **새 버전 만들기** / **앱 번들 업로드**
4. 위에서 만든 `app-release.aab` 를 선택
5. 출시

이게 끝입니다.
