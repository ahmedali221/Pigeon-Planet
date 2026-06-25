class ApiConstants {
  ApiConstants._();

  // static const String baseUrl = 'http://10.0.2.2:8000/api';      // Android emulator
  static const String baseUrl = 'http://192.168.1.36:8000/api';   // real device (same Wi-Fi)
  // static const String baseUrl = 'http://127.0.0.1:8000/api';
  // static const String baseUrl = 'https://ppw-backend.vercel.app/api';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login = '/auth/login/';
  static const String registerCustomer = '/auth/register/customer/';
  static const String tokenRefresh = '/auth/token/refresh/';
  static const String switchProfile = '/auth/switch-profile/';

  // ── User profiles ─────────────────────────────────────────────────────────
  static const String mySellers = '/users/mobile/sellers/';
  static String sellerDetail(int id) => '/users/mobile/sellers/$id/';
  static const String myCustomers = '/users/mobile/customers/';
  static String customerDetail(int id) => '/users/mobile/customers/$id/';

  // ── Insights ──────────────────────────────────────────────────────────────
  static const String insightsSellerHome = '/insights/seller/home/';

  // ── Loyalty ───────────────────────────────────────────────────────────────
  static const String loyaltyPoints = '/loyalty/points/';
  static const String loyaltyPointsTransactions =
      '/loyalty/points/transactions/';
  static const String loyaltyBadges = '/loyalty/badges/';
  static const String loyaltyMyBadges = '/loyalty/badges/my/';

  // ── Notifications ─────────────────────────────────────────────────────────
  static const String notifications = '/notifications/';
  static const String notificationsUnreadCount = '/notifications/unread-count/';
  static const String notificationsMarkAllRead =
      '/notifications/mark-all-read/';
  static String notificationMarkRead(int id) => '/notifications/$id/mark-read/';

  // Announcements
  static const String announcements = '/announcements/';

  // ── Assets ────────────────────────────────────────────────────────────────
  static const String birds = '/assets/birds/';
  static String birdDetail(int id) => '/assets/birds/$id/';
  static String publicBird(String publicId) =>
      '/assets/birds/public/$publicId/';
  static const String supplies = '/assets/supplies/';
  static const String accessories = '/assets/accessories/';
  static const String feeds = '/assets/feeds/';
  static const String supplements = '/assets/supplements/';

  // ── Auctions ──────────────────────────────────────────────────────────────
  static const String auctions = '/auctions/';
  static const String auctionsActive = '/auctions/active/';
  static const String auctionsEndingSoon = '/auctions/ending_soon/';
  static const String auctionsMyAuctions = '/auctions/my_auctions/';
  static String auctionDetail(int id) => '/auctions/$id/';
  static String auctionCancel(int id) => '/auctions/$id/cancel/';
  // Items are fetched via query param — no nested /<id>/items/ endpoint exists
  static const String auctionItems = '/auctions/items/';
  static String auctionItemDetail(int id) => '/auctions/items/$id/';
  static String placeBid(int itemId) => '/auctions/items/$itemId/place_bid/';
  static String buyNow(int itemId) => '/auctions/items/$itemId/buy_now/';
  static const String bids = '/auctions/bids/';
  static const String myBids = '/auctions/bids/my_bids/';
  static const String auctionEvents = '/auctions/events/';

  // ── Packages ──────────────────────────────────────────────────────────────
  static const String packages = '/packages/';
  static const String mySellerPackages = '/packages/my-packages/';
  static String cancelSellerPackage(int id) =>
      '/packages/my-packages/$id/cancel/';

  // ── Promotions ────────────────────────────────────────────────────────────
  static const String currentDiscountOffers =
      '/promotions/discount-offers/current/';
  static const String currentCashbackOffers =
      '/promotions/cashback-offers/current/';
  static const String cashbackBalance = '/promotions/cashback/balance/';
  static const String cashbackTransactions = '/promotions/cashback/my/';
  static const String myPromotionGrants = '/promotions/my-grants/';

  // ── Races ─────────────────────────────────────────────────────────────────
  static const String races = '/races/';
  static String raceDetail(int id) => '/races/$id/';
  static String raceResults(int raceId) => '/races/$raceId/results/';
  static const String raceResultsGlobal = '/race-results/';

  // ── Ratings & Comments ────────────────────────────────────────────────────
  static const String assetRatings = '/asset-ratings/';
  static const String sellerRatings = '/seller-ratings/';
  static const String assetComments = '/asset-comments/';
  static const String sellerComments = '/seller-comments/';

  // ── Orders ────────────────────────────────────────────────────────────────
  static const String orders = '/orders/';
  static String orderDetail(int id) => '/orders/$id/';
  static const String orderItems = '/orders/items/';
  static String approveOrderItem(int itemId) =>
      '/orders/items/$itemId/approve/';
  static String rejectOrderItem(int itemId) => '/orders/items/$itemId/reject/';

  // ── Cart & Checkout ───────────────────────────────────────────────────────
  static const String cart = '/orders/cart/';
  static const String cartItems = '/orders/cart/items/';
  static String cartItemDetail(int id) => '/orders/cart/items/$id/';
  static const String cartClear = '/orders/cart/clear/';
  static const String checkout = '/orders/checkout/';

  // ── Payments ──────────────────────────────────────────────────────────────
  static const String paymentRequests = '/payments/requests/';
  static const String auctionPaymentRequest =
      '/payments/requests/auction-item/';
  static const String marketPaymentRequest = '/payments/requests/order-item/';
  static String paymentRequestDetail(int id) => '/payments/requests/$id/';
  static String approvePaymentRequest(int id) =>
      '/payments/requests/$id/approve/';
  static String rejectPaymentRequest(int id) =>
      '/payments/requests/$id/reject/';

  // ── Complaints ────────────────────────────────────────────────────────────
  static const String complaints = '/complaints/';
  static const String myComplaints = '/complaints/my/';
  static String complaintDetail(int id) => '/complaints/$id/';
  static String cancelComplaint(int id) => '/complaints/$id/cancel/';
  static String reopenComplaint(int id) => '/complaints/$id/reopen/';

  // ── Lucky Wheel ───────────────────────────────────────────────────────────
  static const String luckyWheelCurrent = '/lucky-wheel/current/';
  static const String luckyWheelSpin = '/lucky-wheel/spin/';
  static const String luckyWheelMySpins = '/lucky-wheel/spins/my/';

  // ── Loyalty (extended) ────────────────────────────────────────────────────
  static const String loyaltyBuyWithCashback =
      '/loyalty/points/buy-with-cashback/';

  // ── Referrals ─────────────────────────────────────────────────────────────
  static const String referralCodes = '/referrals/codes/';
  static const String referralRedeem = '/referrals/redeem/';

  // ── Chat ──────────────────────────────────────────────────────────────────
  static const String chatConversations = '/chat/conversations/';
  static String chatMessages(int conversationId) =>
      '/chat/conversations/$conversationId/messages/';
  static String chatMarkRead(int conversationId) =>
      '/chat/conversations/$conversationId/mark-read/';

  // ── Feed ──────────────────────────────────────────────────────────────────
  static const String feedAuctions = '/feed/auctions/';
  static const String feedMarket = '/feed/market/';
  static const String feedSellersList = '/feed/sellers/';
  static const String peopleYouMayKnow = '/feed/people-you-may-know/';
  static String followSeller(int sellerId) => '/feed/sellers/$sellerId/follow/';
  static String unfollowSeller(int sellerId) =>
      '/feed/sellers/$sellerId/unfollow/';
  static const String following = '/feed/sellers/following/';
  static String followSellerPackage(int packageId) =>
      '/feed/seller-packages/$packageId/follow/';
  static String unfollowSellerPackage(int packageId) =>
      '/feed/seller-packages/$packageId/unfollow/';
  static const String followingPackages = '/feed/seller-packages/following/';
  static const String blocks = '/feed/blocks/customer-seller/';
  // Unblock uses the opposite profile's id, not the block record id
  static String unblock(int profileId) =>
      '/feed/blocks/customer-seller/$profileId/';

  // ── Pedigrees ─────────────────────────────────────────────────────────────
  static const String pedigreeDocuments = '/pedigrees/documents/';
  static String pedigreeDocumentDetail(int id) => '/pedigrees/documents/$id/';
  static String pedigreeDocumentReview(int id) =>
      '/pedigrees/documents/$id/review/';

  // ── Dead / unimplemented backend endpoints (DO NOT USE in new code) ───────
  // `/core/activity/` does not exist in the current backend — feature is a stub
  static const String coreActivity = '/core/activity/';
}
