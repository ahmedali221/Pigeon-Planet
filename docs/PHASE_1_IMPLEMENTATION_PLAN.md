# Phase 1 implementation plan (BE + Flutter + pigeon-admin)

**Last updated:** 2026-05-13  
**Related:** [PHASE_1.md](../../PHASE_1.md) (repo root), [spec_extracted.txt](../spec_extracted.txt)

This document mirrors the agreed implementation plan: backend APIs, Flutter wiring, and **pigeon-admin** role dashboards. It lists what is **missing today** and what this plan **will implement**.

---

## Repository folder structure (where work happens)

```text
pingeon planet/                    # workspace root
├── PHASE_1.md                     # status report (sibling)
├── PPW-master/                    # Django REST API
│   └── apps/                      # notifications, users (home-summary), …
├── pigeon_planet/                 # Flutter mobile
│   ├── docs/
│   │   ├── PHASE_1_IMPLEMENTATION_PLAN.md   ← this file
│   │   ├── app_spec_summary.md
│   │   └── architecture.md
│   └── lib/                       # features/home, notifications, …
└── pigeon-admin/                  # React web (admin + role dashboards)
    └── src/features/dashboard/    # NEW: Seller + Customer dashboard pages
```

---

## What will be implemented (addresses current missing gaps)

This maps **spec §1.1** (`spec_extracted.txt`), **PHASE_1.md** gaps, and **pigeon-admin** needs to concrete deliverables. Anything **not** listed here is **out of scope** for this plan (unless added later).

### Spec (`spec_extracted.txt` §1.1 — dual account system)

| Missing today | Will be implemented |
|---------------|---------------------|
| **إشعارات مستقلة** per buyer vs seller (no persisted inbox; mock notifications UI) | Django **in-app notifications** (model + list + mark-read + unread count); Flutter **NotificationsPage** + **HomeTopBar** badge; **pigeon-admin** dashboards may consume the same API. |
| **سجل عمليات مستقل** (no per-mode activity feed) | Django **ActivityLog** (or equivalent) + `GET /api/activity/?profile=…`; Flutter **list screen** (or profile later); optional widgets on admin dashboards. |
| **محفظة نقاط مستقل** (static points; no ledger) | Django **PointWallet** + **PointTransaction** + read/history API; Flutter **HomeAccountRow** points from API or home summary. |
| **لوحة بيانات مستقل** (buyer home still mock-heavy vs seller summary) | Django **customer `home-summary`** (parity with seller); Flutter **HomeBloc** + buyer **HomeAccountRow** / sections; **pigeon-admin** `SellerDashboardPage` / `CustomerDashboardPage` using the same JSON. |
| **§1.2** country/currency for seller, locked account currency | Already on profiles; this plan **surfaces** currency/balance in summaries. Stricter **registration enforcement** is a follow-up unless folded into the BE track. |

### `PHASE_1.md` / prior home audit

| Missing today | Will be implemented |
|---------------|---------------------|
| **Notifications API** | Covered by the notifications track above. |
| **Packages API** | `SubscriptionPackage` + list endpoint; Flutter **PackagesPage** from API; optional **current subscription** on seller summary when a `UserSubscription` (or similar) exists. |
| **Customer balance** on home (buyer placeholder) | **Customer home-summary** + Flutter wiring. |
| **Top bar** hardcoded notification badge | **Unread count** from notifications API. |
| **Cart badge** hardcoded | **Optional:** order/cart count endpoint — add to BE track if required; else **defer**. |
| **Full Profile page** (hub for user, toggle, logout) | **Not** in initial work breakdown; notifications + activity reduce the gap; profile shell = **follow-up** milestone. |

### pigeon-admin (role dashboards)

| Missing today | Will be implemented |
|---------------|---------------------|
| No **role-based** landing for Customer/Seller | New folder **`pigeon-admin/src/features/dashboard/`**, route **`/dashboard`**, **post-login redirect** from `profile_type`; **Manager** stays on `/` overview. |
| Same nav for manager and end-users | **AdminLayout:** conditional links; dashboard entry for Customer/Seller. |
| **`profile_type`** not reliably in auth store | **LoginPage / auth.service:** decode JWT or login payload into `setTokens(..., user)`. |

### Explicitly out of scope (this plan does not deliver)

- Real-time **WebSocket** bidding.
- **OTP** verification service + Flutter wire (unless reprioritized).
- **Image upload** pipeline for pigeon / digital ID assets.
- **Marketing** rows: hero, breeders, coming soon (CMS or feeds).
- **Cart** as first-class domain (if separate from `Order`).

---

## pigeon-admin: dashboard feature (confirmed)

**Target:** `pigeon-admin/` (React).

- Add **`src/features/dashboard/`** with:
  - **SellerDashboardPage** — metrics, notifications snippet, quick links (same REST as mobile `home-summary` + notifications + points when available).
  - **CustomerDashboardPage** — orders/balance-oriented summary (customer `home-summary` when implemented).
  - Optional **DashboardLayout** (lighter than full admin) if sellers/customers should not see the full manager sidebar.

**Routing**

- `AuthUser` in `src/core/store/auth.store.ts` already includes `profile_type: 'SELLER' | 'CUSTOMER' | 'MANAGER'`.
- In `src/core/router/index.tsx` (or a small `RoleRedirect` after login):
  - **MANAGER** — default `/` → `OverviewPage` inside `AdminLayout`.
  - **SELLER** / **CUSTOMER** — default landing **`/dashboard`** (variant by role).
- **`/dashboard`** renders seller vs customer page from `useAuthStore((s) => s.user?.profile_type)`; **MANAGER** visiting `/dashboard` redirects to `/`.

**Login**

- Ensure **LoginPage** / **auth.service** persists **`profile_type`** from JWT/backend into `setTokens(..., user)` when non-manager users use this SPA.

**Sidebar**

- **AdminLayout:** hide manager-only links for Customer/Seller; show **لوحة التحكم** → `/dashboard`.

---

## Shared API + Flutter (unchanged intent)

| Track | Backend (PPW-master) | Flutter (pigeon_planet) |
|-------|----------------------|-------------------------|
| Notifications | New app/module: list, mark-read, unread_count | `NotificationsPage`, `home_top_bar.dart` |
| Customer home summary | `GET .../customers/home-summary/` | `HomeBloc`, buyer `HomeAccountRow` |
| Points | `PointWallet` + API | Account row bolt |
| Activity log | `ActivityLog` + `GET /api/activity/` | List screen (or profile later) |
| Packages | `SubscriptionPackage` + list API | `PackagesPage` |

**Admin dashboards** should use **TanStack Query** + `src/core/api/axios.ts` against the same endpoints. If “mobile” URL prefixes are undesirable for web, add **`/api/dashboard/...`** aliases in Django and point both clients there.

---

## Dependency / risk

- **Who may log in to pigeon-admin?** If only **Manager** today, seller/customer dashboards are unused until login supports those roles **or** impersonation is added. Align with product before shipping UI-only routes.

---

## Suggested order of work

1. **Backend:** customer summary + notifications (shared API).
2. **pigeon-admin:** `features/dashboard/` + routes + role redirect + minimal seller dashboard (existing seller `home-summary`).
3. **pigeon-admin:** customer dashboard (customer summary).
4. **Flutter:** wire home / notifications / packages (parallel or after 1–2).
5. **Follow-ups:** points, activity log, packages polish, optional cart count.

---

## Implementation checklist (tracking)

Use this list in PRs; tick when done.

**pigeon-admin**

- [ ] Add `src/features/dashboard/` (`SellerDashboardPage`, `CustomerDashboardPage`, optional `DashboardLayout`)
- [ ] `AppRouter`: `/dashboard` + post-login redirect by `profile_type`; Manager guard
- [ ] `AdminLayout`: conditional nav for Customer/Seller vs Manager
- [ ] `LoginPage` / `auth.service`: map JWT `profile_type` into auth store

**PPW-master**

- [ ] Notifications API + persistence (+ optional signals)
- [ ] Customer `home-summary` endpoint (+ optional `/api/dashboard/...` aliases)
- [ ] (Follow-up) `PointWallet` / `PointTransaction` + API
- [ ] (Follow-up) `ActivityLog` + `GET /api/activity/`
- [ ] (Follow-up) `SubscriptionPackage` + list API

**pigeon_planet**

- [ ] Wire notifications + top bar badge
- [ ] Wire customer summary in `HomeBloc` + buyer balance UI
- [ ] (Follow-up) Points on `HomeAccountRow`
- [ ] (Follow-up) Activity list screen
- [ ] (Follow-up) `PackagesPage` from API
