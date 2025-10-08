import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/cita_model.dart';
import 'package:p_hn25/view_model/appointment_view_model.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    initializeDateFormatting('es_ES', null);

    // Esta función se mantiene para la consistencia de datos (Enfoque Híbrido).
    // Se ejecuta una vez para actualizar el estado en Firestore.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userViewModel = context.read<UserViewModel>();
      final appointmentViewModel = context.read<AppointmentViewModel>();
      final activeProfile = userViewModel.activeProfile;
      if (activeProfile != null) {
        appointmentViewModel.checkForMissedAppointments(activeProfile.uid);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeProfile = context.watch<UserViewModel>().activeProfile;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: _buildAppBar(),
      body: activeProfile == null
          ? const _AppointmentsShimmer()
          : TabBarView(
              controller: _tabController,
              children: [
                _AppointmentTabPage(
                  key: ValueKey('upcoming_${activeProfile.uid}'),
                  profileId: activeProfile.uid,
                  isUpcoming: true,
                ),
                _AppointmentTabPage(
                  key: ValueKey('past_${activeProfile.uid}'),
                  profileId: activeProfile.uid,
                  isUpcoming: false,
                ),
              ],
            ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.backgroundColor(context),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 2),
          Text(
            'Mis Citas',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Tus citas organizadas en un solo lugar.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: AppColors.textLightColor(context),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
      bottom: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryColor(context),
        unselectedLabelColor: Colors.grey[600],
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.primaryColor(context).withAlpha(70),
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
    );
  }
}

class _AppointmentTabPage extends StatefulWidget {
  final String profileId;
  final bool isUpcoming;

  const _AppointmentTabPage({
    super.key,
    required this.profileId,
    required this.isUpcoming,
  });

  @override
  State<_AppointmentTabPage> createState() => _AppointmentTabPageState();
}

class _AppointmentTabPageState extends State<_AppointmentTabPage>
    with AutomaticKeepAliveClientMixin {
  late Stream<List<CitaModel>> _appointmentsStream;

  @override
  void initState() {
    super.initState();
    final appointmentViewModel = context.read<AppointmentViewModel>();
    _appointmentsStream = widget.isUpcoming
        ? appointmentViewModel.getUpcomingAppointments(widget.profileId)
        : appointmentViewModel.getPastAppointments(widget.profileId);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<List<CitaModel>>(
      stream: _appointmentsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error al cargar las citas: ${snapshot.error}'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _AppointmentsShimmer();
        }
        final appointments = snapshot.data ?? [];
        if (appointments.isEmpty) {
          return widget.isUpcoming
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
          isUpcoming: widget.isUpcoming,
        );
      },
    );
  }

  Widget _buildAppointmentsList({
    required List<CitaModel> appointments,
    required bool isUpcoming,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      cacheExtent: screenHeight,
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final cita = appointments[index];
        bool displayAsUpcoming = isUpcoming;

        final now = DateTime.now();
        if (isUpcoming &&
            cita.status == 'confirmada' &&
            cita.assignedDate != null &&
            cita.assignedDate!.isBefore(now)) {
          displayAsUpcoming = false;
        }

        return AppointmentCard(
          key: ValueKey(cita.id),
          appointment: cita,
          // Usamos nuestra nueva variable para decidir el estilo de la tarjeta.
          isUpcoming: displayAsUpcoming,
        );
      },
    );
  }
}

class _AppointmentsShimmer extends StatelessWidget {
  const _AppointmentsShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 5,
        itemBuilder: (context, index) => const _ShimmerCard(),
        physics: const NeverScrollableScrollPhysics(),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 154,
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}