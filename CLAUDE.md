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

## Requirements Audit Workflow

When the user shares PDF requirement images for a module, follow this order strictly — **before any code**:

1. **Extract requirements** — read the images and list every rule, condition, and constraint verbatim.
2. **Cross-check AGENTS.md** — read the relevant section in `../PPW/AGENTS.md` and identify related modules (e.g., auction chat touching both `chat` and `auctions` apps).
3. **Scan Flutter code** — find the feature folder(s) in `lib/features/` and audit current implementation.
4. **Write gap tables to `../REQUIREMENTS_AUDIT.md`** — backend gaps only:
   - Requirements extracted from the PDF
   - Backend gap table (requirement vs actual backend), with file + line citations
   - Proposed implementation order
5. **List Flutter/UI gaps in the chat** — do NOT write Flutter gaps to the MD file. Report them conversationally so the user can see what's pending.
6. **Wait for confirmation** — do NOT write any code until the user explicitly approves.
7. **Implement** — backend first, then Flutter UI, following the architecture rules below. Report Flutter progress in the chat as each piece is done.
8. **Fill Post-Implementation Notes** in `../REQUIREMENTS_AUDIT.md` — backend changes only (what was built, what changed, why).
9. **Update audit files** — `../MOBILE_BACKEND_AUDIT.md` and `../PPW/BACKEND_CHANGELOG.md`.

The `../REQUIREMENTS_AUDIT.md` file tracks backend gaps and post-implementation notes only. Flutter UI work is discussed and confirmed in the chat.

---

## Combined Module Comparison Workflow

This is the canonical workflow for every module review session. It covers the backend, mobile app, and dashboard simultaneously.

**Step 1 — Read the backend**
Read the backend module code: `../PPW/apps/<module>/` — models, serializers, views, urls, services. Cross-reference `../PPW/AGENTS.md` for business rules, permission patterns, and what each endpoint returns/accepts.

**Step 2 — List mobile gaps (customer & seller scope only)**
Scan the Flutter feature folder (`lib/features/<module>/`): datasources, repos, blocs, pages, widgets, models.
Produce a gap list:
- 🐛 Bugs (wrong URL, wrong field name, broken flow)
- ❌ Missing (endpoint/feature not wired at all)
- ⚠️ Partial (wired but incomplete — missing fields, missing UI, wrong payload)
- 🎨 UI gaps (backend returns data but UI doesn't show it)

Exclude manager-only endpoints — mobile is customer/seller only.

**Step 3 — List dashboard gaps (managerial scope only)**
Scan the Next.js dashboard (`../lotfy-dashboard/src/app/admin/<module>/`): page components, TS types, API calls, forms.
Produce a gap list using the same categories (🐛 ❌ ⚠️ 🎨).

Focus only on what managers can do (list, retrieve, approve, reject, create, update, delete admin-facing data). Skip customer/seller-only flows.

**Step 4 — Present and wait**
Present both gap lists (mobile + dashboard) together before writing any code. Label each gap clearly with its target (Mobile or Dashboard). Wait for explicit confirmation before proceeding.

**Step 5 — Implement**
Implement approved gaps in priority order. Mobile follows architecture rules below. Dashboard follows its existing Next.js/TypeScript patterns. UI is updated alongside wiring — if data exists on the backend but isn't shown, update the UI too.

**Step 6 — Wire navigation (mobile)**
After completing a mobile module page, search existing screens (home, profile, bottom nav, drawer, action buttons) for orphaned buttons/tiles that should navigate to the new page. Wire them before marking done.

**Step 7 — Create test flow file**
Create `../docs/testing/TEST_<MODULE>.md` with manual test steps for the module:
- Mobile section: happy path + edge cases for customer and seller flows
- Dashboard section: happy path + edge cases for manager flows
- Optional API sanity checks (endpoint, method, payload, expected response)

One file per module. Never combine modules.

**Step 8 — Update audit files**
After every module:
- `../MOBILE_BACKEND_AUDIT.md` — update status rows, Module Progress table, Critical Gaps table.
- `../PPW/BACKEND_CHANGELOG.md` — dated entry for every backend file touched.
- `../MODULE_COMPARISON.md` — update the Progress Table row (status + date + notes) and append a Module Detail Log entry listing every fix (M1/D1…) and all files changed.
- `project_dashboard_sync_session.md` memory — update module progress table.

Never skip step 4. Never mark a module done with remaining known gaps. Test flow and audit file updates are part of completing the task, not optional.

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
