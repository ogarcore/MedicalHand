import 'package:flutter/material.dart';
import 'dashboard_header.dart';
import 'next_appointment_card.dart';
import 'no_appointment_card.dart';
import 'dashboard_action_buttons.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {

    const bool tieneCitaProgramada = true;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardHeader(),
          const SizedBox(height: 32),
          if (tieneCitaProgramada)
            const NextAppointmentCard()
          else
            const NoAppointmentCard(),
          const SizedBox(height: 26),
          if (tieneCitaProgramada) const DashboardActionButtons(),
        ],
      ),
    );
  }
}