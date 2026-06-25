part of 'clocks_bloc.dart';

abstract class ClocksEvent {}

class ClocksListLoaded extends ClocksEvent {
  final String search;
  final bool inStockOnly;
  ClocksListLoaded({this.search = '', this.inStockOnly = false});
}

class ClocksSearchChanged extends ClocksEvent {
  final String query;
  ClocksSearchChanged(this.query);
}

class ClockDetailRequested extends ClocksEvent {
  final int id;
  ClockDetailRequested(this.id);
}

class ClockOrderStarted extends ClocksEvent {
  final int clockId;
  final int quantity;
  final String note;
  ClockOrderStarted({required this.clockId, this.quantity = 1, this.note = ''});
}

class ClockPaymentSubmitted extends ClocksEvent {
  final int orderId;
  final String proofUrl;
  final String note;
  ClockPaymentSubmitted({
    required this.orderId,
    required this.proofUrl,
    this.note = '',
  });
}

class ClockMyOrdersLoaded extends ClocksEvent {}

class ClocksOrderReset extends ClocksEvent {}
