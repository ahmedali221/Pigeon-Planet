import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../pedigrees/model/pedigree_document_model.dart';
import '../../../pedigrees/view/pages/pedigrees_page.dart';
import '../../../pedigrees/viewmodel/pedigrees_bloc.dart';
import '../../../pedigrees/viewmodel/pedigrees_event.dart';
import '../../../pedigrees/viewmodel/pedigrees_state.dart';
import '../../model/pigeon_model.dart';
import '../../viewmodel/pigeon_id_bloc.dart';
import 'pigeon_id_form_page.dart';


class PigeonIdCardPage extends StatelessWidget {
  const PigeonIdCardPage({super.key});

  void _confirmDelete(BuildContext context, int id) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('حذف الطائر'),
        content: const Text('هل أنت متأكد من حذف هذا الطائر؟ لا يمكن التراجع.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context
                  .read<PigeonIdBloc>()
                  .add(PigeonIdDeleteRequested(id));
            },
            child: const Text('حذف',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PigeonIdBloc, PigeonIdState>(
      listenWhen: (prev, curr) =>
          curr.status == PigeonIdStatus.deleted ||
          (curr.status == PigeonIdStatus.error &&
              prev.status == PigeonIdStatus.deleting),
      listener: (context, state) {
        if (state.status == PigeonIdStatus.deleted) {
          int count = 0;
          Navigator.popUntil(context, (_) => ++count > 3);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف الطائر بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state.status == PigeonIdStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'حدث خطأ أثناء الحذف'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final genderColor = state.gender == PigeonGender.female
            ? AppColors.red
            : state.gender == PigeonGender.young
                ? AppColors.orange
                : AppColors.blue;
        final genderLabel = state.gender.label;

        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'الهوية الرقمية',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            actions: [
              if (state.savedBird != null) ...[
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  tooltip: 'تعديل',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => sl<PigeonIdBloc>(),
                          child: PigeonIdFormPage(
                              initialPigeon: state.savedBird),
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: state.status == PigeonIdStatus.deleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.delete_rounded),
                  tooltip: 'حذف',
                  onPressed: state.status == PigeonIdStatus.deleting ||
                          state.savedBird?.id == null
                      ? null
                      : () => _confirmDelete(
                          context, state.savedBird!.id!),
                ),
              ],
              IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('سيتم إضافة المشاركة قريباً')),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ── ID Card ──────────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Card header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primaryDark,
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Logo / title — rightmost in RTL
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'كوكب الحمام',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Pigeon Planet',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Gender badge — leftmost in RTL
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                genderLabel,
                                style: TextStyle(
                                  color: genderColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Card body
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Info — rightmost in RTL
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _InfoRow(
                                    icon: Icons.tag_rounded,
                                    label: 'رقم الحلقة',
                                    value: state.ringNumber,
                                    valueColor: AppColors.primary,
                                    bold: true,
                                  ),
                                  const SizedBox(height: 12),
                                  _InfoRow(
                                    icon: Icons.pets_rounded,
                                    label: 'السلالة',
                                    value: state.breed,
                                  ),
                                  if (state.hatchDate != null) ...[
                                    const SizedBox(height: 12),
                                    _InfoRow(
                                      icon: Icons.cake_rounded,
                                      label: 'تاريخ الفقس',
                                      value:
                                          '${state.hatchDate!.day}/${state.hatchDate!.month}/${state.hatchDate!.year}',
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  _InfoRow(
                                    icon: Icons.verified_rounded,
                                    label: 'الحالة',
                                    value: 'موثّق ✓',
                                    valueColor: AppColors.success,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 16),

                            // QR code — leftmost in RTL
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: genderColor, width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: QrImageView(
                                    data: state.savedBird?.qrPayloadUrl ?? state.qrData ?? state.ringNumber,
                                    version: QrVersions.auto,
                                    size: 100,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: QrEyeShape.square,
                                      color: AppColors.primary,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape:
                                          QrDataModuleShape.square,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'امسح للتحقق',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Photo strip
                      if (state.photoPaths.isNotEmpty)
                        _PhotoStrip(paths: state.photoPaths),

                      // Race results
                      if (state.raceResults.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(),
                              const SizedBox(height: 8),
                              const Text(
                                'نتائج السباقات',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...state.raceResults.map(
                                (r) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.emoji_events_rounded,
                                          size: 14,
                                          color: AppColors.orange),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(r,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color:
                                                    AppColors.textPrimary)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Card footer
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: const BoxDecoration(
                          color: AppColors.pageBackground,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_rounded,
                                size: 12, color: AppColors.textHint),
                            const SizedBox(width: 4),
                            const Text(
                              'هوية رقمية موثّقة — كوكب الحمام',
                              style: TextStyle(
                                  fontSize: 10, color: AppColors.textHint),
                            ),
                            const Spacer(),
                            Text(
                              '© ${DateTime.now().year}',
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.textHint),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Pedigrees ─────────────────────────────────────────────
                if (state.savedBird?.id != null)
                  _BirdPedigreesSection(birdId: state.savedBird!.id!),

                const SizedBox(height: 16),

                // ── Action buttons ────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('سيتم إضافة الطباعة قريباً')),
                          );
                        },
                        icon: const Icon(Icons.print_rounded,
                            color: AppColors.primary),
                        label: const Text('طباعة',
                            style: TextStyle(color: AppColors.primary)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to publish flow
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('سيتم ربط النشر في الخطوة القادمة'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                        icon: const Icon(Icons.publish_rounded,
                            color: Colors.white),
                        label: const Text('نشر الحمامة',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Back to birds ─────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      int count = 0;
                      Navigator.popUntil(context, (_) => ++count > 3);
                    },
                    icon: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.primary),
                    label: const Text(
                      'العودة لطيوري',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(icon, size: 14, color: valueColor ?? AppColors.textHint),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      bold ? FontWeight.bold : FontWeight.w500,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Bird pedigrees section ────────────────────────────────────────────────────

class _BirdPedigreesSection extends StatelessWidget {
  final int birdId;
  const _BirdPedigreesSection({required this.birdId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<PedigreesBloc>()..add(PedigreesListRequested(birdId: birdId)),
      child: BlocBuilder<PedigreesBloc, PedigreesState>(
        builder: (context, state) {
          if (state.status == PedigreesStatus.loading) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return Container(
            width: double.infinity,
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
                const Row(
                  children: [
                    Icon(Icons.description_outlined,
                        size: 16, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'وثائق النسب',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (state.status == PedigreesStatus.error)
                  Text(
                    state.errorMessage ?? 'تعذّر تحميل وثائق النسب',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  )
                else if (state.documents.isEmpty)
                  const Text(
                    'لا توجد وثائق نسب مرفوعة لهذا الطائر',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  )
                else
                  ...state.documents.map(
                    (doc) => _PedigreeDocTile(doc: doc),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PedigreesPage(initialBirdId: birdId),
                      ),
                    ),
                    icon: const Icon(Icons.description_rounded, size: 16),
                    label: const Text('عرض شهادة النسب'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PedigreeDocTile extends StatelessWidget {
  final PedigreeDocumentModel doc;
  const _PedigreeDocTile({required this.doc});

  static const _statusLabels = {
    'uploaded': 'جارٍ المعالجة',
    'processed': 'تمت المعالجة',
    'reviewed': 'مراجع',
    'failed': 'فشل',
  };

  static const _statusColors = {
    'uploaded': AppColors.orange,
    'processed': AppColors.primary,
    'reviewed': AppColors.success,
    'failed': AppColors.error,
  };

  @override
  Widget build(BuildContext context) {
    final label = _statusLabels[doc.status] ?? doc.status;
    final color = _statusColors[doc.status] ?? AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.insert_drive_file_outlined,
              size: 16, color: AppColors.textHint),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              doc.reviewedBirdRingNumber ??
                  doc.extractedBirdRingNumber ??
                  'وثيقة #${doc.id}',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textPrimary),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PhotoStrip extends StatelessWidget {
  final List<String> paths;
  const _PhotoStrip({required this.paths});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'الصور',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: paths.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: paths[i].startsWith('http')
                    ? Image.network(
                        paths[i],
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(paths[i]),
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
