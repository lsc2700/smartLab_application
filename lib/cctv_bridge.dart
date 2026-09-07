import 'package:flutter/material.dart';

import 'cctv_player_page.dart';

Future<void> handleCctvInfo(BuildContext context, List<dynamic> args) async {
  final cameras = _normalizeCameras(args);
  if (cameras.isEmpty || !context.mounted) {
    return;
  }

  if (cameras.length == 1) {
    await _openPlayer(context, cameras.first);
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
            ...cameras.map((camera) {
              return ListTile(
                leading: const Icon(Icons.videocam_outlined),
                title: Text(camera.ip),
                subtitle: camera.user.isEmpty ? null : Text(camera.user),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _openPlayer(context, camera);
                },
              );
            }),
          ],
        ),
      );
    },
  );
}

Future<void> _openPlayer(BuildContext context, CctvCamera camera) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => CctvPlayerPage(camera: camera),
    ),
  );
}

List<CctvCamera> _normalizeCameras(List<dynamic> args) {
  if (args.isEmpty) {
    return [];
  }

  final raw = args.first;
  final items = raw is List ? raw : [raw];
  return items.whereType<Map>().map((item) {
    return CctvCamera(
      ip: '${item['ipAddress'] ?? ''}',
      user: '${item['cctvUser'] ?? item['id'] ?? ''}',
      password: '${item['cctvPassword'] ?? item['pw'] ?? ''}',
    );
  }).where((item) => item.ip.isNotEmpty).toList();
}
