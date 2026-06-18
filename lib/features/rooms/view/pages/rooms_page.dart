import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/viewmodel/auth_bloc.dart';
import '../../../chat/view/pages/conversations_page.dart';
import '../../../chat/viewmodel/chat_bloc.dart';

class RoomsPage extends StatelessWidget {
  const RoomsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    String profileType = 'Customer';
    if (authState is AuthSuccess) {
      profileType = authState.user.isSeller ? 'Seller' : 'Customer';
    }
    return BlocProvider(
      create: (_) =>
          sl<ChatBloc>()..add(ChatStarted(profileType: profileType)),
      child: const ConversationsPage(),
    );
  }
}
