class ClockImageModel {
  final int id;
  final String url;
  final int order;

  const ClockImageModel({required this.id, required this.url, required this.order});

  factory ClockImageModel.fromJson(Map<String, dynamic> json) => ClockImageModel(
        id: json['id'] as int,
        url: json['url'] as String,
        order: json['order'] as int? ?? 0,
      );
}

class ClockAgentModel {
  final int id;
  final String name;
  final String governorate;
  final String? photoUrl;
  final String phoneNumber;

  const ClockAgentModel({
    required this.id,
    required this.name,
    required this.governorate,
    this.photoUrl,
    required this.phoneNumber,
  });

  factory ClockAgentModel.fromJson(Map<String, dynamic> json) => ClockAgentModel(
        id: json['id'] as int,
        name: json['name'] as String,
        governorate: json['governorate'] as String,
        photoUrl: json['photo_url'] as String?,
        phoneNumber: json['phone_number'] as String,
      );
}

class ElectronicClockModel {
  final int id;
  final String name;
  final String brand;
  final String description;
  final double price;
  final List<ClockImageModel> images;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final List<String> features;
  final ClockAgentModel? agent;
  final String status;

  const ElectronicClockModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.price,
    required this.images,
    required this.rating,
    required this.reviewCount,
    required this.inStock,
    required this.features,
    this.agent,
    required this.status,
  });

  String? get firstImageUrl => images.isNotEmpty ? images.first.url : null;

  factory ElectronicClockModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'] as List<dynamic>? ?? [];
    final rawFeatures = json['features'] as List<dynamic>? ?? [];

    return ElectronicClockModel(
      id: json['id'] as int,
      name: json['name'] as String,
      brand: json['brand'] as String,
      description: json['description'] as String? ?? '',
      price: double.parse((json['price'] ?? '0').toString()),
      images: rawImages
          .map((e) => ClockImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      rating: double.parse((json['rating'] ?? '0').toString()),
      reviewCount: json['review_count'] as int? ?? 0,
      inStock: json['in_stock'] as bool? ?? false,
      features: rawFeatures
          .map((e) => e is Map ? (e['text'] as String? ?? '') : e.toString())
          .where((s) => s.isNotEmpty)
          .toList(),
      agent: json['agent'] != null && json['agent'] is Map
          ? ClockAgentModel.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String? ?? 'available',
    );
  }
}

// ── Order models ──────────────────────────────────────────────────────────────

class ClockPaymentRequestModel {
  final int id;
  final String paymentProof;
  final String note;
  final String status; // pending | approved | rejected
  final String adminNote;
  final DateTime createdAt;

  const ClockPaymentRequestModel({
    required this.id,
    required this.paymentProof,
    required this.note,
    required this.status,
    required this.adminNote,
    required this.createdAt,
  });

  factory ClockPaymentRequestModel.fromJson(Map<String, dynamic> json) =>
      ClockPaymentRequestModel(
        id: json['id'] as int,
        paymentProof: json['payment_proof'] as String,
        note: json['note'] as String? ?? '',
        status: json['status'] as String,
        adminNote: json['admin_note'] as String? ?? '',
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class ClockOrderModel {
  final int id;
  final int clockId;
  final String clockName;
  final String? clockFirstImageUrl;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String status; // pending | awaiting_payment | completed | cancelled
  final String buyerNote;
  final ClockPaymentRequestModel? paymentRequest;
  final DateTime createdAt;

  const ClockOrderModel({
    required this.id,
    required this.clockId,
    required this.clockName,
    this.clockFirstImageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.status,
    required this.buyerNote,
    this.paymentRequest,
    required this.createdAt,
  });

  bool get isPending => status == 'pending';
  bool get isAwaitingPayment => status == 'awaiting_payment';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  factory ClockOrderModel.fromJson(Map<String, dynamic> json) {
    final clockJson = json['clock'] as Map<String, dynamic>? ?? {};
    final rawImages = clockJson['images'] as List<dynamic>? ?? [];
    final firstImageUrl = rawImages.isNotEmpty
        ? (rawImages.first as Map<String, dynamic>)['url'] as String?
        : null;

    return ClockOrderModel(
      id: json['id'] as int,
      clockId: clockJson['id'] as int? ?? 0,
      clockName: clockJson['name'] as String? ?? '',
      clockFirstImageUrl: firstImageUrl,
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: double.parse((json['unit_price'] ?? '0').toString()),
      totalPrice: double.parse((json['total_price'] ?? '0').toString()),
      status: json['status'] as String? ?? 'pending',
      buyerNote: json['buyer_note'] as String? ?? '',
      paymentRequest: json['payment_request'] != null && json['payment_request'] is Map
          ? ClockPaymentRequestModel.fromJson(
              json['payment_request'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
