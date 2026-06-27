import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/widgets/ppw_app_bar.dart';
import '../../../../../core/widgets/shell_scaffold.dart';
import '../../../../l10n/app_localizations.dart';
import '../../model/race_model.dart';
import '../../viewmodel/races_bloc.dart';
import 'race_detail_page.dart';

class RacesPage extends StatelessWidget {
  const RacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RacesBloc>()..add(const RacesStarted()),
      child: const _RacesView(),
    );
  }
}

class _RacesView extends StatefulWidget {
  const _RacesView();

  @override
  State<_RacesView> createState() => _RacesViewState();
}

class _RacesViewState extends State<_RacesView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final raceType = _tabController.index == 0 ? RaceType.club : RaceType.olr;
    context.read<RacesBloc>().add(RacesTypeChanged(raceType));
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: PPWAppBar(
        title: l10n.raceResults,
        leading: ShellBackButton(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(text: l10n.clubManagerResults),
            Tab(text: l10n.pointsResults),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ClubFilterTab(),
          _OlrFilterTab(),
        ],
      ),
    );
  }
}

// ── Club Manager Tab ──────────────────────────────────────────────────────────

class _ClubFilterTab extends StatefulWidget {
  const _ClubFilterTab();

  @override
  State<_ClubFilterTab> createState() => _ClubFilterTabState();
}

class _ClubFilterTabState extends State<_ClubFilterTab> {
  final _rankCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _clubCtrl = TextEditingController();
  final _competitorCtrl = TextEditingController();
  final _stationCtrl = TextEditingController();
  final _birdCtrl = TextEditingController();
  String _selectedYear = '';

  @override
  void dispose() {
    _rankCtrl.dispose();
    _countryCtrl.dispose();
    _clubCtrl.dispose();
    _competitorCtrl.dispose();
    _stationCtrl.dispose();
    _birdCtrl.dispose();
    super.dispose();
  }

  void _search() {
    context.read<RacesBloc>().add(RacesFilterSearchRequested(
          rank: _rankCtrl.text.trim(),
          country: _countryCtrl.text.trim(),
          clubName: _clubCtrl.text.trim(),
          competitorName: _competitorCtrl.text.trim(),
          seasonYear: _selectedYear,
          stationName: _stationCtrl.text.trim(),
          birdNumber: _birdCtrl.text.trim(),
        ));
  }

  void _clear() {
    _rankCtrl.clear();
    _countryCtrl.clear();
    _clubCtrl.clear();
    _competitorCtrl.clear();
    _stationCtrl.clear();
    _birdCtrl.clear();
    setState(() => _selectedYear = '');
    context.read<RacesBloc>().add(const RacesStarted());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _TabLayout(
      filterCard: _FilterCard(
        children: [
          Row(
            children: [
              Expanded(
                child: _FilterField(
                  controller: _rankCtrl,
                  label: l10n.rankLabel,
                  icon: Icons.emoji_events_rounded,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FilterField(
                  controller: _countryCtrl,
                  label: l10n.country,
                  icon: Icons.flag_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _FilterField(
            controller: _clubCtrl,
            label: l10n.clubNameLabel,
            icon: Icons.shield_rounded,
          ),
          const SizedBox(height: 10),
          _FilterField(
            controller: _competitorCtrl,
            label: l10n.competitorNameLabel,
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 10),
          _SeasonPickerTile(
            selectedYear: _selectedYear,
            onPicked: (y) => setState(() => _selectedYear = y),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _FilterField(
                  controller: _stationCtrl,
                  label: l10n.station,
                  icon: Icons.train_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FilterField(
                  controller: _birdCtrl,
                  label: l10n.birdRingLabel,
                  icon: Icons.flutter_dash_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ActionButtons(onSearch: _search, onClear: _clear),
        ],
      ),
      resultsBody: _ResultsBody(onSearch: _search),
    );
  }
}

// ── OLR / نتائج النقاط Tab ────────────────────────────────────────────────────

class _OlrFilterTab extends StatefulWidget {
  const _OlrFilterTab();

  @override
  State<_OlrFilterTab> createState() => _OlrFilterTabState();
}

class _OlrFilterTabState extends State<_OlrFilterTab> {
  final _clubCtrl = TextEditingController();
  final _competitorCtrl = TextEditingController();
  final _stationCtrl = TextEditingController();
  final _birdCtrl = TextEditingController();
  String _selectedYear = '';

  @override
  void dispose() {
    _clubCtrl.dispose();
    _competitorCtrl.dispose();
    _stationCtrl.dispose();
    _birdCtrl.dispose();
    super.dispose();
  }

  void _search() {
    context.read<RacesBloc>().add(RacesFilterSearchRequested(
          clubName: _clubCtrl.text.trim(),
          competitorName: _competitorCtrl.text.trim(),
          seasonYear: _selectedYear,
          stationName: _stationCtrl.text.trim(),
          birdNumber: _birdCtrl.text.trim(),
        ));
  }

  void _clear() {
    _clubCtrl.clear();
    _competitorCtrl.clear();
    _stationCtrl.clear();
    _birdCtrl.clear();
    setState(() => _selectedYear = '');
    context.read<RacesBloc>().add(const RacesStarted());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _TabLayout(
      filterCard: _FilterCard(
        children: [
          _FilterField(
            controller: _clubCtrl,
            label: l10n.clubNameLabel,
            icon: Icons.shield_rounded,
          ),
          const SizedBox(height: 10),
          _FilterField(
            controller: _competitorCtrl,
            label: l10n.competitorNameLabel,
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 10),
          _SeasonPickerTile(
            selectedYear: _selectedYear,
            onPicked: (y) => setState(() => _selectedYear = y),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _FilterField(
                  controller: _stationCtrl,
                  label: l10n.station,
                  icon: Icons.train_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FilterField(
                  controller: _birdCtrl,
                  label: l10n.birdRingLabel,
                  icon: Icons.flutter_dash_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ActionButtons(onSearch: _search, onClear: _clear),
        ],
      ),
      resultsBody: _ResultsBody(onSearch: _search),
    );
  }
}

// ── Responsive tab layout ─────────────────────────────────────────────────────

class _TabLayout extends StatelessWidget {
  final Widget filterCard;
  final Widget resultsBody;

  const _TabLayout({required this.filterCard, required this.resultsBody});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          children: [
            filterCard,
            Expanded(child: resultsBody),
          ],
        ),
      ),
    );
  }
}

// ── Results body ──────────────────────────────────────────────────────────────

class _ResultsBody extends StatelessWidget {
  final VoidCallback onSearch;

  const _ResultsBody({required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<RacesBloc, RacesState>(
      builder: (context, state) {
        if (state.status == RacesStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == RacesStatus.error) {
          return _ErrorView(
            message: state.errorMessage ?? l10n.errorOccurred,
            onRetry: onSearch,
          );
        }
        if (state.status == RacesStatus.initial) {
          return _EmptyPrompt(message: l10n.filterSearchPrompt);
        }
        if (state.globalSearchResults.isEmpty) {
          return _EmptyView(message: l10n.noMatchingResults);
        }
        final hasFooter =
            state.resultSearchHasMore || state.resultSearchLoadingMore;
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: state.globalSearchResults.length + (hasFooter ? 1 : 0),
          separatorBuilder: (_, i) => const SizedBox(height: 8),
          itemBuilder: (ctx, i) {
            if (i == state.globalSearchResults.length) {
              return _LoadMoreButton(
                loading: state.resultSearchLoadingMore,
                label: l10n.loadMore,
                onTap: () => ctx
                    .read<RacesBloc>()
                    .add(const RaceResultSearchLoadMoreRequested()),
              );
            }
            final result = state.globalSearchResults[i];
            return _ResultRow(
              result: result,
              onTap: result.raceId != null
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<RacesBloc>(),
                            child: RaceDetailPage(raceId: result.raceId!),
                          ),
                        ),
                      )
                  : null,
            );
          },
        );
      },
    );
  }
}

// ── Shared filter widgets ─────────────────────────────────────────────────────

class _FilterCard extends StatelessWidget {
  final List<Widget> children;

  const _FilterCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  const _FilterField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: TextAlign.start,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.pageBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}

class _SeasonPickerTile extends StatelessWidget {
  final String selectedYear;
  final ValueChanged<String> onPicked;

  const _SeasonPickerTile({
    required this.selectedYear,
    required this.onPicked,
  });

  Future<void> _pick(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final initial = DateTime(int.tryParse(selectedYear) ?? now.year);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.chooseSeason),
        contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
        content: SizedBox(
          width: 280,
          height: 280,
          child: YearPicker(
            firstDate: DateTime(2000),
            lastDate: DateTime(now.year + 5),
            selectedDate: initial,
            onChanged: (date) {
              onPicked('${date.year}');
              Navigator.pop(ctx);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasValue = selectedYear.isNotEmpty;
    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.pageBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasValue ? AppColors.primary : Colors.transparent,
            width: hasValue ? 1.5 : 0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: hasValue ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasValue ? selectedYear : l10n.season,
                style: TextStyle(
                  fontSize: 16,
                  color:
                      hasValue ? AppColors.textPrimary : Colors.grey.shade500,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down_rounded,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onSearch;
  final VoidCallback onClear;

  const _ActionButtons({required this.onSearch, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onSearch,
            icon: const Icon(Icons.search_rounded, size: 18),
            label: Text(l10n.search),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded, size: 18),
            label: Text(l10n.clearData),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Result row ────────────────────────────────────────────────────────────────

class _ResultRow extends StatelessWidget {
  final RaceResultModel result;
  final VoidCallback? onTap;

  const _ResultRow({required this.result, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _rankColor(result.rank),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${result.rank}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.competitorName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.ringLabel(result.birdRingNumber),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (result.raceTitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      result.raceTitle!,
                      style: TextStyle(
                          fontSize: 11, color: AppColors.primary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${result.speed.toStringAsFixed(2)} ${l10n.speedUnit}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${result.distanceKm.toStringAsFixed(2)} ${l10n.distanceKmUnit}',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
                if (onTap != null) ...[
                  const SizedBox(height: 2),
                  Icon(Icons.chevron_left_rounded,
                      size: 16, color: AppColors.textSecondary),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.primary;
    }
  }
}

// ── Utility widgets ───────────────────────────────────────────────────────────

class _EmptyPrompt extends StatelessWidget {
  final String message;

  const _EmptyPrompt({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_alt_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String message;

  const _EmptyView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_rounded,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorView({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              message,
              style:
                  const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  final bool loading;
  final String label;
  final VoidCallback onTap;

  const _LoadMoreButton({
    required this.loading,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : OutlinedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.expand_more_rounded, size: 18),
                label: Text(label),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                ),
              ),
      ),
    );
  }
}
