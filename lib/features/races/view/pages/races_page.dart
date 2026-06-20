import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
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
  final _racesSearchCtrl = TextEditingController();
  final _resultsSearchCtrl = TextEditingController();
  final _seasonCtrl = TextEditingController();
  final _stationCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _racesSearchCtrl.dispose();
    _resultsSearchCtrl.dispose();
    _seasonCtrl.dispose();
    _stationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          'النتائج والسباقات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'السباقات'),
            Tab(text: 'بحث النتائج'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _RacesListTab(
            searchCtrl: _racesSearchCtrl,
            seasonCtrl: _seasonCtrl,
            stationCtrl: _stationCtrl,
          ),
          _ResultsSearchTab(searchCtrl: _resultsSearchCtrl),
        ],
      ),
    );
  }
}

// ── Tab 1: Race list ──────────────────────────────────────────────────────────

class _RacesListTab extends StatelessWidget {
  final TextEditingController searchCtrl;
  final TextEditingController seasonCtrl;
  final TextEditingController stationCtrl;

  const _RacesListTab({
    required this.searchCtrl,
    required this.seasonCtrl,
    required this.stationCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RacesBloc, RacesState>(
      builder: (context, state) {
        return Column(
          children: [
            _SearchBar(
              controller: searchCtrl,
              hint: 'بحث في السباقات...',
              onChanged: (q) => context
                  .read<RacesBloc>()
                  .add(RacesSearchChanged(q)),
            ),
            _RaceFiltersBar(
              seasonCtrl: seasonCtrl,
              stationCtrl: stationCtrl,
              state: state,
            ),
            Expanded(
              child: _buildBody(context, state),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, RacesState state) {
    if (state.status == RacesStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == RacesStatus.error) {
      return _ErrorView(
        message: state.errorMessage ?? 'حدث خطأ',
        onRetry: () =>
            context.read<RacesBloc>().add(const RacesRefreshRequested()),
      );
    }
    if (state.status == RacesStatus.searchResults) {
      return _globalResultsList(context, state.globalSearchResults);
    }
    if (state.races.isEmpty) {
      return const _EmptyView(message: 'لا توجد سباقات بعد');
    }
    final hasFooter = state.hasMore || state.loadingMore;
    return RefreshIndicator(
      onRefresh: () async =>
          context.read<RacesBloc>().add(const RacesRefreshRequested()),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.races.length + (hasFooter ? 1 : 0),
        separatorBuilder: (_, i) =>
            i < state.races.length - 1
                ? const SizedBox(height: 12)
                : const SizedBox.shrink(),
        itemBuilder: (ctx, i) {
          if (i == state.races.length) {
            return _LoadMoreButton(
              loading: state.loadingMore,
              onTap: () =>
                  ctx.read<RacesBloc>().add(const RacesLoadMoreRequested()),
            );
          }
          return _RaceCard(
            race: state.races[i],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<RacesBloc>(),
                  child: RaceDetailPage(raceId: state.races[i].id),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _globalResultsList(
      BuildContext context, List<RaceResultModel> results) {
    if (results.isEmpty) {
      return const _EmptyView(message: 'لا توجد نتائج');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (_, index) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _ResultRow(result: results[i], showRace: true),
    );
  }
}

// ── Tab 2: Global result search ───────────────────────────────────────────────

class _RaceFiltersBar extends StatelessWidget {
  final TextEditingController seasonCtrl;
  final TextEditingController stationCtrl;
  final RacesState state;

  const _RaceFiltersBar({
    required this.seasonCtrl,
    required this.stationCtrl,
    required this.state,
  });

  bool get _hasFilters =>
      state.seasonYearFilter.isNotEmpty || state.stationNameFilter.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _FilterField(
                  controller: seasonCtrl,
                  hint: 'الموسم',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FilterField(
                  controller: stationCtrl,
                  hint: 'المحطة',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<RacesBloc>().add(
                          RacesFilterChanged(
                            seasonYear: seasonCtrl.text,
                            stationName: stationCtrl.text,
                          ),
                        );
                  },
                  icon: const Icon(Icons.filter_alt_rounded, size: 18),
                  label: const Text('تطبيق الفلتر'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _hasFilters ||
                        seasonCtrl.text.isNotEmpty ||
                        stationCtrl.text.isNotEmpty
                    ? () {
                        seasonCtrl.clear();
                        stationCtrl.clear();
                        context.read<RacesBloc>().add(
                              const RacesFilterChanged(
                                seasonYear: '',
                                stationName: '',
                              ),
                            );
                      }
                    : null,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('مسح'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  const _FilterField({
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.pageBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

class _ResultsSearchTab extends StatelessWidget {
  final TextEditingController searchCtrl;

  const _ResultsSearchTab({required this.searchCtrl});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RacesBloc, RacesState>(
      builder: (context, state) {
        return Column(
          children: [
            _SearchBar(
              controller: searchCtrl,
              hint: 'رقم الحلقة أو اسم المتسابق...',
              onChanged: (q) => context
                  .read<RacesBloc>()
                  .add(RaceResultSearchChanged(q)),
            ),
            Expanded(child: _buildBody(state)),
          ],
        );
      },
    );
  }

  Widget _buildBody(RacesState state) {
    if (state.status == RacesStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.resultSearchQuery.isEmpty) {
      return const _EmptyView(
        icon: Icons.search_rounded,
        message: 'ابحث برقم حلقة الحمام أو اسم المتسابق',
      );
    }
    if (state.status == RacesStatus.error) {
      return _ErrorView(message: state.errorMessage ?? 'حدث خطأ');
    }
    if (state.globalSearchResults.isEmpty) {
      return const _EmptyView(message: 'لا توجد نتائج مطابقة');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.globalSearchResults.length,
      separatorBuilder: (_, index) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _ResultRow(
        result: state.globalSearchResults[i],
        showRace: true,
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textAlign: TextAlign.start,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

class _RaceCard extends StatelessWidget {
  final RaceModel race;
  final VoidCallback onTap;

  const _RaceCard({required this.race, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final releaseDate = _formatDate(race.releaseDatetime);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${race.seasonYear}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    race.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.location_on_rounded,
              label: race.stationName,
            ),
            const SizedBox(height: 4),
            _InfoRow(
              icon: Icons.calendar_today_rounded,
              label: releaseDate,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _StatChip(
                  icon: Icons.flutter_dash_rounded,
                  value: '${race.totalBirds}',
                  label: 'طائر',
                ),
                const SizedBox(width: 8),
                _StatChip(
                  icon: Icons.group_rounded,
                  value: '${race.competitorsCount}',
                  label: 'متسابق',
                ),
                if (race.plannedDistanceKm != null) ...[
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.straighten_rounded,
                    value: '${race.plannedDistanceKm!.toStringAsFixed(1)} كم',
                    label: '',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatChip({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.pageBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label.isNotEmpty ? '$value $label' : value,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final RaceResultModel result;
  final bool showRace;

  const _ResultRow({required this.result, this.showRace = false});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Rank badge
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
                ),
                const SizedBox(height: 2),
                Text(
                  'حلقة: ${result.birdRingNumber}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (showRace && result.raceTitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    result.raceTitle!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${result.speed.toStringAsFixed(2)} م/ث',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${result.distanceKm.toStringAsFixed(2)} كم',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
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

class _LoadMoreButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  const _LoadMoreButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
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
                label: const Text('تحميل المزيد'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
              ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String message;
  final IconData icon;

  const _EmptyView({
    required this.message,
    this.icon = Icons.emoji_events_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
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
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _formatDate(String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    return DateFormat('yyyy/MM/dd', 'ar').format(dt);
  } catch (_) {
    return iso;
  }
}
