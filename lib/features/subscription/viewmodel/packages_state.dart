import 'package:equatable/equatable.dart';

import '../model/subscription_package_model.dart';

enum PackagesStatus { initial, loading, loaded, requesting, error }

class PackagesState extends Equatable {
  final PackagesStatus status;
  final List<PackageModel> packages;
  final ActiveSellerPackageModel? activePackage;
  final String? errorMessage;
  final String? requestError;
  final bool requestSuccess;

  const PackagesState({
    this.status = PackagesStatus.initial,
    this.packages = const [],
    this.activePackage,
    this.errorMessage,
    this.requestError,
    this.requestSuccess = false,
  });

  PackagesState copyWith({
    PackagesStatus? status,
    List<PackageModel>? packages,
    ActiveSellerPackageModel? activePackage,
    bool clearActivePackage = false,
    String? errorMessage,
    String? requestError,
    bool clearRequestError = false,
    bool? requestSuccess,
  }) {
    return PackagesState(
      status: status ?? this.status,
      packages: packages ?? this.packages,
      activePackage: clearActivePackage ? null : (activePackage ?? this.activePackage),
      errorMessage: errorMessage ?? this.errorMessage,
      requestError: clearRequestError ? null : (requestError ?? this.requestError),
      requestSuccess: requestSuccess ?? this.requestSuccess,
    );
  }

  @override
  List<Object?> get props => [
        status,
        packages,
        activePackage,
        errorMessage,
        requestError,
        requestSuccess,
      ];
}
