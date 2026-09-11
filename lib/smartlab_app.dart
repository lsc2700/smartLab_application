import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import 'cctv_bridge.dart';
import 'web_cookie_store.dart';

const smartLabUrl = 'https://smartlab-admin.co.kr';

class SmartLabApp extends StatelessWidget {
  const SmartLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'smartlab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B4F72)),
        useMaterial3: true,
      ),
      home: const SmartLabWebViewPage(),
    );
  }
}

class SmartLabWebViewPage extends StatefulWidget {
  const SmartLabWebViewPage({super.key});

  @override
  State<SmartLabWebViewPage> createState() => _SmartLabWebViewPageState();
}

class _SmartLabWebViewPageState extends State<SmartLabWebViewPage>
    with WidgetsBindingObserver {
  InAppWebViewController? _controller;
  double _progress = 0;
  bool _loadedOnce = false;
  bool _cookiesReady = false;

  InAppWebViewSettings get _settings => InAppWebViewSettings(
        javaScriptEnabled: true,
        domStorageEnabled: true,
        databaseEnabled: true,
        incognito: false,
        cacheEnabled: true,
        cacheMode: CacheMode.LOAD_DEFAULT,
        javaScriptCanOpenWindowsAutomatically: true,
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        iframeAllow: 'camera; microphone; geolocation',
        iframeAllowFullscreen: true,
        mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
        useHybridComposition: true,
        supportZoom: false,
        builtInZoomControls: false,
        displayZoomControls: false,
        textZoom: 100,
        thirdPartyCookiesEnabled: true,
        sharedCookiesEnabled: true,
        geolocationEnabled: true,
        allowFileAccess: true,
        allowContentAccess: true,
        useOnDownloadStart: true,
        transparentBackground: false,
        hardwareAcceleration: true,
        preferredContentMode: UserPreferredContentMode.MOBILE,
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _restoreCookies();
  }

  Future<void> _restoreCookies() async {
    await WebCookieStore.restore();
    if (mounted) {
      setState(() => _cookiesReady = true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      WebCookieStore.save();
    }
  }

  Future<bool> _handleBack() async {
    final controller = _controller;
    if (controller != null && await controller.canGoBack()) {
      await controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        if (await _handleBack()) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              if (_cookiesReady)
                InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(smartLabUrl)),
                  initialSettings: _settings,
                  onWebViewCreated: (controller) {
                    _controller = controller;
                    controller.addJavaScriptHandler(
                      handlerName: 'cctvInfoHandler',
                      callback: (args) async {
                        await handleCctvInfo(context, args);
                        return {'ok': true};
                      },
                    );
                  },
                  onLoadStop: (controller, url) {
                    WebCookieStore.save();
                    if (mounted) {
                      setState(() {
                        _loadedOnce = true;
                        _progress = 1;
                      });
                    }
                  },
                  onProgressChanged: (controller, progress) {
                    if (mounted) {
                      setState(() => _progress = progress / 100);
                    }
                  },
                  onPermissionRequest: (controller, request) async {
                    return PermissionResponse(
                      resources: request.resources,
                      action: PermissionResponseAction.GRANT,
                    );
                  },
                  onGeolocationPermissionsShowPrompt: (controller, origin) async {
                    return GeolocationPermissionShowPromptResponse(
                      origin: origin,
                      allow: true,
                      retain: true,
                    );
                  },
                  shouldOverrideUrlLoading: (controller, action) async {
                    final uri = action.request.url;
                    if (uri == null) {
                      return NavigationActionPolicy.ALLOW;
                    }
                    final scheme = uri.scheme;
                    if (scheme == 'http' || scheme == 'https') {
                      return NavigationActionPolicy.ALLOW;
                    }
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                    return NavigationActionPolicy.CANCEL;
                  },
                  onReceivedServerTrustAuthRequest: (controller, challenge) async {
                    return ServerTrustAuthResponse(
                      action: ServerTrustAuthResponseAction.PROCEED,
                    );
                  },
                  onCreateWindow: (controller, request) async {
                    final url = request.request.url;
                    if (url != null) {
                      await controller.loadUrl(urlRequest: URLRequest(url: url));
                    }
                    return false;
                  },
                ),
              if (!_cookiesReady || _progress < 1)
                LinearProgressIndicator(
                  value: !_cookiesReady || _progress == 0 ? null : _progress,
                  minHeight: 2,
                  color: const Color(0xFF1B4F72),
                  backgroundColor: Colors.transparent,
                ),
              if (!_loadedOnce)
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('smartlab'),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
