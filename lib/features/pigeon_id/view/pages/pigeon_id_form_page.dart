import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/ppw_app_bar.dart';
import '../../model/pigeon_model.dart';
import '../../viewmodel/pigeon_id_bloc.dart';
import '../widgets/pigeon_id_shared_widgets.dart';
import 'pigeon_id_photos_page.dart';

import '../../../../l10n/app_localizations.dart';

class PigeonIdFormPage extends StatefulWidget {
  final PigeonModel? initialPigeon;
  PigeonIdFormPage({super.key, this.initialPigeon});

  @override
  State<PigeonIdFormPage> createState() => _PigeonIdFormPageState();
}

class _PigeonIdFormPageState extends State<PigeonIdFormPage> {
  final _ringCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _achievementsCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _speedCtrl = TextEditingController();
  final _fatherCtrl = TextEditingController();
  final _motherCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final p = widget.initialPigeon;
    if (p != null) {
      _ringCtrl.text = p.ringNumber;
      _nameCtrl.text = p.name;
      _breedCtrl.text = p.breed;
      _achievementsCtrl.text = p.achievements;
      _priceCtrl.text = p.price > 0 ? p.price.toStringAsFixed(0) : '';
      _descCtrl.text = p.description;
      _speedCtrl.text =
          p.flyingSpeed != null ? p.flyingSpeed!.toStringAsFixed(1) : '';
      _fatherCtrl.text = p.fatherId != null ? '${p.fatherId}' : '';
      _motherCtrl.text = p.motherId != null ? '${p.motherId}' : '';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<PigeonIdBloc>().add(PigeonIdLoadedForEdit(p));
        }
      });
    }
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _achievementsCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _speedCtrl.dispose();
    _fatherCtrl.dispose();
    _motherCtrl.dispose();
    super.dispose();
  }

  void _pickHatchDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 30)),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
      helpText: AppLocalizations.of(context).hatchDate,
    );
    if (picked != null && context.mounted) {
      context.read<PigeonIdBloc>().add(PigeonIdHatchDateChanged(picked));
    }
  }

  void _next(BuildContext context, PigeonIdState state) {
    if (!state.canProceedToPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pigeonFormValidation),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<PigeonIdBloc>(),
          child: PigeonIdPhotosPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PigeonIdBloc, PigeonIdState>(
      listenWhen: (prev, curr) =>
          curr.status == PigeonIdStatus.updated ||
          (curr.status == PigeonIdStatus.error &&
              prev.status == PigeonIdStatus.updating),
      listener: (context, state) {
        if (state.status == PigeonIdStatus.updated) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).birdDataUpdated),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state.status == PigeonIdStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ?? AppLocalizations.of(context).errorOccurred,
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isEditMode = state.editingId != null;
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: PPWAppBar(
            title: isEditMode
                ? AppLocalizations.of(context).editBird
                : AppLocalizations.of(context).digitalId,
          ),
          body: Column(
            children: [
              if (!isEditMode)
                PigeonStepHeader(
                  current: 1,
                  total: 4,
                  label: AppLocalizations.of(context).pigeonBasicData,
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Ring number ──────────────────────────────────
                      PigeonFieldLabel(text: AppLocalizations.of(context).ringNumberRequired),
                      SizedBox(height: 6),
                      PigeonAppInput(
                        controller: _ringCtrl,
                        hint: 'EG-2024-001',
                        onChanged: (v) => context
                            .read<PigeonIdBloc>()
                            .add(PigeonIdRingNumberChanged(v)),
                      ),

                      SizedBox(height: 16),

                      // ── Breed ────────────────────────────────────────
                      PigeonFieldLabel(text: AppLocalizations.of(context).breedRequired),
                      SizedBox(height: 6),
                      PigeonAppInput(
                        controller: _breedCtrl,
                        hint: AppLocalizations.of(context).breedHint,
                        onChanged: (v) => context
                            .read<PigeonIdBloc>()
                            .add(PigeonIdBreedChanged(v)),
                      ),

                      SizedBox(height: 16),

                      // ── Gender ───────────────────────────────────────
                      PigeonFieldLabel(text: AppLocalizations.of(context).genderRequired),
                      SizedBox(height: 8),
                      _GenderSelector(
                        selected: state.gender,
                        onChanged: (g) => context
                            .read<PigeonIdBloc>()
                            .add(PigeonIdGenderChanged(g)),
                      ),

                      SizedBox(height: 20),

                      // ── Optional divider ─────────────────────────────
                      Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12),
                            child: Text(
                              AppLocalizations.of(context).optionalData,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),

                      SizedBox(height: 16),

                      // ── Hatch date ───────────────────────────────────
                      PigeonFieldLabel(text: AppLocalizations.of(context).hatchDate),
                      SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => _pickHatchDate(context),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded,
                                  size: 18,
                                  color: AppColors.textSecondary),
                              SizedBox(width: 10),
                              Text(
                                state.hatchDate != null
                                    ? '${state.hatchDate!.day}/${state.hatchDate!.month}/${state.hatchDate!.year}'
                                    : AppLocalizations.of(context).chooseHatchDate,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: state.hatchDate != null
                                      ? AppColors.textPrimary
                                      : AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // ── Achievements ─────────────────────────────────
                      PigeonFieldLabel(text: AppLocalizations.of(context).achievementsRequired),
                      SizedBox(height: 6),
                      PigeonAppInput(
                        controller: _achievementsCtrl,
                        hint: AppLocalizations.of(context).achievementsHint,
                        onChanged: (v) => context
                            .read<PigeonIdBloc>()
                            .add(PigeonIdAchievementsChanged(v)),
                      ),

                      SizedBox(height: 16),

                      // ── Stamina ability ──────────────────────────────
                      PigeonFieldLabel(text: AppLocalizations.of(context).staminaRequired),
                      SizedBox(height: 8),
                      _StaminaSelector(
                        selected: state.staminaAbility,
                        onChanged: (s) => context
                            .read<PigeonIdBloc>()
                            .add(PigeonIdStaminaChanged(s)),
                      ),

                      SizedBox(height: 20),

                      // ── Optional divider ─────────────────────────────
                      Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              AppLocalizations.of(context).saleData,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),

                      SizedBox(height: 16),

                      // ── Display name ─────────────────────────────────
                      PigeonFieldLabel(text: AppLocalizations.of(context).displayName),
                      SizedBox(height: 6),
                      PigeonAppInput(
                        controller: _nameCtrl,
                        hint: AppLocalizations.of(context).displayNameHint,
                        onChanged: (v) => context
                            .read<PigeonIdBloc>()
                            .add(PigeonIdNameChanged(v)),
                      ),

                      SizedBox(height: 16),

                      // ── Price ─────────────────────────────────────────
                      PigeonFieldLabel(text: AppLocalizations.of(context).priceEgpRequired),
                      SizedBox(height: 6),
                      PigeonAppInput(
                        controller: _priceCtrl,
                        hint: AppLocalizations.of(context).priceHint,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        onChanged: (v) => context
                            .read<PigeonIdBloc>()
                            .add(PigeonIdPriceChanged(v)),
                      ),

                      SizedBox(height: 16),

                      // ── Description ───────────────────────────────────
                      PigeonFieldLabel(text: AppLocalizations.of(context).description),
                      SizedBox(height: 6),
                      PigeonAppInput(
                        controller: _descCtrl,
                        hint: AppLocalizations.of(context).auctionDescBriefHint,
                        maxLines: 3,
                        onChanged: (v) => context
                            .read<PigeonIdBloc>()
                            .add(PigeonIdDescriptionChanged(v)),
                      ),

                      SizedBox(height: 16),

                      // ── Flying speed ──────────────────────────────────
                      PigeonFieldLabel(text: AppLocalizations.of(context).flyingSpeedKmh),
                      SizedBox(height: 6),
                      PigeonAppInput(
                        controller: _speedCtrl,
                        hint: AppLocalizations.of(context).flyingSpeedHint,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        onChanged: (v) => context
                            .read<PigeonIdBloc>()
                            .add(PigeonIdFlyingSpeedChanged(v)),
                      ),

                      // ── Bird status (edit only) ───────────────────────
                      if (state.editingId != null) ...[
                        SizedBox(height: 16),
                        PigeonFieldLabel(text: AppLocalizations.of(context).birdStatus),
                        SizedBox(height: 8),
                        _BirdStatusSelector(
                          selected: state.birdStatus,
                          onChanged: (s) => context
                              .read<PigeonIdBloc>()
                              .add(PigeonIdStatusChanged(s)),
                        ),
                      ],

                      SizedBox(height: 16),

                      // ── Market listing toggle ─────────────────────────
                      _BirdListingToggle(
                        value: state.isMarketListed,
                        onChanged: (v) => context
                            .read<PigeonIdBloc>()
                            .add(PigeonIdMarketListedChanged(v)),
                      ),

                      SizedBox(height: 20),

                      // ── Parent birds (optional) ───────────────────────
                      Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              AppLocalizations.of(context).pedigreeData,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),

                      SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PigeonFieldLabel(text: AppLocalizations.of(context).fatherRingOptional),
                                SizedBox(height: 6),
                                PigeonAppInput(
                                  controller: _fatherCtrl,
                                  hint: AppLocalizations.of(context).birdIdHint,
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) => context
                                      .read<PigeonIdBloc>()
                                      .add(PigeonIdFatherChanged(v)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PigeonFieldLabel(
                                  text: AppLocalizations.of(context)
                                      .motherRingOptional,
                                ),
                                SizedBox(height: 6),
                                PigeonAppInput(
                                  controller: _motherCtrl,
                                  hint: AppLocalizations.of(context).birdIdHint,
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) => context
                                      .read<PigeonIdBloc>()
                                      .add(PigeonIdMotherChanged(v)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              isEditMode
                  ? PigeonNextButton(
                      label: state.status == PigeonIdStatus.updating
                          ? AppLocalizations.of(context).saving
                          : AppLocalizations.of(context).saveChanges,
                      enabled: state.isReadyToSubmit &&
                          state.status != PigeonIdStatus.updating,
                      onTap: () => context
                          .read<PigeonIdBloc>()
                          .add(PigeonIdSubmitted()),
                    )
                  : PigeonNextButton(
                      label: AppLocalizations.of(context).nextAddPhotos,
                      enabled: state.canProceedToPhotos,
                      onTap: () => _next(context, state),
                    ),
            ],
          ),
        );
      },
    );
  }
}

// ── Local widgets ────────────────────────────────────────────────────────────

class _GenderSelector extends StatelessWidget {
  final PigeonGender selected;
  final ValueChanged<PigeonGender> onChanged;

  _GenderSelector(
      {required this.selected, required this.onChanged});

  List<({PigeonGender gender, String label, String emoji, Color color, Color bg})>
      _options(AppLocalizations l) => [
            (
              gender: PigeonGender.male,
              label: l.male,
              emoji: '🔵',
              color: AppColors.blue,
              bg: AppColors.blueLight,
            ),
            (
              gender: PigeonGender.female,
              label: l.female,
              emoji: '🔴',
              color: AppColors.red,
              bg: AppColors.redLight,
            ),
            (
              gender: PigeonGender.young,
              label: l.genderYoung,
              emoji: '🟡',
              color: AppColors.orange,
              bg: AppColors.orangeLight,
            ),
          ];

  @override
  Widget build(BuildContext context) {
    final options = _options(AppLocalizations.of(context));
    return Row(
      children: options.asMap().entries.map((e) {
        final idx = e.key;
        final option = e.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(end: idx < 2 ? 8 : 0),
            child: _GenderOption(
              label: option.label,
              emoji: option.emoji,
              isSelected: selected == option.gender,
              selectedColor: option.color,
              selectedBg: option.bg,
              onTap: () => onChanged(option.gender),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final Color selectedColor;
  final Color selectedBg;
  final VoidCallback onTap;

  _GenderOption({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.selectedColor,
    required this.selectedBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? selectedColor : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: 24)),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color:
                    isSelected ? selectedColor : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaminaSelector extends StatelessWidget {
  final StaminaAbility selected;
  final ValueChanged<StaminaAbility> onChanged;

  _StaminaSelector({required this.selected, required this.onChanged});

  String _labelFor(AppLocalizations l, StaminaAbility stamina) {
    switch (stamina) {
      case StaminaAbility.excellent:
        return l.staminaExcellent;
      case StaminaAbility.verygood:
        return l.staminaVeryGood;
      case StaminaAbility.good:
        return l.staminaGood;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: StaminaAbility.values.map((s) {
        final isSelected = s == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(s),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              margin: EdgeInsetsDirectional.only(
                end: s != StaminaAbility.good ? 8 : 0,
              ),
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryLight : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                _labelFor(l, s),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _BirdStatusSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  List<({String value, String label, Color color})> _options(
    AppLocalizations l,
  ) =>
      [
        (value: 'available', label: l.available, color: AppColors.success),
        (value: 'inactive', label: l.inactive, color: AppColors.textSecondary),
        (value: 'sold', label: l.statusSold, color: AppColors.blue),
      ];

  _BirdStatusSelector(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = _options(AppLocalizations.of(context));
    return Row(
      children: options.asMap().entries.map((e) {
        final idx = e.key;
        final option = e.value;
        final isSelected = selected == option.value;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(option.value),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              margin: EdgeInsetsDirectional.only(end: idx < 2 ? 8 : 0),
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? option.color.withValues(alpha: 0.12)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? option.color : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                option.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? option.color : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _BirdListingToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  _BirdListingToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).listInMarket,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context).listInMarketDesc,
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

