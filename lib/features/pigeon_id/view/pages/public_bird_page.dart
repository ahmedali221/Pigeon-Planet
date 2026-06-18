import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../model/pigeon_model.dart';
import '../../model/pigeon_repository.dart';

class PublicBirdPage extends StatefulWidget {
  final String publicId;

  const PublicBirdPage({super.key, required this.publicId});

  static Future<void> push(BuildContext context, String publicId) =>
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PublicBirdPage(publicId: publicId)),
      );

  @override
  State<PublicBirdPage> createState() => _PublicBirdPageState();
}

class _PublicBirdPageState extends State<PublicBirdPage> {
  PigeonModel? _bird;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result =
        await sl<PigeonRepository>().fetchPublicBird(widget.publicId);
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _error = f.message;
        _loading = false;
      }),
      (bird) => setState(() {
        _bird = bird;
        _loading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'بطاقة الطائر',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorView(message: _error!, onRetry: _load)
              : _BirdView(bird: _bird!),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 56),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 15, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bird content ──────────────────────────────────────────────────────────────

class _BirdView extends StatelessWidget {
  final PigeonModel bird;

  const _BirdView({required this.bird});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroImage(bird: bird),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IdentityCard(bird: bird),
                const SizedBox(height: 16),
                if ((bird.achievements).isNotEmpty)
                  _DetailCard(
                    icon: Icons.emoji_events_rounded,
                    title: 'الإنجازات',
                    content: bird.achievements,
                  ),
                if (bird.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _DetailCard(
                    icon: Icons.description_outlined,
                    title: 'الوصف',
                    content: bird.description,
                  ),
                ],
                const SizedBox(height: 16),
                _QrSection(bird: bird),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  final PigeonModel bird;

  const _HeroImage({required this.bird});

  @override
  Widget build(BuildContext context) {
    final url = bird.thumbnailUrl;
    return Container(
      height: 260,
      width: double.infinity,
      color: AppColors.primary.withValues(alpha: 0.08),
      child: url != null
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const _PlaceholderBird(),
            )
          : const _PlaceholderBird(),
    );
  }
}

class _PlaceholderBird extends StatelessWidget {
  const _PlaceholderBird();

  @override
  Widget build(BuildContext context) => const Center(
        child: Icon(Icons.flutter_dash, size: 80, color: AppColors.border),
      );
}

class _IdentityCard extends StatelessWidget {
  final PigeonModel bird;

  const _IdentityCard({required this.bird});

  @override
  Widget build(BuildContext context) {
    final genderColor = bird.gender == PigeonGender.female
        ? AppColors.red
        : bird.gender == PigeonGender.young
            ? AppColors.orange
            : AppColors.blue;
    final genderLabel = bird.gender.label;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  bird.name.isNotEmpty ? bird.name : bird.ringNumber,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: genderColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: genderColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  genderLabel,
                  style: TextStyle(
                      color: genderColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _Row(icon: Icons.tag_rounded, label: 'رقم الحلقة', value: bird.ringNumber),
          const SizedBox(height: 8),
          _Row(icon: Icons.pets_rounded, label: 'السلالة', value: bird.breed),
          if (bird.hatchDate != null) ...[
            const SizedBox(height: 8),
            _Row(
              icon: Icons.cake_rounded,
              label: 'تاريخ الفقس',
              value:
                  '${bird.hatchDate!.day}/${bird.hatchDate!.month}/${bird.hatchDate!.year}',
            ),
          ],
          if (bird.flyingSpeed != null) ...[
            const SizedBox(height: 8),
            _Row(
              icon: Icons.speed_rounded,
              label: 'سرعة الطيران',
              value: '${bird.flyingSpeed!.toStringAsFixed(1)} م/ث',
            ),
          ],
          if (bird.staminaAbility != StaminaAbility.good ||
              bird.staminaAbility.label.isNotEmpty) ...[
            const SizedBox(height: 8),
            _Row(
              icon: Icons.bolt_rounded,
              label: 'القدرة على التحمل',
              value: bird.staminaAbility.label,
            ),
          ],
          if ((bird.sellerNickname ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            _Row(
              icon: Icons.storefront_rounded,
              label: 'المربّي',
              value: bird.sellerNickname!,
            ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Row(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
              fontSize: 13, color: AppColors.textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _DetailCard(
      {required this.icon, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _QrSection extends StatelessWidget {
  final PigeonModel bird;

  const _QrSection({required this.bird});

  @override
  Widget build(BuildContext context) {
    final qrData = bird.qrPayloadUrl ?? bird.ringNumber;
    return Center(
      child: Column(
        children: [
          const Text(
            'رمز التحقق الرقمي',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 140,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.primary,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'هوية رقمية موثّقة — كوكب الحمام',
            style: TextStyle(fontSize: 10, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}
