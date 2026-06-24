import 'package:equatable/equatable.dart';

import '../model/subscription_package_model.dart';

enum PackagesStatus { initial, loading, loaded, requesting, error }

class PackagesState extends Equatable {
  final PackagesStatus status;
  final List<PackageModel> packages;
  final List<ActiveSellerPackageModel> activePackages;
  final PendingSellerPackageModel? pendingPackage;
  final String? errorMessage;
  final String? requestError;
  final bool requestSuccess;
  final bool cancelling;
  final String? cancelError;

  const PackagesState({
    this.status = PackagesStatus.initial,
    this.packages = const [],
    this.activePackages = const [],
    this.pendingPackage,
    this.errorMessage,
    this.requestError,
    this.requestSuccess = false,
    this.cancelling = false,
    this.cancelError,
  });

  PackagesState copyWith({
    PackagesStatus? status,
    List<PackageModel>? packages,
    List<ActiveSellerPackageModel>? activePackages,
    PendingSellerPackageModel? pendingPackage,
    bool clearPendingPackage = false,
    String? errorMessage,
    String? requestError,
    bool clearRequestError = false,
    bool? requestSuccess,
    bool? cancelling,
    String? cancelError,
    bool clearCancelError = false,
  }) {
    return PackagesState(
      status: status ?? this.status,
      packages: packages ?? this.packages,
      activePackages: activePackages ?? this.activePackages,
      pendingPackage:
          clearPendingPackage ? null : (pendingPackage ?? this.pendingPackage),
      errorMessage: errorMessage ?? this.errorMessage,
      requestError:
          clearRequestError ? null : (requestError ?? this.requestError),
      requestSuccess: requestSuccess ?? this.requestSuccess,
      cancelling: cancelling ?? this.cancelling,
      cancelError: clearCancelError ? null : (cancelError ?? this.cancelError),
    );
  }

  @override
  List<Object?> get props => [
        status,
        packages,
        activePackages,
        pendingPackage,
        errorMessage,
        requestError,
        requestSuccess,
        cancelling,
        cancelError,
      ];
}
