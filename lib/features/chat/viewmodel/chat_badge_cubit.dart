import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/chat_repository.dart';

class ChatBadgeCubit extends Cubit<int> {
  final ChatRepository _repository;
  Timer? _timer;

  ChatBadgeCubit({required ChatRepository repository})
      : _repository = repository,
        super(0) {
    _fetchCount();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _fetchCount());
  }

  Future<void> _fetchCount() async {
    final result = await _repository.listConversations();
    if (isClosed) return;
    result.fold(
      (_) {},
      (conversations) {
        final total =
            conversations.fold<int>(0, (sum, c) => sum + c.unreadCount);
        if (!isClosed) emit(total);
      },
    );
  }

  void refresh() => _fetchCount();

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
