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
    on<AuthSwitchProfileRequested>(_onSwitchProfile);
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
      (user) => emit(AuthSuccess(user)),
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
      (user) => emit(AuthSuccess(user)),
    );
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

    final createResult = await _repository.createSellerProfile();
    if (createResult.isLeft()) {
      final message = createResult.fold((f) => f.message, (_) => '');
      emit(AuthProfileSwitchFailure(sessionUser, message));
      return;
    }
    final switchResult = await _repository.switchProfile('Seller');
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
