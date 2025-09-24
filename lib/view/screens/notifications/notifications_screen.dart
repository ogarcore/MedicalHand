import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/view_model/notification_view_model.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'widgets/notification_filters.dart';
import 'widgets/notification_footer.dart';
import 'widgets/notification_list.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Todas', 'No leídas'];
  bool _isLoadingDelayed = true;

  @override
  void initState() {
    super.initState();
    // Mantenemos la lógica para el Shimmer inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isLoadingDelayed = false;
        });
      }
    });
  }

  void _markAllAsRead() {
    final mainUserId = Provider.of<UserViewModel>(
      context,
      listen: false,
    ).currentUser?.uid;
    if (mainUserId == null) return;
    Provider.of<NotificationViewModel>(
      context,
      listen: false,
    ).markAllAsRead(mainUserId);
  }

  void _clearAll() {
    final mainUserId = Provider.of<UserViewModel>(
      context,
      listen: false,
    ).currentUser?.uid;
    if (mainUserId == null) return;
    Provider.of<NotificationViewModel>(
      context,
      listen: false,
    ).clearAll(mainUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Centro de Notificaciones',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textColor(context),
            letterSpacing: -0.4,
          ),
        ),
        backgroundColor: AppColors.backgroundColor(context),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      bottomNavigationBar: NotificationFooter(
        onMarkAllAsRead: _markAllAsRead,
        onClearAll: _clearAll,
      ),
      body: Consumer<NotificationViewModel>(
        builder: (context, viewModel, child) {
          final unreadCount = viewModel.unreadCount;
          final filteredNotifications = _selectedFilterIndex == 1
              ? viewModel.notifications.where((n) => !n.isRead).toList()
              : viewModel.notifications;

          return Column(
            children: [
              NotificationFilters(
                unreadCount: unreadCount,
                filters: _filters,
                selectedIndex: _selectedFilterIndex,
                onFilterSelected: (index) {
                  setState(() {
                    _selectedFilterIndex = index;
                  });
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: NotificationList(
                  isLoading: _isLoadingDelayed || viewModel.isLoading,
                  notifications: filteredNotifications,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
