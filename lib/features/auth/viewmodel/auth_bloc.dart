import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/auth_repository.dart';
import '../model/user_model.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc({required AuthRepository repository})
    : _repository = repository,
      super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterPersonalRequested>(_onRegisterPersonal);
    on<AuthRegisterProviderRequested>(_onRegisterProvider);
    on<AuthOtpVerifyRequested>(_onOtpVerify);
    on<AuthResendOtpRequested>(_onResendOtp);
    on<AuthSwitchProfileRequested>(_onSwitchProfile);
    on<AuthSwitchProfileByIdRequested>(_onSwitchProfileById);
    on<AuthBecomeSellerRequested>(_onBecomeSeller);
    on<AuthProfileSwitchFailureAcknowledged>(
      _onProfileSwitchFailureAcknowledged,
    );
    on<AuthLogoutRequested>(_onLogout);
    on<AuthReset>(_onReset);
  }

  Future<void> _onCheck(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _repository.getStoredUser();
    result.fold(
      (_) => emit(const AuthInitial()),
      (user) =>
          user != null ? emit(AuthSuccess(user)) : emit(const AuthInitial()),
    );
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _repository.login(
      phoneNumber: event.phoneNumber,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  Future<void> _onRegisterPersonal(
    AuthRegisterPersonalRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _repository.registerPersonal(
      phoneNumber: event.phoneNumber,
      password: event.password,
      country: event.country,
      username: event.username,
      avatarPath: event.avatarPath,
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(AuthOtpRequired(event.phoneNumber)),
    );
  }

  Future<void> _onRegisterProvider(
    AuthRegisterProviderRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _repository.registerProvider(
      phoneNumber: event.phoneNumber,
      password: event.password,
      country: event.country,
      username: event.username,
      avatarPath: event.avatarPath,
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(AuthOtpRequired(event.phoneNumber)),
    );
  }

  Future<void> _onOtpVerify(
    AuthOtpVerifyRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _repository.verifyOtp(
      phoneNumber: event.phoneNumber,
      code: event.code,
    );
    await result.fold((failure) async => emit(AuthFailure(failure.message)), (
      _,
    ) async {
      // Tokens were saved during registerPersonal/registerProvider login.
      // Restore session from storage so the root bloc has an authenticated user.
      final stored = await _repository.getStoredUser();
      stored.fold(
        (_) => emit(AuthOtpVerified(event.phoneNumber)),
        (user) => user != null
            ? emit(AuthSuccess(user))
            : emit(AuthOtpVerified(event.phoneNumber)),
      );
    });
  }

  Future<void> _onResendOtp(
    AuthResendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.resendOtp(phoneNumber: event.phoneNumber);
    emit(const AuthOtpResent());
  }

  Future<void> _onSwitchProfile(
    AuthSwitchProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthSwitchingProfile) return;

    UserModel? previous;
    if (state is AuthSuccess) {
      previous = (state as AuthSuccess).user;
    } else if (state is AuthProfileSwitchFailure) {
      previous = (state as AuthProfileSwitchFailure).user;
    }

    if (previous == null) return;
    final sessionUser = previous;

    emit(AuthSwitchingProfile(sessionUser));
    final result = await _repository.switchProfile(event.newProfile);
    result.fold(
      (failure) => emit(AuthProfileSwitchFailure(sessionUser, failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  Future<void> _onSwitchProfileById(
    AuthSwitchProfileByIdRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthSwitchingProfile) return;

    UserModel? previous;
    if (state is AuthSuccess) {
      previous = (state as AuthSuccess).user;
    } else if (state is AuthProfileSwitchFailure) {
      previous = (state as AuthProfileSwitchFailure).user;
    }
    if (previous == null) return;

    emit(AuthSwitchingProfile(previous));
    final result = await _repository.switchProfileById(event.profileId);
    result.fold(
      (failure) => emit(AuthProfileSwitchFailure(previous!, failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  Future<void> _onBecomeSeller(
    AuthBecomeSellerRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthSwitchingProfile) return;

    UserModel? previous;
    if (state is AuthSuccess) {
      previous = (state as AuthSuccess).user;
    } else if (state is AuthProfileSwitchFailure) {
      previous = (state as AuthProfileSwitchFailure).user;
    }
    if (previous == null) return;
    final sessionUser = previous;

    emit(AuthSwitchingProfile(sessionUser));

    // Fetch existing seller profiles — switch to first (earliest-created) if any.
    final idsResult = await _repository.fetchMySellerProfileIds();
    if (idsResult.isLeft()) {
      final message = idsResult.fold((f) => f.message, (_) => '');
      emit(AuthProfileSwitchFailure(sessionUser, message));
      return;
    }
    final ids = idsResult.getOrElse(() => []);

    if (ids.isNotEmpty) {
      final switchResult = await _repository.switchProfileById(ids.first);
      switchResult.fold(
        (failure) => emit(AuthProfileSwitchFailure(sessionUser, failure.message)),
        (user) => emit(AuthSuccess(user)),
      );
      return;
    }

    // No seller profile yet — create one then switch.
    final createResult = await _repository.createSellerProfile();
    if (createResult.isLeft()) {
      final message = createResult.fold((f) => f.message, (_) => '');
      emit(AuthProfileSwitchFailure(sessionUser, message));
      return;
    }

    final idsAfterCreate = await _repository.fetchMySellerProfileIds();
    if (idsAfterCreate.isLeft() || idsAfterCreate.getOrElse(() => []).isEmpty) {
      emit(AuthProfileSwitchFailure(sessionUser, 'فشل في إنشاء الملف الشخصي'));
      return;
    }

    final switchResult = await _repository.switchProfileById(
      idsAfterCreate.getOrElse(() => []).first,
    );
    switchResult.fold(
      (failure) => emit(AuthProfileSwitchFailure(sessionUser, failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  void _onProfileSwitchFailureAcknowledged(
    AuthProfileSwitchFailureAcknowledged event,
    Emitter<AuthState> emit,
  ) {
    if (state is AuthProfileSwitchFailure) {
      emit(AuthSuccess((state as AuthProfileSwitchFailure).user));
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.logout();
    emit(const AuthInitial());
  }

  void _onReset(AuthReset event, Emitter<AuthState> emit) =>
      emit(const AuthInitial());
}
