import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _cookieKey = 'smartlab_webview_cookies';
final smartLabOrigin = WebUri(smartLabCookieUrl);
const smartLabCookieUrl = 'https://smartlab-admin.co.kr';

class WebCookieStore {
  WebCookieStore._();

  static final CookieManager _cookies = CookieManager.instance();

  static Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cookieKey);
    if (raw == null || raw.isEmpty) {
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final items = (jsonDecode(raw) as List<dynamic>).whereType<Map>();
    for (final item in items) {
      final name = '${item['name'] ?? ''}';
      final value = '${item['value'] ?? ''}';
      final expiresDate = item['expiresDate'] as int?;
      if (name.isEmpty || expiresDate == null || expiresDate <= now) {
        continue;
      }
      await _cookies.setCookie(
        url: smartLabOrigin,
        name: name,
        value: value,
        domain: item['domain'] as String? ?? 'smartlab-admin.co.kr',
        path: item['path'] as String? ?? '/',
        expiresDate: expiresDate,
        isSecure: item['isSecure'] as bool? ?? true,
        isHttpOnly: item['isHttpOnly'] as bool? ?? false,
        sameSite: _sameSite(item['sameSite'] as String?),
      );
    }
  }

  static Future<void> save() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final cookies = await _cookies.getCookies(url: smartLabOrigin);
    final payload = cookies.where((cookie) {
      final expiresDate = cookie.expiresDate;
      if (expiresDate == null || expiresDate <= now) {
        return false;
      }
      if (cookie.isSessionOnly == true) {
        return false;
      }
      return true;
    }).map(
      (cookie) => {
        'name': cookie.name,
        'value': cookie.value,
        'domain': cookie.domain,
        'path': cookie.path,
        'expiresDate': cookie.expiresDate,
        'isSecure': cookie.isSecure,
        'isHttpOnly': cookie.isHttpOnly,
        'sameSite': cookie.sameSite?.toNativeValue(),
      },
    ).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cookieKey, jsonEncode(payload));
    await _cookies.flush();
  }
}

HTTPCookieSameSitePolicy? _sameSite(String? value) {
  switch (value) {
    case 'Lax':
      return HTTPCookieSameSitePolicy.LAX;
    case 'Strict':
      return HTTPCookieSameSitePolicy.STRICT;
    case 'None':
      return HTTPCookieSameSitePolicy.NONE;
    default:
      return null;
  }
}
