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

---

## Mobile App Scope — Customer & Seller Only

The mobile app (`pigeon_planet/`) serves **customers and sellers only**. Manager-only endpoints and admin flows are out of scope for this app. When reading the backend (`../PPW/AGENTS.md`), filter every endpoint by whether a customer or seller can call it. Skip anything that requires a `Manager` active profile.

---

## Backend Reference

**`../PPW/AGENTS.md`** is the source of truth for all endpoints, payload shapes, business rules, actor permissions, and planned phases. Read the relevant section before implementing or modifying any module.

**`../MOBILE_BACKEND_AUDIT.md`** tracks implementation status of every backend module against the mobile app. Update it after completing each module.

---

## Module Implementation Workflow

For every backend module tackled in the mobile app, follow this order strictly:

1. **Compare** — read the relevant `AGENTS.md` section, then scan the current Flutter code (datasources, repos, blocs, pages, models).
2. **Scope** — keep only what customers or sellers can do; exclude manager endpoints entirely.
3. **Pre-implementation list** — before writing any code, produce a written list of:
   - 🐛 Bugs (wrong URLs, wrong field names, broken flows)
   - ❌ Missing implementations (endpoints not wired)
   - ⚠️ Partial implementations (wired but incomplete)
   - 🎨 UI gaps (data available from backend but not displayed or shown incorrectly)
   - Priority order for fixing them
   Present this list and wait for confirmation before proceeding.
4. **Implement** — build fixes following the architecture rules below. UI is updated alongside backend wiring — if data exists on the backend but isn't shown, update the UI too.
5. **Wire navigation** — after creating or completing a module page, search existing screens (home, profile, bottom nav, drawer, action buttons) for any button or tile that should navigate to the new page but currently does nothing or navigates to a stub. Wire those entry points up so the feature is reachable.
6. **Update the audit and changelog** — after every comparison, fix, or backend change:
   - Edit `../MOBILE_BACKEND_AUDIT.md`: change ❌ → ✅, resolve ⚠️/🐛 rows, update the Module Progress table (Last Worked date + Status), and add a dated entry to the Critical Gaps table for anything newly resolved.
   - Edit `../PPW/BACKEND_CHANGELOG.md`: add a dated section for every backend file touched — what changed and why.

Never skip step 3. Never mark a module done with remaining known gaps. Never skip the audit/changelog updates — they are part of completing the task, not optional housekeeping.

---

## Architecture Rules (Non-Negotiable)

### 1. SOLID Principles

- **Single Responsibility** — datasource fetches, repository maps, bloc manages state, widget renders. One job each.
- **Open/Closed** — abstract base classes for datasources and repositories so real vs mock are swappable.
- **Dependency Inversion** — blocs depend on repository abstractions, not concrete datasource classes.

### 2. MVVM + Repository — Layer Order

```
RemoteDataSource  →  Repository  →  Bloc  →  View
(API + raw JSON)     (maps data)    (state)   (pure UI)
```

- No Dio/HTTP calls inside blocs or widgets — always through the repository.
- Blocs receive repository instances via constructor injection.
- Repositories receive datasource instances via constructor injection.

### 3. Feature-Based Folder Structure

```
lib/features/<feature_name>/
  model/
    datasources/       ← abstract interface + real implementation
    repositories/      ← abstract interface + concrete implementation
    models/            ← data models / DTOs
  bloc/                ← events, states, bloc class
  view/
    pages/             ← full-screen pages
    widgets/           ← feature-specific widget classes
```

Shared components go in `lib/core/widgets/` or `lib/shared/widgets/` — not duplicated per feature.

### 4. Custom Widget Classes — Never Widget Functions

Always write `StatelessWidget` / `StatefulWidget` classes. Never a function returning `Widget`.

```dart
// ❌ Wrong
Widget buildCard(BuildContext context) => Card(...);

// ✅ Correct
class PigeonCard extends StatelessWidget {
  const PigeonCard({super.key, required this.pigeon});
  final Pigeon pigeon;
  @override
  Widget build(BuildContext context) => Card(...);
}
```

This enables `const` constructors, correct tree diffing, and `BuildContext` safety.

### 5. Flutter Code Optimization

- Use `const` constructors on every widget, padding, style, and color that doesn't change.
- `ListView.builder` / `GridView.builder` for any list longer than ~5 items.
- `BlocBuilder` with `buildWhen` to narrow rebuilds to only the state fields that changed.
- `BlocListener` for side effects (navigation, snackbars); `BlocBuilder` for UI; `BlocConsumer` only when both are genuinely needed.
- Never create new objects (lists, maps, closures) inside `build()` — lift them to `final` fields or compute once.
- Prefer `SizedBox` over `Container` for spacing-only widgets.

### 6. Reuse Existing App Components

Before creating a new widget:
- Check `lib/core/widgets/` and `lib/shared/` for existing buttons, cards, loaders, empty states, error states.
- Use the app theme for colors, text styles, spacing — never hardcode hex values or font sizes inline.
- Match event/state naming conventions already used in existing blocs.
