import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/di/injection.dart';
import '../../model/auction_create_payload.dart';
import '../../model/bird_summary_model.dart';
import '../../viewmodel/auctions_bloc.dart';
import '../../../home/view/pages/seller_my_auctions_page.dart';
import '../../../subscription/view/pages/packages_page.dart';
import '../../../pigeon_id/model/pigeon_model.dart';
import '../../../pigeon_id/model/pigeon_repository.dart';
import '../../../pigeon_id/view/pages/pigeon_id_form_page.dart';
import '../../../pigeon_id/viewmodel/pigeon_id_bloc.dart';

class AuctionCreatePage extends StatefulWidget {
  const AuctionCreatePage({super.key});

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
      initialDate: initial ?? DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
    if (_titleCtrl.text.trim().isEmpty) {
      _showSnack('يرجى إدخال عنوان المزاد');
      return false;
    }
    if (_startTime == null) {
      _showSnack('يرجى تحديد وقت البدء');
      return false;
    }
    if (!_startTime!.isAfter(DateTime.now())) {
      _showSnack('وقت البدء يجب أن يكون في المستقبل');
      return false;
    }
    if (_endTime == null) {
      _showSnack('يرجى تحديد وقت الانتهاء');
      return false;
    }
    if (!_endTime!.isAfter(_startTime!)) {
      _showSnack('وقت الانتهاء يجب أن يكون بعد وقت البدء');
      return false;
    }
    final minBid = double.tryParse(_minBidCtrl.text);
    if (minBid == null || minBid <= 0) {
      _showSnack('يرجى إدخال حد أدنى صحيح للمزايدة');
      return false;
    }
    return true;
  }

  bool _validateStep3() {
    if (_items.isEmpty) {
      _showSnack('يرجى إضافة طائر واحد على الأقل');
      return false;
    }
    bool hasError = false;
    for (final item in _items) {
      final p = double.tryParse(item.startingPrice);
      if (p == null || p <= 0) {
        item.priceError = 'أدخل سعراً صحيحاً';
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
          child: const PigeonIdFormPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      label: 'عرض الباقات',
                      textColor: Colors.white,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PackagesPage(),
                        ),
                      ),
                    )
                  : null,
            ),
          );
        }
        if (state.createdAuction != null && !state.isCreating) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء المزاد بنجاح'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SellerMyAuctionsPage()),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'إنشاء مزاد جديد',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
              onPressed: () {
                if (_step > 1) {
                  setState(() => _step--);
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          body: Column(
            children: [
              _StepIndicator(current: _step, total: 3),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          title: 'بيانات المزاد',
          children: [
            _FieldLabel('عنوان المزاد *'),
            _Input(controller: _titleCtrl, hint: 'مثال: مزاد الحمام البلجيكي'),
            const SizedBox(height: 14),
            _FieldLabel('الوصف'),
            _Input(controller: _descCtrl, hint: 'وصف مختصر للمزاد...', maxLines: 3),
            const SizedBox(height: 14),
            _FieldLabel('صورة المزاد'),
            _ThumbnailPicker(
              path: _thumbnailPath,
              onPick: _pickThumbnail,
              onRemove: () => setState(() => _thumbnailPath = null),
            ),
            const SizedBox(height: 14),
            _FieldLabel('نوع المزاد *'),
            _AuctionTypeSelector(
              selected: _auctionType,
              onChanged: (v) => setState(() => _auctionType = v),
            ),
            const SizedBox(height: 14),
            _FieldLabel('وقت البدء *'),
            _DateButton(
              value: _startTime != null ? _fmtDt(_startTime!) : null,
              hint: 'اختر تاريخ ووقت البدء',
              onTap: () async {
                final dt = await _pickDateTime(context, _startTime);
                if (dt != null) setState(() => _startTime = dt);
              },
            ),
            const SizedBox(height: 14),
            _FieldLabel('وقت الانتهاء *'),
            _DateButton(
              value: _endTime != null ? _fmtDt(_endTime!) : null,
              hint: 'اختر تاريخ ووقت الانتهاء',
              onTap: () async {
                final dt = await _pickDateTime(context, _endTime);
                if (dt != null) setState(() => _endTime = dt);
              },
            ),
            const SizedBox(height: 14),
            _FieldLabel('الحد الأدنى للمزايدة *'),
            _Input(
              controller: _minBidCtrl,
              hint: '1.00',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 14),
            _FieldLabel('الوسوم'),
            _Input(controller: _tagsCtrl, hint: 'racing, champion, ...'),
          ],
        ),
      ],
    );
  }

  // ── Step 2: Options ───────────────────────────────────────────────────────
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          title: 'إعدادات المزاد',
          children: [
            // Auto extend
            _ToggleRow(
              label: 'تمديد تلقائي',
              subtitle: 'تمديد المزاد تلقائياً عند وجود مزايدة في آخر دقائق',
              value: _autoExtend,
              onChanged: (v) => setState(() => _autoExtend = v),
            ),
            if (_autoExtend) ...[
              const SizedBox(height: 10),
              _FieldLabel('مدة التمديد (دقائق)'),
              _Input(
                controller: _autoExtendMinCtrl,
                hint: '5',
                keyboardType: TextInputType.number,
              ),
            ],
            const Divider(height: 28),
            // Buy now
            _ToggleRow(
              label: 'شراء فوري',
              subtitle: 'السماح بالشراء الفوري بسعر محدد',
              value: _buyNow,
              onChanged: (v) => setState(() => _buyNow = v),
            ),
            if (_buyNow) ...[
              const SizedBox(height: 10),
              _FieldLabel('سعر الشراء الفوري *'),
              _Input(
                controller: _buyNowPriceCtrl,
                hint: '0.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
            const Divider(height: 28),
            // Deposit
            _ToggleRow(
              label: 'عربون مطلوب',
              subtitle: 'اشتراط دفع عربون للمشاركة في المزاد',
              value: _depositRequired,
              onChanged: (v) => setState(() => _depositRequired = v),
            ),
            if (_depositRequired) ...[
              const SizedBox(height: 10),
              _FieldLabel('مهلة الدفع (أيام)'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          title: 'الطيور (${_items.length})',
          trailing: GestureDetector(
            onTap: _openPigeonForm,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text('إضافة طائر',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          children: [
            if (_items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.add_circle_outline_rounded,
                          size: 40, color: AppColors.textHint),
                      const SizedBox(height: 8),
                      const Text('لم تتم إضافة طيور بعد',
                          style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _openPigeonForm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('+ إضافة طائر',
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
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
    final item = _items[idx];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
              Text('طائر ${idx + 1}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _items.removeAt(idx)),
                child: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppColors.error),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _BirdChip(bird: item.bird),
          if (_isPairType) ...[
            const SizedBox(height: 8),
            const Text('الطائر المزاوج',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            if (item.pairedBird != null)
              Row(
                children: [
                  Expanded(child: _BirdChip(bird: item.pairedBird!)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => item.pairedBird = null),
                    child: const Icon(Icons.close_rounded,
                        size: 18, color: AppColors.error),
                  ),
                ],
              )
            else
              GestureDetector(
                onTap: () => _openPigeonForm(pairedForIndex: idx),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('+ أضف طائراً مزاوجاً',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 10),
          const Text('سعر البدء *',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.start,
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: const TextStyle(color: AppColors.textHint),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
    final isLast = _step == 3;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
              : Text(
                  isLast ? 'إنشاء المزاد' : 'التالي ←',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
  const _StepIndicator({required this.current, required this.total});

  static const _labels = ['التفاصيل', 'الإعدادات', 'الطيور'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                        : Text('$step',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isActive ? Colors.white : AppColors.textSecondary,
                            )),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _labels[i],
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
  const _SectionCard({required this.title, required this.children, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              if (trailing != null) ...[const Spacer(), trailing!],
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;
  const _Input({
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
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        filled: true,
        fillColor: AppColors.pageBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
  const _DateButton({required this.hint, required this.onTap, this.value});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.pageBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 10),
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
  const _ThumbnailPicker({
    required this.path,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
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
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined,
                  size: 32, color: AppColors.textHint),
              SizedBox(height: 6),
              Text('اختر صورة غلاف للمزاد',
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('تغيير',
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
  const _ToggleRow({
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
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
  const _AuctionTypeSelector({required this.selected, required this.onChanged});

  static const _types = [
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
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                const SizedBox(width: 6),
                Text(t.$3, style: const TextStyle(fontSize: 14)),
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
  const _BirdChip({required this.bird});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bird.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                Text(bird.ringNumber,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary, fontFamily: 'monospace')),
              ],
            ),
          ),
          Text(
            bird.gender == 'male' ? 'ذكر' : bird.gender == 'female' ? 'أنثى' : 'صغير',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
