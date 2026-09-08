/// 웹 등록 화면 기준: 하이크비전 DS-7616NXI-K2/16P NVR (16채널)
const hikvisionChannelCount = 16;

class CctvNvr {
  const CctvNvr({
    required this.ip,
    required this.user,
    required this.password,
  });

  final String ip;
  final String user;
  final String password;

  String get host {
    var raw = ip.trim();
    raw = raw.replaceFirst(RegExp(r'^https?://'), '');
    raw = raw.split('/').first;
    return raw.split(':').first;
  }

  /// 모바일 그리드용 서브스트림 (102, 202, ...)
  String subStreamUrl(int channel) => _rtspUrl(channel, sub: true);

  /// 전체화면용 메인스트림 (101, 201, ...)
  String mainStreamUrl(int channel) => _rtspUrl(channel, sub: false);

  String _rtspUrl(int channel, {required bool sub}) {
    final streamId = channel * 100 + (sub ? 2 : 1);
    final user = Uri.encodeComponent(this.user);
    final password = Uri.encodeComponent(this.password);
    return 'rtsp://$user:$password@$host:554/Streaming/Channels/$streamId';
  }
}
