# Pigeon Planet — Full Architecture & Vision Document

## 1. App Overview

**Pigeon Planet** is a comprehensive cross-platform (Android + iOS) pigeon marketplace platform with a Web Admin Panel. It is the world's first carrier-pigeon platform to implement a tamper-proof digital identity + ownership history for each bird.

### Core Pillars
| Pillar | Description |
|---|---|
| Auction System | Multi-type real-time auctions |
| Fixed Market | Instant-buy pigeon marketplace |
| Products Store | Supplies, feed, accessories |
| Loft Program | Full digital loft & pedigree manager |
| PP Coins | Internal loyalty economy |
| Admin Panel | Web dashboard for full platform control |

### Languages & Platforms
- Arabic + English (dynamic switch at runtime)
- Flutter Hybrid App: Android + iOS
- Flutter Web: Admin Panel

### Revenue Model
- Prepaid seller subscription packages
- Commission packages (earnest-money deposit deducted per sale)
- Auction boost / promotion services (paid)
- Optional paid features (e.g., Voice Bot)
- Fixed commission on sales (per package tier)

---

## 2. Architecture Decision

### Pattern: MVVM + Feature-First + BLoC + Repository

```
UI (View)  ←→  BLoC (ViewModel)  ←→  UseCase  ←→  Repository  ←→  DataSource
```

- **View**: Flutter Widgets / Pages — presents state, dispatches events
- **BLoC**: Receives events, calls use cases, emits states — zero business logic
- **UseCase**: Single-responsibility domain action — contains the business rule
- **Repository (abstract)**: Domain-layer contract, no implementation details
- **Repository (impl)**: Data layer — coordinates remote + local data sources
- **DataSource**: Raw data access (API, Firestore, SharedPreferences, etc.)

### Dual Account Model
Every user has both a **Buyer profile** and a **Seller profile** under one account. A toggle button switches the active mode. Each mode has independent: dashboard, notifications, points wallet, and transaction history.

---

## 3. Project Folder Structure

```
lib/
├── core/
│   ├── constants/          # API URLs, asset paths, config keys
│   ├── di/                 # GetIt service locator setup (injection.dart)
│   ├── error/              # Failure classes, AppException
│   ├── network/            # Dio client, interceptors, NetworkInfo
│   ├── router/             # GoRouter route definitions + guards
│   ├── theme/              # AppTheme, AppColors, AppTextStyles
│   └── utils/              # Extensions, validators, formatters
│
├── features/
│   ├── auth/
│   ├── account/            # Dual account toggle, profile, country/currency
│   ├── pigeon_id/          # Digital ID, QR, video capture, ownership history
│   ├── auction/            # All auction types + bidding engine
│   ├── market/             # Fixed-price market + products store
│   ├── loft/               # Loft management + pedigree + AI scanner
│   ├── points/             # PP Coins, levels, badges, cashback
│   ├── rewards/            # Challenges, lucky wheel, prizes
│   ├── packages/           # Subscription packages + earnest-money system
│   ├── chat/               # 1-to-1 messaging + in-auction chat
│   ├── seller_dashboard/   # Seller metrics + post-sale workflow
│   ├── payment/            # Payment gateway integration + shipping
│   ├── notifications/      # Push + in-app notification management
│   └── admin/              # Web admin panel features
│
└── main.dart
```

### Per-Feature Structure (consistent across all features)

```
features/<feature_name>/
├── data/
│   ├── datasources/
│   │   ├── <feature>_remote_datasource.dart
│   │   └── <feature>_local_datasource.dart
│   ├── models/             # JSON-serializable DTO models (extend entities)
│   └── repositories/
│       └── <feature>_repository_impl.dart
├── domain/
│   ├── entities/           # Pure Dart classes, no JSON annotations
│   ├── repositories/
│   │   └── <feature>_repository.dart   # Abstract interface
│   └── usecases/           # One file per use case
└── presentation/
    ├── bloc/
    │   ├── <feature>_bloc.dart
    │   ├── <feature>_event.dart
    │   └── <feature>_state.dart
    ├── pages/
    └── widgets/
```

---

## 4. Features Breakdown

### 4.1 `auth` — Authentication & Registration

**Entities:** `UserEntity` (id, email, phone, name, country, currency, createdAt)

**Use Cases:**
- `RegisterUseCase` — phone + email registration, mandatory seller country/currency selection
- `LoginUseCase`
- `LogoutUseCase`
- `VerifyOtpUseCase`
- `RefreshTokenUseCase`

**BLoC States:** `AuthInitial`, `AuthLoading`, `AuthAuthenticated(user)`, `AuthUnauthenticated`, `AuthError(message)`

**Business Rules:**
- Seller's country/currency is locked after first registration — cannot change later
- Currency applies to all auctions created by this seller

---

### 4.2 `account` — Dual Account (Bilateral Accounts)

**Entities:** `SellerProfileEntity`, `BuyerProfileEntity`, `ActiveModeEntity(mode: buyer|seller)`

**Use Cases:**
- `SwitchAccountModeUseCase` — toggles buyer ↔ seller with no logout
- `UpdateSellerProfileUseCase`
- `UpdateBuyerProfileUseCase`
- `GetSellerBadgesUseCase` — 18 seller badges
- `GetBuyerBadgesUseCase` — 18 buyer badges

**BLoC States:** `AccountModeChanged(mode)`, `ProfileUpdated`, `BadgesLoaded(badges)`

**Business Rules:**
- Each mode has its own: dashboard, notifications stream, points wallet, transaction history
- Toggle visible as a persistent top bar switch

---

### 4.3 `pigeon_id` — Pigeon Digital ID

**Entities:** `PigeonEntity`, `OwnershipRecordEntity`, `QRCodeEntity`, `PigeonVideoEntity`

**Use Cases:**
- `CreatePigeonIdUseCase` — validates all mandatory fields before saving
- `GenerateQrCodeUseCase`
- `ScanQrCodeUseCase` — shows bird profile; if scanned by buyer shows "Add to Loft" button
- `RequestLoftAdditionUseCase` — buyer scans → seller gets notification → seller approves/rejects
- `RecordVideoUseCase` — wraps in-app camera with Zajel Scanner UI
- `MergeVideosUseCase` — calls FFmpeg to merge 4 clips into 20s video + watermark + anti-fraud code
- `TransferOwnershipUseCase` — appends to ownership chain on full payment
- `GetOwnershipHistoryUseCase`

**Mandatory fields (cannot publish without):**
- Ring number (text)
- Breed / Pedigree (text + tree)
- Minimum 4 photos
- Mandatory video (in-app only; no external video upload)
- Auto-generated QR Code
- Gender (male/female — displayed with distinct color in cover)

**Optional:** Hatch date, race results

**Video Capture UI (Zajel Scanner):**
- Transparent pigeon-shaped overlay
- Leveler (turns green when phone is straight)
- Progress stepper: 4 stages — Full Body 🦢, Wing (L/R), Eye 👁️ (macro), Ring Number 🔢
- Auto-capture when element is clear (no button press, prevents shake)
- FFmpeg post-processing: merge → 20s video → add watermark, date, ring number, anti-fraud animated code, optional ambient music

**Data retention:** Bird data auto-deleted 7 days after auction ends; invoices/ownership history manually deletable after 1 month.

---

### 4.4 `auction` — Auction System

**Entities:** `AuctionEntity`, `BidEntity`, `AuctionResultEntity`, `RaffleEntity`

#### Auction Types
| Type | Key | Description |
|---|---|---|
| Single Bird | `single` | 1 bird, 1 winner |
| Multi-Bird | `multi` | 2–10 birds, independent bidding per bird, same end time |
| Breeding Pair | `breeding_pair` | ♂ + ♀ together, 1 bid, 1 winner |
| Squab Pair | `squab_pair` | Young pigeon pair, shows age + parent data |
| One Loft Race | `one_loft_race` | Multiple race birds, independent bids, sorted by classification |

#### Bidding Modes (seller sets before publish, cannot change after)
| Mode | Key | Description |
|---|---|---|
| Instant Free Bid | `instant_free` | Bid and win immediately, no payment deadline extension, no deposit |
| Conditional Bid | `conditional` | Winner has 60 min to pay deposit (seller sets %). Non-payment = auto-ban. Full balance due within 7/14/30 days (seller sets). Failing full payment = 100% deposit forfeit to seller |

#### Anti-Sniping Timer
- Seller sets 3–5 minute grace window
- Any bid within the window resets the countdown
- When timer expires with no bids → current highest bidder wins

#### Advanced Bidding Features
- **Bidder Duel** (in last 10 min): Top bidder can send a challenge message to a chosen rival
- **Last-Moment Reward**: 5 PP Coins per bid in last 5 minutes; "Ignites the End" badge (1 week)
- **Admin Target**: Admin sets a milestone amount; first to reach it wins a prize (badge/discount/money)
- **Full Auction Challenge**: Bid on all birds in a multi-auction → consolation prize + badge
- **Electronic Raffle**: After auction ends, auto-raffle among all participants; seller chooses public/private

#### Silent Auction (Section 3.6)
- No current price shown to anyone
- Each bidder places a secret max price
- AI picks highest at end → announces winner + final price only

**Use Cases:**
- `CreateAuctionUseCase`
- `PlaceBidUseCase`
- `WatchAuctionLiveUseCase` (stream)
- `GetAuctionDetailsUseCase`
- `EndAuctionUseCase`
- `ProcessConditionalBidDepositUseCase`
- `ProcessRaffleUseCase`
- `BoostAuctionUseCase` (paid promotion)

**BLoC:** `AuctionBloc` handles live events via WebSocket stream

---

### 4.5 `market` — Fixed Market + Products Store

**Entities:** `FixedListingEntity`, `ProductEntity`, `CartEntity`, `OrderEntity`

**Listing Dual-Path:** When a seller publishes a bird, they choose:
- "Publish as Auction" → goes to auction system
- "Publish at Fixed Price" → goes to Fixed Market

**Fixed Market Rules:**
- Same digital ID requirements as auctions (ring, 4 photos, mandatory video)
- Buyer sees: final price + shipping cost, "Buy Now" or "Add to Cart" buttons
- Payment: in-app gateway (commission deducted) OR request seller's payment details (shown in private screen, no commission)

**Products Store Categories:** Supplies (cages, nests, feeders), Nutritional supplements & medicines, Feed (grain mixes, seeds), Accessories (rings, clips, stickers, books)

**Products Store Rules:**
- No digital ID required
- Seller sets: quantity, shipping options per product/category
- Multi-item cart, same payment methods

**Transaction Completion Flow (5 steps — applies to all sales):**
1. Seller taps 📨 Send Invoice
2. Buyer taps 💳 Pay
3. Seller confirms ✅ Payment Received
4. Seller taps 📦 Shipped / Delivered
5. Buyer taps ✅ Received

> PP Coins are only awarded after Step 5.

**Use Cases:** `ListBirdFixedUseCase`, `AddToCartUseCase`, `CheckoutUseCase`, `ConfirmDeliveryUseCase`, `RateSaleUseCase`

---

### 4.6 `loft` — Loft Management Program

**Entities:** `LoftEntity`, `LoftBirdEntity`, `PedigreeEntity`, `RaceResultEntity`

**Reference implementation:** colopig.com — build equivalent with improvements

**Sub-features:**
- **Pedigree Templates (Section 4.2):** 10+ designs (tree, table, classic, modern); each with 3 color options + per-cell manual color; add breeder logo; fixed QR in corner; printable as PDF/PNG
- **AI Pedigree Scanner (Section 4.3):** Upload photo of existing pedigree → AI extracts: ring number, breed, father, mother, grandparents, hatch dates, race results → user reviews & edits → save. Reduces data entry from 10 min to 10 sec
- **Race Results Sync (Section 4.4):** Sync with club races and individual point races. After filling data, results appear automatically; can save as PDF/JPEG
- **Pedigree Designer (Section 4.6):** Full designer tool

**Subscription Plans (Section 4.5):** 3–4 tiers (fully configurable from admin dashboard), includes: bird limit, monthly pedigree certificate quota, access to premium templates, optional 7-day free trial

**QR Integration:** When a QR is scanned via the Loft app → shows full bird profile page; presents "Add to My Loft" button for buyers

---

### 4.7 `points` — PP Coins & Gamification

**Entities:** `PPCoinsWalletEntity`, `SellerLevelEntity`, `BuyerLevelEntity`, `BadgeEntity`

**PP Coins (🪙 PP):**
- Internal currency — NOT withdrawable as cash
- Earned via: commercial activity (auctions, sales, purchases) + interactive activity (bids, referrals, reviews, last-minute bids)
- Points only awarded after completed transaction (Step 5 of sale flow)
- Can be purchased directly in-app (credit cards / e-wallets) for: exclusive raffles, discounts, premium features

**Seller Levels:** tiered levels based on PP Coins accumulated
**Buyer Levels:** tiered levels based on PP Coins accumulated

**Cashback (Section 5.6):** 1–5% of purchase value → credited as PP Coins

**Badges:**
- 18 Seller Badges + 18 Buyer Badges
- Some are automatic (milestone-based), some are purchasable / require point threshold
- Displayed on user's profile and auction cards

**Use Cases:** `EarnPointsUseCase`, `SpendPointsUseCase`, `BuyPointsUseCase`, `GetWalletUseCase`, `AwardBadgeUseCase`, `GetUserLevelUseCase`

---

### 4.8 `rewards` — Incentives & Prizes

**Entities:** `ChallengeEntity`, `WheelSpinEntity`, `PrizeEntity`

**Onboarding Rewards:** 100 PP Coins free on sign-up + 20% discount on first boost

**Referral Challenge (Monthly):**
- Top user who shares the most app links wins prizes (iPhone, AirPods, etc.)
- New member acceptance is manual by admin (anti-bot)
- UI: countdown timer, Top 10 leaderboard, personal progress bar "Your points: 15 | Gap to 1st: 5"

**Seasonal Seller Awards:** Admin-defined. Criteria: total completed sales (40%), buyer ratings (30%), zero-cancellation streak (20%), buyer engagement (10%)

**Lucky Wheel (Section 13.2):**
- Small floating icon on left side of screen
- Appears only when conditions are met
- Spins with sound effects

**Million Challenge (Section 13.3):**
- Dedicated screen with large countdown, Top 10 leaderboard, personal progress bar, floating share button

**Prize Delivery:**
- Digital prizes → auto-credited to account
- Physical/monetary prizes → user fills form (name, address, ID) → admin reviews → manual delivery

---

### 4.9 `packages` — Subscriptions

**Entities:** `PackageEntity`, `EarnestMoneyAccountEntity`, `SubscriptionEntity`

#### Prepaid Packages
- Seller pays upfront; fixed number of auctions or duration included
- Tiers: Starter / Pro / Elite (exact amounts configurable from admin panel)

#### Commission Packages (Earnest Money System)
- No upfront monthly fee
- Seller deposits earnest money (e.g., 1000 EGP) into app wallet
- Each completed sale → commission deducted from earnest balance
- When balance reaches zero → all seller's auctions auto-paused
- System notification: "Earnest balance depleted, add [amount] to resume auctions"
- Payment only via in-app gateway (no external)

#### Promotion Services
- Paid boost: elevates auction ranking/visibility
- Paid highlight: featured placement in home feed

---

### 4.10 `chat` — Communication

**Entities:** `ConversationEntity`, `MessageEntity`, `AuctionChatEntity`

**Rules:**
- One-to-one private messages only (no group chat)
- In-auction public chat is optional (seller enables per auction); no bid buttons inside chat
- **Auto-filter in all chats:**
  - Phone numbers → auto-blocked + instant warning to sender + violation logged
  - WhatsApp accounts → same
  - External contact links → same

**Smart Block (Section 9.4):**
- Blocking a buyer does NOT hide auctions from them (they can still browse and read descriptions)
- Blocked buyer cannot bid or send messages

---

### 4.11 `seller_dashboard` — Seller Control Panel

**Entities:** `SellerStatsEntity`, `AuctionManagementEntity`, `ShippingSettingsEntity`

**Dashboard Metrics:** Active auctions, total sales, highest sale price, most-engaged auction

**Wallet Section:** PP Coins balance, earnest money balance, transaction history

**Achievements:** Current badges, current level, prizes won

**Auction Management:** Create new, edit/pause active, view completed results

**Post-Sale Workflow:** Follows the 5-step flow (see market section)

**Settings:** Shipping options + payment details (bank account, Vodafone Cash, etc. — shown only to winning buyer in private screen)

---

### 4.12 `payment` — Payment & Shipping

**Supported Payment Methods:**
- Credit/Debit cards (Visa, Mastercard, Mada, etc.) via secure payment gateway
- E-wallets: Apple Pay, Google Pay, local wallets per country
- Manual bank transfer
- Cash on delivery

**Critical Policy:**
- ALL platform-related payments (packages, services, points) → in-app gateway only
- Buyer ↔ Seller direct payment (post-auction) → seller's details shown ONLY in winning buyer's private post-auction screen (never public)

**Shipping Options (seller sets per auction):**
- Personal pickup
- Courier company
- International shipping
- Hand delivery

---

### 4.13 `notifications` — Notifications

**Notification Types:**
- Bid updates, outbid alerts, auction end, win confirmation
- Deposit timers (conditional bids), payment deadline
- Earnest money low balance warning
- Points earned, badge awarded, level up, prize won
- Loft QR scan request (seller approves/rejects)
- Post-sale flow step notifications

**Per-User Settings:**
- Enable/disable each notification type
- Buyer mode vs. Seller mode notification filter
- Do Not Disturb schedule

**Congratulations Messages:** Every point earned → in-app celebration message. Example: "🎉 Congrats! You earned 50 points from auction [Bird Name]"

---

### 4.14 `admin` — Admin Panel (Web)

**Tech:** Flutter Web

**Staff Hierarchy:** Super Admin → Admin → Moderator; each employee has own account; full audit log (who did what + timestamp)

**Admin Functions:**
1. **User Management:** activate/block/edit accounts, manage dual profiles, review seller verification requests
2. **Bird Management:** verify digital IDs, monitor mandatory videos, flag violations
3. **Auction Management:** monitor live auctions, adjust settings, disable violating auctions
4. **Points / Badges / Prizes:** set point values per activity, configure seasonal prizes, track prize delivery
5. **Packages:** add/edit prepaid & commission packages, monitor earnest balances
6. **Notifications:** send global announcements, manage targeted notifications, monitor reminders
7. **Chat / Complaints:** review flagged messages, monitor violations, ban users
8. **General Settings:** languages, currencies, payment methods, shipping types, data deletion policies
9. **Reports & Analytics:** user counts (active/banned), auction counts (live/ended), total sales, staff performance, user engagement analysis
10. **Payment Gateway Management:** enable/disable payment methods, monitor platform transactions
11. **Marketing Offers Management:** create/edit/end monthly, seasonal, flash sale offers — configurable without code changes
12. **Admin Announcement Bar (Section 11.3):** scrolling top bar with custom text + expiry duration; user can dismiss with X

**Exclusive Features controlled by Admin:**
- Lucky Wheel prizes/conditions
- Bidder Target milestones
- Referral Challenge prizes
- Seasonal awards criteria

---

### 4.15 Exclusive Innovative Features

#### Smart Auction Voice Bot (Section 13.1) — Paid
- Converts auction into live audio commentary experience
- Settings: voice type (male/female), language/dialect (Egyptian Arabic, Modern Standard Arabic, English)
- Personal Voice Clone 🔥: record one sentence → AI clones seller's own voice for all commentary
- Bot tasks: announces each new bid, announces winner, reads bird info

#### Lucky Wheel (Section 13.2)
- Floating icon (left side)
- Condition-gated (criteria set by admin)
- Animated spin with sound effects

#### Million Challenge (Section 13.3)
- Dedicated full-screen challenge
- Large countdown timer
- Top 10 leaderboard
- Personal progress bar
- Floating share button

---

## 5. Data Flow Example — Place Bid

```
BidPage (Widget)
  │ user taps "Bid"
  ▼
AuctionBloc.add(PlaceBidEvent(auctionId, amount))
  │
  ▼
PlaceBidUseCase.execute(PlaceBidParams)
  │ validates: amount > currentBid + minIncrement
  │ validates: user has sufficient balance (if conditional mode)
  ▼
AuctionRepository.placeBid(auctionId, amount, userId)
  │
  ▼
AuctionRemoteDataSource.placeBid(...)
  │ POST /auctions/{id}/bids
  ▼
API Response
  │
  ▼ (via WebSocket stream)
AuctionBloc emits BidPlacedState / AuctionUpdatedState
  │
  ▼
BidPage rebuilds — shows new price, updated countdown
```

---

## 6. State Management Conventions

- Each feature has its own BLoC
- BLoC files: `<feature>_bloc.dart`, `<feature>_event.dart`, `<feature>_state.dart`
- States use `Equatable` for efficient rebuilds
- Use `BlocBuilder` for UI that rebuilds on state change
- Use `BlocListener` for side effects (navigation, snackbars, dialogs)
- Use `BlocConsumer` when both are needed
- Provide BLoCs at the feature route level (not globally unless truly global)

### Global BLoCs (provided at app root)
- `AuthBloc` — authentication state across the app
- `AccountModeBloc` — buyer/seller mode toggle
- `NotificationBloc` — incoming push notification handling

---

## 7. Dependency Injection

Use `get_it` for service locator. Register all dependencies in `core/di/injection.dart`:

```dart
// Pattern:
sl.registerLazySingleton<AuctionRepository>(() => AuctionRepositoryImpl(sl(), sl()));
sl.registerFactory<AuctionBloc>(() => AuctionBloc(sl(), sl(), sl()));
```

- `registerLazySingleton` for repositories, data sources, services
- `registerFactory` for BLoCs (new instance per page)

---

## 8. Key Dependencies to Add

```yaml
dependencies:
  # State Management
  flutter_bloc: ^8.x
  equatable: ^2.x

  # DI
  get_it: ^7.x

  # Navigation
  go_router: ^13.x

  # Network
  dio: ^5.x

  # Local Storage
  shared_preferences: ^2.x
  hive_flutter: ^1.x

  # Realtime (auctions)
  web_socket_channel: ^2.x

  # Media
  camera: ^0.10.x
  video_player: ^2.x
  ffmpeg_kit_flutter: ^6.x
  qr_flutter: ^4.x
  mobile_scanner: ^3.x

  # Localization
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.x

  # Images
  cached_network_image: ^3.x
  image_picker: ^1.x

  # PDF / Print
  pdf: ^3.x
  printing: ^5.x

  # Payments
  # (add specific gateway SDK per target market)

  # Push Notifications
  firebase_messaging: ^14.x
  flutter_local_notifications: ^16.x

  # Utils
  dartz: ^0.10.x      # Either type for error handling
  uuid: ^4.x

dev_dependencies:
  bloc_test: ^9.x
  mocktail: ^1.x
```

---

## 9. Localization

- Two languages: Arabic (RTL) and English (LTR)
- Dynamic runtime language toggle (no app restart)
- Use `flutter_localizations` + `intl` ARB files
- Store language preference in `SharedPreferences`
- All text goes through `AppLocalizations.of(context)` — no hardcoded strings in widgets

---

## 10. Implementation Phases

### Phase 1 — Core Platform
- Authentication (register, login, OTP)
- Dual account system (buyer/seller toggle)
- Pigeon Digital ID (mandatory fields + video capture + QR)
- Single-bird auctions (instant free bid mode)
- Fixed market (buy now)
- Basic seller dashboard
- Push notifications
- Arabic + English localization

### Phase 2 — Full Auction Engine
- All 5 auction types
- Conditional bid with deposit/earnest system
- Anti-sniping timer
- Bidder Duel, Last Moment Rewards
- Silent Auction
- Electronic Raffle
- Ownership History
- PP Coins + Levels
- Packages (prepaid + commission)
- Chat (1-to-1 + in-auction)
- Admin Panel (core management)

### Phase 3 — Advanced & Monetization Features
- Loft Program (full pedigree + AI scanner)
- Smart Auction Voice Bot
- Lucky Wheel
- Referral Challenge + Seasonal Awards
- Million Challenge
- Marketing Offers Management
- Full Admin Analytics
- Products Store
- Multi-Room System for sellers
