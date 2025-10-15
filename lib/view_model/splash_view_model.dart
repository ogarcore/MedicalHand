import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:p_hn25/view_model/appointment_view_model.dart';
import 'package:p_hn25/view_model/notification_view_model.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import '../view/screens/home/home_screen.dart';
import '../view/screens/splash/no_internet_screen.dart';
import '../view/screens/welcome/welcome_screen.dart';
import 'package:p_hn25/data/network/notification_service.dart';

class SplashViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService.instance;

  Future<void> checkStatusAndNavigate(
    BuildContext context, {
    required UserViewModel userViewModel,
    required NotificationViewModel notificationViewModel,
  }) async {
    final connectivityResult = await (Connectivity().checkConnectivity());

    if (!context.mounted) return;

    if (connectivityResult.contains(ConnectivityResult.none)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NoInternetScreen()),
      );
      return;
    }

    final currentUser = _auth.currentUser;

    if (currentUser != null) {
      try {
        final appointmentViewModel =
            Provider.of<AppointmentViewModel>(context, listen: false);

        // Se inician las cargas de datos del usuario y la cita.
        final dataFuture = Future.wait([
          userViewModel.fetchCurrentUser(),
          appointmentViewModel.fetchInitialDashboardAppointment(currentUser.uid),
        ]);

        await dataFuture;
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }

        _notificationService.initNotifications(
          userViewModel: userViewModel,
          notificationViewModel: notificationViewModel,
        );
      } catch (e) {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const NoInternetScreen()),
          );
        }
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    }
  }
}