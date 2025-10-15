// lib/view/screens/appointments/widgets/appointment_tab_page.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/data/models/cita_model.dart';
import 'package:p_hn25/view_model/appointment_view_model.dart';
import 'package:provider/provider.dart';
import 'appointment_card.dart';
import 'appointments_shimmer.dart';
import 'empty_state_widget.dart';
import 'past_appointments_filter_bar.dart';

class AppointmentTabPage extends StatefulWidget {
  final String profileId;
  final bool isUpcoming;
  final GlobalKey<PastAppointmentsFilterBarState>? filterBarKey;
  final ValueChanged<bool>? onFilterStateChanged;

  const AppointmentTabPage({
    super.key,
    required this.profileId,
    required this.isUpcoming,
    this.filterBarKey,
    this.onFilterStateChanged,
  });

  @override
  State<AppointmentTabPage> createState() => _AppointmentTabPageState();
}

class _AppointmentTabPageState extends State<AppointmentTabPage>
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
      final dateMatch = _filters.date == null ||
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
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppointmentsShimmer();
        }

        final allAppointments = snapshot.data ?? [];
        final filteredAppointments = _applyFilters(allAppointments);

        if (allAppointments.isEmpty) {
          return widget.isUpcoming
              ? EmptyStateWidget(
                  icon: HugeIcons.strokeRoundedCardiogram01,
                  title: 'cuida_tu_salud'.tr(),
                  message: 'an_no_tienes_citas_programadas_agendar_una_consulta_es_el_pr'.tr())
              : EmptyStateWidget(
                  icon: HugeIcons.strokeRoundedMedicalFile,
                  title: 'sin_historial'.tr(),
                  message: 'aqu_aparecern_tus_citas_una_vez_que_hayan_sido_finalizadas_o'.tr());
        }

        return Stack(
          children: [
            if (!widget.isUpcoming)
              PastAppointmentsFilterBar(
                key: widget.filterBarKey,
                allAppointments: allAppointments,
                currentFilters: _filters,
                onFiltersChanged: (newFilters) {
                  setState(() => _filters = newFilters);
                  widget.onFilterStateChanged?.call(newFilters.hasActiveFilters);
                },
              ),
            if (filteredAppointments.isEmpty && allAppointments.isNotEmpty)
              EmptyStateWidget(
                  icon: HugeIcons.strokeRoundedSearch02,
                  title: 'sin_resultados'.tr(),
                  message: 'no_se_encontraron_citas_que_coincidan_con_los_filtros_selecc'.tr())
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
      padding: EdgeInsets.all(16.0.r),
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