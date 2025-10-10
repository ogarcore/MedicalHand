import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/cita_model.dart';
import 'package:p_hn25/view_model/appointment_view_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class VirtualTicketCard extends StatelessWidget {
  final CitaModel appointment;

  const VirtualTicketCard({super.key, required this.appointment});

  String _getQueueDocId() {
    final specialty = (appointment.specialty ?? '').replaceAll(' ', '');
    final hospitalId = appointment.idHospital;
    final formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    return '$specialty-$hospitalId-$formattedDate';
  }

  @override
Widget build(BuildContext context) {
  final appointmentViewModel = context.read<AppointmentViewModel>();
  final queueDocId = _getQueueDocId();
  final userId = appointment.uid;

  return StreamBuilder<DocumentSnapshot>(
    stream: appointmentViewModel.getVirtualQueueStream(queueDocId),
    builder: (context, snapshot) {
      if (!snapshot.hasData || !snapshot.data!.exists) {
        return const Center(child: CircularProgressIndicator());
      }

      final queueData = snapshot.data!.data() as Map<String, dynamic>;
      final currentTurn = queueData['currentTurn'] as int? ?? 0;

      return StreamBuilder<DocumentSnapshot>(
        stream: appointmentViewModel.getPatientQueueStream(queueDocId, userId),
        builder: (context, patientSnapshot) {
          if (!patientSnapshot.hasData || !patientSnapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final patientData =
              patientSnapshot.data!.data() as Map<String, dynamic>;
          final yourTurn = patientData['turnNumber'] as int? ?? 0;
          final turnsLeft = yourTurn - currentTurn;
          final progressValue = yourTurn > 0 ? currentTurn / yourTurn : 0;

          // VERIFICAR SI ES EL TURNO
          final bool isYourTurn = turnsLeft <= 0;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Cabecera superior con gradiente
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor(context),
                          Color.lerp(AppColors.primaryColor(context), Colors.white, 0.2)!,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fila Virtual',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Seguimiento en tiempo real',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (appointment.clinicOffice != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(40),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withAlpha(60),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  HugeIcons.strokeRoundedLocation06,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  appointment.clinicOffice!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Contenido principal
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // MENSAJE CUANDO ES EL TURNO - SOLO ESTE CAMBIO
                        if (isYourTurn) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.warningColor(context).withAlpha(15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.warningColor(context).withAlpha(120),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  HugeIcons.strokeRoundedAlertCircle,
                                  size: 20,
                                  color: AppColors.warningColor(context),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '¡Es tu turno!',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.warningColor(context),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Acércate al consultorio ${appointment.clinicOffice ?? ''}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.warningColor(context),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Sección principal de turnos
                        Row(
                          children: [
                            // Turno actual
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(14,12,12,4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          HugeIcons.strokeRoundedComputerUser,
                                          size: 14,
                                          color: Colors.grey.shade500,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'TURNO ACTUAL',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade500,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$currentTurn',
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // Tu turno
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(14,12,12,4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.green.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          HugeIcons.strokeRoundedUserTime01,
                                          size: 14,
                                          color: AppColors.secondaryColor(context),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'TU TURNO',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color:AppColors.secondaryColor(context),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '$yourTurn',
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.secondaryColor(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Barra de progreso MEJORADA - empieza desde izquierda
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progreso de fila',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  '${(progressValue * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Stack(
                                children: [
                                  // Fondo gris completo
                                  Container(
                                    width: double.infinity,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  // Progreso que se llena desde izquierda
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      return Container(
                                        width: constraints.maxWidth * progressValue,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade400,
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Información adicional en dos columnas
                        Row(
                          children: [
                            // Personas delante
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(12,10,12,6),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PERSONAS DELANTE',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade500,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      turnsLeft > 0 ? '$turnsLeft' : '0',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // Tiempo estimado
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(12,10,12,6),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TIEMPO ESTIMADO',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade500,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${turnsLeft * 12} min',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 14),
                        
                        // Pie de la card
                        Container(
                          padding: const EdgeInsets.all(6),
                          child: Text(
                            'La información se actualiza en tiempo real',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}