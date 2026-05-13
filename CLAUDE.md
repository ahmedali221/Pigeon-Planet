# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Pigeon Planet** is a cross-platform Flutter application — a comprehensive pigeon marketplace with auctions, fixed-price market, loft management, loyalty economy, and a web admin panel. The full product specification is in [docs/architecture.md](docs/architecture.md).

> `lib/main.dart` currently contains only the default Flutter counter demo — all real features are yet to be built.

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run the app (connected device or emulator)
flutter run

# Run on a specific platform
flutter run -d chrome        # Web (Chrome)
flutter run -d windows       # Windows desktop
flutter run -d android       # Android device/emulator

# Build
flutter build apk            # Android APK
flutter build web            # Web
flutter build windows        # Windows

# Test
flutter test                 # All tests
flutter test test/widget_test.dart  # Single test file

# Lint / static analysis
flutter analyze
```

## Architecture

- **Entry point:** `lib/main.dart` — `main()` calls `runApp(MyApp())`
- **App root:** `MyApp` (StatelessWidget) sets up `MaterialApp` with theme and home route
- All UI lives under `lib/`. As the app grows, organize by feature (e.g., `lib/features/`, `lib/widgets/`, `lib/services/`)
- Platform-specific build configs are in `android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/` — generally do not edit these unless dealing with native integration

## Architecture

**Pattern:** MVVM + Feature-First + BLoC + Repository

```
UI (View) ↔ BLoC (ViewModel) ↔ UseCase ↔ Repository (abstract) ↔ DataSource
```

**Folder convention:**
```
lib/
├── core/           # DI (get_it), router (go_router), theme, network (Dio), error types
└── features/
    └── <feature>/
        ├── data/         # datasources/, models/, repositories/ (impl)
        ├── domain/       # entities/, repositories/ (abstract), usecases/
        └── presentation/ # bloc/, pages/, widgets/
```

See [docs/architecture.md](docs/architecture.md) for the full feature breakdown, data-flow examples, and implementation phases.

**Key packages to use:**
- State: `flutter_bloc`, `equatable`
- DI: `get_it`
- Navigation: `go_router`
- Network: `dio`
- Realtime auctions: `web_socket_channel`
- Error handling: `dartz` (Either type)
- Media: `camera`, `ffmpeg_kit_flutter`, `qr_flutter`, `mobile_scanner`
- Localization: `flutter_localizations` + `intl` (Arabic RTL + English, runtime toggle)

## Tech Stack

- Flutter SDK `^3.10.4`, Dart
- Material Design (`uses-material-design: true`)
- Linting via `flutter_lints` (rules in `analysis_options.yaml`)
- Target platforms: Android + iOS (app), Web (admin panel)

## RTL / Arabic Text Direction

`main.dart` sets `locale: Locale('ar')` with `GlobalMaterialLocalizations.delegate` — Flutter's `Directionality` is **RTL globally**. Never add a manual `Directionality` widget or hardcode direction.

### Rules — always follow these:

| Wrong ❌ | Correct ✅ | Why |
|---|---|---|
| `TextAlign.right` | `TextAlign.start` | `.start` respects locale direction |
| `TextAlign.left` | `TextAlign.end` | same reason |
| `CrossAxisAlignment.end` (Column, for Arabic text) | `CrossAxisAlignment.start` | in RTL, `.start` = right side |
| `MainAxisAlignment.end` (Row, for Arabic content) | `MainAxisAlignment.start` | in RTL, `.start` = right side |
| `WrapAlignment.end` | `WrapAlignment.start` | same |
| `EdgeInsets.only(left: x)` for directional padding | `EdgeInsetsDirectional.only(start: x)` | absolute vs logical |

### Row child order in RTL
In RTL, **first child = rightmost**, last child = leftmost. Always write Row children in visual right-to-left order:

```dart
// ✅ Correct — matches visual layout in RTL
Row(children: [
  Icon(emoji),        // rightmost
  Text(name),         // middle
  Spacer(),
  Icon(chevron),      // leftmost
])
```

### What Flutter handles automatically (do nothing extra)
- Row layout direction (reversed)
- `TextAlign.start/end` resolution
- AppBar `actions` → placed on the right (start in RTL)
- `Scaffold`, `ListView`, `GridView` scroll direction

### `Positioned` — absolute, not direction-aware
`Positioned(left: x)` and `Positioned(right: x)` are **absolute** and do NOT flip in RTL. Place them manually according to the visual design. Use `Positioned.directional` only if the element must flip between LTR/RTL.

## Source Specification

Full product requirements (Arabic PDF): `App pigeon planet وثيقة نطاق المشروع ومواصفات التطبيق النهائية2.pdf`
Extracted architecture doc: [docs/architecture.md](docs/architecture.md)
