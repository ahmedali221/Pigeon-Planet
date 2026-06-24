import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int id;
  final String phoneNumber;
  final String profileType; // 'Customer' | 'Seller' | 'Manager'
  final int? profileId; // active profile's DB id
  final String accessToken;
  final String refreshToken;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.phoneNumber,
    required this.profileType,
    this.profileId,
    required this.accessToken,
    required this.refreshToken,
    this.avatarUrl,
  });

  bool get isSeller => profileType == 'Seller';
  bool get isCustomer => profileType == 'Customer';

  UserModel copyWith({
    int? id,
    String? phoneNumber,
    String? profileType,
    int? profileId,
    String? accessToken,
    String? refreshToken,
    String? avatarUrl,
  }) =>
      UserModel(
        id: id ?? this.id,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        profileType: profileType ?? this.profileType,
        profileId: profileId ?? this.profileId,
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );

  @override
  List<Object?> get props =>
      [id, phoneNumber, profileType, profileId, accessToken, refreshToken, avatarUrl];
}
