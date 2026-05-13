# Pigeon Planet — App Specification Summary

> Extracted and translated from the original Arabic PDF specification document.

---

## Overview

Pigeon Planet is an integrated platform for carrier pigeon services. It combines:

- A **hybrid mobile app** (Android + iOS)
- A **Web Admin Panel** for full platform management
- A **multi-type auction system**
- An **e-commerce store** for pigeon supplies
- A **Loft Management Program**
- A **race results recognition system**
- **Digital land/loft sale** with full contents

**Languages:** Arabic + English (dynamically switchable at runtime)

**Revenue Model:**
- Prepaid seller subscription packages
- Commission packages with earnest-money system (no upfront payment)
- Paid auction boost & ranking promotion services
- Paid premium features (e.g., Voice Bot)
- Fixed commission on sales (per package tier)

---

## Section 1 — Accounts & Identity

### 1.1 Dual Account System (Bilateral Accounts)

Every user can be both a **Seller** and a **Buyer** simultaneously from the same account.

- A clear toggle button at the top of the screen switches between modes
- Each mode has its own:
  - Independent dashboard
  - Independent notifications
  - Independent transaction history
  - Independent points wallet
- Switching is instant with no logout required

### 1.2 Seller Country & Currency

Mandatory when registering as a seller:

- Must select their **country**
- The country's currency becomes the **primary currency** for that account
- All auctions created by this seller use this currency
- All dashboards, reports, and invoices use this currency
- **Cannot be changed later** (can be set differently per individual auction)

### 1.3 Badges

- **18 Seller Badges** — awarded based on seller activity milestones
- **18 Buyer Badges** — awarded based on buyer activity milestones
- Some premium badges (e.g., "Elite", "Gold") can be purchased or require a point threshold

---

## Section 2 — Pigeon Digital ID

### 2.1 Mandatory Fields

No auction can be published without a complete Digital ID:

| Field | Type | Required |
|---|---|---|
| Ring Number | Text | ✅ Mandatory |
| Breed / Pedigree | Text + family tree | ✅ Mandatory |
| Photos | Minimum 4 images | ✅ Mandatory |
| Video | In-app recording only | ✅ Mandatory |
| QR Code | Auto-generated | ✅ Mandatory |
| Gender | Male ♂ / Female ♀ (shown in different color on cover) | ✅ Mandatory |
| Hatch Date | Date | Optional |
| Race Results | Race name + placement | Optional |

### 2.2 Smart QR Code

- Unique code generated per bird
- Can be printed on a pedigree certificate or sticker
- When scanned via the Loft app → displays the full bird profile
- **Add-to-Loft mechanism:** Buyer scans QR → sees "Add to My Loft" button → seller receives notification and chooses ✅ Approve / ❌ Reject → on approval, bird is added to buyer's loft while preserving the original seller's source record

### 2.3 Mandatory Smart Video (Controlled Video Template / Zajel Scanner)

> Philosophy: "Make the professional look professional, and the beginner look professional too."

**Rules:**
- Camera must be opened **inside the app only** — uploading pre-recorded or studio videos is forbidden

**Filming UI (Zajel Scanner):**
1. **Transparent Overlay** — white pigeon-shaped guide drawn on screen; seller places the bird inside the frame
2. **Leveler** — horizontal line at screen center; turns green when phone is perfectly straight
3. **Progress Stepper** — 4 icons at top of screen guiding through:
   - 🦢 Full body
   - 🪶 Wing (right / left)
   - 👁️ Eye (macro)
   - 🔢 Ring number / leg band
4. **Auto-Capture** — camera captures automatically when the element is clear in the frame (no button press required — prevents shake)

**Post-Processing (FFmpeg):**
- All 4 clips are automatically merged into one 20-second video
- Added automatically: app watermark, filming date, ring number, animated anti-fraud code, optional ambient background music (can be muted)
- Result: a unified professional video for all sellers regardless of skill level

### 2.4 Ownership History

> First pigeon app in the world to implement a tamper-proof ownership record.

- On confirmed full payment: previous seller is added to "Owners History"; buyer becomes "Current Owner"
- Record includes: owner name + date + sale price
- Visible only to the seller and buyer — never shown publicly

**Data Retention Policy:**
- Bird data: auto-deleted 7 days after auction ends
- Invoices & ownership history: can be manually deleted after 1 month

---

## Section 3 — Auction & Fixed Market System

### 3.1 Auction Types

| Type | Description |
|---|---|
| 🟢 Single Bird | 1 bird, 1 winner |
| 🟡 Multi-Bird | 2–10 birds; each has independent price, independent bidding, independent winner; all end at the same time; Grid or vertical list view |
| 🔵 Breeding Pair | Male + female together; one bid; one winner; gender icon color-coded; distinctive cover color |
| 🟣 Squab Pair | Young pigeon pair; one bid; one winner; displays age + parent data if available |
| 🏁 One Loft Race | Multiple race birds; independent bidding per bird; displays past race results; birds sorted by classification |

### 3.2 Anti-Sniping Timer

- Seller sets a grace window (3–5 minutes) before publishing
- Any bid placed within the window **resets the countdown**
- When timer expires with no bids → current highest bidder wins

### 3.3 Bidding Modes

#### 🟢 1. Instant Free Bid
- Immediate win upon bid
- No extended payment deadline
- No deposit required

#### 🔵 2. Conditional Bid (with Earnest Deposit)
- Seller chooses to allow or block conditional bids (set before publishing, cannot change after)
- On winning: buyer receives notification — *"You won the auction — you have 60 minutes to pay the deposit"*
- 60-minute countdown begins; auction status: "Awaiting Deposit"

**Deposit Options:** seller sets deposit percentage + payment deadline (7 / 14 / 30 days)

**If deposit is NOT paid:**
- Winner's bid is automatically cancelled
- Private notification sent to bidder + seller only (no public embarrassment)
- Bidder receives an automatic ban

**After deposit is paid:**
- Bird is reserved under buyer's name
- Bird is locked from any other bidding
- Countdown begins for the selected payment period

**If remaining balance is NOT paid:**
- Bidder loses 100% of the deposit — goes entirely to the seller

### 3.4 Advanced Bidding Features

- **🔥 Bidder Duel:** In the last 10 minutes, the top bidder can send a challenge message to a chosen rival; if the challenger wins over their rival → bonus points
- **⚡ Last-Moment Reward:** 5 PP Coins for every bid placed in the last 5 minutes; "Ignites the End" badge awarded (lasts 1 week)
- **🎯 Admin Target:** Admin sets a target amount for certain auctions; first to reach it wins a prize (badge / discount / money)
- **🧩 Full Auction Challenge:** User who bids on every bird in a multi-auction (even without winning) receives a consolation prize + badge

### 3.5 Electronic Raffle After Auction

- Seller chooses: Public (everyone) or Private (bidders only)
- Auto-raffle runs immediately after auction ends among all participants
- Prize options: free shipping, discount, PP Coins (seller or admin defines)

### 3.6 Silent Auction

> An exclusive innovative feature.

- A special pigeon listed in an auction where **no one can see the current price**
- Each bidder places their secret maximum price
- When time ends, AI calculates the highest amount and announces winner + final price only
- Goal: create suspense and eliminate "bidding fear" for buyers

### 3.7 Fixed Market (Fixed Price)

A separate section inside the app (distinct from auctions) for:
- Buying and selling birds at a fixed price (instant purchase, no waiting)
- Buying and selling pigeon supplies and accessories

**Publishing Rules:**
- Same digital ID requirements apply (ring number, photos, mandatory video)
- When a seller lists a bird, they choose: **Publish as Auction** or **Publish at Fixed Price**

**Buyer Experience:**
- Separate gallery with same filters as auctions (breed, age, price, seller location)
- Clear display of final price + shipping cost
- "Buy Now" or "Add to Cart" buttons → goes directly to payment screen

**Payment Options:**
- In-app payment (credit card / e-wallet) — commission deducted if applicable
- Request direct payment info: buyer taps "Request Payment Details" → seller's bank/wallet info shown for a limited time (no commission)

### 3.8 Transaction Completion Flow (Mandatory for All Sales)

| Step | Actor | Action |
|---|---|---|
| 1 | Seller | 📨 Send Invoice |
| 2 | Buyer | 💳 Pay |
| 3 | Seller | ✅ Confirm Payment Received |
| 4 | Seller | 📦 Mark as Shipped / Delivered |
| 5 | Buyer | ✅ Confirm Receipt |

> ⚠️ PP Coins are only awarded after Step 5.

### 3.9 Products Store

**Categories:**
- **Supplies:** cages, nests, feeders, drinkers, cleaning tools
- **Nutritional Supplements & Medicine:** vitamins, minerals, preventive and therapeutic drugs
- **Feed:** grain mixes, specialty seeds
- **Accessories:** rings, clips, stickers, educational books

**Store Rules:**
- No digital ID required for products
- Seller sets: available quantity (auto-decrements on sale), shipping options per product or per category
- Multi-item cart; same payment methods

### 3.10 Ratings & Reviews

- 5-star rating system
- Written reviews for both products and sellers
- Shown on the product page and on the seller's profile page

---

## Section 4 — Loft Management Program

- Full implementation similar to **colopig.com** with improvements

### 4.1 Pedigree Templates

- 10+ professional designs: tree, table, classic, modern
- Each design comes in 3 color options + ability to manually color individual cells
- Can add breeder's logo
- Fixed QR code in corner
- Printable as PDF

### 4.2 AI Pedigree Scanner

- Upload a photo of an existing pedigree certificate
- AI automatically extracts: ring number, breed, father, mother, grandparents, hatch dates, race results
- User reviews and edits the extracted data → save to system
- Reduces entry time from **10 minutes to 10 seconds**

### 4.3 Race Results

- Syncs with club race results and individual point races
- After data is entered, results appear automatically
- Can be saved as PDF or JPEG

### 4.4 Subscription Plans (Loft)

- 3–4 tiers (fully configurable from admin dashboard), plus custom on-request plans
- Each plan includes: bird count limit, monthly pedigree certificates quota, access to premium templates
- Optional 7-day free trial for paid plans

### 4.5 Pedigree Designer

- Full design tool for creating printable pedigree certificates
- 10+ professional templates (tree, table, classic, modern)

---

## Section 5 — Points & Rewards System

### 5.1 PP Coins (Pigeon Planet Coins) 🪙

Internal currency displayed as: **🪙 PP**

### 5.2 How Points Are Earned

- **Commercial Activity:** completing auctions, sales, purchases
- **Interactive Activity:** placing bids, writing reviews, referrals, last-minute bids, etc.
- **Critical Rule:** Points are only awarded after the buyer confirms receipt (Step 5 of sale flow)

### 5.3 Congratulation Messages

Every time a user earns points → an in-app congratulation message is sent:
> 🎉 "Congrats! You earned 50 points from auction [Bird Name]"

Messages can be grouped (optional).

### 5.4 Seller Levels

Tiered progression based on accumulated PP Coins.

### 5.5 Buyer Levels

Tiered progression based on accumulated PP Coins.

### 5.6 Cashback

- 1%–5% of purchase value
- Converted to PP Coins balance (not withdrawable as cash)
- Used in future auctions and services

---

## Section 6 — Incentives & Prizes

### 6.1 Onboarding Rewards

- 100 free PP Coins on sign-up
- 20% discount on first auction boost

### 6.2 Interactive Joint Awards

Defined by admin.

### 6.3 Seasonal Seller Awards

Defined and managed by admin. **Winning criteria:**
- Total completed sales (40%)
- Buyer ratings (30%)
- Zero-cancellation streak (20%)
- Buyer engagement (10%)

### 6.4 Monthly Referral Challenge

- Most users who share the app link win prizes
- New member acceptance is **manual by admin** (to prevent bots)
- **Prizes:** 🏆 1st Place: iPhone, 2nd: AirPods, etc.
- **UI:** Countdown timer (days : hours : minutes), Top 10 leaderboard, personal progress bar

### 6.5 Prize Delivery

- **Digital prizes** (points, badges, discounts): auto-added to account
- **Physical / monetary prizes:** user fills a form (name, address, ID) → admin reviews → manual delivery

### 6.6 Pigeon Points Purchase

Users can buy additional PP Coins directly in-app using credit cards / e-wallets, to use for:
- Entering exclusive raffles
- Getting discounts
- Activating premium features

### 6.7 Badge System

- Some important badges ("Elite", "Gold") are purchasable or require a point threshold to unlock — not granted automatically

### 6.8 Marketing Offers (Admin-Managed)

All offers are created and managed from the admin panel:
- **Monthly offers:** limited discounts on seller packages or boosts
- **Seasonal / annual offers:** major campaigns during breeding or racing seasons (discounts + double points)
- **Flash Sales:** 24–48 hour quick offers on specific services (e.g., 50% off first paid auction)

---

## Section 7 — Packages & Subscriptions

### 7.1 Prepaid Packages

Seller pays upfront; receives a fixed number of auctions or a time duration. Tiers: Starter / Pro / Elite (fully configurable from admin panel).

### 7.2 Commission Packages (Earnest Money System)

- No monthly upfront fee
- Seller deposits an earnest amount (e.g., 1000 EGP) into the app wallet
- Commission is deducted from this balance after each completed sale
- **No fixed package duration**
- When balance reaches zero → all seller's auctions are auto-paused
- Notification: *"Earnest balance depleted — add 1000 EGP to resume your auctions"*
- All payments via the app gateway only

### 7.3 Supported Payment Methods

- Credit / Debit cards (Visa, Mastercard, Mada, etc.) via secure payment gateway
- E-wallets: Apple Pay, Google Pay, local wallets per country
- Manual bank transfer
- Cash on delivery

### 7.4 Critical Payment Policy ⚠️

- All platform-related payments (packages, services, points) → **in-app gateway only**
- Seller's payment details (bank account, wallet number) are **never shown publicly**
- **Only exception:** After a successful auction, the winning buyer's private screen shows the seller's payment details (that the seller entered in their settings) for direct transfer — with no commission

---

## Section 8 — Multi-Room System (for Sellers)

One seller account can create **multiple independent "rooms"**:

- Each room has: independent name, description, subscription package, and auctions
- All rooms appear on the seller's public profile page, clearly labelled as belonging to the same owner
- Users follow the specific room they prefer

**Use cases:**
- Separate elite auctions from regular auctions
- Manage two farms from a single account

---

## Section 9 — Communication & Chat

### 9.1 General Rules

- Private messaging is **one-to-one only** (no group chats)

### 9.2 In-Auction Public Chat

- Optional — seller enables per auction
- Side chat panel inside the auction page
- Not connected to bidding (no bid buttons inside chat)
- Seller uses it for announcements and descriptions; bidders leave short comments
- Auto-moderation: banned words are blocked automatically

### 9.3 Contact Info Blocking

Strictly forbidden in all chats:
- Phone numbers → **auto-blocked** + instant warning to sender + violation logged
- WhatsApp accounts, external contact links → same treatment

### 9.4 Smart Block

When a seller blocks a buyer:
- Blocked buyer **can still see** the seller's birds, auctions, and descriptions
- Blocked buyer **cannot** place bids or send messages

---

## Section 10 — Seller Dashboard

### 10.1 Dashboard Sections

| Section | Content |
|---|---|
| 📊 Summary | Active auctions count, total sales, highest sale price, most engaged auction |
| 🪙 Wallet | PP Coins balance, earnest money balance, transaction history |
| 🏅 Achievements | Current badges, current level, prizes won |
| 📋 Auction Management | Create new, edit/pause active auctions, view completed results |
| 🚚 Shipping Settings | Shipping options per auction |
| 💳 Payment Settings | Bank account, wallet numbers for buyer direct payment |

### 10.2 Post-Sale Workflow

All sales follow the mandatory 5-step flow (see Section 3.8).

---

## Section 11 — Admin Panel (Web)

### 11.1 Staff Structure & Permissions

- Full role-based permissions: Super Admin → Admin → Moderator
- Every employee has a separate account
- Every action is logged: employee name + date + time
- No action can be deleted or modified without elevated permission
- Full audit log for all operations

### 11.2 Admin Tasks

1. **User Management:** activate / block / edit buyer and seller accounts, manage dual profiles, review seller verification requests
2. **Bird Management:** verify digital IDs, monitor mandatory videos, flag violations
3. **Auction Management:** monitor live auctions, adjust timers and bid types, disable violating auctions
4. **Points / Badges / Prizes:** set point values per activity, configure seasonal prizes, track prize delivery to winners
5. **Package Management:** add/edit prepaid and commission packages, monitor earnest money balances
6. **Notifications:** send global broadcasts, manage targeted notifications, monitor reminders
7. **Chat & Complaints:** review reported messages, monitor violations, ban users
8. **General Settings:** languages, currencies, payment methods, shipping types, data deletion policies
9. **Reports & Analytics:** user counts, auction counts, total sales, staff performance, user engagement analysis
10. **Payment Gateway Management:** enable/disable payment methods, monitor platform transactions
11. **Marketing Offers Management:** create/edit/end monthly, seasonal, and flash sale offers — without requiring code changes
12. **Admin Announcement Bar:** scrolling banner at top of app with custom text and expiry duration; users can dismiss with X

---

## Section 12 — UI/UX

### 12.1 Visual Identity

Colors and visual style follow the prototype app that was previously built.

### 12.2 Home Screen — Auction Feed

- User can choose between Grid view or vertical list view
- Zoom In / Out support
- View preference is saved per user

### 12.3 Single Auction Page (Element Order)

1. **Header:** auction name, auction type badge, bird gender (color-coded), seller name + badge
2. **Media:** photo gallery (swipe), mandatory video (auto-plays muted)
3. **Auction Info:** current price, minimum bid, remaining time (countdown), bid count
4. **Bid Buttons:** Free Bid / Conditional Bid (depending on auction settings)
5. **Public Chat:** optional (if enabled by seller)
6. **Sponsor Bar:** sponsor logo + name (does not affect bidding)
7. **Bird Details:** ring number, breed, age, QR Code

### 12.4 Winner Bar

Scrolling banner shown to everyone at top of screen after a win:
> 🏆 [Username] won [free shipping] in auction [Bird Name] 🎉

Color: Royal Blue for prizes.

### 12.5 Sound Effects

Various sound effects for: bid placed, outbid alert, auction won, timer warning, etc.

---

## Section 13 — Exclusive Innovative Features

### 13.1 Smart Auction Voice Bot (Paid Feature)

Converts the auction into a professional live audio commentary experience.

**Settings:**
- Voice type: male / female
- Language / dialect: Egyptian Arabic, Modern Standard Arabic, English
- 🔥 Personal Voice Clone: seller records one sentence → AI clones their voice for all commentary

**Bot tasks:** announces each new bid, announces the winner, reads bird info aloud

> *"Choose your auction voice... and let the bird sell itself with your voice"*

### 13.2 Lucky Wheel

- Small floating icon on the left side of the screen
- Appears only when specific conditions (set by admin) are met
- Animates and spins with sound effects

### 13.3 Million Challenge

Dedicated screen for major prize campaigns:
- Large countdown timer
- Top 10 leaderboard
- Personal progress bar
- Floating share button

---

## Section 14 — Payment & Shipping

### 14.1 Shipping Options (Seller Sets Per Auction)

- Personal pickup
- Courier company
- International shipping
- Hand delivery

Seller sets shipping duration (e.g., 3–5 days, 7 days). Options displayed on auction page.

### 14.2 Payment Policy

- Strict: all platform-service payments must go through in-app gateway
- Any attempt to share phone numbers or external payment links in chat → immediate warning + violation recorded

---

## Section 15 — Print & Reports

**Printable documents include:** pedigree certificates, invoices, ownership history, race results

**Export formats:**
- 📸 Image (PNG / JPEG)
- 📄 PDF
- ✉️ Share via WhatsApp, email, etc.

---

## Section 16 — Notifications

### 16.1 Notification Types

- Bid placed, outbid, auction ended, auction won
- Deposit timer (conditional bids), payment deadline reminders
- Earnest balance low warning
- Points earned, badge awarded, level up, prize won
- Loft QR scan request (approve/reject)
- Post-sale flow step updates (invoice sent, payment confirmed, shipped, received)

### 16.2 User Notification Settings

- Enable/disable each notification type individually
- Filter by account mode (buyer / seller)
- Do Not Disturb schedule

Every reward event (points purchase, package activation, badge earned, offer ended, raffle win) triggers an in-app congratulation message.

---

## Section 17 — Implementation Phases

### Phase 1 — Core Platform
- Dual account system (buyer / seller toggle)
- Pigeon Digital ID (all mandatory fields + Zajel Scanner video + QR)
- Single-bird auctions (instant free bid mode)
- Fixed market (buy now)
- Basic seller dashboard
- Push notifications
- Arabic + English localization

### Phase 2 — Full Auction Engine
- All 5 auction types
- Conditional bid with deposit / earnest system
- Anti-sniping timer, Bidder Duel, Last Moment Rewards
- Silent Auction + Electronic Raffle
- Ownership History chain
- PP Coins + Seller / Buyer levels
- Subscription packages (prepaid + commission)
- One-to-one chat + in-auction chat
- Admin Panel (core management)

### Phase 3 — Advanced & Monetization
- Full Loft Program (pedigree designer + AI scanner + race results)
- Smart Auction Voice Bot
- Lucky Wheel
- Referral Challenge + Seasonal Awards
- Million Challenge
- Products Store
- Multi-Room System for sellers
- Full Admin Analytics & Marketing Offers

---

*This document is a full English summary of the 44-page Arabic specification PDF.*
