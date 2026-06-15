class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://ppw-backend.vercel.app/api';

  // Auth
  static const String login = '/auth/login/';
  static const String registerCustomer = '/auth/register/customer/';
  static const String tokenRefresh = '/auth/token/refresh/';
  static const String switchProfile = '/auth/switch-profile/';

  // User profiles
  static const String mySellers = '/users/mobile/sellers/';
  static const String sellerHomeSummary = '/users/mobile/sellers/home-summary/';
  static String sellerDetail(int id) => '/users/mobile/sellers/$id/';
  static const String myCustomers = '/users/mobile/customers/';
  static const String customerHomeSummary =
      '/users/mobile/customers/home-summary/';
  static String customerDetail(int id) => '/users/mobile/customers/$id/';

  // Core (notifications, activity, points, subscriptions)
  static const String coreNotifications = '/core/notifications/';
  static const String coreNotificationsUnreadCount =
      '/core/notifications/unread-count/';
  static String coreNotificationRead(int id) => '/core/notifications/$id/read/';
  static const String coreActivity = '/core/activity/';
  static const String corePoints = '/loyalty/points/';
  static const String corePointsHistory = '/loyalty/points/transactions/';
  static const String loyaltyBadges = '/loyalty/badges/';
  static const String loyaltyMyBadges = '/loyalty/badges/my/';
  static const String coreSubscriptionPackages = '/core/subscription-packages/';

  // Assets
  static const String birds = '/assets/birds/';
  static String birdDetail(int id) => '/assets/birds/$id/';
  static const String supplies = '/assets/supplies/';
  static const String accessories = '/assets/accessories/';
  static const String feeds = '/assets/feeds/';
  static const String supplements = '/assets/supplements/';

  // Auctions
  static const String auctions = '/auctions/';
  static const String auctionsActive = '/auctions/active/';
  static const String auctionsEndingSoon = '/auctions/ending_soon/';
  static const String auctionsMyAuctions = '/auctions/my_auctions/';
  static String auctionDetail(int id) => '/auctions/$id/';
  static String auctionItems(int auctionId) => '/auctions/$auctionId/items/';
  static const String allAuctionItems = '/auctions/items/';
  static String auctionItemDetail(int itemId) => '/auctions/items/$itemId/';
  static String placeBid(int itemId) => '/auctions/items/$itemId/place_bid/';
  static const String bids = '/auctions/bids/';
  static const String createAuction = '/auctions/';

  // Packages
  static const String packages = '/packages/';
  static const String mySellerPackages = '/packages/my-packages/';
  static const String mySellerPackagesActive =
      '/packages/my-packages/?active=true';

  // Races
  static const String races = '/races/';
  static String raceDetail(int id) => '/races/$id/';
  static String raceResults(int raceId) => '/races/$raceId/results/';
  static const String raceResultsGlobal = '/race-results/';

  // Ratings
  static const String assetRatings = '/asset-ratings/';
  static const String sellerRatings = '/seller-ratings/';
  static const String assetComments = '/asset-comments/';
  static const String sellerComments = '/seller-comments/';

  // Orders
  static const String orders = '/orders/';
  static String orderDetail(int id) => '/orders/$id/';
  static const String orderItems = '/orders/items/';
  static String approveOrderItem(int itemId) =>
      '/orders/items/$itemId/approve/';
  static String rejectOrderItem(int itemId) => '/orders/items/$itemId/reject/';

  // Cart & Checkout
  static const String cart = '/orders/cart/';
  static const String cartItems = '/orders/cart/items/';
  static String cartItemDetail(int id) => '/orders/cart/items/$id/';
  static const String cartClear = '/orders/cart/clear/';
  static const String checkout = '/orders/checkout/';
}
