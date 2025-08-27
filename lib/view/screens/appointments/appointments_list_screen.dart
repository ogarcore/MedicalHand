// lib/view/screens/appointments/appointments_list_screen.dart
import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'widgets/appointment_card.dart'; // Importamos el nuevo widget

class AppointmentsListScreen extends StatefulWidget {
  const AppointmentsListScreen({super.key});

  @override
  State<AppointmentsListScreen> createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Los datos de ejemplo se quedan en la pantalla principal
  final List<Map<String, String>> upcomingAppointments = [
    {'specialty': 'Cardiología', 'hospital': 'Hospital Vélez Paiz', 'date': '25 Sep, 2025 - 10:00 AM', 'status': 'Confirmada', 'doctor': 'Por Asignar', 'office': 'Consultorio 5'},
    {'specialty': 'Odontología', 'hospital': 'Centro de Salud Sócrates Flores', 'date': 'Por asignar', 'status': 'Pendiente', 'doctor': 'Por Asignar', 'office': 'Por Asignar'},
  ];

  final List<Map<String, String>> pastAppointments = [
    {'specialty': 'Medicina General', 'hospital': 'Hospital Manolo Morales', 'date': '12 Jul, 2025 - 08:00 AM', 'status': 'Finalizada', 'doctor': 'Dra. Ana Pérez', 'office': 'Consultorio 2'},
    {'specialty': 'Dermatología', 'hospital': 'Hospital Vélez Paiz', 'date': '05 Jun, 2025 - 11:00 AM', 'status': 'Cancelada', 'doctor': 'Dr. Luis Castro', 'office': 'Consultorio 8'},
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        // ----- INICIO DE LOS CAMBIOS -----
        // 1. Añadimos un título al AppBar.
        title: const Text(
          'Mis Citas',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        centerTitle: false, // Alinea el título a la izquierda.
        // 2. Quitamos el color de sombreado que aparece al hacer scroll.
        surfaceTintColor: Colors.transparent,
        // ----- FIN DE LOS CAMBIOS -----
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: Colors.grey[600],
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.primaryColor.withAlpha(70),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
          tabs: [
            Tab(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                child: const Text('Próximas'),
              ),
            ),
            Tab(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                child: const Text('Pasadas'),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentsList(appointments: upcomingAppointments, isUpcoming: true),
          _buildAppointmentsList(appointments: pastAppointments, isUpcoming: false),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList({required List<Map<String, String>> appointments, required bool isUpcoming}) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return AppointmentCard(
          isUpcoming: isUpcoming,
          specialty: appointment['specialty']!,
          hospital: appointment['hospital']!,
          date: appointment['date']!,
          status: appointment['status']!,
          doctor: appointment['doctor']!,
          office: appointment['office']!,
        );
      },
    );
  }
}