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

class AuthOtpVerifyRequested extends AuthEvent {
  final String phoneNumber;
  final String code;

  const AuthOtpVerifyRequested({
    required this.phoneNumber,
    required this.code,
  });

  @override
  List<Object?> get props => [phoneNumber, code];
}

class AuthResendOtpRequested extends AuthEvent {
  final String phoneNumber;
  const AuthResendOtpRequested({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthSwitchProfileRequested extends AuthEvent {
  final String newProfile;
  const AuthSwitchProfileRequested(this.newProfile);

  @override
  List<Object?> get props => [newProfile];
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
