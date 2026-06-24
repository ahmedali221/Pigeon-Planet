import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/seller_product_model.dart';
import '../model/seller_product_payload.dart';
import '../model/seller_products_repository.dart';

part 'seller_products_event.dart';
part 'seller_products_state.dart';

class SellerProductsBloc
    extends Bloc<SellerProductsEvent, SellerProductsState> {
  final SellerProductsRepository _repository;

  SellerProductsBloc({required SellerProductsRepository repository})
      : _repository = repository,
        super(const SellerProductsState()) {
    on<SellerProductsStarted>(_onStarted);
    on<SellerProductsRefreshRequested>(_onRefresh);
    on<SellerProductCategoryFiltered>(_onCategoryFiltered);
    on<SellerProductCreateRequested>(_onCreate);
    on<SellerProductUpdateRequested>(_onUpdate);
    on<SellerProductDeleteRequested>(_onDelete);
    on<SellerProductsLoadMoreRequested>(_onLoadMore);
  }

  Future<void> _onStarted(
    SellerProductsStarted event,
    Emitter<SellerProductsState> emit,
  ) =>
      _load(emit);

  Future<void> _onRefresh(
    SellerProductsRefreshRequested event,
    Emitter<SellerProductsState> emit,
  ) =>
      _load(emit);

  Future<void> _load(Emitter<SellerProductsState> emit) async {
    emit(state.copyWith(
        status: SellerProductsStatus.loading, clearError: true, currentPage: 1));
    final result = await _repository.getMyProducts(page: 1);
    result.fold(
      (f) => emit(state.copyWith(
        status: SellerProductsStatus.error,
        errorMessage: f.message,
      )),
      (page) => emit(state.copyWith(
        status: SellerProductsStatus.loaded,
        products: page.products,
        hasMore: page.hasMore,
        currentPage: 1,
      )),
    );
  }

  Future<void> _onLoadMore(
    SellerProductsLoadMoreRequested event,
    Emitter<SellerProductsState> emit,
  ) async {
    if (!state.hasMore || state.status == SellerProductsStatus.loadingMore) {
      return;
    }

    final nextPage = state.currentPage + 1;
    emit(state.copyWith(status: SellerProductsStatus.loadingMore));
    final result = await _repository.getMyProducts(page: nextPage);
    result.fold(
      (f) => emit(state.copyWith(status: SellerProductsStatus.loaded)),
      (page) => emit(state.copyWith(
        status: SellerProductsStatus.loaded,
        products: [...state.products, ...page.products],
        hasMore: page.hasMore,
        currentPage: nextPage,
      )),
    );
  }

  void _onCategoryFiltered(
    SellerProductCategoryFiltered event,
    Emitter<SellerProductsState> emit,
  ) {
    emit(state.copyWith(
      selectedCategory: event.category,
      clearSelectedCategory: event.category == null,
    ));
  }

  Future<void> _onCreate(
    SellerProductCreateRequested event,
    Emitter<SellerProductsState> emit,
  ) async {
    emit(state.copyWith(
        mutationStatus: SellerMutationStatus.creating,
        clearMutationError: true));
    final result = await _repository.createProduct(event.payload);
    result.fold(
      (f) => emit(state.copyWith(
        mutationStatus: SellerMutationStatus.failure,
        mutationError: f.message,
      )),
      (product) => emit(state.copyWith(
        mutationStatus: SellerMutationStatus.success,
        products: [...state.products, product],
      )),
    );
  }

  Future<void> _onUpdate(
    SellerProductUpdateRequested event,
    Emitter<SellerProductsState> emit,
  ) async {
    emit(state.copyWith(
        mutationStatus: SellerMutationStatus.updating,
        clearMutationError: true));
    final result =
        await _repository.updateProduct(event.category, event.id, event.payload);
    result.fold(
      (f) => emit(state.copyWith(
        mutationStatus: SellerMutationStatus.failure,
        mutationError: f.message,
      )),
      (updated) => emit(state.copyWith(
        mutationStatus: SellerMutationStatus.success,
        products: state.products
            .map((p) => p.id == updated.id ? updated : p)
            .toList(),
      )),
    );
  }

  Future<void> _onDelete(
    SellerProductDeleteRequested event,
    Emitter<SellerProductsState> emit,
  ) async {
    emit(state.copyWith(
        mutationStatus: SellerMutationStatus.deleting,
        clearMutationError: true));
    final result = await _repository.deleteProduct(event.category, event.id);
    result.fold(
      (f) => emit(state.copyWith(
        mutationStatus: SellerMutationStatus.failure,
        mutationError: f.message,
      )),
      (_) => emit(state.copyWith(
        mutationStatus: SellerMutationStatus.success,
        products: state.products.where((p) => p.id != event.id).toList(),
      )),
    );
  }
}
