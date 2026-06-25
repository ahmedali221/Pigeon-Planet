import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/services/permission_service.dart';
import '../../../../../core/services/cloudinary_service.dart';
import '../../../subscription/model/datasources/subscription_packages_remote_datasource.dart';
import '../../../subscription/model/subscription_package_model.dart';
import '../../../subscription/view/pages/packages_page.dart';
import '../../model/seller_product_model.dart';
import '../../model/seller_product_payload.dart';
import '../../viewmodel/seller_products_bloc.dart';

import '../../../../l10n/app_localizations.dart';
class SellerProductFormPage extends StatefulWidget {
  final SellerProductModel? product;

  SellerProductFormPage({super.key, this.product});

  bool get isEdit => product != null;

  @override
  State<SellerProductFormPage> createState() => _SellerProductFormPageState();
}

class _SellerProductFormPageState extends State<SellerProductFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _countCtrl;

  String _selectedCategory = 'accessories';
  bool _isMarketListed = true;
  String _selectedStatus = 'available';

  // Images: local paths (new picks) + existing URLs (edit mode)
  final List<String> _imagePaths = [];
  bool _isUploading = false;
  final _picker = ImagePicker();

  // Package selection (create mode only)
  late final Future<List<ActiveSellerPackageModel>> _activePackagesFuture;
  int? _selectedPackageId;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _titleCtrl = TextEditingController(text: p?.title ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _priceCtrl = TextEditingController(
        text: p != null ? p.price.toStringAsFixed(0) : '');
    _countCtrl =
        TextEditingController(text: p != null ? '${p.count}' : '');
    if (p != null) {
      _selectedCategory = p.category;
      _isMarketListed = p.isMarketListed;
      _selectedStatus = p.status;
      _imagePaths.addAll(p.imageUrls);
    }
    if (!widget.isEdit) {
      _activePackagesFuture = sl<SubscriptionPackagesRemoteDataSource>()
          .fetchActivePackages()
          .then((list) {
        if (list.length == 1 && mounted) {
          setState(() => _selectedPackageId = list.first.id);
        }
        return list;
      });
    } else {
      _activePackagesFuture = Future.value([]);
    }
  }

  Future<void> _pickImage() async {
    final granted = await PermissionService.requestGalleryPermission();
    if (!granted) return;
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1280,
    );
    if (picked != null && _imagePaths.length < 5) {
      setState(() => _imagePaths.add(picked.path));
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _countCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SellerProductsBloc, SellerProductsState>(
      listenWhen: (prev, curr) =>
          curr.mutationStatus != prev.mutationStatus &&
          (curr.mutationStatus == SellerMutationStatus.success ||
              curr.mutationStatus == SellerMutationStatus.failure),
      listener: (context, state) {
        if (state.mutationStatus == SellerMutationStatus.success) {
          Navigator.pop(context);
        } else if (state.mutationStatus == SellerMutationStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.mutationError ?? AppLocalizations.of(context).errorOccurred),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        body: Column(
          children: [
            _FormHeader(isEdit: widget.isEdit),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    // ── Category (create only) ────────────────────────────
                    if (!widget.isEdit) ...[
                      _SectionLabel(AppLocalizations.of(context).alfya2),
                      SizedBox(height: 8),
                      _CategoryDropdown(
                        value: _selectedCategory,
                        onChanged: (v) =>
                            setState(() => _selectedCategory = v!),
                      ),
                      SizedBox(height: 20),
                    ],

                    // ── Title ─────────────────────────────────────────────
                    _SectionLabel(AppLocalizations.of(context).asmAlmntj),
                    SizedBox(height: 8),
                    _Field(
                      controller: _titleCtrl,
                      hint: AppLocalizations.of(context).mthalAlfHmamBrymks,
                      validator: (v) =>
                          (v == null || v.trim().length < 3)
                              ? AppLocalizations.of(context).no23
                              : null,
                    ),
                    SizedBox(height: 20),

                    // ── Description ───────────────────────────────────────
                    _SectionLabel(AppLocalizations.of(context).description),
                    SizedBox(height: 8),
                    _Field(
                      controller: _descCtrl,
                      hint: AppLocalizations.of(context).sfAlmntjBshklWadh,
                      maxLines: 3,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? AppLocalizations.of(context).alwsfMtlwb
                              : null,
                    ),
                    SizedBox(height: 20),

                    // ── Price & Count ─────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionLabel(AppLocalizations.of(context).alsarJM),
                              SizedBox(height: 8),
                              _Field(
                                controller: _priceCtrl,
                                hint: '0',
                                keyboardType:
                                    TextInputType.numberWithOptions(decimal: true),
                                validator: (v) {
                                  final n = double.tryParse(v ?? '');
                                  if (n == null || n <= 0) {
                                    return AppLocalizations.of(context).sarGhyrSalh;
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionLabel(AppLocalizations.of(context).quantity),
                              SizedBox(height: 8),
                              _Field(
                                controller: _countCtrl,
                                hint: '1',
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  final n = int.tryParse(v ?? '');
                                  if (n == null || n < 1) {
                                    return AppLocalizations.of(context).kmyaGhyrSalha;
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // ── Status (edit only) ────────────────────────────────
                    if (widget.isEdit) ...[
                      _SectionLabel(AppLocalizations.of(context).alhala2),
                      SizedBox(height: 8),
                      _StatusDropdown(
                        value: _selectedStatus,
                        onChanged: (v) =>
                            setState(() => _selectedStatus = v!),
                      ),
                      SizedBox(height: 20),
                    ],

                    // ── Images ───────────────────────────────────────────
                    _SectionLabel(AppLocalizations.of(context).alswrHta),
                    SizedBox(height: 8),
                    SizedBox(
                      height: 96,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // Existing / picked images
                          for (final path in _imagePaths)
                            Padding(
                              padding: EdgeInsetsDirectional.only(end: 8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: path.startsWith('http')
                                        ? Image.network(path,
                                            width: 88,
                                            height: 88,
                                            fit: BoxFit.cover)
                                        : Image.file(File(path),
                                            width: 88,
                                            height: 88,
                                            fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: GestureDetector(
                                      onTap: () => setState(
                                          () => _imagePaths.remove(path)),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: EdgeInsets.all(2),
                                        child: Icon(Icons.close,
                                            color: Colors.white, size: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Add-image button
                          if (_imagePaths.length < 5)
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: AppColors.border,
                                      style: BorderStyle.solid),
                                ),
                                child: Icon(Icons.add_a_photo_outlined,
                                    color: AppColors.textHint, size: 28),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // ── Market listed toggle ───────────────────────────────
                    _ListingToggle(
                      value: _isMarketListed,
                      onChanged: (v) =>
                          setState(() => _isMarketListed = v),
                    ),
                    SizedBox(height: 20),

                    // ── Package selector (create only) ────────────────────
                    if (!widget.isEdit) ...[
                      _SectionLabel(AppLocalizations.of(context).packageLabel2),
                      SizedBox(height: 8),
                      _ProductPackageSelector(
                        future: _activePackagesFuture,
                        selectedId: _selectedPackageId,
                        onSelected: (id) =>
                            setState(() => _selectedPackageId = id),
                        onGoToPackages: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PackagesPage()),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],

                    // ── Submit button ─────────────────────────────────────
                    BlocBuilder<SellerProductsBloc, SellerProductsState>(
                      buildWhen: (p, c) =>
                          p.mutationStatus != c.mutationStatus,
                      builder: (context, state) {
                        final busy = _isUploading ||
                            state.mutationStatus ==
                                SellerMutationStatus.creating ||
                            state.mutationStatus ==
                                SellerMutationStatus.updating;
                        return SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: busy ? null : () => _submit(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: busy
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white),
                                      ),
                                      if (_isUploading) ...[
                                        SizedBox(width: 10),
                                        Text('جاري رفع الصور...',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14)),
                                      ]
                                    ],
                                  )
                                : Text(
                                    widget.isEdit ? AppLocalizations.of(context).save5 : AppLocalizations.of(context).add3,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final bloc = context.read<SellerProductsBloc>();
    setState(() => _isUploading = true);

    // Upload any local-path images to Cloudinary; keep existing https:// URLs as-is
    final imageUrls = <String>[];
    final category = widget.isEdit ? widget.product!.category : _selectedCategory;
    final title = _titleCtrl.text.trim();
    for (final path in _imagePaths) {
      if (path.startsWith('http')) {
        imageUrls.add(path);
      } else {
        final url = await CloudinaryService.uploadProductImage(path, category, title);
        if (url != null) imageUrls.add(url);
      }
    }

    if (!mounted) return;
    setState(() => _isUploading = false);

    if (widget.isEdit) {
      bloc.add(SellerProductUpdateRequested(
        id: widget.product!.id,
        category: widget.product!.category,
        payload: SellerProductUpdatePayload(
          title: title,
          description: _descCtrl.text.trim(),
          price: _priceCtrl.text.trim(),
          count: int.parse(_countCtrl.text.trim()),
          isMarketListed: _isMarketListed,
          status: _selectedStatus,
          imageUrls: imageUrls,
        ),
      ));
    } else {
      bloc.add(SellerProductCreateRequested(
        SellerProductPayload(
          category: _selectedCategory,
          title: title,
          description: _descCtrl.text.trim(),
          price: _priceCtrl.text.trim(),
          count: int.parse(_countCtrl.text.trim()),
          isMarketListed: _isMarketListed,
          imageUrls: imageUrls,
          sellerPackageId: _selectedPackageId,
        ),
      ));
    }
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _FormHeader extends StatelessWidget {
  final bool isEdit;
  _FormHeader({required this.isEdit});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: topPadding + 12,
        bottom: 14,
        right: 16,
        left: 16,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white, size: 20),
          ),
          Expanded(
            child: Text(
              isEdit ? AppLocalizations.of(context).edit3 : AppLocalizations.of(context).add4,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 28),
        ],
      ),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  _Field({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textAlign: TextAlign.start,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: AppColors.textHint, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  _CategoryDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final categories = [
      ('accessories', AppLocalizations.of(context).iksswarat, '💊'),
      ('feeds', AppLocalizations.of(context).no24, '🌾'),
      ('supplements', AppLocalizations.of(context).no25, '⚡'),
    ];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          onChanged: onChanged,
          items: categories
              .map((c) => DropdownMenuItem(
                    value: c.$1,
                    child: Text('${c.$3}  ${c.$2}',
                        style: TextStyle(fontSize: 14)),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  _StatusDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final statuses = [
      ('available', AppLocalizations.of(context).mtah),
      ('sold', AppLocalizations.of(context).mbaa),
      ('inactive', AppLocalizations.of(context).active3),
    ];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          onChanged: onChanged,
          items: statuses
              .map((s) => DropdownMenuItem(
                    value: s.$1,
                    child: Text(s.$2,
                        style: TextStyle(fontSize: 14)),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _ListingToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  _ListingToggle({required this.value, required this.onChanged});

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
                  'عرض في المتجر',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'سيظهر المنتج للمشترين في المتجر',
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

// ── Product package selector ──────────────────────────────────────────────────

class _ProductPackageSelector extends StatelessWidget {
  final Future<List<ActiveSellerPackageModel>> future;
  final int? selectedId;
  final ValueChanged<int?> onSelected;
  final VoidCallback onGoToPackages;

  _ProductPackageSelector({
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
              border:
                  Border.all(color: AppColors.orange.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: AppColors.orange, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'لا توجد باقة نشطة — ستُرفض عملية النشر',
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
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3)),
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
                        '${p.remainingPoints} نقطة متبقية · تكلفة المنتج: ${p.productCost} نقطة',
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
        return Column(
          children: [
            for (final p in packages)
              GestureDetector(
                onTap: () => onSelected(p.id),
                child: Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding:
                      EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                              '${p.remainingPoints} نقطة متبقية · تكلفة المنتج: ${p.productCost} نقطة',
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
