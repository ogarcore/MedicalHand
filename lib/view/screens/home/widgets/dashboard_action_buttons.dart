import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/cita_model.dart';
import 'package:p_hn25/data/network/permission_service.dart';
import 'package:p_hn25/view/screens/appointments/appointment_options_screen.dart';
import 'package:p_hn25/view/screens/home/pre_check_in_instructions_screen.dart';
import 'package:p_hn25/view/screens/home/qr_scanner_screen.dart';
import 'package:p_hn25/view_model/appointment_view_model.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class DashboardActionButtons extends StatelessWidget {
  final CitaModel? appointment;
  // Instancia del servicio de permisos.
  final PermissionService _permissionService = PermissionService();

  DashboardActionButtons({super.key, this.appointment});

  bool get _isCheckInAvailable {
    final appt = appointment;
    if (appt?.assignedDate == null) return false;

    final now = DateTime.now();
    final appointmentDate = appt!.assignedDate!;
    return now.year == appointmentDate.year &&
        now.month == appointmentDate.month &&
        now.day == appointmentDate.day;
  }

  Future<void> _handleScanQRPressed(BuildContext context) async {
    final hasPermission = await _permissionService.handleCameraPermission(
      context,
      reason:
          'MedicalHand necesita acceso a tu cámara para escanear el código QR de llegada y registrarte en la fila virtual.',
    );
    if (!hasPermission || !context.mounted) return;

    final scannedData = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    if (scannedData != null && context.mounted) {
      // Obtenemos los ViewModels y los datos necesarios.
      final appointmentViewModel = context.read<AppointmentViewModel>();
      final userViewModel = context.read<UserViewModel>();
      final activeProfile = userViewModel.activeProfile;

      if (appointment == null || activeProfile == null) return;

      // Mostramos un diálogo de carga.
      // Mostramos un diálogo de carga mejorado.
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withAlpha(100),
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(28),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono con contenedor decorativo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor(context),
                        Color.lerp(
                          AppColors.primaryColor(context),
                          Colors.white,
                          0.2,
                        )!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor(context).withAlpha(80),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    HugeIcons.strokeRoundedQrCode01,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 24),

                // Texto principal
                Text(
                  'Procesando código QR',
                  style: TextStyle(
                    color: AppColors.primaryColor(context),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Texto secundario
                Text(
                  'Estamos asignando tu lugar en la fila virtual',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Indicador de progreso con diseño mejorado
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryColor(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Asignando turno...',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Mensaje adicional pequeño
                Text(
                  'Esto puede tomar unos segundos',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Llamamos a la función del ViewModel.
      final result = await appointmentViewModel.performCheckIn(
        qrData: scannedData,
        appointment: appointment!,
        patientUid: activeProfile.uid,
        patientName:
            "${activeProfile.firstName} ${" "} ${activeProfile.lastName}",
      );

      if (context.mounted) {
        Navigator.of(context).pop(); // Cerramos el diálogo de carga.

        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '¡Check-in exitoso! Tu turno es el #${result['turnNumber']}.',
              ),
              backgroundColor: AppColors.successColor(context).withAlpha(240),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'Ocurrió un error desconocido.',
              ),
              backgroundColor: AppColors.warningColor(context).withAlpha(240),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final graceColor = AppColors.secondaryColor(context).withAlpha(200);
    final warningColor = AppColors.warningColor(context);
    final accentColor = AppColors.accentColor(context);

    final bool canCheckIn = _isCheckInAvailable;
    final bool isAsistenciaConfirmada =
        appointment?.status == 'asistencia_confirmada';
    final bool isEnFila = appointment?.status == 'en_fila';

    return Column(
      children: [
        if (canCheckIn && !isEnFila)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeInBack,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
            child: isAsistenciaConfirmada
                ? _ShakeButton(
                    key: const ValueKey('escanearQR'),
                    child: _buildCompactGlamorousButton(
                      context: context,
                      title: 'Escanear QR',
                      subtitle: 'Recibir turno',
                      icon: HugeIcons.strokeRoundedQrCode01,
                      primaryColor: warningColor,
                      onPressed: () => _handleScanQRPressed(context),
                    ),
                  )
                : _ShakeButton(
                    key: const ValueKey('confirmarAsistencia'),
                    child: _buildCompactGlamorousButton(
                      context: context,
                      title: 'Confirmar asistencia',
                      subtitle: 'Registra de asistencia',
                      icon: HugeIcons.strokeRoundedTickDouble04,
                      primaryColor: graceColor,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PreCheckInInstructionsScreen(
                              appointment: appointment!,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        if (canCheckIn) const SizedBox(height: 12),
        _buildCompactGlamorousButton(
          context: context,
          title: 'Agendar cita',
          subtitle: 'Nueva consulta',
          icon: HugeIcons.strokeRoundedLayerAdd,
          primaryColor: accentColor,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AppointmentOptionsScreen()),
          ),
        ),
      ],
    );
  }

  // El resto del código de este widget no necesita ningún cambio.
  Widget _buildCompactGlamorousButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color primaryColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            primaryColor,
            Color.lerp(primaryColor.withAlpha(190), Colors.black, 0.1)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withAlpha(70),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          splashColor: Colors.white.withAlpha(40),
          highlightColor: Colors.white.withAlpha(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withAlpha(50), width: 1.2),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withAlpha(70),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.2,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withAlpha(220),
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withAlpha(70),
                      width: 1.2,
                    ),
                  ),
                  child: const Icon(
                    HugeIcons.strokeRoundedArrowRight01,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShakeButton extends StatefulWidget {
  final Widget child;
  const _ShakeButton({required this.child, super.key});

  @override
  State<_ShakeButton> createState() => _ShakeButtonState();
}

class _ShakeButtonState extends State<_ShakeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offsetAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _offsetAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: -6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) _controller.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_offsetAnimation.value, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
