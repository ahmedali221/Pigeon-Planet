import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/file_source_sheet.dart';
import '../../../../l10n/app_localizations.dart';

class PaymentProofSheet extends StatefulWidget {
  const PaymentProofSheet({super.key});

  static Future<PlatformFile?> show(BuildContext context) {
    return showModalBottomSheet<PlatformFile?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PaymentProofSheet(),
    );
  }

  @override
  State<PaymentProofSheet> createState() => _PaymentProofSheetState();
}

class _PaymentProofSheetState extends State<PaymentProofSheet> {
  PlatformFile? _proofFile;
  bool _attempted = false;

  Future<void> _pickFile() async {
    final file = await FileSourceSheet.show(
      context,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (file != null) setState(() => _proofFile = file);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final hasProof = _proofFile != null;
    final showError = _attempted && !hasProof;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l.paymentProofSheetTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.paymentProofSheetSubtitle,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: hasProof ? AppColors.primaryLight : AppColors.pageBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: showError
                      ? AppColors.error
                      : hasProof
                          ? AppColors.primary
                          : AppColors.border,
                  width: hasProof ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    hasProof ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                    color: hasProof ? AppColors.primary : AppColors.textHint,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasProof ? l.proofAttached : l.attachProofBtn,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: hasProof ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                        if (hasProof) ...[
                          const SizedBox(height: 2),
                          Text(
                            _proofFile!.name,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (hasProof)
                    Text(
                      l.changeProofBtn,
                      style: const TextStyle(fontSize: 12, color: AppColors.primary),
                    ),
                ],
              ),
            ),
          ),
          if (showError) ...[
            const SizedBox(height: 6),
            Text(
              l.proofRequired,
              style: const TextStyle(fontSize: 12, color: AppColors.error),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() => _attempted = true);
                if (_proofFile != null) {
                  Navigator.pop(context, _proofFile);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                l.confirmAndCheckout,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
