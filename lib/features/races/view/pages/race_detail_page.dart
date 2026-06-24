import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/ppw_app_bar.dart';
import '../../model/race_model.dart';
import '../../viewmodel/races_bloc.dart';

import '../../../../l10n/app_localizations.dart';
class RaceDetailPage extends StatefulWidget {
  final int raceId;

  RaceDetailPage({super.key, required this.raceId});

  @override
  State<RaceDetailPage> createState() => _RaceDetailPageState();
}

class _RaceDetailPageState extends State<RaceDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<RacesBloc>().add(RaceDetailRequested(widget.raceId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: const PPWAppBar(
        title: 'تفاصيل السباق',
      ),
      body: BlocBuilder<RacesBloc, RacesState>(
        builder: (context, state) {
          if (state.detailStatus == RacesDetailStatus.loading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state.detailStatus == RacesDetailStatus.error) {
            return _ErrorBody(
              message: state.detailErrorMessage ?? 'حدث خطأ في تحميل السباق',
              onRetry: () => context
                  .read<RacesBloc>()
                  .add(RaceDetailRequested(widget.raceId)),
            );
          }
          final race = state.selectedRace;
          if (race == null) {
            return Center(child: CircularProgressIndicator());
          }
          return _RaceDetailBody(race: race, state: state);
        },
      ),
    );
  }
}

class _RaceDetailBody extends StatelessWidget {
  final RaceModel race;
  final RacesState state;

  _RaceDetailBody({required this.race, required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RaceInfoCard(race: race),
          SizedBox(height: 20),
          Text(
            'نتائج السباق',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          if (state.detailResults.isEmpty)
            _EmptyResults()
          else ...[
            _ResultsTable(results: state.detailResults),
            if (state.detailResultsHasMore || state.detailResultsLoadingMore)
              _LoadMoreButton(
                loading: state.detailResultsLoadingMore,
                onTap: () => context
                    .read<RacesBloc>()
                    .add(RaceDetailResultsLoadMoreRequested(race.id)),
              ),
          ],
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _RaceInfoCard extends StatelessWidget {
  final RaceModel race;

  _RaceInfoCard({required this.race});

  @override
  Widget build(BuildContext context) {
    final releaseDate = _formatDatetime(race.releaseDatetime);
    return Container(
      width: double.infinity,
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
                padding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${race.seasonYear}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  race.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          _DetailRow(icon: Icons.location_on_rounded, label: AppLocalizations.of(context).station, value: race.stationName),
          _DetailRow(icon: Icons.access_time_rounded, label: 'وقت الإطلاق', value: releaseDate),
          _DetailRow(icon: Icons.flutter_dash_rounded, label: 'عدد الطيور', value: '${race.totalBirds}'),
          _DetailRow(icon: Icons.group_rounded, label: 'عدد المتسابقين', value: '${race.competitorsCount}'),
          if (race.plannedDistanceKm != null)
            _DetailRow(
              icon: Icons.straighten_rounded,
              label: 'المسافة المخططة',
              value: '${race.plannedDistanceKm!.toStringAsFixed(3)} كم',
            ),
          if (race.weatherCondition.isNotEmpty)
            _DetailRow(
              icon: Icons.wb_sunny_rounded,
              label: 'حالة الطقس',
              value: race.weatherCondition,
            ),
          if (race.notes.isNotEmpty)
            _DetailRow(icon: Icons.notes_rounded, label: 'ملاحظات', value: race.notes),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsTable extends StatelessWidget {
  final List<RaceResultModel> results;

  _ResultsTable({required this.results});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header row
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  'المركز',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Text(
                  'المتسابق / الحلقة',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(width: 4),
              Expanded(
                flex: 2,
                child: Text(
                  'السرعة / المسافة',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4),
        // Result rows
        ...results.asMap().entries.map((entry) {
          final i = entry.key;
          final r = entry.value;
          return Container(
            margin: EdgeInsets.only(bottom: 4),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: i.isEven ? Colors.white : Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Container(
                    height: 28,
                    decoration: BoxDecoration(
                      color: _rankColor(r.rank),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${r.rank}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.competitorName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        r.birdRingNumber,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${r.speed.toStringAsFixed(2)} م/ث',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        '${r.distanceKm.toStringAsFixed(2)} كم',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
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

class _EmptyResults extends StatelessWidget {
  _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.list_alt_rounded, size: 48, color: Colors.grey.shade300),
            SizedBox(height: 12),
            Text(
              'لا توجد نتائج لهذا السباق بعد',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  _LoadMoreButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12),
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
                ),
              ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: Colors.redAccent),
            SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white),
              child: Text(AppLocalizations.of(context).retry),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDatetime(String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    return DateFormat('yyyy/MM/dd HH:mm', 'ar').format(dt);
  } catch (_) {
    return iso;
  }
}
