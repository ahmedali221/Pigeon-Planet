part of 'payments_bloc.dart';

abstract class PaymentsEvent extends Equatable {
  const PaymentsEvent();
  @override
  List<Object?> get props => [];
}

class PaymentsLoadRequested extends PaymentsEvent {
  const PaymentsLoadRequested();
}

class AuctionPaymentCreateRequested extends PaymentsEvent {
  final int auctionItemId;
  final String? buyerNote;
  final PlatformFile? proofFile;

  const AuctionPaymentCreateRequested(this.auctionItemId, {this.buyerNote, this.proofFile});

  @override
  List<Object?> get props => [auctionItemId, buyerNote, proofFile?.path];
}

class MarketPaymentCreateRequested extends PaymentsEvent {
  final int orderItemId;
  final String? buyerNote;
  final PlatformFile? proofFile;

  const MarketPaymentCreateRequested(this.orderItemId,
      {this.buyerNote, this.proofFile});

  @override
  List<Object?> get props => [orderItemId, buyerNote, proofFile?.path];
}

class PaymentBuyerNoteUpdateRequested extends PaymentsEvent {
  final int requestId;
  final String buyerNote;
  final PlatformFile? proofFile;

  PaymentBuyerNoteUpdateRequested(this.requestId, this.buyerNote, {this.proofFile});

  @override
  List<Object?> get props => [requestId, buyerNote, proofFile?.path];
}

class PaymentApproveRequested extends PaymentsEvent {
  final int requestId;

  const PaymentApproveRequested(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class PaymentRejectRequested extends PaymentsEvent {
  final int requestId;
  final String? sellerNote;

  const PaymentRejectRequested(this.requestId, {this.sellerNote});

  @override
  List<Object?> get props => [requestId, sellerNote];
}
