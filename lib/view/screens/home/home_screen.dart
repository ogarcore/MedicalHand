import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/view/screens/appointments/appointments_list_screen.dart';
import 'package:p_hn25/view/screens/history/clinical_history_screen.dart';
import 'package:p_hn25/view/screens/home/widgets/home_app_bar.dart';
import 'package:p_hn25/view/screens/home/widgets/main_bottom_nav_bar.dart';
import 'package:p_hn25/view_model/notification_view_model.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'widgets/dashboard_view.dart';
import '../../widgets/custom_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 1;

  final List<Widget> _pages = [
    const AppointmentsListScreen(),
    const DashboardView(),
    const ClinicalHistoryScreen(),
  ];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserNotifications();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      print("App reanudada. Recargando notificaciones...");
      _loadUserNotifications();
    }
  }

  void _loadUserNotifications() {
    final userId = Provider.of<UserViewModel>(
      context,
      listen: false,
    ).currentUser?.uid;
    if (userId != null) {
      Provider.of<NotificationViewModel>(
        context,
        listen: false,
      ).loadNotifications(userId);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<bool> _showExitConfirmationDialog() async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => CustomModal(
        icon: HugeIcons.strokeRoundedLogout01,
        title: 'Salir de Medical Hand',
        content: const Text(
          '¿Estás seguro de que quieres cerrar la aplicación?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        actions: [
          ModalButton(
            text: 'Cancelar',
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ModalButton(
            text: 'Salir',
            isWarning: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final bool shouldExit = await _showExitConfirmationDialog();
          if (shouldExit) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: const HomeAppBar(),
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: MainBottomNavBar(
          currentIndex: _currentIndex,
          onItemTapped: _onItemTapped,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Transform.translate(
          offset: const Offset(0, 6),
          child: Container(
            width: 53,
            height: 53,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withAlpha(60),
                  blurRadius: 4,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withAlpha(100),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: FloatingActionButton(
              onPressed: () => _onItemTapped(1),
              backgroundColor: Colors.transparent,
              elevation: 0,
              shape: const CircleBorder(),
              child: const Icon(
                HugeIcons.strokeRoundedHome12,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
