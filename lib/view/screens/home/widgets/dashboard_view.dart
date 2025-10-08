import 'dart:async';
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
  Timer? _timer;
  // Esta variable ahora solo se usa para controlar el timer y evitar que se reinicie innecesariamente.
  String? _monitoredAppointmentId;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
  }

  void _startTimer(CitaModel? appointment) {
    _timer?.cancel();
    _monitoredAppointmentId = appointment?.id;
    if (appointment?.assignedDate == null || !mounted) return;

    final monitoredAppointment = appointment!;

    _timer = Timer.periodic(const Duration(seconds: 30), (timer) { // Verificación más frecuente
      // Si el widget ya no existe o la cita que monitoreamos ha cambiado, detenemos este timer.
      if (!mounted || _monitoredAppointmentId != monitoredAppointment.id) {
        timer.cancel();
        return;
      }
      final hasPassed = DateTime.now().isAfter(monitoredAppointment.assignedDate!);
      if (hasPassed) {
        context
            .read<AppointmentViewModel>()
            .updateAppointmentStatus(monitoredAppointment.id!, 'no_asistio');
        timer.cancel(); // El stream se encargará de actualizar la UI.
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
    final appointmentViewModel = context.watch<AppointmentViewModel>();

    return StreamBuilder<CitaModel?>(
      // La Key es CRUCIAL para que al cambiar de perfil, el StreamBuilder se reconstruya
      // desde cero, garantizando que no queden datos del perfil anterior.
      key: ValueKey(activeProfile.uid),
      initialData: appointmentViewModel.initialDashboardAppointment,
      stream: appointmentViewModel.getDashboardAppointmentStream(activeProfile.uid),
      builder: (context, snapshot) {
        // --- INICIO DE LA CORRECCIÓN DEFINITIVA ---
        
        // La ÚNICA fuente de la verdad para la UI es el dato que llega del StreamBuilder.
        // Ya no usamos una variable de estado local para decidir qué mostrar.
        final CitaModel? currentAppointment = snapshot.data;
        
        // El timer se gestiona de forma independiente, solo para la lógica de expirar la cita.
        // Se reinicia solo si la cita que llega del stream es diferente a la que ya estamos monitoreando.
        if (_monitoredAppointmentId != currentAppointment?.id) {
          _startTimer(currentAppointment);
        }

        // La validez de la cita se calcula SIEMPRE con el dato más reciente del stream.
        final bool isAppointmentStillValid = currentAppointment?.assignedDate != null &&
            currentAppointment!.assignedDate!.isAfter(DateTime.now());

        final Widget appointmentSection;
        
        // La lógica para decidir qué widget mostrar es ahora simple y directa.
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          appointmentSection = const _DashboardLoadingShimmer(key: ValueKey('loading'));
        } else if (isAppointmentStillValid) {
          appointmentSection = NextAppointmentCard(
            key: ValueKey(currentAppointment.id),
            appointment: currentAppointment,
          );
        } else {
          appointmentSection = const NoAppointmentCard(key: ValueKey('no-appointment'));
        }

        // --- FIN DE LA CORRECCIÓN DEFINITIVA ---

        return Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: appointmentSection,
            ),
            const SizedBox(height: 16),
            DashboardActionButtons(
              // Pasamos directamente la cita del stream a los botones.
              appointment: isAppointmentStillValid ? currentAppointment : null,
            ),
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
}

// El Shimmer no necesita cambios.
class _DashboardLoadingShimmer extends StatelessWidget {
  const _DashboardLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      period: const Duration(milliseconds: 1500),
      child: const _AppointmentCardPlaceholder(),
    );
  }
}

class _AppointmentCardPlaceholder extends StatelessWidget {
  const _AppointmentCardPlaceholder();

  Widget _buildPlaceholderLine({required double width, double height = 14, double borderRadius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 188,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPlaceholderLine(width: 160, height: 18, borderRadius: 6),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildPlaceholderLine(width: 80, height: 16, borderRadius: 6),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildPlaceholderLine(width: 60, height: 15, borderRadius: 6),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withAlpha(150),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPlaceholderLine(width: 30, height: 27, borderRadius: 6),
                      const SizedBox(height: 2),
                      _buildPlaceholderLine(width: 40, height: 14, borderRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildButtonPlaceholder(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildButtonPlaceholder(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonPlaceholder() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 8),
          _buildPlaceholderLine(width: 80, height: 14, borderRadius: 6),
        ],
      ),
    );
  }
}