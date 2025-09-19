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
  late AppointmentViewModel _appointmentViewModel;

  Stream<List<CitaModel>>? _upcomingAppointmentsStream;
  Stream<List<CitaModel>>? _pastAppointmentsStream;
  String? _currentProfileId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    initializeDateFormatting('es_ES', null);

    _appointmentViewModel = Provider.of<AppointmentViewModel>(
      context,
      listen: false,
    );

    final initialProfile = Provider.of<UserViewModel>(
      context,
      listen: false,
    ).activeProfile;
    if (initialProfile != null) {
      _initializeStreams(initialProfile.uid);
    }
  }

  void _initializeStreams(String profileId) {
    if (_currentProfileId == profileId) return;

    setState(() {
      _currentProfileId = profileId;
      _upcomingAppointmentsStream = _appointmentViewModel
          .getUpcomingAppointments(profileId);
      _pastAppointmentsStream = _appointmentViewModel.getPastAppointments(
        profileId,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, userViewModel, child) {
        final activeProfile = userViewModel.activeProfile;

        if (activeProfile == null) {
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            appBar: _buildAppBar(),
            body: const _AppointmentsShimmer(),
          );
        }

        if (activeProfile.uid != _currentProfileId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initializeStreams(activeProfile.uid);
          });
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: _buildAppBar(),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildAppointmentsStream(
                stream: _upcomingAppointmentsStream,
                isUpcoming: true,
              ),
              _buildAppointmentsStream(
                stream: _pastAppointmentsStream,
                isUpcoming: false,
              ),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.backgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 2),
          const Text(
            'Mis Citas',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Tus citas organizadas en un solo lugar.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: AppColors.textLightColor,
            ),
          ),
          const SizedBox(height: 4),
        ],
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
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 15,
        ),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        tabs: [
          Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Próximas'),
            ),
          ),
          Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Pasadas'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsStream({
    required Stream<List<CitaModel>>? stream,
    required bool isUpcoming,
  }) {
    if (stream == null) {
      return const _AppointmentsShimmer();
    }

    return StreamBuilder<List<CitaModel>>(
      stream: stream,
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
    final screenHeight = MediaQuery.of(context).size.height;

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      cacheExtent: screenHeight,
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final cita = appointments[index];
        return AppointmentCard(
          key: ValueKey(cita.id),
          appointment: cita,
          isUpcoming: isUpcoming,
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
