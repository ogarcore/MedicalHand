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
// Importamos el archivo de filtros
import 'widgets/past_appointments_filter_bar.dart';

class AppointmentsListScreen extends StatefulWidget {
  const AppointmentsListScreen({super.key});

  @override
  State<AppointmentsListScreen> createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<PastAppointmentsFilterBarState> _filterBarKey =
      GlobalKey<PastAppointmentsFilterBarState>();

  // 🔥 1. AÑADIMOS UNA VARIABLE DE ESTADO PARA SABER SI LOS FILTROS ESTÁN ACTIVOS.
  bool _areFiltersActive = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    initializeDateFormatting('es_ES', null);

    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          // Si no estamos en la pestaña de "Pasadas", reseteamos el estado del filtro.
          if (_tabController.index != 1) {
            _areFiltersActive = false;
          }
        });
      }
    });

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
    _tabController.removeListener(() {});
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
                  filterBarKey: _filterBarKey,
                  // 🔥 2. PASAMOS UNA FUNCIÓN CALLBACK PARA RECIBIR EL ESTADO DE LOS FILTROS.
                  onFilterStateChanged: (isActive) {
                    // Actualizamos el estado en el widget padre para que el AppBar se reconstruya.
                    setState(() {
                      _areFiltersActive = isActive;
                    });
                  },
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
      actions: [
        if (_tabController.index == 1)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                _areFiltersActive
                    ? HugeIcons
                          .strokeRoundedFilterEdit 
                    : HugeIcons.strokeRoundedFilter, 
                color: _areFiltersActive
                    ? AppColors.warningColor(
                        context,
                      ) // Color cuando los filtros están activos
                    : AppColors.primaryColor(context), // Color por defecto
              ),

              onPressed: () {
                _filterBarKey.currentState?.showFilterBottomSheet();
              },
              tooltip: 'Filtrar citas pasadas',
            ),
          ),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryColor(context),
        unselectedLabelColor: Colors.grey[600],
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.primaryColor(context).withAlpha(70),
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
}

class _AppointmentTabPage extends StatefulWidget {
  final String profileId;
  final bool isUpcoming;
  final GlobalKey<PastAppointmentsFilterBarState>? filterBarKey;
  // 🔥 4. AÑADIMOS EL PARÁMETRO PARA LA FUNCIÓN CALLBACK.
  final ValueChanged<bool>? onFilterStateChanged;

  const _AppointmentTabPage({
    super.key,
    required this.profileId,
    required this.isUpcoming,
    this.filterBarKey,
    this.onFilterStateChanged, // El callback es opcional.
  });

  @override
  State<_AppointmentTabPage> createState() => _AppointmentTabPageState();
}

class _AppointmentTabPageState extends State<_AppointmentTabPage>
    with AutomaticKeepAliveClientMixin {
  late Stream<List<CitaModel>> _appointmentsStream;
  AppointmentFilters _filters = AppointmentFilters();

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

  List<CitaModel> _applyFilters(List<CitaModel> appointments) {
    if (!_filters.hasActiveFilters) {
      return appointments;
    }

    return appointments.where((cita) {
      final dateMatch =
          _filters.date == null ||
          (cita.assignedDate != null &&
              cita.assignedDate!.year == _filters.date!.year &&
              cita.assignedDate!.month == _filters.date!.month &&
              cita.assignedDate!.day == _filters.date!.day);

      final statusMatch =
          _filters.status == null || cita.status == _filters.status;

      return dateMatch && statusMatch;
    }).toList();
  }

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

        final allAppointments = snapshot.data ?? [];
        final filteredAppointments = _applyFilters(allAppointments);

        if (allAppointments.isEmpty) {
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

        return Stack(
          children: [
            if (!widget.isUpcoming)
              PastAppointmentsFilterBar(
                key: widget.filterBarKey,
                allAppointments: allAppointments,
                currentFilters: _filters,
                onFiltersChanged: (newFilters) {
                  setState(() {
                    _filters = newFilters;
                  });
                  // 🔥 5. LLAMAMOS AL CALLBACK PARA NOTIFICAR AL PADRE SOBRE EL CAMBIO.
                  widget.onFilterStateChanged?.call(
                    newFilters.hasActiveFilters,
                  );
                },
              ),

            if (filteredAppointments.isEmpty && allAppointments.isNotEmpty)
              const EmptyStateWidget(
                icon: HugeIcons.strokeRoundedSearch02,
                title: 'Sin Resultados',
                message:
                    'No se encontraron citas que coincidan con los filtros seleccionados.',
              )
            else
              _buildAppointmentsList(
                appointments: filteredAppointments,
                isUpcoming: widget.isUpcoming,
              ),
          ],
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
      cacheExtent: MediaQuery.of(context).size.height,
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
