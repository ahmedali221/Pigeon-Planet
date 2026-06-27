import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/widgets/ppw_app_bar.dart';
import '../../../auth/viewmodel/auth_bloc.dart';
import '../../viewmodel/pedigree_tree_cubit.dart';
import '../../model/pedigree_document_model.dart';
import '../../viewmodel/pedigrees_bloc.dart';
import '../../viewmodel/pedigrees_event.dart';
import '../../viewmodel/pedigrees_state.dart';
import '../widgets/customer_pedigrees_tab.dart';
import '../widgets/pedigree_status_badge.dart';
import '../widgets/seller_pedigrees_tab.dart';
import 'pedigree_detail_page.dart';

import '../../../../l10n/app_localizations.dart';

class PedigreesPage extends StatelessWidget {
  final int? initialBirdId;
  // true when the current user does NOT own this bird (customer viewing seller's bird)
  final bool isReadOnly;

  const PedigreesPage({
    super.key,
    this.initialBirdId,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isSeller = authState is AuthSuccess && authState.user.isSeller;

    // Bottom-nav tab (no birdId) — local tree only, no API pedigree list needed
    if (initialBirdId == null) {
      return BlocProvider.value(
        value: sl<PedigreeTreeCubit>(),
        child: isSeller
            ? const SellerPedigreesTab()
            : const CustomerPedigreesTab(),
      );
    }

    // birdId-scoped view — show per-bird API documents + local tree cubit
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<PedigreesBloc>()
            ..add(PedigreesListRequested(birdId: initialBirdId)),
        ),
        BlocProvider.value(value: sl<PedigreeTreeCubit>()),
      ],
      child: _PedigreesView(isReadOnly: isReadOnly),
    );
  }
}

// ── Bird-scoped or owner pedigree list view ───────────────────────────────────

class _PedigreesView extends StatelessWidget {
  final bool isReadOnly;
  const _PedigreesView({this.isReadOnly = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PedigreesBloc, PedigreesState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: PPWAppBar(
            title: AppLocalizations.of(context).shhadatAlnsb,
          ),
          body: _Body(state: state, isReadOnly: isReadOnly),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  final PedigreesState state;
  final bool isReadOnly;
  const _Body({required this.state, required this.isReadOnly});

  @override
  Widget build(BuildContext context) {
    if (state.status == PedigreesStatus.loading && state.documents.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == PedigreesStatus.error && state.documents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              Text(
                state.errorMessage ??
                    AppLocalizations.of(context).errorOccurred,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (state.documents.isEmpty) {
      return _EmptyState(isReadOnly: isReadOnly);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: state.documents.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _DocumentTile(
        document: state.documents[i],
        isReadOnly: isReadOnly,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isReadOnly;
  const _EmptyState({required this.isReadOnly});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.purpleLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.description_outlined,
                  color: AppColors.purple, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'لا توجد شهادات نسب',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isReadOnly
                  ? 'لم يتم رفع شهادة نسب لهذا الطائر بعد'
                  : 'لا توجد شهادات نسب لهذا الطائر بعد',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final PedigreeDocumentModel document;
  final bool isReadOnly;
  const _DocumentTile({required this.document, required this.isReadOnly});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<PedigreesBloc>(),
            child: PedigreeDetailPage(
              document: document,
              isReadOnly: isReadOnly,
            ),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.purpleLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.description_rounded,
                  color: AppColors.purple, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'شهادة نسب #${document.id}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  PedigreeStatusBadge(status: document.status),
                  if (document.created != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(document.created!),
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textHint),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_back_ios_rounded,
                color: AppColors.textSecondary, size: 14),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
