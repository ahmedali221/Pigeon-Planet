import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int id;
  final String phoneNumber;
  final String profileType; // 'Customer' | 'Seller' | 'Manager'
  final String accessToken;
  final String refreshToken;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.phoneNumber,
    required this.profileType,
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
    String? accessToken,
    String? refreshToken,
    String? avatarUrl,
  }) =>
      UserModel(
        id: id ?? this.id,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        profileType: profileType ?? this.profileType,
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );

  @override
  List<Object?> get props =>
      [id, phoneNumber, profileType, accessToken, refreshToken, avatarUrl];
}
