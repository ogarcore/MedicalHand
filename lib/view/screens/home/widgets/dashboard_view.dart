import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:p_hn25/data/models/cita_model.dart';
import 'package:p_hn25/data/models/user_model.dart';
import 'package:p_hn25/view/screens/home/widgets/ai_chat_card.dart';
import 'package:p_hn25/view/screens/home/widgets/dashboard_action_buttons.dart';
import 'package:p_hn25/view/screens/home/widgets/dashboard_header.dart';
import 'package:p_hn25/view/screens/home/widgets/next_appointment_card.dart';
import 'package:p_hn25/view/screens/home/widgets/no_appointment_card.dart';
import 'package:p_hn25/view_model/appointment_view_model.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

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

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.watch<UserViewModel>();
    final activeProfile = userViewModel.activeProfile;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 2, right: 19, bottom: 24, left: 19),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardHeader(),
          const SizedBox(height: 12),
          if (activeProfile == null)
            const _DashboardLoadingShimmer()
          else
            _buildDashboardContent(context, activeProfile),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, UserModel activeProfile) {
    final appointmentViewModel = context.read<AppointmentViewModel>();

    return StreamBuilder<CitaModel?>(
      key: ValueKey(activeProfile.uid),
      // CAMBIO CLAVE 4: Le damos al StreamBuilder los datos que ya cargamos.
      initialData: appointmentViewModel.initialDashboardAppointment,
      stream: appointmentViewModel.getDashboardAppointmentStream(
        activeProfile.uid,
      ),
      builder: (context, snapshot) {
        return Column(
          children: [
            // El shimmer ahora solo se mostrará si estamos esperando Y no tenemos datos iniciales.
            // Gracias a la pre-carga, esto casi nunca pasará, evitando el parpadeo.
            _buildAppointmentSection(context, snapshot),
            const SizedBox(height: 16),
            DashboardActionButtons(appointment: snapshot.data),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey.shade300,
                      Colors.grey.shade400,
                      Colors.grey.shade300,
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const AiChatCard(),
          ],
        );
      },
    );
  }

  Widget _buildAppointmentSection(
    BuildContext context,
    AsyncSnapshot<CitaModel?> snapshot,
  ) {
    // CAMBIO CLAVE 5: Ajustamos la condición de carga.
    // Solo muestra el shimmer si está esperando Y NO tiene datos para mostrar.
    if (snapshot.connectionState == ConnectionState.waiting &&
        !snapshot.hasData) {
      return const _DashboardLoadingShimmer();
    }

    // Si hay un error, lo mostramos.
    if (snapshot.hasError) {
      return const NoAppointmentCard();
    }

    // Si tenemos datos (ya sea iniciales o del stream), los mostramos.
    final appointment = snapshot.data;
    if (appointment != null) {
      return NextAppointmentCard(appointment: appointment);
    } else {
      return const NoAppointmentCard();
    }
  }
}

// El resto de los widgets de shimmer no necesitan cambios.
class _DashboardLoadingShimmer extends StatelessWidget {
  const _DashboardLoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: const _AppointmentCardPlaceholder(),
    );
  }
}

class _AppointmentCardPlaceholder extends StatelessWidget {
  const _AppointmentCardPlaceholder();

  Widget _buildPlaceholderLine({required double width, double height = 14}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(220),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPlaceholderLine(width: 150, height: 18),
              _buildPlaceholderLine(width: 80, height: 24),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 3, width: 40, color: Colors.white),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPlaceholderLine(width: double.infinity),
                    const SizedBox(height: 8),
                    _buildPlaceholderLine(width: 180),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
