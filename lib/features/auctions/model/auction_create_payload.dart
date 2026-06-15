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
  });

  Map<String, dynamic> toJson() => {
        if (birdId != null) 'bird_id': birdId,
        if (birdName != null && birdName!.isNotEmpty) 'bird_name': birdName,
        if (ringNumber != null && ringNumber!.isNotEmpty) 'ring_number': ringNumber,
        if (gender != null) 'gender': gender,
        if (colour != null && colour!.isNotEmpty) 'colour': colour,
        if (pairedBirdId != null) 'paired_bird_id': pairedBirdId,
        if (pairedBirdName != null && pairedBirdName!.isNotEmpty) 'paired_bird_name': pairedBirdName,
        if (pairedRingNumber != null && pairedRingNumber!.isNotEmpty) 'paired_ring_number': pairedRingNumber,
        if (pairedGender != null) 'paired_gender': pairedGender,
        if (pairedColour != null && pairedColour!.isNotEmpty) 'paired_colour': pairedColour,
        'starting_price': startingPrice,
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
    this.thumbnailPath,
    this.thumbnailUrl,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty)
          'thumbnail_url': thumbnailUrl,
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
        'items': items.map((i) => i.toJson()).toList(),
      };

  AuctionCreatePayload copyWith({String? thumbnailUrl}) => AuctionCreatePayload(
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
        thumbnailPath: thumbnailPath,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      );
}
