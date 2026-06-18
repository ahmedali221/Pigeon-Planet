import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_colors.dart';
import '../../model/pigeon_model.dart';
import '../../viewmodel/pigeon_id_bloc.dart';
import '../widgets/pigeon_id_shared_widgets.dart';
import 'pigeon_id_card_page.dart';

class PigeonIdPreviewPage extends StatefulWidget {
  const PigeonIdPreviewPage({super.key});

  @override
  State<PigeonIdPreviewPage> createState() => _PigeonIdPreviewPageState();
}

class _PigeonIdPreviewPageState extends State<PigeonIdPreviewPage> {
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;

  @override
  void initState() {
    super.initState();
    final path = context.read<PigeonIdBloc>().state.videoPath;
    if (path != null) {
      _videoController = VideoPlayerController.file(File(path))
        ..initialize().then((_) {
          if (mounted) setState(() => _videoInitialized = true);
        });
      _videoController!.addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    context.read<PigeonIdBloc>().add(const PigeonIdSubmitted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PigeonIdBloc, PigeonIdState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status &&
          (curr.status == PigeonIdStatus.submitted ||
              curr.status == PigeonIdStatus.updated),
      listener: (context, state) {
        final bloc = context.read<PigeonIdBloc>();
        if (bloc.onBirdSaved != null && state.savedBird != null) {
          bloc.onBirdSaved!(state.savedBird!);
          return;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: bloc,
              child: const PigeonIdCardPage(),
            ),
          ),
        );
      },
      builder: (context, state) {
        final isMale = state.gender == PigeonGender.male;

        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'مراجعة البيانات',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            actions: [
              IconButton(
                icon:
                    const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: Column(
            children: [
              PigeonStepHeader(
                  current: 4, total: 4, label: 'المراجعة النهائية'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Basic info card ──────────────────────────────
                      _SectionCard(
                        title: 'البيانات الأساسية',
                        icon: Icons.info_outline_rounded,
                        child: Column(
                          children: [
                            _PreviewRow(
                                label: 'رقم الحلقة',
                                value: state.ringNumber),
                            const Divider(height: 20),
                            _PreviewRow(
                                label: 'السلالة', value: state.breed),
                            const Divider(height: 20),
                            _PreviewRow(
                              label: 'الجنس',
                              value: isMale ? 'ذكر 🔵' : 'أنثى 🔴',
                              valueColor: isMale
                                  ? AppColors.blue
                                  : AppColors.red,
                            ),
                            if (state.hatchDate != null) ...[
                              const Divider(height: 20),
                              _PreviewRow(
                                label: 'تاريخ الفقس',
                                value:
                                    '${state.hatchDate!.day}/${state.hatchDate!.month}/${state.hatchDate!.year}',
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Photos card ──────────────────────────────────
                      _SectionCard(
                        title: 'الصور (${state.photoPaths.length})',
                        icon: Icons.photo_library_rounded,
                        trailing: state.photoPaths.length >= 4
                            ? _CheckBadge(ok: true)
                            : _CheckBadge(ok: false),
                        child: SizedBox(
                          height: 90,
                          child: state.photoPaths.isEmpty
                              ? const Center(
                                  child: Text('لا توجد صور',
                                      style: TextStyle(
                                          color: AppColors.textHint)),
                                )
                              : ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: state.photoPaths.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(width: 8),
                                  itemBuilder: (_, i) => ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(10),
                                    child: state.photoPaths[i].startsWith('http')
                                        ? Image.network(
                                            state.photoPaths[i],
                                            width: 90,
                                            height: 90,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(state.photoPaths[i]),
                                            width: 90,
                                            height: 90,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Video card ───────────────────────────────────
                      _SectionCard(
                        title: 'فيديو زاجل',
                        icon: Icons.videocam_rounded,
                        trailing:
                            _CheckBadge(ok: state.videoPath != null),
                        child: state.videoPath != null && _videoInitialized
                            ? Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: AspectRatio(
                                      aspectRatio: _videoController!
                                          .value.aspectRatio,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          VideoPlayer(_videoController!),
                                          GestureDetector(
                                            onTap: () {
                                              _videoController!.value.isPlaying
                                                  ? _videoController!.pause()
                                                  : _videoController!.play();
                                            },
                                            child: AnimatedOpacity(
                                              opacity: _videoController!
                                                      .value.isPlaying
                                                  ? 0.0
                                                  : 1.0,
                                              duration: const Duration(
                                                  milliseconds: 250),
                                              child: Container(
                                                width: 52,
                                                height: 52,
                                                decoration: const BoxDecoration(
                                                  color: Colors.black54,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                    Icons.play_arrow_rounded,
                                                    color: Colors.white,
                                                    size: 34),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  VideoProgressIndicator(
                                    _videoController!,
                                    allowScrubbing: true,
                                    colors: const VideoProgressColors(
                                      playedColor: AppColors.primary,
                                      bufferedColor: AppColors.primaryLight,
                                      backgroundColor: AppColors.border,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: state.videoPath != null
                                          ? AppColors.primaryLight
                                          : AppColors.redLight,
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      state.videoPath != null
                                          ? Icons.play_circle_rounded
                                          : Icons.videocam_off_rounded,
                                      color: state.videoPath != null
                                          ? AppColors.primary
                                          : AppColors.red,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      state.videoPath != null
                                          ? 'تم تسجيل فيديو زاجل بنجاح ✓'
                                          : 'لم يتم تسجيل الفيديو بعد',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: state.videoPath != null
                                            ? AppColors.textPrimary
                                            : AppColors.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),

                      // ── Race results ─────────────────────────────────
                      if (state.raceResults.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _SectionCard(
                          title:
                              'نتائج السباقات (${state.raceResults.length})',
                          icon: Icons.emoji_events_rounded,
                          child: Column(
                            children: state.raceResults
                                .map((r) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: Row(
                                        children: [
                                          const Icon(
                                              Icons.chevron_left_rounded,
                                              size: 16,
                                              color: AppColors.primary),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(r,
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    color: AppColors
                                                        .textPrimary)),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              PigeonNextButton(
                label: 'إنشاء الهوية الرقمية',
                enabled: state.isReadyToSubmit,
                onTap: () => _submit(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Local widgets ────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _PreviewRow(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _CheckBadge extends StatelessWidget {
  final bool ok;
  const _CheckBadge({required this.ok});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: ok ? AppColors.primaryLight : AppColors.redLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ok ? Icons.check_circle_rounded : Icons.error_rounded,
            size: 12,
            color: ok ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 4),
          Text(
            ok ? 'مكتمل' : 'ناقص',
            style: TextStyle(
              fontSize: 11,
              color: ok ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
