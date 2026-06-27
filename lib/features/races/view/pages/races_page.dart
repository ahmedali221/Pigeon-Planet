import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: l10n.clubRaces),
            Tab(text: l10n.olrRaces),
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
    final l10n = AppLocalizations.of(context);
    final country = _countryCtrl.text.trim();
    final club = _clubCtrl.text.trim();
    final year = _selectedYear;
    if (country.isEmpty || club.isEmpty || year.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.requiredFieldsError)),
      );
      return;
    }
    context.read<RacesBloc>().add(RacesFilterSearchRequested(
          rank: _rankCtrl.text.trim(),
          country: country,
          clubName: club,
          competitorName: _competitorCtrl.text.trim(),
          seasonYear: year,
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
    return _FilterScrollLayout(
      onSearch: _search,
      filterChildren: [
        _FilterField(
          controller: _rankCtrl,
          label: l10n.rankLabel,
          icon: Icons.emoji_events_rounded,
          keyboardType: TextInputType.number,
          digitsOnly: true,
        ),
        const SizedBox(height: 10),
        _FilterField(
          controller: _countryCtrl,
          label: '${l10n.country} *',
          icon: Icons.flag_rounded,
        ),
        const SizedBox(height: 10),
        _FilterField(
          controller: _clubCtrl,
          label: '${l10n.clubNameLabel} *',
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
          isRequired: true,
          onPicked: (y) => setState(() => _selectedYear = y),
        ),
        const SizedBox(height: 10),
        _FilterField(
          controller: _stationCtrl,
          label: l10n.station,
          icon: Icons.train_rounded,
        ),
        const SizedBox(height: 10),
        _FilterField(
          controller: _birdCtrl,
          label: l10n.birdRingLabel,
          icon: Icons.flutter_dash_rounded,
        ),
        const SizedBox(height: 14),
        _ActionButtons(onSearch: _search, onClear: _clear),
      ],
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
  final _rankCtrl = TextEditingController();
  final _pointNameCtrl = TextEditingController();
  final _competitorCtrl = TextEditingController();
  final _birdCtrl = TextEditingController();
  String _selectedYear = '';

  @override
  void dispose() {
    _rankCtrl.dispose();
    _pointNameCtrl.dispose();
    _competitorCtrl.dispose();
    _birdCtrl.dispose();
    super.dispose();
  }

  void _search() {
    context.read<RacesBloc>().add(RacesFilterSearchRequested(
          rank: _rankCtrl.text.trim(),
          pointName: _pointNameCtrl.text.trim(),
          competitorName: _competitorCtrl.text.trim(),
          seasonYear: _selectedYear,
          birdNumber: _birdCtrl.text.trim(),
        ));
  }

  void _clear() {
    _rankCtrl.clear();
    _pointNameCtrl.clear();
    _competitorCtrl.clear();
    _birdCtrl.clear();
    setState(() => _selectedYear = '');
    context.read<RacesBloc>().add(const RacesStarted());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _FilterScrollLayout(
      onSearch: _search,
      filterChildren: [
        _FilterField(
          controller: _rankCtrl,
          label: l10n.rankLabel,
          icon: Icons.emoji_events_rounded,
          keyboardType: TextInputType.number,
          digitsOnly: true,
        ),
        const SizedBox(height: 10),
        _FilterField(
          controller: _pointNameCtrl,
          label: l10n.pointNameLabel,
          icon: Icons.place_rounded,
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
        _FilterField(
          controller: _birdCtrl,
          label: l10n.birdRingLabel,
          icon: Icons.flutter_dash_rounded,
        ),
        const SizedBox(height: 14),
        _ActionButtons(onSearch: _search, onClear: _clear),
      ],
    );
  }
}

// ── Unified scroll layout: filter form + results in one scroll ────────────────

class _FilterScrollLayout extends StatelessWidget {
  final List<Widget> filterChildren;
  final VoidCallback onSearch;

  const _FilterScrollLayout({
    required this.filterChildren,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: BlocBuilder<RacesBloc, RacesState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                // ── Filter card ──────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
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
                      children: filterChildren,
                    ),
                  ),
                ),
                // ── Results section ──────────────────────────────────────────
                ..._buildResultSlivers(context, state, l10n),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildResultSlivers(
    BuildContext context,
    RacesState state,
    AppLocalizations l10n,
  ) {
    Widget fillWith(Widget child) => SliverFillRemaining(
          hasScrollBody: false,
          child: child,
        );

    if (state.status == RacesStatus.loading) {
      return [fillWith(const Center(child: CircularProgressIndicator()))];
    }
    if (state.status == RacesStatus.error) {
      return [
        fillWith(_ErrorView(
          message: state.errorMessage ?? l10n.errorOccurred,
          onRetry: onSearch,
        )),
      ];
    }
    if (state.status == RacesStatus.initial) {
      return [fillWith(_EmptyPrompt(message: l10n.filterSearchPrompt))];
    }
    if (state.globalSearchResults.isEmpty) {
      return [fillWith(_EmptyView(message: l10n.noMatchingResults))];
    }

    final results = state.globalSearchResults;
    final hasFooter = state.resultSearchHasMore || state.resultSearchLoadingMore;
    final count = results.length + (hasFooter ? 1 : 0);

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        sliver: SliverList.separated(
          itemCount: count,
          separatorBuilder: (_, i) => const SizedBox(height: 8),
          itemBuilder: (ctx, i) {
            if (i == results.length) {
              return _LoadMoreButton(
                loading: state.resultSearchLoadingMore,
                label: l10n.loadMore,
                onTap: () => ctx
                    .read<RacesBloc>()
                    .add(const RaceResultSearchLoadMoreRequested()),
              );
            }
            final result = results[i];
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
        ),
      ),
    ];
  }
}

// ── Shared filter widgets ─────────────────────────────────────────────────────

class _FilterField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool digitsOnly;

  const _FilterField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.digitsOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: digitsOnly
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
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
  final bool isRequired;

  const _SeasonPickerTile({
    required this.selectedYear,
    required this.onPicked,
    this.isRequired = false,
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
                hasValue ? selectedYear : (isRequired ? '${l10n.season} *' : l10n.season),
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

// ── Result card ───────────────────────────────────────────────────────────────

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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header: rank + name + country/club ──────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  _RankBadge(rank: result.rank),
                  const SizedBox(width: 10),
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
                        if (result.clubName != null ||
                            result.pointName != null ||
                            result.raceSeasonYear != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            [
                              if (result.clubName != null) result.clubName!,
                              if (result.pointName != null) result.pointName!,
                              if (result.raceSeasonYear != null)
                                '${result.raceSeasonYear}',
                            ].join(' · '),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (result.country != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      result.country!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                  if (onTap != null) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_left_rounded,
                        size: 16, color: AppColors.textSecondary),
                  ],
                ],
              ),
            ),
            // ── Station row ─────────────────────────────────────────
            if (result.raceStationName != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.train_rounded,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      result.raceStationName!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            // ── Bird ring ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.flutter_dash_rounded,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    l10n.ringLabel(result.birdRingNumber),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            // ── Arrival datetime (OLR) ───────────────────────────────
            if (result.arrivalDatetime.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      '${l10n.arrivalDateTimeLabel}: ${result.arrivalDatetime}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            const Divider(height: 1, indent: 12, endIndent: 12),
            // ── Metrics grid ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetricChip(
                    label: l10n.speedUnit,
                    value: result.speed.toStringAsFixed(2),
                    icon: Icons.speed_rounded,
                    highlight: true,
                  ),
                  _MetricChip(
                    label: l10n.distanceKmUnit,
                    value: result.distanceKm.toStringAsFixed(2),
                    icon: Icons.straighten_rounded,
                  ),
                  if (result.points != null)
                    _MetricChip(
                      label: l10n.racePointsLabel,
                      value: result.points!.toStringAsFixed(2),
                      icon: Icons.stars_rounded,
                    ),
                  if (result.timeDifference != null)
                    _MetricChip(
                      label: l10n.timeDifferenceLabel,
                      value: result.timeDifference!,
                      icon: Icons.timer_outlined,
                    ),
                  if (result.arrivalsCount != null)
                    _MetricChip(
                      label: l10n.arrivalsCountLabel,
                      value: '${result.arrivalsCount}',
                      icon: Icons.groups_rounded,
                    ),
                  if (result.totalBirds != null)
                    _MetricChip(
                      label: l10n.totalBirdsLabel,
                      value: '${result.totalBirds}',
                      icon: Icons.flutter_dash_rounded,
                    ),
                  if (result.basketNumber != null)
                    _MetricChip(
                      label: l10n.baskLabel,
                      value: '${result.basketNumber}',
                      icon: Icons.inventory_2_rounded,
                    ),
                ],
              ),
            ),
            // ── Result lines ─────────────────────────────────────────
            if (result.resultLines1 != null || result.resultLines2 != null) ...[
              const Divider(height: 1, indent: 12, endIndent: 12),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    if (result.resultLines1 != null)
                      Expanded(
                        child: _TimeLine(
                          label: l10n.resultLine1Label,
                          value: result.resultLines1!,
                        ),
                      ),
                    if (result.resultLines1 != null &&
                        result.resultLines2 != null)
                      const SizedBox(width: 12),
                    if (result.resultLines2 != null)
                      Expanded(
                        child: _TimeLine(
                          label: l10n.resultLine2Label,
                          value: result.resultLines2!,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: _rankColor(rank),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
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

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool highlight;

  const _MetricChip({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.pageBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 13,
              color: highlight ? AppColors.primary : AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: highlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _TimeLine extends StatelessWidget {
  final String label;
  final String value;

  const _TimeLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
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
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
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
