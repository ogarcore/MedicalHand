import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/notification_model.dart';
import 'package:p_hn25/view_model/notification_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'notification_tile.dart';

class NotificationsPanel extends StatefulWidget {
  final VoidCallback onClose;
  const NotificationsPanel({super.key, required this.onClose});

  @override
  State<NotificationsPanel> createState() => _NotificationsPanelState();
}

class _NotificationsPanelState extends State<NotificationsPanel> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Todas', 'No leídas'];

  // 2. Variable para asegurar que el shimmer solo se muestre en la construcción inicial.
  bool _isInitialBuild = true;

  @override
  void initState() {
    super.initState();
    // Después de que el primer frame se dibuje, marcamos que ya no es la construcción inicial.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isInitialBuild = false;
        });
      }
    });
  }

  void _markAllAsRead(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    Provider.of<NotificationViewModel>(
      context,
      listen: false,
    ).markAllAsRead(userId);
  }

  void _clearAll(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    Provider.of<NotificationViewModel>(context, listen: false).clearAll(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationViewModel>(
      builder: (context, viewModel, child) {
        final unreadCount = viewModel.unreadCount;
        final filteredNotifications = _selectedFilterIndex == 1
            ? viewModel.notifications.where((n) => !n.isRead).toList()
            : viewModel.notifications;

        return GestureDetector(
          onTap: widget.onClose,
          behavior: HitTestBehavior.opaque,
          child: DraggableScrollableSheet(
            initialChildSize: 0.72,
            minChildSize: 0.52,
            maxChildSize: 0.88,
            snap: true,
            snapSizes: const [0.52, 0.72, 0.88],
            builder: (_, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(46),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // --- HEADER Y FILTROS (no cambian) ---
                    Container(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      child: Center(
                        child: Container(
                          width: 36,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Centro de Notificaciones',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textColor,
                              letterSpacing: -0.4,
                            ),
                          ),
                          if (unreadCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryColor.withAlpha(229),
                                    AppColors.primaryColor.withAlpha(178),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                '$unreadCount nuevas',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      height: 42,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      child: Row(
                        children: List.generate(_filters.length, (index) {
                          final isSelected = index == _selectedFilterIndex;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedFilterIndex = index),
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primaryColor
                                                .withAlpha(77),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    _filters[index],
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[700],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- LISTA DE NOTIFICACIONES OPTIMIZADA ---
                    Expanded(
                      child: _buildNotificationContent(
                        viewModel,
                        filteredNotifications,
                        scrollController,
                      ),
                    ),

                    // --- FOOTER Y BOTONES (no cambian) ---
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 12,
                            offset: const Offset(0, -4),
                          ),
                        ],
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _markAllAsRead(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                'Marcar leídas',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _clearAll(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                                shadowColor: AppColors.primaryColor.withAlpha(
                                  102,
                                ),
                              ),
                              child: const Text(
                                'Limpiar todo',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNotificationContent(
    NotificationViewModel viewModel,
    List<NotificationModel> filteredNotifications,
    ScrollController scrollController,
  ) {
    if (_isInitialBuild || viewModel.isLoading) {
      return const _NotificationListShimmer();
    }

    if (filteredNotifications.isEmpty) {
      return const Center(
        child: Text(
          'No hay notificaciones para mostrar.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      cacheExtent: 500, // Mantenemos la optimización de scroll
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = filteredNotifications[index];
        return NotificationTile(
          notification: notification,
          icon: HugeIcons.strokeRoundedCalendar02,
          iconColor: AppColors.primaryColor,
          isRead: notification.isRead,
        );
      },
    );
  }
}

class _NotificationListShimmer extends StatelessWidget {
  const _NotificationListShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: ListView.builder(
        physics:
            const NeverScrollableScrollPhysics(), // Desactiva el scroll durante la carga
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 8, // Muestra 8 tiles "fantasma"
        itemBuilder: (context, index) => Container(
          height: 70, // Altura aproximada de un NotificationTile
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
