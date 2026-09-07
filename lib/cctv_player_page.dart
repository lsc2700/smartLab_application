import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class CctvCamera {
  const CctvCamera({
    required this.ip,
    required this.user,
    required this.password,
  });

  final String ip;
  final String user;
  final String password;

  WebUri get uri {
    final raw = ip.contains('://') ? ip : 'http://$ip';
    return WebUri(raw);
  }
}

class CctvPlayerPage extends StatelessWidget {
  const CctvPlayerPage({super.key, required this.camera});

  final CctvCamera camera;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(camera.ip, style: const TextStyle(fontSize: 16)),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: camera.uri),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          mediaPlaybackRequiresUserGesture: false,
          allowsInlineMediaPlayback: true,
          mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
          useHybridComposition: true,
          supportZoom: true,
          hardwareAcceleration: true,
        ),
        onReceivedHttpAuthRequest: (controller, challenge) async {
          if (camera.user.isEmpty) {
            return HttpAuthResponse(action: HttpAuthResponseAction.CANCEL);
          }
          return HttpAuthResponse(
            username: camera.user,
            password: camera.password,
            action: HttpAuthResponseAction.PROCEED,
            permanentPersistence: true,
          );
        },
        onReceivedServerTrustAuthRequest: (controller, challenge) async {
          return ServerTrustAuthResponse(
            action: ServerTrustAuthResponseAction.PROCEED,
          );
        },
      ),
    );
  }
}
