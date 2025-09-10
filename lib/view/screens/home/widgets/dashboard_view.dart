// lib/view/screens/home/dashboard_view.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:p_hn25/data/models/cita_model.dart';
import 'package:p_hn25/view/screens/home/widgets/dashboard_action_buttons.dart';
import 'package:p_hn25/view/screens/home/widgets/dashboard_header.dart';
import 'package:p_hn25/view/screens/home/widgets/next_appointment_card.dart';
import 'package:p_hn25/view/screens/home/widgets/no_appointment_card.dart';
import 'package:p_hn25/view_model/appointment_view_model.dart';
import 'package:provider/provider.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  Stream<CitaModel?>? _appointmentStream;
  late AppointmentViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);

    _viewModel = Provider.of<AppointmentViewModel>(context, listen: false);

    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _viewModel.listenToNextAppointment(userId);
      });
    }
  }

  @override
  void dispose() {
    _viewModel.disposeListeners();
    super.dispose();
  }

  // Helper para verificar si la cita es hoy
  bool _isAppointmentToday(CitaModel? appointment) {
    if (appointment?.assignedDate == null) return false;
    final now = DateTime.now();
    final appointmentDate = appointment!.assignedDate!;
    return now.year == appointmentDate.year &&
        now.month == appointmentDate.month &&
        now.day == appointmentDate.day;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 19.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardHeader(),
          const SizedBox(height: 24),
          StreamBuilder<CitaModel?>(
            stream: _appointmentStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.none &&
                  snapshot.data == null) {
                return const NoAppointmentCard();
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text("Error al cargar la cita."));
              }

              final appointment = snapshot.data;
              final bool hasAppointment = appointment != null;

              if (hasAppointment) {
                final bool canCheckIn = _isAppointmentToday(appointment);
                return Column(
                  children: [
                    NextAppointmentCard(appointment: appointment),
                    const SizedBox(height: 26),
                    DashboardActionButtons(canCheckIn: canCheckIn),
                  ],
                );
              } else {
                return const NoAppointmentCard();
              }
            },
          ),
        ],
      ),
    );
  }
}
