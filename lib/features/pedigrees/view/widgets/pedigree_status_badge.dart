import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class PedigreeStatusBadge extends StatelessWidget {
  final String status;
  const PedigreeStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final (label, color) = switch (status) {
      'reviewed' => (l.tmtAlmrajaa2, AppColors.success),
      'processed' => (l.tmtAlmaalja2, AppColors.blue),
      'failed' => (l.fshlMrajaaYdwya, AppColors.orange),
      _ => (l.mrfwa2, AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
