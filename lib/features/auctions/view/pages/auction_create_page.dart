import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/widgets/ppw_app_bar.dart';
import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../model/auction_create_payload.dart';
import '../../model/bird_summary_model.dart';
import '../../viewmodel/auctions_bloc.dart';
import '../../../home/view/pages/seller_my_auctions_page.dart';
import '../../../subscription/model/datasources/subscription_packages_remote_datasource.dart';
import '../../../subscription/model/subscription_package_model.dart';
import '../../../subscription/view/pages/packages_page.dart';
import '../../../pigeon_id/model/pigeon_model.dart';
import '../../../pigeon_id/model/pigeon_repository.dart';
import '../../../pigeon_id/view/pages/pigeon_id_form_page.dart';
import '../../../pigeon_id/viewmodel/pigeon_id_bloc.dart';

class AuctionCreatePage extends StatefulWidget {
  AuctionCreatePage({super.key});

  @override
  State<AuctionCreatePage> createState() => _AuctionCreatePageState();
}

class _AuctionCreatePageState extends State<AuctionCreatePage> {
  int _step = 1;

  // ── Step 1 controllers ────────────────────────────────────────────────────
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _minBidCtrl = TextEditingController(text: '1.00');
  final _tagsCtrl = TextEditingController();
  DateTime? _startTime;
  DateTime? _endTime;
  String _auctionType = 'single';
  String? _thumbnailPath;
  final _picker = ImagePicker();

  // ── Package selection ─────────────────────────────────────────────────────
  late final Future<List<ActiveSellerPackageModel>> _activePackagesFuture;
  int? _selectedPackageId;

  @override
  void initState() {
    super.initState();
    _activePackagesFuture = sl<SubscriptionPackagesRemoteDataSource>()
        .fetchActivePackages()
        .then((list) {
      if (list.length == 1 && mounted) {
        setState(() => _selectedPackageId = list.first.id);
      }
      return list;
    });
  }

  // ── Step 2 controllers ────────────────────────────────────────────────────
  bool _autoExtend = false;
  final _autoExtendMinCtrl = TextEditingController(text: '5');
  bool _buyNow = false;
  final _buyNowPriceCtrl = TextEditingController();
  bool _depositRequired = false;
  final _deadlineDaysCtrl = TextEditingController(text: '3');

  // ── Step 3 state ──────────────────────────────────────────────────────────
  final List<_ItemRow> _items = [];

  bool get _isPairType => _auctionType == 'pair' || _auctionType == 'breeding';

  int? get _maxItems {
    switch (_auctionType) {
      case 'single':
        return 1;
      case 'multi':
        return 10;
      case 'pair':
      case 'breeding':
        return 1;
      default:
        return null; // racing: no cap
    }
  }

  bool get _canAddMore {
    final max = _maxItems;
    return max == null || _items.length < max;
  }

  ({IconData icon, Color color, String text, String? counter}) get _typeHint {
    final count = _items.length;
    switch (_auctionType) {
      case 'single':
        return (
          icon: Icons.looks_one_rounded,
          color: AppColors.primary,
          text: 'هذا المزاد يقبل طائراً واحداً فقط',
          counter: '$count / 1',
        );
      case 'multi':
        return (
          icon: Icons.format_list_numbered_rounded,
          color: AppColors.blue,
          text: 'أضف من ٢ إلى ١٠ طيور — كل طائر يُزايد عليه بشكل مستقل',
          counter: '$count / 10',
        );
      case 'pair':
        return (
          icon: Icons.people_alt_rounded,
          color: AppColors.orange,
          text: 'أضف طائراً واحداً ثم اختر زوجه من بطاقة الطائر (ذكر + أنثى)',
          counter: '$count / 1',
        );
      case 'breeding':
        return (
          icon: Icons.egg_outlined,
          color: const Color(0xFF7B5EA7),
          text: 'مزاد تناسل — طائر واحد مع زوجه (ذكر + أنثى) من بطاقة الطائر',
          counter: '$count / 1',
        );
      default: // racing
        return (
          icon: Icons.flag_rounded,
          color: AppColors.error,
          text: 'أضف طائرين على الأقل لمجموعة السباق',
          counter: count >= 2 ? null : '$count / 2+',
        );
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _minBidCtrl.dispose();
    _tagsCtrl.dispose();
    _autoExtendMinCtrl.dispose();
    _buyNowPriceCtrl.dispose();
    _deadlineDaysCtrl.dispose();
    super.dispose();
  }

  // ── Thumbnail picker ───────────────────────────────────────────────────────
  Future<void> _pickThumbnail() async {
    final granted = await PermissionService.requestGalleryPermission();
    if (!granted) return;
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1280,
    );
    if (picked != null) {
      setState(() => _thumbnailPath = picked.path);
    }
  }

  // ── Date/time picker ───────────────────────────────────────────────────────
  Future<DateTime?> _pickDateTime(BuildContext context, DateTime? initial) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now().add(Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (date == null || !context.mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial ?? DateTime.now()),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  // ── Validation ─────────────────────────────────────────────────────────────
  bool _validateStep1() {
    final l = AppLocalizations.of(context);
    if (_titleCtrl.text.trim().isEmpty) {
      _showSnack(l.pleaseEnterAuctionTitle);
      return false;
    }
    if (_startTime == null) {
      _showSnack(l.pleaseSelectStartTime);
      return false;
    }
    if (!_startTime!.isAfter(DateTime.now())) {
      _showSnack(l.startTimeMustBeFuture);
      return false;
    }
    if (_endTime == null) {
      _showSnack(l.pleaseSelectEndTime);
      return false;
    }
    if (!_endTime!.isAfter(_startTime!)) {
      _showSnack(l.endTimeAfterStartTime);
      return false;
    }
    final minBid = double.tryParse(_minBidCtrl.text);
    if (minBid == null || minBid <= 0) {
      _showSnack(l.pleaseEnterValidMinBid);
      return false;
    }
    return true;
  }

  bool _validateStep3() {
    final l = AppLocalizations.of(context);
    if (_items.isEmpty) {
      _showSnack(l.pleaseAddAtLeastOneBird);
      return false;
    }
    bool hasError = false;
    for (final item in _items) {
      final p = double.tryParse(item.startingPrice);
      if (p == null || p <= 0) {
        item.priceError = l.enterValidPrice;
        hasError = true;
      }
    }
    if (hasError) {
      setState(() {});
      return false;
    }
    return true;
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _submit() {
    if (!_validateStep3()) return;
    final payload = AuctionCreatePayload(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      auctionType: _auctionType,
      startTime: _startTime!.toUtc().toIso8601String(),
      endTime: _endTime!.toUtc().toIso8601String(),
      autoExtendEnabled: _autoExtend,
      autoExtendMinutes: _autoExtend ? int.tryParse(_autoExtendMinCtrl.text) : null,
      buyNowEnabled: _buyNow,
      buyNowPrice: _buyNow ? _buyNowPriceCtrl.text.trim() : null,
      depositRequired: _depositRequired,
      paymentDeadlineDays: _depositRequired ? int.tryParse(_deadlineDaysCtrl.text) : null,
      minBidIncrement: _minBidCtrl.text.trim(),
      tags: _tagsCtrl.text.trim().isEmpty ? null : _tagsCtrl.text.trim(),
      sellerPackageId: _selectedPackageId,
      thumbnailPath: _thumbnailPath,
      items: _items
          .map((i) => AuctionItemInput(
                birdId: i.bird.id,
                pairedBirdId: i.pairedBird?.id,
                startingPrice: i.startingPrice,
              ))
          .toList(),
    );
    context.read<AuctionsBloc>().add(AuctionCreateRequested(payload));
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  String _fmtDt(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  void _showAddBirdChoice(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddBirdChoiceSheet(
        onNewBird: () {
          Navigator.pop(context);
          _openPigeonForm();
        },
        onExistingBird: () {
          Navigator.pop(context);
          _showExistingBirdsSheet(context);
        },
      ),
    );
  }

  void _showExistingBirdsSheet(BuildContext context) {
    final bloc = context.read<AuctionsBloc>();
    bloc.add(const AuctionSellerBirdsRequested(availableForAuction: true));
    final alreadyAddedIds = _items.map((i) => i.bird.id).toSet();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => BlocProvider.value(
        value: bloc,
        child: _ExistingBirdsPicker(
          alreadyAddedIds: alreadyAddedIds,
          onSelected: (bird) {
            if (!mounted) return;
            Navigator.pop(sheetCtx);
            setState(() => _items.add(_ItemRow(bird: bird)));
          },
        ),
      ),
    );
  }

  void _openPigeonForm({int? pairedForIndex}) {
    final auctionRoute = ModalRoute.of(context)!;
    final pigeonBloc = PigeonIdBloc(
      repository: sl<PigeonRepository>(),
      onBirdSaved: (PigeonModel pigeon) {
        if (!mounted) return;
        final bird = BirdSummaryModel(
          id: pigeon.id ?? 0,
          name: pigeon.name.isNotEmpty ? pigeon.name : pigeon.ringNumber,
          ringNumber: pigeon.ringNumber,
          gender: pigeon.gender == PigeonGender.male ? 'male' : 'female',
          colour: pigeon.breed,
          achievements: pigeon.achievements,
          flyingSpeed: pigeon.flyingSpeed,
          price: pigeon.price,
          imageUrls: pigeon.thumbnailUrl != null ? [pigeon.thumbnailUrl!] : [],
        );
        setState(() {
          if (pairedForIndex != null) {
            _items[pairedForIndex].pairedBird = bird;
          } else {
            _items.add(_ItemRow(bird: bird));
          }
        });
        Navigator.of(context).popUntil((route) => route == auctionRoute);
      },
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: pigeonBloc,
          child: PigeonIdFormPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return BlocConsumer<AuctionsBloc, AuctionsState>(
      listenWhen: (p, c) =>
          p.isCreating != c.isCreating ||
          p.createError != c.createError ||
          p.createdAuction?.id != c.createdAuction?.id,
      listener: (context, state) {
        if (state.createError != null) {
          final isPackageError = state.createError!.toLowerCase().contains('package') ||
              state.createError!.contains('باقة') ||
              state.createError!.contains('نقاط') ||
              state.createError!.contains('permission') ||
              state.createError!.contains('403');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.createError!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: isPackageError ? 6 : 4),
              action: isPackageError
                  ? SnackBarAction(
                      label: l.viewPackages,
                      textColor: Colors.white,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PackagesPage(),
                        ),
                      ),
                    )
                  : null,
            ),
          );
        }
        if (state.createdAuction != null && !state.isCreating) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.auctionCreatedSuccess),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => SellerMyAuctionsPage()),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: PPWAppBar(
            title: l.createNewAuction,
            onBackPressed: () {
              if (_step > 1) {
                setState(() => _step--);
              } else {
                Navigator.pop(context);
              }
            },
          ),
          body: Column(
            children: [
              _StepIndicator(current: _step, total: 3),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: _step == 1
                      ? _buildStep1()
                      : _step == 2
                          ? _buildStep2()
                          : _buildStep3(),
                ),
              ),
              _buildBottomBar(state),
            ],
          ),
        );
      },
    );
  }

  // ── Step 1: Auction details ────────────────────────────────────────────────
  Widget _buildStep1() {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          title: l.auctionData,
          children: [
            _FieldLabel(l.auctionTitleFieldLabel),
            _Input(controller: _titleCtrl, hint: l.auctionTitleExample),
            SizedBox(height: 14),
            _FieldLabel(l.description),
            _Input(controller: _descCtrl, hint: l.auctionDescBriefHint, maxLines: 3),
            SizedBox(height: 14),
            _FieldLabel(l.auctionImage),
            _ThumbnailPicker(
              path: _thumbnailPath,
              onPick: _pickThumbnail,
              onRemove: () => setState(() => _thumbnailPath = null),
            ),
            SizedBox(height: 14),
            _FieldLabel(l.auctionTypeField),
            _AuctionTypeSelector(
              selected: _auctionType,
              onChanged: (v) => setState(() => _auctionType = v),
            ),
            SizedBox(height: 14),
            _FieldLabel(l.startTimeField),
            _DateButton(
              value: _startTime != null ? _fmtDt(_startTime!) : null,
              hint: l.chooseStartDateTime,
              onTap: () async {
                final dt = await _pickDateTime(context, _startTime);
                if (dt != null) setState(() => _startTime = dt);
              },
            ),
            SizedBox(height: 14),
            _FieldLabel(l.endTimeField),
            _DateButton(
              value: _endTime != null ? _fmtDt(_endTime!) : null,
              hint: l.chooseEndDateTime,
              onTap: () async {
                final dt = await _pickDateTime(context, _endTime);
                if (dt != null) setState(() => _endTime = dt);
              },
            ),
            SizedBox(height: 14),
            _FieldLabel(l.minBidField),
            _Input(
              controller: _minBidCtrl,
              hint: '1.00',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 14),
            _FieldLabel(l.tagsFieldLabel),
            _Input(controller: _tagsCtrl, hint: 'racing, champion, ...'),
            SizedBox(height: 14),
            _FieldLabel(l.usedPackageLabel),
            _PackageSelector(
              future: _activePackagesFuture,
              selectedId: _selectedPackageId,
              onSelected: (id) => setState(() => _selectedPackageId = id),
              onGoToPackages: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PackagesPage()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Step 2: Options ───────────────────────────────────────────────────────
  Widget _buildStep2() {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          title: l.auctionSettings,
          children: [
            // Auto extend
            _ToggleRow(
              label: l.autoExtend,
              subtitle: l.autoExtendDesc,
              value: _autoExtend,
              onChanged: (v) => setState(() => _autoExtend = v),
            ),
            if (_autoExtend) ...[
              SizedBox(height: 10),
              _FieldLabel(l.extensionDuration),
              _Input(
                controller: _autoExtendMinCtrl,
                hint: '5',
                keyboardType: TextInputType.number,
              ),
            ],
            Divider(height: 28),
            // Buy now
            _ToggleRow(
              label: l.buyNowDialogTitle,
              subtitle: l.buyNowDesc,
              value: _buyNow,
              onChanged: (v) => setState(() => _buyNow = v),
            ),
            if (_buyNow) ...[
              SizedBox(height: 10),
              _FieldLabel(l.buyNowPriceField),
              _Input(
                controller: _buyNowPriceCtrl,
                hint: '0.00',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
            Divider(height: 28),
            // Deposit
            _ToggleRow(
              label: l.depositRequired,
              subtitle: l.depositRequiredDesc,
              value: _depositRequired,
              onChanged: (v) => setState(() => _depositRequired = v),
            ),
            if (_depositRequired) ...[
              SizedBox(height: 10),
              _FieldLabel(l.paymentDeadlineDays),
              _Input(
                controller: _deadlineDaysCtrl,
                hint: '3',
                keyboardType: TextInputType.number,
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ── Step 3: Birds ─────────────────────────────────────────────────────────
  Widget _buildStep3() {
    final l = AppLocalizations.of(context);
    final hint = _typeHint;
    final canAdd = _canAddMore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          title: l.birdsCount(_items.length),
          trailing: canAdd
              ? GestureDetector(
                  onTap: () => _showAddBirdChoice(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(l.addBirdLabel,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )
              : null,
          children: [
            // ── Type requirement hint ────────────────────────────────────
            Container(
              margin: EdgeInsets.only(bottom: 14),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: hint.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: hint.color.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Icon(hint.icon, color: hint.color, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      hint.text,
                      style: TextStyle(
                          fontSize: 12,
                          color: hint.color,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  if (hint.counter != null) ...[
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: hint.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        hint.counter!,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: hint.color),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (_items.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.add_circle_outline_rounded,
                          size: 40, color: AppColors.textHint),
                      SizedBox(height: 8),
                      Text(l.noBirdsAdded,
                          style: TextStyle(color: AppColors.textSecondary)),
                      SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _showAddBirdChoice(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(l.addBirdBtn,
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...List.generate(_items.length, _buildItemCard),
          ],
        ),
      ],
    );
  }

  Widget _buildItemCard(int idx) {
    final l = AppLocalizations.of(context);
    final item = _items[idx];
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.pageBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l.birdNumber(idx + 1),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary)),
              Spacer(),
              GestureDetector(
                onTap: () => setState(() => _items.removeAt(idx)),
                child: Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppColors.error),
              ),
            ],
          ),
          SizedBox(height: 8),
          _BirdChip(bird: item.bird),
          if (_isPairType) ...[
            SizedBox(height: 8),
            Text(l.pairedBird,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            SizedBox(height: 6),
            if (item.pairedBird != null)
              Row(
                children: [
                  Expanded(child: _BirdChip(bird: item.pairedBird!)),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => item.pairedBird = null),
                    child: Icon(Icons.close_rounded,
                        size: 18, color: AppColors.error),
                  ),
                ],
              )
            else
              GestureDetector(
                onTap: () => _openPigeonForm(pairedForIndex: idx),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(l.addPairedBird,
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ),
                ),
              ),
          ],
          SizedBox(height: 10),
          Text(l.startingPriceField,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          SizedBox(height: 6),
          TextField(
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.start,
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: TextStyle(color: AppColors.textHint),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: item.priceError != null ? AppColors.error : AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: item.priceError != null ? AppColors.error : AppColors.border),
              ),
              errorText: item.priceError,
            ),
            onChanged: (v) => setState(() {
              item.startingPrice = v;
              item.priceError = null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(AuctionsState state) {
    final l = AppLocalizations.of(context);
    final isLast = _step == 3;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: state.isCreating
              ? null
              : () {
                  if (_step == 1) {
                    if (_validateStep1()) setState(() => _step = 2);
                  } else if (_step == 2) {
                    setState(() => _step = 3);
                  } else {
                    _submit();
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: state.isCreating
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
              : Text(
                  isLast ? l.createAuction : l.nextArrow,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────

class _ItemRow {
  final BirdSummaryModel bird;
  String startingPrice = '';
  BirdSummaryModel? pairedBird;
  String? priceError;

  _ItemRow({required this.bird});
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  _StepIndicator({required this.current, required this.total});

    @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final labels = [l.details, l.settings, l.birds];
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(total, (i) {
          final step = i + 1;
          final isActive = step == current;
          final isDone = step < current;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone || isActive ? AppColors.primary : AppColors.pageBackground,
                    border: Border.all(
                      color: isDone || isActive ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Center(
                    child: isDone
                        ? Icon(Icons.check_rounded, size: 14, color: Colors.white)
                        : Text('$step',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isActive ? Colors.white : AppColors.textSecondary,
                            )),
                  ),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (step < total)
                  Expanded(
                    child: Container(
                      height: 1,
                      color: step < current ? AppColors.primary : AppColors.border,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? trailing;
  _SectionCard({required this.title, required this.children, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              if (trailing != null) ...[Spacer(), trailing!],
            ],
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;
  _Input({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textAlign: TextAlign.start,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
        filled: true,
        fillColor: AppColors.pageBackground,
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String? value;
  final String hint;
  final VoidCallback onTap;
  _DateButton({required this.hint, required this.onTap, this.value});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.pageBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textSecondary),
            SizedBox(width: 10),
            Text(
              value ?? hint,
              style: TextStyle(
                fontSize: 14,
                color: value != null ? AppColors.textPrimary : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThumbnailPicker extends StatelessWidget {
  final String? path;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  _ThumbnailPicker({
    required this.path,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (path == null) {
      return GestureDetector(
        onTap: onPick,
        child: Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.pageBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined,
                  size: 32, color: AppColors.textHint),
              SizedBox(height: 6),
              Text(l.chooseCoverImage,
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Image.file(
            File(path!),
            width: double.infinity,
            height: 160,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 8,
            left: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              onTap: onPick,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(l.change,
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  _ToggleRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
          activeTrackColor: AppColors.primaryLight,
        ),
      ],
    );
  }
}

class _AuctionTypeSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  _AuctionTypeSelector({required this.selected, required this.onChanged});

  static final _types = [
    ('single', 'فردي', '🐦'),
    ('multi', 'متعدد', '🐦‍🐦'),
    ('pair', 'زوج', '💑'),
    ('breeding', 'تناسل', '🥚'),
    ('racing', 'سباق', '🏁'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _types.map((t) {
        final isSelected = selected == t.$1;
        return GestureDetector(
          onTap: () => onChanged(t.$1),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryLight : AppColors.pageBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.$2,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                SizedBox(width: 6),
                Text(t.$3, style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _BirdChip extends StatelessWidget {
  final BirdSummaryModel bird;
  _BirdChip({required this.bird});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryLight,
            backgroundImage:
                bird.thumbnailUrl != null ? NetworkImage(bird.thumbnailUrl!) : null,
            child: bird.thumbnailUrl == null
                ? Text(
                    bird.name.isNotEmpty ? bird.name[0].toUpperCase() : '?',
                    style: TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                  )
                : null,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bird.name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                Text(bird.ringNumber,
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary, fontFamily: 'monospace')),
              ],
            ),
          ),
          Text(
            bird.gender == 'male' ? l.male : bird.gender == 'female' ? l.female : l.chick,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Add-bird choice bottom sheet ──────────────────────────────────────────────

class _AddBirdChoiceSheet extends StatelessWidget {
  final VoidCallback onNewBird;
  final VoidCallback onExistingBird;

  _AddBirdChoiceSheet({required this.onNewBird, required this.onExistingBird});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l.addBirdLabel,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _ChoiceOptionTile(
            icon: Icons.add_circle_outline_rounded,
            iconColor: AppColors.primary,
            title: 'إضافة طائر جديد',
            subtitle: 'أنشئ بيانات طائر جديد وأضفه إلى المزاد',
            onTap: onNewBird,
          ),
          const SizedBox(height: 12),
          _ChoiceOptionTile(
            icon: Icons.inventory_2_outlined,
            iconColor: AppColors.blue,
            title: 'اختيار من طيوري',
            subtitle: 'اختر طائراً موجوداً لم يُدرج في مزاد أو متجر',
            onTap: onExistingBird,
          ),
        ],
      ),
    );
  }
}

class _ChoiceOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _ChoiceOptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.pageBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left_rounded, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

// ── Existing-birds picker sheet ───────────────────────────────────────────────

class _ExistingBirdsPicker extends StatelessWidget {
  final Set<int> alreadyAddedIds;
  final void Function(BirdSummaryModel) onSelected;

  _ExistingBirdsPicker({
    required this.alreadyAddedIds,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'اختر طائراً',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'طيوري المتاحة للإضافة في المزاد',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Divider(height: 20, color: AppColors.divider),
          Expanded(
            child: BlocBuilder<AuctionsBloc, AuctionsState>(
              buildWhen: (p, c) =>
                  p.sellerBirds != c.sellerBirds ||
                  p.sellerBirdsLoading != c.sellerBirdsLoading,
              builder: (context, state) {
                if (state.sellerBirdsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                final birds = state.sellerBirds
                    .where((b) => !alreadyAddedIds.contains(b.id))
                    .toList();

                if (birds.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.flutter_dash_rounded,
                              size: 48, color: AppColors.textHint),
                          const SizedBox(height: 12),
                          const Text(
                            'لا توجد طيور متاحة',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'جميع طيورك مدرجة في مزادات أو المتجر',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: birds.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _ExistingBirdTile(
                    bird: birds[i],
                    onTap: () => onSelected(birds[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExistingBirdTile extends StatelessWidget {
  final BirdSummaryModel bird;
  final VoidCallback onTap;

  _ExistingBirdTile({required this.bird, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.pageBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryLight,
              backgroundImage:
                  bird.thumbnailUrl != null ? NetworkImage(bird.thumbnailUrl!) : null,
              child: bird.thumbnailUrl == null
                  ? Text(
                      bird.name.isNotEmpty ? bird.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bird.name.isNotEmpty ? bird.name : bird.ringNumber,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bird.ringNumber,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  bird.gender == 'male'
                      ? l.male
                      : bird.gender == 'female'
                          ? l.female
                          : l.chick,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                if (bird.colour.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    bird.colour,
                    style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.add_circle_rounded, color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Package selector ──────────────────────────────────────────────────────────

class _PackageSelector extends StatelessWidget {
  final Future<List<ActiveSellerPackageModel>> future;
  final int? selectedId;
  final ValueChanged<int?> onSelected;
  final VoidCallback onGoToPackages;

  _PackageSelector({
    required this.future,
    required this.selectedId,
    required this.onSelected,
    required this.onGoToPackages,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ActiveSellerPackageModel>>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 40,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final packages = snap.data ?? [];
        if (packages.isEmpty) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.orangeLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.orange.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: AppColors.orange, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'لا توجد باقة نشطة — ستُرفض عملية الإنشاء',
                    style: TextStyle(
                        color: AppColors.orange,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                TextButton(
                  onPressed: onGoToPackages,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.orange,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text('اشترك', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          );
        }
        if (packages.length == 1) {
          final p = packages.first;
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.verified_rounded,
                    color: AppColors.primary, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.package.name,
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${p.remainingPoints} نقطة متبقية · تكلفة المزاد: ${p.auctionCost} نقطة',
                        style: TextStyle(
                            color: AppColors.primary.withValues(alpha: 0.8),
                            fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        // Multiple active packages — show a picker
        return Column(
          children: [
            for (final p in packages)
              GestureDetector(
                onTap: () => onSelected(p.id),
                child: Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: selectedId == p.id
                        ? AppColors.primaryLight
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selectedId == p.id
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selectedId == p.id
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: selectedId == p.id
                            ? AppColors.primary
                            : AppColors.textHint,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.package.name,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary),
                            ),
                            Text(
                              '${p.remainingPoints} نقطة متبقية · تكلفة المزاد: ${p.auctionCost} نقطة',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
