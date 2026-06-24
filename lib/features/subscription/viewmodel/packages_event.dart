import 'package:file_picker/file_picker.dart';

abstract class PackagesEvent {}

class PackagesLoadRequested extends PackagesEvent {}

class PackageRequestSubmitted extends PackagesEvent {
  final int packageId;
  final PlatformFile? proofFile;
  PackageRequestSubmitted(this.packageId, {this.proofFile});
}

class PackageCancelRequested extends PackagesEvent {
  final int packageId;
  PackageCancelRequested(this.packageId);
}
