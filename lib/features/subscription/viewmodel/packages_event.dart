abstract class PackagesEvent {}

class PackagesLoadRequested extends PackagesEvent {}

class PackageRequestSubmitted extends PackagesEvent {
  final int packageId;
  PackageRequestSubmitted(this.packageId);
}
