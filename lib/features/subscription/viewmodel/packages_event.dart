abstract class PackagesEvent {}

class PackagesLoadRequested extends PackagesEvent {}

class PackageRequestSubmitted extends PackagesEvent {
  final int packageId;
  PackageRequestSubmitted(this.packageId);
}

class PackageCancelRequested extends PackagesEvent {
  final int packageId;
  PackageCancelRequested(this.packageId);
}
