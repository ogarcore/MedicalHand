// lib/view/screens/appointments/appointments_list_screen.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/cita_model.dart';
import 'package:p_hn25/view_model/appointment_view_model.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'widgets/appointment_card.dart';
import 'widgets/empty_state_widget.dart';

class AppointmentsListScreen extends StatefulWidget {
  const AppointmentsListScreen({super.key});

  @override
  State<AppointmentsListScreen> createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AppointmentViewModel _appointmentViewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    initializeDateFormatting('es_ES', null);
    _appointmentViewModel = Provider.of<AppointmentViewModel>(
      context,
      listen: false,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(CitaModel cita) {
    if (cita.status == 'pendiente') return 'Por asignar';
    if (cita.assignedDate != null) {
      return DateFormat(
        'd MMM, y - hh:mm a',
        'es_ES',
      ).format(cita.assignedDate!);
    }
    return 'Fecha no disponible';
  }

  @override
  Widget build(BuildContext context) {
    // Envolvemos todo en un Consumer para que reaccione a los cambios de perfil
    return Consumer<UserViewModel>(
      builder: (context, userViewModel, child) {
        final activeProfile = userViewModel.activeProfile;

        // Si todavía no se ha cargado un perfil, mostramos un indicador de carga
        if (activeProfile == null) {
          return const Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Una vez que tenemos un perfil activo, construimos la pantalla
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.backgroundColor,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            centerTitle: false,
            title: const Text(
              'Mis Citas',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: Colors.grey[600],
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.primaryColor.withAlpha(70),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 15,
              ),
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
              tabs: [
                Tab(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Próximas'),
                  ),
                ),
                Tab(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Pasadas'),
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Le pasamos el UID del perfil activo para buscar sus citas
              _buildAppointmentsStream(
                stream: _appointmentViewModel.getUpcomingAppointments(
                  activeProfile.uid,
                ),
                isUpcoming: true,
              ),
              // Le pasamos el UID del perfil activo para buscar su historial
              _buildAppointmentsStream(
                stream: _appointmentViewModel.getPastAppointments(
                  activeProfile.uid,
                ),
                isUpcoming: false,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppointmentsStream({
    required Stream<List<CitaModel>> stream,
    required bool isUpcoming,
  }) {
    return StreamBuilder<List<CitaModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error al cargar las citas: ${snapshot.error}'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final appointments = snapshot.data ?? [];
        if (appointments.isEmpty) {
          return isUpcoming
              ? const EmptyStateWidget(
                  icon: HugeIcons.strokeRoundedCardiogram01,
                  title: '¡Cuida tu salud!',
                  message:
                      'Aún no tienes citas programadas. Agendar una consulta es el primer paso para tu bienestar.',
                )
              : const EmptyStateWidget(
                  icon: HugeIcons.strokeRoundedMedicalFile,
                  title: 'Sin Historial',
                  message:
                      'Aquí aparecerán tus citas una vez que hayan sido finalizadas o canceladas.',
                );
        }
        return _buildAppointmentsList(
          appointments: appointments,
          isUpcoming: isUpcoming,
        );
      },
    );
  }

  Widget _buildAppointmentsList({
    required List<CitaModel> appointments,
    required bool isUpcoming,
  }) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final cita = appointments[index];
        return AppointmentCard(
          isUpcoming: isUpcoming,
          specialty: cita.specialty ?? 'Consulta General',
          hospital: cita.hospital,
          date: _formatDate(cita),
          status: cita.status,
          doctor: cita.assignedDoctor ?? 'Por Asignar',
          office: cita.clinicOffice ?? 'Por Asignar',
        );
      },
    );
  }
}
