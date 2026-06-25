class PaymentRequestModel {
  final int id;
  final String status; // pending, approved, rejected, cancelled
  final String type;   // auction, market  (mapped from request_type)
  final double amount;
  final String? buyerNote;
  final String? sellerNote;
  final int? auctionItemId;
  final int? orderItemId;
  final int? assetId;
  final String assetTitle;
  final String assetCategory;
  final int? buyerProfileId;
  final int? sellerProfileId;
  final DateTime created;
  final DateTime? modified;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final String? paymentProofUrl;

  const PaymentRequestModel({
    required this.id,
    required this.status,
    required this.type,
    required this.amount,
    this.buyerNote,
    this.sellerNote,
    this.auctionItemId,
    this.orderItemId,
    this.assetId,
    this.assetTitle = '',
    this.assetCategory = '',
    this.buyerProfileId,
    this.sellerProfileId,
    required this.created,
    this.modified,
    this.approvedAt,
    this.rejectedAt,
    this.paymentProofUrl,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';
  bool get isAuction => type == 'auction';

  /// Auction rejections are final — the item reverts to UNSOLD and the buyer
  /// loses their claim. Only market rejections can be resubmitted.
  bool get canUpdate =>
      status == 'pending' ||
      (status == 'rejected' && !isAuction);

  factory PaymentRequestModel.fromJson(Map<String, dynamic> json) {
    // Detail serializer returns auction_item_id / order_item_id as flat ints.
    // Fall back to nested/int shapes for any future variance.
    int? auctionItemId = json['auction_item_id'] as int?;
    if (auctionItemId == null) {
      final ai = json['auction_item'];
      if (ai is int) { auctionItemId = ai; }
      else if (ai is Map) { auctionItemId = ai['id'] as int?; }
    }

    int? orderItemId = json['order_item_id'] as int?;
    if (orderItemId == null) {
      final oi = json['order_item'];
      if (oi is int) { orderItemId = oi; }
      else if (oi is Map) { orderItemId = oi['id'] as int?; }
    }

    final asset = json['asset'] as Map<String, dynamic>?;
    final buyer = json['buyer'] as Map<String, dynamic>?;
    final seller = json['seller'] as Map<String, dynamic>?;

    return PaymentRequestModel(
      id: json['id'] as int,
      status: json['status'] as String? ?? 'pending',
      // BE field is request_type; keep json['type'] as fallback
      type: json['request_type'] as String? ?? json['type'] as String? ?? 'market',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      buyerNote: (json['buyer_note'] as String?)?.isEmpty == true
          ? null
          : json['buyer_note'] as String?,
      sellerNote: (json['seller_note'] as String?)?.isEmpty == true
          ? null
          : json['seller_note'] as String?,
      auctionItemId: auctionItemId,
      orderItemId: orderItemId,
      assetId: asset?['id'] as int?,
      assetTitle: asset?['title'] as String? ?? '',
      assetCategory: asset?['category'] as String? ?? '',
      buyerProfileId: buyer?['id'] as int?,
      sellerProfileId: seller?['id'] as int?,
      created: DateTime.parse(json['created'] as String),
      modified: DateTime.tryParse(json['modified'] as String? ?? ''),
      approvedAt: DateTime.tryParse(json['approved_at'] as String? ?? ''),
      rejectedAt: DateTime.tryParse(json['rejected_at'] as String? ?? ''),
      paymentProofUrl: json['payment_proof'] as String?,
    );
  }

  PaymentRequestModel copyWith({
    String? status,
    String? buyerNote,
    String? sellerNote,
    String? paymentProofUrl,
  }) =>
      PaymentRequestModel(
        id: id,
        status: status ?? this.status,
        type: type,
        amount: amount,
        buyerNote: buyerNote ?? this.buyerNote,
        sellerNote: sellerNote ?? this.sellerNote,
        auctionItemId: auctionItemId,
        orderItemId: orderItemId,
        assetId: assetId,
        assetTitle: assetTitle,
        assetCategory: assetCategory,
        buyerProfileId: buyerProfileId,
        sellerProfileId: sellerProfileId,
        created: created,
        modified: modified,
        approvedAt: approvedAt,
        rejectedAt: rejectedAt,
        paymentProofUrl: paymentProofUrl ?? this.paymentProofUrl,
      );

  String get statusLabel => switch (status) {
        'pending' => 'في الانتظار',
        'approved' => 'مقبول',
        'rejected' => 'مرفوض',
        'cancelled' => 'ملغى',
        _ => status,
      };

  String get typeLabel => isAuction ? 'مزاد' : 'متجر';

  String get categoryLabel {
    switch (assetCategory) {
      case 'bird':
        return 'حمام';
      case 'supply':
        return 'مستلزم';
      case 'accessory':
        return 'إكسسوار';
      case 'feed':
        return 'علف';
      case 'supplement':
        return 'مكمل';
      default:
        return assetCategory;
    }
  }
}
