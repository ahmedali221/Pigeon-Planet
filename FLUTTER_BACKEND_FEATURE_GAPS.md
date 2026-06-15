# Flutter Backend Feature Gaps

This document compares implemented backend features in `PPW` with what is currently implemented in the Flutter app under `pigeon_planet`.

## Scope

- Races
- Loyalty
- Ratings and comments

## Summary

| Feature | Backend status | Flutter status | Gap |
| --- | --- | --- | --- |
| Races | Implemented | Mostly implemented read-only | Manager write flows are missing |
| Loyalty | Implemented | Partially surfaced through package points | Real loyalty wallet, transactions, and badges are missing |
| Ratings and comments | Implemented | Asset rating display only | Rating creation, seller ratings, and comments are missing |

## Races

### Backend

Backend routes are wired through `PPW/ppw/urls.py`:

- `/api/races/`
- `/api/races/<id>/`
- `/api/races/<id>/results/`
- `/api/race-results/`
- `/api/race-results/<id>/`

Backend supports:

- authenticated race list
- authenticated race detail with nested results
- authenticated per-race result list
- authenticated global race-result search
- manager-only race create/update/delete
- manager-only race-result create/update/delete
- manager-only bulk result creation for a race

### Flutter

Flutter has a real races feature:

- `lib/features/races/model/race_model.dart`
- `lib/features/races/model/datasources/real_races_remote_datasource.dart`
- `lib/features/races/model/races_repository.dart`
- `lib/features/races/viewmodel/races_bloc.dart`
- `lib/features/races/view/pages/races_page.dart`
- `lib/features/races/view/pages/race_detail_page.dart`

API constants exist in:

- `lib/core/constants/api_constants.dart`

Implemented Flutter behavior:

- race list
- race detail
- per-race result display
- global race-result search
- home navigation to `RacesPage`

### Missing Flutter Work

- manager race creation screen
- manager race edit screen
- manager race delete action
- manager result creation/edit/delete
- bulk result creation/import UI
- role-aware write actions for manager users
- pagination/load-more handling for large race/result lists

## Loyalty

### Backend

Backend routes are wired through `PPW/apps/loyalty/urls.py` under `/api/loyalty/`:

- `/api/loyalty/points/`
- `/api/loyalty/points/transactions/`
- `/api/loyalty/badges/`
- `/api/loyalty/badges/my/`

Backend supports:

- authenticated point balance retrieval
- authenticated point transaction list
- manager transaction listing across users
- static badge catalog
- current active profile badge awards
- manager badge awards by profile
- manager badge award creation

### Flutter

Flutter defines loyalty constants:

- `corePoints = '/loyalty/points/'`
- `corePointsHistory = '/loyalty/points/transactions/'`

However, these constants are currently unused.

Current Flutter points behavior is implemented in:

- `lib/features/home/model/datasources/points_remote_datasource.dart`

That datasource currently fetches active seller package data from:

- `/packages/my-packages/?active=true`

This means the app is showing seller package remaining points, not the backend loyalty wallet.

### Missing Flutter Work

- replace or separate package-points fetching from loyalty wallet fetching
- implement `LoyaltyRemoteDataSource`
- implement loyalty models:
  - point balance
  - point transaction
  - badge definition
  - badge award
- implement loyalty repository
- implement loyalty bloc/cubit
- add loyalty UI for:
  - wallet balance
  - transaction history
  - badge catalog
  - my badges
- optionally add manager-only badge award UI if manager features belong in mobile

## Ratings And Comments

### Backend

Backend routes are wired through `PPW/apps/ratings/urls.py`:

- `/api/asset-comments/`
- `/api/seller-comments/`
- `/api/asset-ratings/`
- `/api/seller-ratings/`

Backend supports:

- authenticated asset comment list/create
- authenticated seller comment list/create
- authenticated asset rating list/create
- authenticated seller rating list/create
- optional nested rating comments
- completed-order eligibility validation for ratings
- cached aggregate updates for assets and seller profiles

### Flutter

Flutter currently defines only:

- `assetRatings = '/asset-ratings/'`

Current Flutter implementation:

- fetches asset ratings by `asset_id`
- maps them to `AssetRatingModel`
- displays them in auction item review UI

Relevant files:

- `lib/features/auctions/model/asset_rating_model.dart`
- `lib/features/auctions/model/datasources/real_auctions_remote_datasource.dart`
- `lib/features/auctions/view/widgets/auction_reviews_section.dart`
- `lib/features/auctions/view/pages/auction_item_detail_page.dart`

### Missing Flutter Work

- API constants:
  - `/asset-comments/`
  - `/seller-comments/`
  - `/seller-ratings/`
- models:
  - asset comment
  - seller comment
  - seller rating
  - rating/comment create payloads
- data source methods:
  - list asset comments
  - create asset comment
  - list seller comments
  - create seller comment
  - create asset rating
  - list seller ratings
  - create seller rating
- UI:
  - rating form after eligible completed purchase
  - asset comments section
  - seller comments/reviews section
  - seller rating list
  - empty/error/loading states
- business handling:
  - display backend eligibility errors clearly
  - prevent duplicate rating submission where possible
  - keep comments separate from rating comments in UI

## Recommended Implementation Order

1. Complete read-only gaps first:
   - loyalty wallet balance
   - loyalty transactions
   - my badges
   - seller ratings list
   - asset/seller comments list

2. Add customer write flows:
   - create asset comment
   - create seller comment
   - create asset rating with optional comment
   - create seller rating with optional comment

3. Add manager-only flows only if needed in mobile:
   - race/result create and edit
   - badge award management

4. Polish integration:
   - role-aware actions
   - pagination
   - backend validation messages
   - refresh affected aggregates after create actions

## Notes

- Races are the closest to complete in Flutter.
- Loyalty should not reuse seller package points as the loyalty wallet without renaming the UI, because they represent different backend modules.
- Ratings/comments are currently display-only and asset-focused; the backend supports a broader trust layer than the app exposes.
