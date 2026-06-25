class AuctionItemInput {
  final int? birdId;
  final String? birdName;
  final String? ringNumber;
  final String? gender;
  final String? colour;
  final int? pairedBirdId;
  final String? pairedBirdName;
  final String? pairedRingNumber;
  final String? pairedGender;
  final String? pairedColour;
  final String startingPrice;
  final String? reservePrice;

  const AuctionItemInput({
    this.birdId,
    this.birdName,
    this.ringNumber,
    this.gender,
    this.colour,
    this.pairedBirdId,
    this.pairedBirdName,
    this.pairedRingNumber,
    this.pairedGender,
    this.pairedColour,
    required this.startingPrice,
    this.reservePrice,
  });

  Map<String, dynamic> toJson() => {
        if (birdId != null) 'bird_id': birdId,
        if (pairedBirdId != null) 'paired_bird_id': pairedBirdId,
        'starting_price': startingPrice,
        if (reservePrice != null && reservePrice!.isNotEmpty)
          'reserve_price': reservePrice,
      };
}

class AuctionCreatePayload {
  final String title;
  final String description;
  final String auctionType;
  final String startTime;
  final String endTime;
  final bool autoExtendEnabled;
  final int? autoExtendMinutes;
  final bool buyNowEnabled;
  final String? buyNowPrice;
  final bool depositRequired;
  final int? paymentDeadlineDays;
  final String minBidIncrement;
  final String? tags;
  final List<AuctionItemInput> items;
  final int? sellerPackageId;

  /// Local file path of the cover image to upload to Cloudinary before sending.
  /// Not serialized; the datasource uploads it and injects the resulting URL.
  final String? thumbnailPath;

  /// Already-uploaded Cloudinary URL (used when no local path needs uploading).
  final String? thumbnailUrl;

  const AuctionCreatePayload({
    required this.title,
    required this.description,
    required this.auctionType,
    required this.startTime,
    required this.endTime,
    this.autoExtendEnabled = false,
    this.autoExtendMinutes,
    this.buyNowEnabled = false,
    this.buyNowPrice,
    this.depositRequired = false,
    this.paymentDeadlineDays,
    required this.minBidIncrement,
    this.tags,
    required this.items,
    this.sellerPackageId,
    this.thumbnailPath,
    this.thumbnailUrl,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'auction_type': auctionType,
        'start_time': startTime,
        'end_time': endTime,
        'auto_extend_enabled': autoExtendEnabled,
        if (autoExtendMinutes != null) 'auto_extend_minutes': autoExtendMinutes,
        'buy_now_enabled': buyNowEnabled,
        if (buyNowPrice != null) 'buy_now_price': buyNowPrice,
        'deposit_required': depositRequired,
        if (paymentDeadlineDays != null)
          'payment_deadline_days': paymentDeadlineDays,
        'min_bid_increment': minBidIncrement,
        if (tags != null && tags!.isNotEmpty) 'tags': tags,
        if (sellerPackageId != null) 'seller_package_id': sellerPackageId,
        'items': items.map((i) => i.toJson()).toList(),
      };

  AuctionCreatePayload copyWith({
    String? thumbnailUrl,
    int? sellerPackageId,
  }) =>
      AuctionCreatePayload(
        title: title,
        description: description,
        auctionType: auctionType,
        startTime: startTime,
        endTime: endTime,
        autoExtendEnabled: autoExtendEnabled,
        autoExtendMinutes: autoExtendMinutes,
        buyNowEnabled: buyNowEnabled,
        buyNowPrice: buyNowPrice,
        depositRequired: depositRequired,
        paymentDeadlineDays: paymentDeadlineDays,
        minBidIncrement: minBidIncrement,
        tags: tags,
        items: items,
        sellerPackageId: sellerPackageId ?? this.sellerPackageId,
        thumbnailPath: thumbnailPath,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      );
}
