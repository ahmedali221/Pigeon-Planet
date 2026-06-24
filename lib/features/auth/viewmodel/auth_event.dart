part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String phoneNumber;
  final String password;

  const AuthLoginRequested({
    required this.phoneNumber,
    required this.password,
  });

  @override
  List<Object?> get props => [phoneNumber, password];
}

class AuthRegisterPersonalRequested extends AuthEvent {
  final String phoneNumber;
  final String password;
  final String country;
  final String username;
  final String? avatarPath;

  const AuthRegisterPersonalRequested({
    required this.phoneNumber,
    required this.password,
    required this.country,
    required this.username,
    this.avatarPath,
  });

  @override
  List<Object?> get props => [phoneNumber, password, country, username, avatarPath];
}

class AuthRegisterProviderRequested extends AuthEvent {
  final String phoneNumber;
  final String password;
  final String country;
  final String username;
  final String? avatarPath;

  const AuthRegisterProviderRequested({
    required this.phoneNumber,
    required this.password,
    required this.country,
    required this.username,
    this.avatarPath,
  });

  @override
  List<Object?> get props => [phoneNumber, password, country, username, avatarPath];
}

/// Switch active profile.
/// - [profileId] non-null → switch to a specific seller room by DB id
/// - [profileId] null → switch to customer using [newProfile] = 'Customer'
class AuthSwitchProfileRequested extends AuthEvent {
  final String? newProfile;
  final int? profileId;

  const AuthSwitchProfileRequested({this.newProfile, this.profileId})
      : assert(newProfile != null || profileId != null,
            'Must provide either newProfile or profileId');

  @override
  List<Object?> get props => [newProfile, profileId];
}

/// Fired when a customer-profile user wants to switch to Seller.
/// Creates the seller profile if it doesn't exist, then switches.
class AuthBecomeSellerRequested extends AuthEvent {
  const AuthBecomeSellerRequested();
}

class AuthProfileSwitchFailureAcknowledged extends AuthEvent {
  const AuthProfileSwitchFailureAcknowledged();
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthReset extends AuthEvent {
  const AuthReset();
}
