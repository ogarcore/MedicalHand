// lib/view/screens/appointments/appointments_list_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/cita_model.dart';
import 'package:p_hn25/view_model/appointment_view_model.dart';
import 'package:provider/provider.dart';
// CAMBIO: Se eliminaron las importaciones de shimmer y el skeleton.
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
  late AppointmentViewModel _viewModel;
  late String _userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    initializeDateFormatting('es_ES', null);
    _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel = Provider.of<AppointmentViewModel>(context, listen: false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(CitaModel cita) {
    if (cita.status == 'pendiente') {
      return 'Por asignar';
    }
    if (cita.assignedDate != null) {
      return DateFormat('d MMM, y - hh:mm a', 'es_ES')
          .format(cita.assignedDate!);
    }
    return 'Fecha no disponible';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: const Text(
          'Mis Citas',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: Colors.grey[600],
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.primaryColor.withAlpha(70),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
          tabs: [
            Tab(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(12)),
                child: const Text('Próximas'),
              ),
            ),
            Tab(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(12)),
                child: const Text('Pasadas'),
              ),
            ),
          ],
        ),
      ),
      body: _userId.isEmpty
          ? const Center(child: Text("Verificando usuario..."))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentsStream(
                  stream: _viewModel.getUpcomingAppointments(_userId),
                  isUpcoming: true,
                ),
                _buildAppointmentsStream(
                  stream: _viewModel.getPastAppointments(_userId),
                  isUpcoming: false,
                ),
              ],
            ),
    );
  }

  Widget _buildAppointmentsStream(
      {required Stream<List<CitaModel>> stream, required bool isUpcoming}) {
    return StreamBuilder<List<CitaModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text('Error al cargar las citas: ${snapshot.error}'));
        }

        // CAMBIO: Se reemplaza el Shimmer por un CircularProgressIndicator.
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final appointments = snapshot.data!;

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
            appointments: appointments, isUpcoming: isUpcoming);
      },
    );
  }

  Widget _buildAppointmentsList(
      {required List<CitaModel> appointments, required bool isUpcoming}) {
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