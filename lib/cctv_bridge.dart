import 'package:flutter/material.dart';

import 'cctv_nvr.dart';
import 'cctv_player_page.dart';

Future<void> handleCctvInfo(BuildContext context, List<dynamic> args) async {
  final nvrs = _normalizeNvrs(args);
  if (nvrs.isEmpty || !context.mounted) {
    return;
  }

  if (nvrs.length == 1) {
    await _openPlayer(context, nvrs.first);
    return;
  }

  if (!context.mounted) {
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'CCTV',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            ...nvrs.map((nvr) {
              return ListTile(
                leading: const Icon(Icons.videocam_outlined),
                title: Text(nvr.ip),
                subtitle: nvr.user.isEmpty ? null : Text(nvr.user),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _openPlayer(context, nvr);
                },
              );
            }),
          ],
        ),
      );
    },
  );
}

Future<void> _openPlayer(BuildContext context, CctvNvr nvr) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => CctvPlayerPage(nvr: nvr),
    ),
  );
}

List<CctvNvr> _normalizeNvrs(List<dynamic> args) {
  if (args.isEmpty) {
    return [];
  }

  final raw = args.first;
  final items = raw is List ? raw : [raw];
  return items.whereType<Map>().map((item) {
    return CctvNvr(
      ip: '${item['ipAddress'] ?? ''}',
      user: '${item['cctvUser'] ?? item['id'] ?? ''}',
      password: '${item['cctvPassword'] ?? item['pw'] ?? ''}',
    );
  }).where((item) => item.ip.isNotEmpty).toList();
}
