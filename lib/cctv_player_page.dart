import 'package:flutter/material.dart';

import 'cctv_channel_tile.dart';
import 'cctv_nvr.dart';

class CctvPlayerPage extends StatefulWidget {
  const CctvPlayerPage({super.key, required this.nvr});

  final CctvNvr nvr;

  @override
  State<CctvPlayerPage> createState() => _CctvPlayerPageState();
}

class _CctvPlayerPageState extends State<CctvPlayerPage> {
  int _page = 0;
  int? _fullscreenChannel;

  int get _pageCount => (hikvisionChannelCount / 4).ceil();

  List<int> get _channels {
    final start = _page * 4 + 1;
    return [for (var i = start; i < start + 4 && i <= hikvisionChannelCount; i++) i];
  }

  @override
  Widget build(BuildContext context) {
    if (_fullscreenChannel != null) {
      final channel = _fullscreenChannel!;
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text('CH $channel'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _fullscreenChannel = null),
          ),
        ),
        body: CctvChannelTile(
          rtspUrl: widget.nvr.mainStreamUrl(channel),
          label: 'CH $channel',
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('CCTV'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              key: ValueKey('cctv-page-$_page'),
              crossAxisCount: 2,
              physics: const NeverScrollableScrollPhysics(),
              children: _channels
                  .map(
                    (channel) => CctvChannelTile(
                      key: ValueKey('grid-$_page-$channel'),
                      rtspUrl: widget.nvr.subStreamUrl(channel),
                      label: 'CH $channel',
                      onTap: () => setState(() => _fullscreenChannel = channel),
                    ),
                  )
                  .toList(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _page == 0 ? null : () => setState(() => _page -= 1),
                icon: const Icon(Icons.chevron_left, color: Colors.white),
              ),
              Text(
                '${_page + 1} / $_pageCount',
                style: const TextStyle(color: Colors.white70),
              ),
              IconButton(
                onPressed: _page >= _pageCount - 1 ? null : () => setState(() => _page += 1),
                icon: const Icon(Icons.chevron_right, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
