part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final UserModel user;

  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

/// Active session while `/auth/switch-profile/` is in flight (keeps user on Home).
class AuthSwitchingProfile extends AuthState {
  final UserModel user;

  const AuthSwitchingProfile(this.user);

  @override
  List<Object?> get props => [user];
}

/// Switch failed; session restored. Consume in UI then dispatch [AuthProfileSwitchFailureAcknowledged].
class AuthProfileSwitchFailure extends AuthState {
  final UserModel user;
  final String message;

  const AuthProfileSwitchFailure(this.user, this.message);

  @override
  List<Object?> get props => [user, message];
}

class AuthOtpRequired extends AuthState {
  final String phoneNumber;
  const AuthOtpRequired(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthOtpVerified extends AuthState {
  final String phoneNumber;
  const AuthOtpVerified(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthOtpResent extends AuthState {
  const AuthOtpResent();
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
