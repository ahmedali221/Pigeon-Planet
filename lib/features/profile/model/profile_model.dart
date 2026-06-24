import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  final int id;
  final String type; // 'Seller' | 'Customer'
  final String? nickname; // seller only
  final String? username;
  final String? phoneNumber;
  final String? avatarUrl;
  final String country;
  final String currency;
  final double? cashbackBalance; // customer only
  final double? avgRating; // seller only
  final int? ratingsCount; // seller only
  final bool activated;
  final bool isActive;
  final bool isValid;
  final DateTime? created;
  final String? nationalId;
  final String? address;
  final String? recodedVoice; // seller only
  final int successfulInvitesCount;
  final int completedOrdersCount;
  final String? sellerLevel; // seller only — e.g. "bronze"
  final String? sellerLevelLabel; // seller only — human-readable
  final String? customerLevel; // customer only
  final String? customerLevelLabel; // customer only
  final double? levelDiscountPercent; // customer only
  final double? levelCashbackPercent; // customer only

  const ProfileModel({
    required this.id,
    required this.type,
    this.nickname,
    this.username,
    this.phoneNumber,
    this.avatarUrl,
    required this.country,
    required this.currency,
    this.cashbackBalance,
    this.avgRating,
    this.ratingsCount,
    required this.activated,
    required this.isActive,
    required this.isValid,
    this.created,
    this.nationalId,
    this.address,
    this.recodedVoice,
    this.successfulInvitesCount = 0,
    this.completedOrdersCount = 0,
    this.sellerLevel,
    this.sellerLevelLabel,
    this.customerLevel,
    this.customerLevelLabel,
    this.levelDiscountPercent,
    this.levelCashbackPercent,
  });

  bool get isSeller => type == 'Seller';

  String get displayName {
    if (isSeller) {
      return (nickname != null && nickname!.isNotEmpty) ? nickname! : 'بائع';
    }
    return (username != null && username!.isNotEmpty) ? username! : 'مشتري';
  }

  static const Map<String, String> _countryNames = {
    'EG': 'مصر', 'SA': 'السعودية', 'AE': 'الإمارات',
    'KW': 'الكويت', 'QA': 'قطر', 'BH': 'البحرين',
    'OM': 'عُمان', 'JO': 'الأردن', 'IQ': 'العراق',
    'LB': 'لبنان', 'SY': 'سوريا', 'PS': 'فلسطين',
    'YE': 'اليمن', 'MA': 'المغرب', 'TN': 'تونس',
    'DZ': 'الجزائر', 'LY': 'ليبيا', 'SD': 'السودان',
    'US': 'الولايات المتحدة', 'EU': 'الاتحاد الأوروبي',
  };

  static const Map<String, String> countryCurrency = {
    'EG': 'EGP', 'SA': 'SAR', 'AE': 'AED', 'KW': 'KWD',
    'QA': 'QAR', 'BH': 'BHD', 'OM': 'OMR', 'JO': 'JOD',
    'IQ': 'IQD', 'LB': 'LBP', 'SY': 'SYP', 'PS': 'ILS',
    'YE': 'YER', 'MA': 'MAD', 'TN': 'TND', 'DZ': 'DZD',
    'LY': 'LYD', 'SD': 'SDG', 'US': 'USD', 'EU': 'EUR',
  };

  static List<String> get countryCodes => _countryNames.keys.toList();

  String get countryName => _countryNames[country] ?? country;

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: (json['id'] as int?) ?? 0,
        type: json['type'] as String? ?? 'Customer',
        nickname: json['nickname'] as String?,
        username: json['username'] as String?,
        phoneNumber: json['phone_number'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        country: json['country'] as String? ?? '',
        currency: json['currency'] as String? ?? '',
        cashbackBalance: double.tryParse(json['cashback_balance']?.toString() ?? ''),
        avgRating: double.tryParse(json['avg_rating']?.toString() ?? ''),
        ratingsCount: json['ratings_count'] as int?,
        activated: json['activated'] as bool? ?? false,
        isActive: json['is_active'] as bool? ?? true,
        isValid: json['is_valid'] as bool? ?? true,
        created: json['created'] != null
            ? DateTime.tryParse(json['created'] as String)
            : null,
        nationalId: json['national_id'] as String?,
        address: json['address'] as String?,
        recodedVoice: json['recoded_voice'] as String?,
        successfulInvitesCount: (json['successful_invites_count'] as int?) ?? 0,
        completedOrdersCount: (json['completed_orders_count'] as int?) ?? 0,
        sellerLevel: json['seller_level'] as String?,
        sellerLevelLabel: json['seller_level_label'] as String?,
        customerLevel: json['customer_level'] as String?,
        customerLevelLabel: json['customer_level_label'] as String?,
        levelDiscountPercent:
            double.tryParse(json['level_discount_percent']?.toString() ?? ''),
        levelCashbackPercent:
            double.tryParse(json['level_cashback_percent']?.toString() ?? ''),
      );

  ProfileModel copyWith({
    String? nickname,
    String? avatarUrl,
    String? country,
    String? currency,
    String? nationalId,
    String? address,
  }) =>
      ProfileModel(
        id: id,
        type: type,
        nickname: nickname ?? this.nickname,
        username: username,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        country: country ?? this.country,
        currency: currency ?? this.currency,
        cashbackBalance: cashbackBalance,
        avgRating: avgRating,
        ratingsCount: ratingsCount,
        activated: activated,
        isActive: isActive,
        isValid: isValid,
        created: created,
        nationalId: nationalId ?? this.nationalId,
        address: address ?? this.address,
        recodedVoice: recodedVoice,
        successfulInvitesCount: successfulInvitesCount,
        completedOrdersCount: completedOrdersCount,
        sellerLevel: sellerLevel,
        sellerLevelLabel: sellerLevelLabel,
        customerLevel: customerLevel,
        customerLevelLabel: customerLevelLabel,
        levelDiscountPercent: levelDiscountPercent,
        levelCashbackPercent: levelCashbackPercent,
      );

  @override
  List<Object?> get props => [
        id, type, nickname, username, phoneNumber, avatarUrl, country, currency,
        cashbackBalance, avgRating, ratingsCount, activated, isActive, isValid,
        created, nationalId, address, recodedVoice, successfulInvitesCount,
        completedOrdersCount, sellerLevel, sellerLevelLabel, customerLevel,
        customerLevelLabel, levelDiscountPercent, levelCashbackPercent,
      ];
}
