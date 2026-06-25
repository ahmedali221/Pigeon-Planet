part of 'transfers_bloc.dart';

abstract class TransfersEvent extends Equatable {
  const TransfersEvent();
  @override
  List<Object?> get props => [];
}

class TransfersLoadRequested extends TransfersEvent {
  final int? assetId;
  const TransfersLoadRequested({this.assetId});
  @override
  List<Object?> get props => [assetId];
}

class TransferCreateRequested extends TransfersEvent {
  final int assetId;
  final int toProfileId;
  final String? note;

  const TransferCreateRequested({
    required this.assetId,
    required this.toProfileId,
    this.note,
  });

  @override
  List<Object?> get props => [assetId, toProfileId, note];
}

class TransferSellerSearchRequested extends TransfersEvent {
  final String query;
  const TransferSellerSearchRequested(this.query);
  @override
  List<Object?> get props => [query];
}
