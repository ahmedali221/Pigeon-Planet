# Races Module — Demo Implementation

## Overview

The Races tab supports two distinct race types, each with its own set of filters accessed via a bottom sheet. Race details can be exported as a PNG image saved to the device.

---

## Race Types

| Type | Arabic | Description |
|---|---|---|
| `RaceType.club` | سباقات الأندية | Club-level races filtered by country, club, and season |
| `RaceType.olr` | سباقات نقاط مشتركة (O.L.R) | Open Long Race / shared-point races |

The active type is stored in `RacesState.raceType` and toggled via `RacesTypeChanged` event. Switching type clears all active filters and reloads the list.

---

## UI Structure

```
RacesPage
└── TabBarView
    ├── Tab 1 — Races
    │   ├── _RaceTypeSwitcher       ← animated Club / O.L.R toggle
    │   ├── Row
    │   │   ├── _SearchBar          ← live search
    │   │   └── _FilterIconButton   ← opens bottom sheet (badge when active)
    │   └── ListView of _RaceCard
    │
    └── Tab 2 — Search Results
        ├── _SearchBar
        └── ListView of _ResultRow
```

---

## Filter Bottom Sheet

Opened by tapping the filter icon. Content depends on the active race type.

### Club Filters
| Field | Arabic | Input |
|---|---|---|
| Country | الدولة | Free text |
| Club | النادي | Free text |
| Season | السيزون | Year picker dialog |

### OLR Filters
| Field | Arabic | Input |
|---|---|---|
| Point name | اسم النقطة | Free text |
| Station name | اسم المحطة | Free text |
| Hobbyist name | اسم الهاوي | Free text |
| Season | السيزون | Year picker dialog |
| Rank | المركز | Numeric |
| Bird number | رقم الطير | Free text |

**Season field** uses Flutter's built-in `YearPicker` widget (range: 2000 → current year + 5). No external package required.

**Filter badge** — a primary-colored dot appears on the filter icon whenever `RacesState.hasActiveFilters` is `true`.

**Backend note:** Only `seasonYear` and `stationName` are currently forwarded to the repository. All other fields are stored in state and ready for wiring once the backend exposes the corresponding query params.

---

## Export as Image

On the Race Detail page:

- The entire detail body is wrapped in a `RepaintBoundary` keyed to `_repaintKey`.
- A `FloatingActionButton.extended` (**تنزيل كصورة**) captures the boundary at `pixelRatio: 3.0`.
- The PNG bytes are saved to:
  ```
  [getApplicationDocumentsDirectory()]/pigeon_races/race_{id}_{timestamp}.png
  ```
- No external package required — uses `path_provider` (already in pubspec) and `dart:io`.
- FAB shows a spinner + **"جاري الحفظ..."** while saving, then a green SnackBar on success.

---

## BLoC Changes

### New Events
```dart
RacesTypeChanged(RaceType raceType)   // switch type, clear filters, reload
RacesFilterChanged(...)               // all filter fields as named params (all optional)
```

### New State Fields
```dart
RaceType raceType          // default: RaceType.club
String countryFilter
String clubFilter
String seasonYearFilter
String pointNameFilter
String stationNameFilter
String hobbyistNameFilter
String rankFilter
String birdNumberFilter
bool hasActiveFilters      // computed getter — drives badge dot
```

---

## Files Changed

| File | Change |
|---|---|
| `lib/features/races/viewmodel/races_state.dart` | `RaceType` enum, 7 new filter fields, `hasActiveFilters` getter |
| `lib/features/races/viewmodel/races_event.dart` | `RacesTypeChanged`, extended `RacesFilterChanged` |
| `lib/features/races/viewmodel/races_bloc.dart` | `_onTypeChanged` handler, updated `_onFilterChanged` |
| `lib/features/races/view/pages/races_page.dart` | Type switcher, filter icon + badge, `_RaceFilterSheet`, `_SeasonPickerTile` |
| `lib/features/races/view/pages/race_detail_page.dart` | `RepaintBoundary`, `_exportAsImage()`, download FAB |

---

## What's Pending (Backend Wiring)

- [ ] Pass `country`, `club`, `pointName`, `hobbyistName`, `rank`, `birdNumber` to `getRaces()` once the backend exposes these query params
- [ ] Add `race_type` filter param to `getRaces()` to return only club or OLR races
- [ ] Add `share_plus` to pubspec if share-to-apps export is needed (current implementation saves to device storage only)
