class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Auth
  static const String login = '/auth/login/';
  static const String registerCustomer = '/auth/register/customer/';
  static const String tokenRefresh = '/auth/token/refresh/';
  static const String switchProfile = '/auth/switch-profile/';

  // User profiles
  static const String mySellers = '/users/mobile/sellers/';
  static const String sellerHomeSummary = '/users/mobile/sellers/home-summary/';
  static const String myCustomers = '/users/mobile/customers/';

  // Assets
  static const String birds = '/assets/birds/';
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

  // Orders
  static const String orders = '/orders/';
  static String orderDetail(int id) => '/orders/$id/';
  static const String orderItems = '/orders/items/';
  static String approveOrderItem(int itemId) =>
      '/orders/items/$itemId/approve/';
  static String rejectOrderItem(int itemId) => '/orders/items/$itemId/reject/';
}
