import 'package:flutter_test/flutter_test.dart';
import 'package:smartlab_application/smartlab_app.dart';

void main() {
  test('스마트랩 웹 주소가 설정되어 있다', () {
    expect(smartLabUrl, 'https://smartlab-admin.co.kr');
  });
}
