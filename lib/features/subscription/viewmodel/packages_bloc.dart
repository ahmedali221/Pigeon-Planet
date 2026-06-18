import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/datasources/subscription_packages_remote_datasource.dart';
import '../model/subscription_package_model.dart';
import 'packages_event.dart';
import 'packages_state.dart';

class PackagesBloc extends Bloc<PackagesEvent, PackagesState> {
  final SubscriptionPackagesRemoteDataSource _datasource;

  PackagesBloc({required SubscriptionPackagesRemoteDataSource datasource})
      : _datasource = datasource,
        super(const PackagesState()) {
    on<PackagesLoadRequested>(_onLoad);
    on<PackageRequestSubmitted>(_onRequest);
    on<PackageCancelRequested>(_onCancel);
  }

  Future<void> _onLoad(
    PackagesLoadRequested event,
    Emitter<PackagesState> emit,
  ) async {
    emit(state.copyWith(status: PackagesStatus.loading));
    try {
      List<PackageModel>? packages;
      ActiveSellerPackageModel? activePackage;
      PendingSellerPackageModel? pendingPackage;

      await Future.wait([
        _datasource.fetchPackages().then((v) => packages = v),
        _datasource.fetchActivePackage().then((v) => activePackage = v),
        _datasource.fetchPendingPackage().then((v) => pendingPackage = v),
      ]);

      emit(state.copyWith(
        status: PackagesStatus.loaded,
        packages: packages ?? [],
        activePackage: activePackage,
        clearActivePackage: activePackage == null,
        pendingPackage: pendingPackage,
        clearPendingPackage: pendingPackage == null,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: PackagesStatus.error,
        errorMessage: 'تعذر تحميل الباقات. تحقق من اتصالك وحاول مجدداً.',
      ));
    }
  }

  Future<void> _onCancel(
    PackageCancelRequested event,
    Emitter<PackagesState> emit,
  ) async {
    emit(state.copyWith(cancelling: true, clearCancelError: true));
    try {
      await _datasource.cancelPackage(event.packageId);
      emit(state.copyWith(
        cancelling: false,
        clearPendingPackage: true,
      ));
    } catch (_) {
      emit(state.copyWith(
        cancelling: false,
        cancelError: 'تعذر إلغاء الطلب. حاول مرة أخرى.',
      ));
    }
  }

  Future<void> _onRequest(
    PackageRequestSubmitted event,
    Emitter<PackagesState> emit,
  ) async {
    emit(state.copyWith(
      status: PackagesStatus.requesting,
      clearRequestError: true,
      requestSuccess: false,
    ));
    try {
      await _datasource.requestPackage(event.packageId);
      emit(state.copyWith(
        status: PackagesStatus.loaded,
        requestSuccess: true,
        clearRequestError: true,
      ));
    } catch (e) {
      final msg = e.toString().isNotEmpty ? e.toString() : 'فشل تقديم الطلب. حاول مرة أخرى.';
      emit(state.copyWith(
        status: PackagesStatus.loaded,
        requestError: msg,
        requestSuccess: false,
      ));
    }
  }
}
