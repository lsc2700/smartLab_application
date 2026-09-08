import 'package:flutter_test/flutter_test.dart';
import 'package:smartlab_application/cctv_nvr.dart';

void main() {
  test('하이크비전 NVR RTSP 주소를 만든다', () {
    const nvr = CctvNvr(
      ip: '192.168.0.10:8080',
      user: 'admin',
      password: 'pw!@',
    );

    expect(nvr.host, '192.168.0.10');
    expect(
      nvr.subStreamUrl(1),
      'rtsp://admin:pw!%40@192.168.0.10:554/Streaming/Channels/102',
    );
    expect(
      nvr.mainStreamUrl(2),
      'rtsp://admin:pw!%40@192.168.0.10:554/Streaming/Channels/201',
    );
  });
}
