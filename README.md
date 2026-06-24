# pigeon_planet

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

## Localization Audit

Run this before or during localization work to find Dart files that likely
contain user-facing string literals still needing `AppLocalizations`:

```sh
dart run tool/check_unlocalized_text.dart
```

Useful variants:

```sh
dart run tool/check_unlocalized_text.dart lib/features/cart
dart run tool/check_unlocalized_text.dart --output=unlocalized_files.txt
dart run tool/check_unlocalized_text.dart --locations-only lib/features/cart
dart run tool/check_unlocalized_text.dart --fail-on-findings
```

By default the tool prints only the file path and number of findings in each
file. `--locations-only` prints the exact `file:line:column` locations.
`--output` writes the same report shown in the terminal to a file.

`--fail-on-findings` exits with code `1`, so it is intended for CI once the
current backlog has been cleaned up.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
