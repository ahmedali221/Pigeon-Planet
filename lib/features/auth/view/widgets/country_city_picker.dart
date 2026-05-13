import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_countries.dart';
import '../../../../core/constants/app_strings.dart';

class CountryCityPicker extends StatefulWidget {
  final void Function(String country, String city) onChanged;

  const CountryCityPicker({super.key, required this.onChanged});

  @override
  State<CountryCityPicker> createState() => _CountryCityPickerState();
}

class _CountryCityPickerState extends State<CountryCityPicker> {
  AppCountry? _selectedCountry;
  String? _selectedCity;
  final _cityController = TextEditingController();

  List<String> get _cities =>
      _selectedCountry != null
          ? (AppCountries.citiesByCountry[_selectedCountry!.name] ?? [])
          : [];

  bool get _hasCityList => _cities.isNotEmpty;

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _notify() {
    if (_selectedCountry != null) {
      final city = _hasCityList ? (_selectedCity ?? '') : _cityController.text;
      widget.onChanged(_selectedCountry!.name, city);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Country dropdown
        _PickerLabel(
          label: AppStrings.country,
          icon: Icons.language_rounded,
          iconColor: AppColors.primary,
          child: DropdownButtonFormField<AppCountry>(
            value: _selectedCountry, // ignore: deprecated_member_use
            isExpanded: true,
            hint: const Text(AppStrings.countryHint),
            decoration: const InputDecoration(),
            items: AppCountries.all
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(
                        '${c.flag}  ${c.name}',
                        textDirection: TextDirection.rtl,
                      ),
                    ))
                .toList(),
            onChanged: (c) {
              setState(() {
                _selectedCountry = c;
                _selectedCity = null;
                _cityController.clear();
              });
              _notify();
            },
          ),
        ),

        const SizedBox(height: 16),

        // City — dropdown if list exists, free text otherwise
        _PickerLabel(
          label: AppStrings.city,
          icon: Icons.location_on_outlined,
          iconColor: AppColors.orange,
          child: _selectedCountry == null
              // Disabled placeholder
              ? TextFormField(
                  enabled: false,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    hintText: AppStrings.cityHint,
                  ),
                )
              : _hasCityList
                  ? DropdownButtonFormField<String>(
                      value: _selectedCity, // ignore: deprecated_member_use
                      isExpanded: true,
                      hint: Text(AppStrings.cityHintActive),
                      decoration: const InputDecoration(),
                      items: _cities
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c,
                                    textDirection: TextDirection.rtl),
                              ))
                          .toList(),
                      onChanged: (v) {
                        setState(() => _selectedCity = v);
                        _notify();
                      },
                    )
                  : TextFormField(
                      controller: _cityController,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: AppStrings.cityHintActive,
                      ),
                      onChanged: (_) => _notify(),
                    ),
        ),
      ],
    );
  }
}

class _PickerLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _PickerLabel({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Text(' *',
                style: TextStyle(color: AppColors.error, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
