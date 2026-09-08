import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class CctvChannelTile extends StatefulWidget {
  const CctvChannelTile({
    super.key,
    required this.rtspUrl,
    required this.label,
    this.onTap,
  });

  final String rtspUrl;
  final String label;
  final VoidCallback? onTap;

  @override
  State<CctvChannelTile> createState() => _CctvChannelTileState();
}

class _CctvChannelTileState extends State<CctvChannelTile> {
  late final Player _player;
  late final VideoController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    _player.stream.error.listen((message) {
      if (mounted && message.isNotEmpty) {
        setState(() => _error = message);
      }
    });
    _player.open(Media(widget.rtspUrl));
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ColoredBox(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_error == null)
              Video(
                controller: _controller,
                controls: NoVideoControls,
                fit: BoxFit.contain,
              )
            else
              const Center(
                child: Text(
                  '연결 안 됨',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                width: double.infinity,
                color: Colors.black54,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  widget.label,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
