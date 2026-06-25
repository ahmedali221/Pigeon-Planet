import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/widgets/ppw_app_bar.dart';
import '../../../../../core/widgets/shell_scaffold.dart';
import '../../model/race_model.dart';
import '../../viewmodel/races_bloc.dart';
import 'race_detail_page.dart';

import '../../../../l10n/app_localizations.dart';

class RacesPage extends StatelessWidget {
  const RacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RacesBloc>()..add(const RacesStarted()),
      child: _RacesView(),
    );
  }
}

class _RacesView extends StatefulWidget {
  _RacesView();

  @override
  State<_RacesView> createState() => _RacesViewState();
}

class _RacesViewState extends State<_RacesView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _racesSearchCtrl = TextEditingController();
  final _resultsSearchCtrl = TextEditingController();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: PPWAppBar(
        title: AppLocalizations.of(context).racesAndResults,
        leading: ShellBackButton(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: AppLocalizations.of(context).races),
            Tab(text: AppLocalizations.of(context).searchResults),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _RacesListTab(searchCtrl: _racesSearchCtrl),
          _ResultsSearchTab(searchCtrl: _resultsSearchCtrl),
        ],
      ),
    );
  }
}

// ── Tab 1: Race list ──────────────────────────────────────────────────────────

class _RacesListTab extends StatelessWidget {
  final TextEditingController searchCtrl;

  _RacesListTab({required this.searchCtrl});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RacesBloc, RacesState>(
      builder: (context, state) {
        return Column(
          children: [
            _RaceTypeSwitcher(),
            _SearchRowWithFilter(searchCtrl: searchCtrl, state: state),
            Expanded(child: _buildBody(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, RacesState state) {
    if (state.status == RacesStatus.loading) {
      return Center(child: CircularProgressIndicator());
    }
    if (state.status == RacesStatus.error) {
      return _ErrorView(
        message:
            state.errorMessage ?? AppLocalizations.of(context).errorOccurred5,
        onRetry: () =>
            context.read<RacesBloc>().add(const RacesRefreshRequested()),
      );
    }
    if (state.status == RacesStatus.searchResults) {
      return _globalResultsList(context, state);
    }
    if (state.races.isEmpty) {
      return _EmptyView(message: AppLocalizations.of(context).noRacesYet);
    }
    final hasFooter = state.hasMore || state.loadingMore;
    return RefreshIndicator(
      onRefresh: () async =>
          context.read<RacesBloc>().add(const RacesRefreshRequested()),
      child: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: state.races.length + (hasFooter ? 1 : 0),
        separatorBuilder: (_, i) =>
            i < state.races.length - 1 ? SizedBox(height: 12) : SizedBox.shrink(),
        itemBuilder: (ctx, i) {
          if (i == state.races.length) {
            return _LoadMoreButton(
              loading: state.loadingMore,
              onTap: () => ctx.read<RacesBloc>().add(const RacesLoadMoreRequested()),
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

  Widget _globalResultsList(BuildContext context, RacesState state) {
    final results = state.globalSearchResults;
    if (results.isEmpty) {
      return _EmptyView(message: AppLocalizations.of(context).noResults);
    }
    final hasFooter = state.resultSearchHasMore || state.resultSearchLoadingMore;
    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: results.length + (hasFooter ? 1 : 0),
      separatorBuilder: (_, index) => SizedBox(height: 8),
      itemBuilder: (context, i) {
        if (i == results.length) {
          return _LoadMoreButton(
            loading: state.resultSearchLoadingMore,
            onTap: () => context
                .read<RacesBloc>()
                .add(const RaceResultSearchLoadMoreRequested()),
          );
        }
        return _ResultRow(result: results[i], showRace: true);
      },
    );
  }
}

// ── Race type switcher ────────────────────────────────────────────────────────

class _RaceTypeSwitcher extends StatelessWidget {
  const _RaceTypeSwitcher();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RacesBloc, RacesState>(
      buildWhen: (p, n) => p.raceType != n.raceType,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                _TypeButton(
                  label: 'سباقات الأندية',
                  icon: Icons.groups_rounded,
                  isActive: state.raceType == RaceType.club,
                  onTap: () => context
                      .read<RacesBloc>()
                      .add(const RacesTypeChanged(RaceType.club)),
                ),
                _TypeButton(
                  label: 'O.L.R',
                  icon: Icons.public_rounded,
                  isActive: state.raceType == RaceType.olr,
                  onTap: () => context
                      .read<RacesBloc>()
                      .add(const RacesTypeChanged(RaceType.olr)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  _TypeButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.textSecondary,
                  fontWeight:
                      isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Search row + filter icon ──────────────────────────────────────────────────

class _SearchRowWithFilter extends StatelessWidget {
  final TextEditingController searchCtrl;
  final RacesState state;

  _SearchRowWithFilter({required this.searchCtrl, required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchCtrl,
              onChanged: (q) =>
                  context.read<RacesBloc>().add(RacesSearchChanged(q)),
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).racesSearchHint,
                prefixIcon: Icon(Icons.search_rounded),
                suffixIcon: searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded),
                        onPressed: () {
                          searchCtrl.clear();
                          context
                              .read<RacesBloc>()
                              .add(const RacesSearchChanged(''));
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
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          SizedBox(width: 8),
          _FilterIconButton(state: state),
        ],
      ),
    );
  }
}

class _FilterIconButton extends StatelessWidget {
  final RacesState state;

  _FilterIconButton({required this.state});

  @override
  Widget build(BuildContext context) {
    final active = state.hasActiveFilters;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? AppColors.primary : AppColors.border,
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.filter_alt_rounded,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
            onPressed: () => _openFilterSheet(context, state),
          ),
        ),
        if (active)
          Positioned(
            top: -4,
            left: -4,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }

  void _openFilterSheet(BuildContext context, RacesState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<RacesBloc>(),
        child: _RaceFilterSheet(state: state),
      ),
    );
  }
}

// ── Filter bottom sheet ───────────────────────────────────────────────────────

class _RaceFilterSheet extends StatefulWidget {
  final RacesState state;

  _RaceFilterSheet({required this.state});

  @override
  State<_RaceFilterSheet> createState() => _RaceFilterSheetState();
}

class _RaceFilterSheetState extends State<_RaceFilterSheet> {
  // Club controllers
  late final TextEditingController _countryCtrl;
  late final TextEditingController _clubCtrl;
  // OLR controllers
  late final TextEditingController _pointNameCtrl;
  late final TextEditingController _stationCtrl;
  late final TextEditingController _hobbyistCtrl;
  late final TextEditingController _rankCtrl;
  late final TextEditingController _birdNumberCtrl;
  // Shared year picker state
  String _selectedYear = '';

  @override
  void initState() {
    super.initState();
    final s = widget.state;
    _countryCtrl = TextEditingController(text: s.countryFilter);
    _clubCtrl = TextEditingController(text: s.clubFilter);
    _selectedYear = s.seasonYearFilter;
    _pointNameCtrl = TextEditingController(text: s.pointNameFilter);
    _stationCtrl = TextEditingController(text: s.stationNameFilter);
    _hobbyistCtrl = TextEditingController(text: s.hobbyistNameFilter);
    _rankCtrl = TextEditingController(text: s.rankFilter);
    _birdNumberCtrl = TextEditingController(text: s.birdNumberFilter);
  }

  @override
  void dispose() {
    _countryCtrl.dispose();
    _clubCtrl.dispose();
    _pointNameCtrl.dispose();
    _stationCtrl.dispose();
    _hobbyistCtrl.dispose();
    _rankCtrl.dispose();
    _birdNumberCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickYear() async {
    final now = DateTime.now();
    final initial = DateTime(
      int.tryParse(_selectedYear) ?? now.year,
    );
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('اختر السيزون'),
        contentPadding: EdgeInsets.fromLTRB(0, 12, 0, 0),
        content: SizedBox(
          width: 280,
          height: 280,
          child: YearPicker(
            firstDate: DateTime(2000),
            lastDate: DateTime(now.year + 5),
            selectedDate: initial,
            onChanged: (date) {
              setState(() => _selectedYear = '${date.year}');
              Navigator.pop(ctx);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isClub = widget.state.raceType == RaceType.club;
    return Container(
      margin: EdgeInsets.only(top: 60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(
              children: [
                Icon(Icons.filter_alt_rounded,
                    color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  isClub ? 'فلاتر سباقات الأندية' : 'فلاتر O.L.R',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 24),
          // Fields
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: isClub ? _buildClubFields() : _buildOlrFields(),
            ),
          ),
          // Action buttons
          Padding(
            padding: EdgeInsets.fromLTRB(
                20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _applyFilters,
                    icon: Icon(Icons.check_rounded, size: 18),
                    label: Text('تطبيق الفلتر'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _clearFilters,
                  icon: Icon(Icons.close_rounded, size: 18),
                  label: Text('مسح'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: AppColors.border),
                    padding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClubFields() {
    return Column(
      children: [
        _SheetField(
          controller: _countryCtrl,
          label: 'الدولة',
          icon: Icons.flag_rounded,
        ),
        SizedBox(height: 12),
        _SheetField(
          controller: _clubCtrl,
          label: 'النادي',
          icon: Icons.shield_rounded,
        ),
        SizedBox(height: 12),
        _SeasonPickerTile(
          selectedYear: _selectedYear,
          onTap: _pickYear,
        ),
      ],
    );
  }

  Widget _buildOlrFields() {
    return Column(
      children: [
        _SheetField(
          controller: _pointNameCtrl,
          label: 'اسم النقطة',
          icon: Icons.location_on_rounded,
        ),
        SizedBox(height: 12),
        _SheetField(
          controller: _stationCtrl,
          label: 'اسم المحطة',
          icon: Icons.train_rounded,
        ),
        SizedBox(height: 12),
        _SheetField(
          controller: _hobbyistCtrl,
          label: 'اسم الهاوي',
          icon: Icons.person_rounded,
        ),
        SizedBox(height: 12),
        _SeasonPickerTile(
          selectedYear: _selectedYear,
          onTap: _pickYear,
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SheetField(
                controller: _rankCtrl,
                label: 'المركز',
                icon: Icons.emoji_events_rounded,
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _SheetField(
                controller: _birdNumberCtrl,
                label: 'رقم الطير',
                icon: Icons.flutter_dash_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _applyFilters() {
    context.read<RacesBloc>().add(RacesFilterChanged(
          country: _countryCtrl.text.trim(),
          club: _clubCtrl.text.trim(),
          seasonYear: _selectedYear,
          pointName: _pointNameCtrl.text.trim(),
          stationName: _stationCtrl.text.trim(),
          hobbyistName: _hobbyistCtrl.text.trim(),
          rank: _rankCtrl.text.trim(),
          birdNumber: _birdNumberCtrl.text.trim(),
        ));
    Navigator.pop(context);
  }

  void _clearFilters() {
    _countryCtrl.clear();
    _clubCtrl.clear();
    setState(() => _selectedYear = '');
    _pointNameCtrl.clear();
    _stationCtrl.clear();
    _hobbyistCtrl.clear();
    _rankCtrl.clear();
    _birdNumberCtrl.clear();
    context.read<RacesBloc>().add(const RacesFilterChanged());
    Navigator.pop(context);
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  _SheetField({
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
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}

class _SeasonPickerTile extends StatelessWidget {
  final String selectedYear;
  final VoidCallback onTap;

  _SeasonPickerTile({required this.selectedYear, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasValue = selectedYear.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
            SizedBox(width: 12),
            Expanded(
              child: Text(
                hasValue ? selectedYear : 'السيزون',
                style: TextStyle(
                  fontSize: 16,
                  color: hasValue ? AppColors.textPrimary : Colors.grey.shade500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab 2: Global result search ───────────────────────────────────────────────

class _ResultsSearchTab extends StatelessWidget {
  final TextEditingController searchCtrl;

  _ResultsSearchTab({required this.searchCtrl});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RacesBloc, RacesState>(
      builder: (context, state) {
        return Column(
          children: [
            _SearchBar(
              controller: searchCtrl,
              hint: AppLocalizations.of(context).raceSearchHint,
              onChanged: (q) =>
                  context.read<RacesBloc>().add(RaceResultSearchChanged(q)),
            ),
            Expanded(child: _buildBody(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, RacesState state) {
    if (state.status == RacesStatus.loading) {
      return Center(child: CircularProgressIndicator());
    }
    if (state.resultSearchQuery.isEmpty) {
      return _EmptyView(
        icon: Icons.search_rounded,
        message: AppLocalizations.of(context).search4,
      );
    }
    if (state.status == RacesStatus.error) {
      return _ErrorView(
          message: state.errorMessage ??
              AppLocalizations.of(context).errorOccurred6);
    }
    if (state.globalSearchResults.isEmpty) {
      return _EmptyView(message: AppLocalizations.of(context).no22);
    }
    final hasFooter = state.resultSearchHasMore || state.resultSearchLoadingMore;
    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: state.globalSearchResults.length + (hasFooter ? 1 : 0),
      separatorBuilder: (_, index) => SizedBox(height: 8),
      itemBuilder: (context, i) {
        if (i == state.globalSearchResults.length) {
          return _LoadMoreButton(
            loading: state.resultSearchLoadingMore,
            onTap: () => context
                .read<RacesBloc>()
                .add(const RaceResultSearchLoadMoreRequested()),
          );
        }
        return _ResultRow(
          result: state.globalSearchResults[i],
          showRace: true,
        );
      },
    );
  }
}

// ── Shared search bar ─────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  _SearchBar({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textAlign: TextAlign.start,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(Icons.search_rounded),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded),
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
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

// ── Race card ─────────────────────────────────────────────────────────────────

class _RaceCard extends StatelessWidget {
  final RaceModel race;
  final VoidCallback onTap;

  _RaceCard({required this.race, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final releaseDate = _formatDate(race.releaseDatetime);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${race.seasonYear}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    race.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
            SizedBox(height: 10),
            _InfoRow(
              icon: Icons.location_on_rounded,
              label: race.stationName,
            ),
            SizedBox(height: 4),
            _InfoRow(
              icon: Icons.calendar_today_rounded,
              label: releaseDate,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                _StatChip(
                  icon: Icons.flutter_dash_rounded,
                  value: '${race.totalBirds}',
                  label: AppLocalizations.of(context).bird,
                ),
                SizedBox(width: 8),
                _StatChip(
                  icon: Icons.group_rounded,
                  value: '${race.competitorsCount}',
                  label: AppLocalizations.of(context).racer,
                ),
                if (race.plannedDistanceKm != null) ...[
                  SizedBox(width: 8),
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
        SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
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
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.pageBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          SizedBox(width: 4),
          Text(
            label.isNotEmpty ? '$value $label' : value,
            style: TextStyle(
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

// ── Result row ────────────────────────────────────────────────────────────────

class _ResultRow extends StatelessWidget {
  final RaceResultModel result;
  final bool showRace;

  _ResultRow({required this.result, this.showRace = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: Offset(0, 2),
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
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.competitorName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'حلقة: ${result.birdRingNumber}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (showRace && result.raceTitle != null) ...[
                  SizedBox(height: 2),
                  Text(
                    result.raceTitle!,
                    style: TextStyle(
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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '${result.distanceKm.toStringAsFixed(2)} كم',
                style: TextStyle(
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
        return Color(0xFFFFD700);
      case 2:
        return Color(0xFFC0C0C0);
      case 3:
        return Color(0xFFCD7F32);
      default:
        return AppColors.primary;
    }
  }
}

// ── Shared utility widgets ────────────────────────────────────────────────────

class _LoadMoreButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  _LoadMoreButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: loading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : OutlinedButton.icon(
                onPressed: onTap,
                icon: Icon(Icons.expand_more_rounded, size: 18),
                label: Text(AppLocalizations.of(context).loadMore),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
          SizedBox(height: 16),
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

  _ErrorView({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
            SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white),
                child: Text(AppLocalizations.of(context).retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── LEGACY filter bar — replaced by type-aware filter sheet ──────────────────
/*
class _RaceFiltersBar extends StatelessWidget {
  final TextEditingController seasonCtrl;
  final TextEditingController stationCtrl;
  final RacesState state;

  _RaceFiltersBar({
    required this.seasonCtrl,
    required this.stationCtrl,
    required this.state,
  });

  bool get _hasFilters =>
      state.seasonYearFilter.isNotEmpty || state.stationNameFilter.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: EdgeInsets.all(10),
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
                  hint: AppLocalizations.of(context).season,
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _FilterField(
                  controller: stationCtrl,
                  hint: AppLocalizations.of(context).station,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
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
                  icon: Icon(Icons.filter_alt_rounded, size: 18),
                  label: Text(AppLocalizations.of(context).applyFilter),
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
              SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _hasFilters ||
                        seasonCtrl.text.isNotEmpty ||
                        stationCtrl.text.isNotEmpty
                    ? () {
                        seasonCtrl.clear();
                        stationCtrl.clear();
                        context.read<RacesBloc>().add(
                              RacesFilterChanged(
                                seasonYear: '',
                                stationName: '',
                              ),
                            );
                      }
                    : null,
                icon: Icon(Icons.close_rounded, size: 18),
                label: Text(AppLocalizations.of(context).clear),
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

  _FilterField({
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
            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
*/

String _formatDate(String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    return DateFormat('yyyy/MM/dd', 'ar').format(dt);
  } catch (_) {
    return iso;
  }
}
