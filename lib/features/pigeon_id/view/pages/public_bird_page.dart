import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/ppw_app_bar.dart';
import '../../../../../core/di/injection.dart';
import '../../model/pigeon_model.dart';
import '../../model/pigeon_repository.dart';

import '../../../../l10n/app_localizations.dart';
class PublicBirdPage extends StatefulWidget {
  final String publicId;

  PublicBirdPage({super.key, required this.publicId});

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
      appBar: PPWAppBar(
        title: AppLocalizations.of(context).btaqaAltayr,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
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

  _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 56),
            SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15, color: AppColors.textSecondary),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh_rounded),
              label: Text(AppLocalizations.of(context).retry),
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

  _BirdView({required this.bird});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroImage(bird: bird),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IdentityCard(bird: bird),
                SizedBox(height: 16),
                if ((bird.achievements).isNotEmpty)
                  _DetailCard(
                    icon: Icons.emoji_events_rounded,
                    title: AppLocalizations.of(context).achievements,
                    content: bird.achievements,
                  ),
                if (bird.description.isNotEmpty) ...[
                  SizedBox(height: 12),
                  _DetailCard(
                    icon: Icons.description_outlined,
                    title: AppLocalizations.of(context).description,
                    content: bird.description,
                  ),
                ],
                SizedBox(height: 16),
                _QrSection(bird: bird),
                SizedBox(height: 32),
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

  _HeroImage({required this.bird});

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
              errorBuilder: (_, _, _) => _PlaceholderBird(),
            )
          : _PlaceholderBird(),
    );
  }
}

class _PlaceholderBird extends StatelessWidget {
  _PlaceholderBird();

  @override
  Widget build(BuildContext context) => Center(
        child: Icon(Icons.flutter_dash, size: 80, color: AppColors.border),
      );
}

class _IdentityCard extends StatelessWidget {
  final PigeonModel bird;

  _IdentityCard({required this.bird});

  @override
  Widget build(BuildContext context) {
    final genderColor = bird.gender == PigeonGender.female
        ? AppColors.red
        : bird.gender == PigeonGender.young
            ? AppColors.orange
            : AppColors.blue;
    final genderLabel = bird.gender.label;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: Offset(0, 2),
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
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          SizedBox(height: 12),
          Divider(height: 1),
          SizedBox(height: 12),
          _Row(icon: Icons.tag_rounded, label: AppLocalizations.of(context).ringNumber, value: bird.ringNumber),
          SizedBox(height: 8),
          _Row(icon: Icons.pets_rounded, label: AppLocalizations.of(context).breed, value: bird.breed),
          if (bird.hatchDate != null) ...[
            SizedBox(height: 8),
            _Row(
              icon: Icons.cake_rounded,
              label: AppLocalizations.of(context).hatchDate,
              value:
                  '${bird.hatchDate!.day}/${bird.hatchDate!.month}/${bird.hatchDate!.year}',
            ),
          ],
          if (bird.flyingSpeed != null) ...[
            SizedBox(height: 8),
            _Row(
              icon: Icons.speed_rounded,
              label: AppLocalizations.of(context).sraaAltyran,
              value: '${bird.flyingSpeed!.toStringAsFixed(1)} م/ث',
            ),
          ],
          if (bird.staminaAbility != StaminaAbility.good ||
              bird.staminaAbility.label.isNotEmpty) ...[
            SizedBox(height: 8),
            _Row(
              icon: Icons.bolt_rounded,
              label: AppLocalizations.of(context).alqdraAlaAlthml,
              value: bird.staminaAbility.label,
            ),
          ],
          if ((bird.sellerNickname ?? '').isNotEmpty) ...[
            SizedBox(height: 8),
            Divider(height: 1),
            SizedBox(height: 8),
            _Row(
              icon: Icons.storefront_rounded,
              label: AppLocalizations.of(context).almrby,
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

  _Row(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
              fontSize: 13, color: AppColors.textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
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

  _DetailCard(
      {required this.icon, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
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

  _QrSection({required this.bird});

  @override
  Widget build(BuildContext context) {
    final qrData = bird.qrPayloadUrl ?? bird.ringNumber;
    return Center(
      child: Column(
        children: [
          Text(
            'رمز التحقق الرقمي',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 140,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.primary,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'هوية رقمية موثّقة — كوكب الحمام',
            style: TextStyle(fontSize: 10, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}
