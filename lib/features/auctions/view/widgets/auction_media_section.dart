import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/constants/app_colors.dart';

class AuctionMediaSection extends StatefulWidget {
  final int currentImage;
  final bool isFavorite;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onFavorite;
  final List<String> imageUrls;
  final String? videoUrl;

  const AuctionMediaSection({
    super.key,
    required this.currentImage,
    required this.isFavorite,
    required this.onPageChanged,
    required this.onFavorite,
    this.imageUrls = const [],
    this.videoUrl,
  });

  @override
  State<AuctionMediaSection> createState() => _AuctionMediaSectionState();
}

class _AuctionMediaSectionState extends State<AuctionMediaSection> {
  VideoPlayerController? _controller;
  bool _videoLoading = false;

  List<_MediaItem> _buildItems(AppLocalizations l) {
    final photoLabels = [
      l.birdPhoto,
      l.birdWing,
      l.birdEye,
      l.ringNumberThumbnail,
    ];

    final items = <_MediaItem>[];
    for (int i = 0; i < widget.imageUrls.length && i < 4; i++) {
      final label =
          i < photoLabels.length ? photoLabels[i] : l.photoNumber(i + 1);
      items.add(
          _MediaItem(url: widget.imageUrls[i], isVideo: false, label: label));
    }
    if (widget.videoUrl != null) {
      items.add(
          _MediaItem(url: widget.videoUrl!, isVideo: true, label: l.birdVideo));
    }
    if (items.isEmpty) {
      items.add(_MediaItem(url: '', isVideo: false, label: l.birdPhoto));
    }
    return items;
  }

  int _videoIndex(List<_MediaItem> items) {
    for (int i = 0; i < items.length; i++) {
      if (items[i].isVideo) return i;
    }
    return -1;
  }

  bool _isOnVideoTab(List<_MediaItem> items) =>
      widget.currentImage == _videoIndex(items) && _videoIndex(items) != -1;

  @override
  void didUpdateWidget(AuctionMediaSection old) {
    super.didUpdateWidget(old);
    // Stop video when user swipes away to an image tab
    final l = AppLocalizations.of(context);
    final items = _buildItems(l);
    if (!_isOnVideoTab(items) && _controller != null) {
      _stopVideo();
    }
  }

  @override
  void dispose() {
    _stopVideo();
    super.dispose();
  }

  Future<void> _startVideo(String url) async {
    if (url.isEmpty || _videoLoading) return;
    setState(() => _videoLoading = true);
    try {
      final ctrl = VideoPlayerController.networkUrl(Uri.parse(url));
      await ctrl.initialize();
      ctrl.play();
      if (mounted) {
        setState(() {
          _controller = ctrl;
          _videoLoading = false;
        });
      } else {
        ctrl.dispose();
      }
    } catch (_) {
      if (mounted) setState(() => _videoLoading = false);
    }
  }

  void _stopVideo() {
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    _videoLoading = false;
  }

  void _togglePlayPause() {
    if (_controller == null) return;
    setState(() {
      _controller!.value.isPlaying
          ? _controller!.pause()
          : _controller!.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = _buildItems(l);
    final safeIndex = widget.currentImage.clamp(0, items.length - 1);
    final current = items[safeIndex];

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // ── Main viewer ──────────────────────────────────────────────────
          Stack(
            children: [
              SizedBox(
                height: 260,
                width: double.infinity,
                child: current.isVideo
                    ? _buildVideoView(current.url, l)
                    : _BirdImage(url: current.url),
              ),
              // views — top right (start in RTL)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l.zeroViews,
                          style:
                              const TextStyle(color: Colors.white, fontSize: 11)),
                      const SizedBox(width: 4),
                      const Icon(Icons.visibility_outlined,
                          color: Colors.white70, size: 13),
                    ],
                  ),
                ),
              ),
              // share + favorite — top left (end in RTL)
              Positioned(
                top: 12,
                left: 12,
                child: Row(
                  children: [
                    AuctionCircleBtn(icon: Icons.share_rounded, onTap: () {}),
                    const SizedBox(width: 8),
                    AuctionCircleBtn(
                      icon: isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      iconColor: isFavorite ? AppColors.red : null,
                      onTap: widget.onFavorite,
                    ),
                  ],
                ),
              ),
              // page indicator — bottom left (end in RTL)
              Positioned(
                bottom: 10,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${items.length} / ${safeIndex + 1}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // watermark — bottom center
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'PIGEON PLANET',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Thumbnail strip ──────────────────────────────────────────────
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final isSelected = i == safeIndex;
                final item = items[i];
                return GestureDetector(
                  onTap: () => widget.onPageChanged(i),
                  child: Container(
                    width: 52,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          item.isVideo
                              ? Container(color: Colors.black87)
                              : _BirdImage(url: item.url),
                          if (item.isVideo)
                            Container(
                              color: Colors.black.withValues(alpha: 0.4),
                              child: const Icon(Icons.play_arrow_rounded,
                                  color: Colors.white, size: 22),
                            ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2),
                              color: Colors.black.withValues(alpha: 0.55),
                              child: Text(
                                item.label,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 7),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool get isFavorite => widget.isFavorite;

  Widget _buildVideoView(String url, AppLocalizations l) {
    // Initialized and ready
    if (_controller != null && _controller!.value.isInitialized) {
      return GestureDetector(
        onTap: _togglePlayPause,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
            // play/pause overlay
            ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: _controller!,
              builder: (_, value, _) => value.isPlaying
                  ? const SizedBox.shrink()
                  : Container(
                      color: Colors.black38,
                      child: const Center(
                        child: Icon(Icons.play_circle_fill_rounded,
                            color: Colors.white, size: 64),
                      ),
                    ),
            ),
            // progress bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _controller!,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: AppColors.primary,
                  backgroundColor: Colors.white24,
                  bufferedColor: Colors.white38,
                ),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              ),
            ),
          ],
        ),
      );
    }

    // Loading
    if (_videoLoading) {
      return Container(
        color: Colors.black87,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
      );
    }

    // Idle — tap to play
    return GestureDetector(
      onTap: () => _startVideo(url),
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_circle_outline_rounded,
                  color: Colors.white70, size: 64),
              const SizedBox(height: 10),
              Text(l.tapToWatchVideo,
                  style: const TextStyle(color: Colors.white60, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Private helpers ───────────────────────────────────────────────────────────

class _MediaItem {
  final String url;
  final bool isVideo;
  final String label;
  const _MediaItem(
      {required this.url, required this.isVideo, required this.label});
}

class _BirdImage extends StatelessWidget {
  final String url;
  const _BirdImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Container(
        color: AppColors.primaryLight,
        child: const Center(
          child:
              Icon(Icons.flutter_dash, color: AppColors.primary, size: 60),
        ),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: AppColors.primaryLight,
        child: const Center(
          child: Icon(Icons.broken_image_rounded,
              color: AppColors.primary, size: 40),
        ),
      ),
      loadingBuilder: (_, child, progress) => progress == null
          ? child
          : Container(
              color: AppColors.primaryLight,
              child: const Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary),
              ),
            ),
    );
  }
}

// ── Shared button ─────────────────────────────────────────────────────────────

class AuctionCircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const AuctionCircleBtn(
      {super.key, required this.icon, required this.onTap, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
            color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon,
            color: iconColor ?? AppColors.textSecondary, size: 18),
      ),
    );
  }
}
