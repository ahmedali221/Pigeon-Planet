# pigeon_planet

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

## Localization Audit

Run this before or during localization work to find likely user-facing Dart
string literals that still need to move into `AppLocalizations` / ARB files:

```sh
dart run tool/check_unlocalized_text.dart
```

Useful variants:

```sh
dart run tool/check_unlocalized_text.dart lib/features/cart
dart run tool/check_unlocalized_text.dart --locations-only --output=unlocalized_locations.txt
dart run tool/check_unlocalized_text.dart --write-arb lib/features/cart
dart run tool/check_unlocalized_text.dart --format=json
dart run tool/check_unlocalized_text.dart --fail-on-findings
```

`--locations-only` writes a compact `file:line:column` list. `--output`
writes the same report shown in the terminal to a file.

`--write-arb` adds missing findings to `lib/l10n/app_ar.arb` and
`lib/l10n/app_en.arb`, using generated keys and metadata that points back to
the source file/line. Review the generated translations, run Flutter
localization generation, then replace the hard-coded Dart strings with
`AppLocalizations` calls.

`--fail-on-findings` exits with code `1`, so it is intended for CI once the
current backlog has been cleaned up.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
