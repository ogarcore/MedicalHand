// lib/view/screens/home/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:p_hn25/data/models/cita_model.dart';
import 'package:p_hn25/data/models/user_model.dart';
import 'package:p_hn25/view/screens/home/widgets/dashboard_action_buttons.dart';
import 'package:p_hn25/view/screens/home/widgets/dashboard_header.dart';
import 'package:p_hn25/view/screens/home/widgets/next_appointment_card.dart';
import 'package:p_hn25/view/screens/home/widgets/no_appointment_card.dart';
import 'package:p_hn25/view_model/appointment_view_model.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
  }

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
    // Obtenemos el UserViewModel una vez aquí
    final userViewModel = context.watch<UserViewModel>();
    final activeProfile = userViewModel.activeProfile;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 19.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardHeader(),
          const SizedBox(height: 24),
          // Si no hay perfil activo todavía (ej. al iniciar la app), mostramos un loader.
          if (activeProfile == null)
            const Center(child: CircularProgressIndicator())
          else
            // Una vez que tenemos el perfil, construimos el StreamBuilder
            // que se actualizará automáticamente si activeProfile cambia.
            _buildDashboardContent(context, activeProfile),
        ],
      ),
    );
  }

  // CAMBIO: Extraemos la lógica del StreamBuilder a un widget separado para mayor claridad
  Widget _buildDashboardContent(BuildContext context, UserModel activeProfile) {
    // Obtenemos el AppointmentViewModel aquí
    final appointmentViewModel = Provider.of<AppointmentViewModel>(
      context,
      listen: false,
    );

    return StreamBuilder<CitaModel?>(
      // El Stream ahora se crea aquí, usando el UID del perfil activo.
      // Cuando el perfil activo cambie, este widget se reconstruirá y creará un nuevo stream.
      stream: appointmentViewModel.getDashboardAppointmentStream(
        activeProfile.uid,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Error al cargar la cita."));
        }

        final appointment = snapshot.data;
        if (appointment != null) {
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
    );
  }
}
