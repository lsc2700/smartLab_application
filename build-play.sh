#!/bin/zsh
set -euo pipefail

export PATH="$PATH:/Users/mac_yhj/flutter/bin"
cd "$(dirname "$0")"

if [ ! -f android/key.properties ]; then
  echo "android/key.properties 가 없습니다."
  echo "android/key.properties.example 을 복사해서 패키지 이름과 비밀번호를 넣으세요."
  exit 1
fi

flutter pub get
flutter build appbundle --release

echo ""
echo "제출할 파일:"
echo "$(pwd)/build/app/outputs/bundle/release/app-release.aab"
echo ""
echo "Play Console → 테스트 및 출시 → 프로덕션 → 앱 번들 업로드"
