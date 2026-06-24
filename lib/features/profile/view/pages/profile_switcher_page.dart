import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/ppw_app_bar.dart';
import '../../../../../core/di/injection.dart';
import '../../../auth/viewmodel/auth_bloc.dart';
import '../../model/profile_model.dart';
import '../../viewmodel/profile_bloc.dart';
import 'create_room_page.dart';
import 'edit_room_page.dart';

import '../../../../l10n/app_localizations.dart';
class ProfileSwitcherPage extends StatelessWidget {
  ProfileSwitcherPage({super.key});

  static Route<void> route(AuthBloc authBloc) => MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<ProfileBloc>()
            ..add(ProfileRoomsLoadRequested()),
          child: BlocProvider.value(
            value: authBloc,
            child: ProfileSwitcherPage(),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: PPWAppBar(
        title: AppLocalizations.of(context).switchProfile,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous is AuthSwitchingProfile && current is AuthSuccess,
        listener: (context, state) {
          context.read<ProfileBloc>().add(ProfileRoomsLoadRequested());
        },
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listenWhen: (p, c) => p.roomsStatus != c.roomsStatus,
          listener: (context, state) {
          if (state.roomsStatus == RoomsStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تعذّر تحميل الغرف'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          },
          buildWhen: (p, c) =>
              p.roomsStatus != c.roomsStatus || p.rooms != c.rooms,
          builder: (context, state) {
          if (state.roomsStatus == RoomsStatus.loading) {
            return Center(child: CircularProgressIndicator());
          }
          final rooms = state.rooms;
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
                  itemCount: rooms.length,
                  separatorBuilder: (_, _) => SizedBox(height: 10),
                  itemBuilder: (context, i) =>
                      _RoomTile(room: rooms[i]),
                ),
              ),
              _AddRoomButton(rooms: rooms),
            ],
          );
          },
        ),
      ),
    );
  }
}

class _RoomTile extends StatelessWidget {
  final ProfileModel room;

  _RoomTile({required this.room});

  @override
  Widget build(BuildContext context) {
    final isActive = room.isActive;
    final isPending = !room.activated;

    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (p, c) => c is AuthSwitchingProfile || c is AuthSuccess,
      builder: (context, authState) {
        final isSwitching = authState is AuthSwitchingProfile;
        return GestureDetector(
          onTap: isActive || isSwitching
              ? null
              : () => context
                  .read<AuthBloc>()
                  .add(AuthSwitchProfileRequested(profileId: room.id)),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.border,
                width: isActive ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: isActive
                      ? AppColors.primary
                      : AppColors.primaryLight,
                  child: Text(
                    room.displayName.isNotEmpty
                        ? room.displayName[0]
                        : '؟',
                    style: TextStyle(
                      color: isActive ? Colors.white : AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (room.country.isNotEmpty) ...[
                        SizedBox(height: 2),
                        Text(
                          room.countryName,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isActive)
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'الحالية',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (isPending)
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Text(
                      'قيد المراجعة',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else if (isSwitching)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                if (!isSwitching)
                  _RoomMenuButton(room: room),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RoomMenuButton extends StatelessWidget {
  final ProfileModel room;

  const _RoomMenuButton({required this.room});

  Future<void> _confirmDelete(BuildContext context) async {
    final bloc = context.read<ProfileBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('حذف الغرفة'),
        content: Text(
          'هل أنت متأكد من حذف "${room.displayName}"؟ لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('حذف', style: TextStyle(color: Colors.red.shade600)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      bloc.add(ProfileDeleteRequested(room));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ProfileBloc>();
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: AppColors.textHint, size: 20),
      onSelected: (value) async {
        if (value == 'edit') {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: bloc,
                child: EditRoomPage(room: room),
              ),
            ),
          );
        } else if (value == 'delete') {
          await _confirmDelete(context);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
              SizedBox(width: 8),
              Text('تعديل'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red.shade500),
              SizedBox(width: 8),
              Text('حذف', style: TextStyle(color: Colors.red.shade500)),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddRoomButton extends StatelessWidget {
  final List<ProfileModel> rooms;

  _AddRoomButton({required this.rooms});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final bloc = context.read<ProfileBloc>();
              final active = rooms.firstWhere(
                (r) => r.isActive,
                orElse: () => rooms.first,
              );
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: bloc,
                    child: CreateRoomPage(
                      country: active.country,
                      currency: active.currency,
                    ),
                  ),
                ),
              );
              if (context.mounted) {
                bloc.add(ProfileRoomsLoadRequested());
              }
            },
            icon: Icon(Icons.add_rounded),
            label: Text('إضافة غرفة جديدة'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }
}
