import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/view_model/notification_view_model.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'widgets/notification_filters.dart';
import 'widgets/notification_footer.dart';
import 'widgets/notification_list.dart';

// --- CLASE DE EJEMPLO PARA REFERENCIAS ---
class _ReferralExample {
  final String specialty;
  final String originatingDoctor;
  final DateTime date;
  _ReferralExample({
    required this.specialty,
    required this.originatingDoctor,
    required this.date,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Todas', 'No leídas'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _markAllAsRead() {
    final mainUserId =
        Provider.of<UserViewModel>(context, listen: false).currentUser?.uid;
    if (mainUserId == null) return;
    Provider.of<NotificationViewModel>(context, listen: false)
        .markAllAsRead(mainUserId);
  }

  void _clearAll() {
    final mainUserId =
        Provider.of<UserViewModel>(context, listen: false).currentUser?.uid;
    if (mainUserId == null) return;
    Provider.of<NotificationViewModel>(context, listen: false)
        .clearAll(mainUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Bandeja de Entrada',
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            alignment: Alignment.center,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryColor(context),
              unselectedLabelColor: Colors.grey[600],
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
              labelStyle:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 3.0,
                  color: AppColors.primaryColor(context),
                ),
                insets: const EdgeInsets.symmetric(horizontal: 60.0),
              ),
              tabs: [
                Tab(
                  child: Consumer<NotificationViewModel>(
                    builder: (context, viewModel, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Notificaciones'),
                          if (viewModel.unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.warningColor(context),
                                    AppColors.warningColor(context)
                                        .withOpacity(0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.redAccent.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                viewModel.unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
                const Tab(text: 'Referencias'),
              ],
            ),
          ),
        ),
      ),

      // --- NUEVA ANIMACIÓN MÁS FLUIDA Y ELEGANTE DEL FOOTER ---
      bottomNavigationBar: AnimatedBuilder(
        animation: _tabController.animation!,
        builder: (context, child) {
          final showFooter = _tabController.index == 0;
          return AnimatedSlide(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            offset: showFooter ? Offset.zero : const Offset(0, 1),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: showFooter ? 1 : 0,
              curve: Curves.easeInOut,
              child: SizedBox(
                height: 85.0,
                child: Wrap(children: [child!]),
              ),
            ),
          );
        },
        child: Consumer<NotificationViewModel>(
          builder: (context, viewModel, child) {
            return NotificationFooter(
              onMarkAllAsRead: _markAllAsRead,
              onClearAll: _clearAll,
              unreadCount: viewModel.unreadCount,
            );
          },
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsView(),
          _buildReferralsView(),
        ],
      ),
    );
  }

  Widget _buildReferralsView() {
    final exampleReferrals = [
      _ReferralExample(
        specialty: 'Cardiología',
        originatingDoctor: 'Dr. Roberto Cruz',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      _ReferralExample(
        specialty: 'Dermatología',
        originatingDoctor: 'Dra. Ana Pérez',
        date: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    if (exampleReferrals.isEmpty) {
      return Center(
        child: Text(
          "No tienes referencias.",
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exampleReferrals.length,
      itemBuilder: (context, index) {
        return _buildReferralCard(exampleReferrals[index]);
      },
    );
  }

  Widget _buildReferralCard(_ReferralExample referral) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0.5,
        shadowColor: Colors.black.withAlpha(15),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.primaryColor(context).withOpacity(0.1),
          highlightColor: AppColors.primaryColor(context).withOpacity(0.08),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor(context).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    HugeIcons.strokeRoundedTaskDone01,
                    color: AppColors.primaryColor(context),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Referencia para ${referral.specialty}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enviada por: ${referral.originatingDoctor}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsView() {
    return Consumer<NotificationViewModel>(
      builder: (context, viewModel, child) {
        final filteredNotifications = _selectedFilterIndex == 1
            ? viewModel.notifications.where((n) => !n.isRead).toList()
            : viewModel.notifications;

        return Column(
          children: [
            NotificationFilters(
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
                isLoading: viewModel.isLoading,
                notifications: filteredNotifications,
              ),
            ),
          ],
        );
      },
    );
  }
}
