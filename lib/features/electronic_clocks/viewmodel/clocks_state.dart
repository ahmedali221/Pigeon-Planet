part of 'clocks_bloc.dart';

enum ClocksListStatus { initial, loading, loaded, error }

enum ClockDetailStatus { initial, loading, loaded, error }

enum ClockOrderStatus { idle, placing, placed, paying, paid, error }

class ClocksState extends Equatable {
  final ClocksListStatus listStatus;
  final List<ElectronicClockModel> clocks;
  final String search;
  final ClockDetailStatus detailStatus;
  final ElectronicClockModel? selectedClock;
  final ClockOrderStatus orderStatus;
  final ClockOrderModel? currentOrder;
  final List<ClockOrderModel> myOrders;
  final bool myOrdersLoading;
  final String? errorMessage;

  const ClocksState({
    this.listStatus = ClocksListStatus.initial,
    this.clocks = const [],
    this.search = '',
    this.detailStatus = ClockDetailStatus.initial,
    this.selectedClock,
    this.orderStatus = ClockOrderStatus.idle,
    this.currentOrder,
    this.myOrders = const [],
    this.myOrdersLoading = false,
    this.errorMessage,
  });

  ClocksState copyWith({
    ClocksListStatus? listStatus,
    List<ElectronicClockModel>? clocks,
    String? search,
    ClockDetailStatus? detailStatus,
    ElectronicClockModel? selectedClock,
    bool clearSelectedClock = false,
    ClockOrderStatus? orderStatus,
    ClockOrderModel? currentOrder,
    bool clearCurrentOrder = false,
    List<ClockOrderModel>? myOrders,
    bool? myOrdersLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ClocksState(
      listStatus: listStatus ?? this.listStatus,
      clocks: clocks ?? this.clocks,
      search: search ?? this.search,
      detailStatus: detailStatus ?? this.detailStatus,
      selectedClock:
          clearSelectedClock ? null : selectedClock ?? this.selectedClock,
      orderStatus: orderStatus ?? this.orderStatus,
      currentOrder:
          clearCurrentOrder ? null : currentOrder ?? this.currentOrder,
      myOrders: myOrders ?? this.myOrders,
      myOrdersLoading: myOrdersLoading ?? this.myOrdersLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        listStatus, clocks, search,
        detailStatus, selectedClock,
        orderStatus, currentOrder,
        myOrders, myOrdersLoading,
        errorMessage,
      ];
}
