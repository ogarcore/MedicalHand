// lib/view/screens/home/widgets/notifications_panel.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'notification_tile.dart';

class NotificationsPanel extends StatefulWidget {
  final VoidCallback onClose;
  
  const NotificationsPanel({super.key, required this.onClose});

  @override
  State<NotificationsPanel> createState() => _NotificationsPanelState();
}

class _NotificationsPanelState extends State<NotificationsPanel> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Todas', 'No leídas', 'Médicas', 'Recordatorios'];
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.transparent,
        child: DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.52,
          maxChildSize: 0.88,
          snap: true,
          snapSizes: const [0.52, 0.72, 0.88],
          builder: (_, scrollController) {
            return GestureDetector(
              onTap: () {}, // Evita que el tap se propague al fondo
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(46), // 0.18 * 255 ≈ 46
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Barra superior con indicador
                    Container(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      child: Center(
                        child: Container(
                          width: 36,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    
                    // Encabezado del panel
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Centro de Notificaciones',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textColor,
                              letterSpacing: -0.4,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryColor.withAlpha(229), // 0.9 * 255 ≈ 229
                                  AppColors.primaryColor.withAlpha(178), // 0.7 * 255 ≈ 178
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Text(
                              '3 nuevas',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Opciones de filtro
                    Container(
                      height: 42,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      child: Row(
                        children: List.generate(_filters.length, (index) {
                          final isSelected = index == _selectedFilterIndex;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedFilterIndex = index;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primaryColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: isSelected ? [
                                    BoxShadow(
                                      color: AppColors.primaryColor.withAlpha(77), // 0.3 * 255 ≈ 77
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ] : null,
                                ),
                                child: Center(
                                  child: Text(
                                    _filters[index],
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.grey[700],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Lista de notificaciones
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView(
                          controller: scrollController,
                          physics: const ClampingScrollPhysics(),
                          children: const [
                            NotificationTile(
                              icon: HugeIcons.strokeRoundedCalendar02,
                              iconColor: AppColors.primaryColor,
                              title: 'Cita Confirmada',
                              subtitle: 'Tu cita de Cardiología para el 25 de Sep ha sido confirmada. Llega 15 minutos antes.',
                              time: 'Hace 5m',
                              isRead: false,
                            ),
                            NotificationTile(
                              icon: HugeIcons.strokeRoundedMedicalFile,
                              iconColor: AppColors.accentColor,
                              title: 'Resultados Disponibles',
                              subtitle: 'Los resultados de tu examen de sangre ya están listos para revisión.',
                              time: 'Hace 2h',
                              isRead: false,
                            ),
                            NotificationTile(
                              icon: HugeIcons.strokeRoundedCalendarFavorite01,
                              iconColor: AppColors.graceColor,
                              title: 'Recordatorio de Cita',
                              subtitle: 'No olvides tu cita de Dermatología mañana a las 11:00 AM.',
                              time: 'Ayer',
                              isRead: true,
                            ),
                            NotificationTile(
                              icon: HugeIcons.strokeRoundedHealth,
                              iconColor: Colors.orange,
                              title: 'Recordatorio de Medicamento',
                              subtitle: 'Es hora de tomar tu medicamento recetado: Metformina 500mg.',
                              time: '10 Sep',
                              isRead: true,
                            ),
                            NotificationTile(
                              icon: HugeIcons.strokeRoundedCalendar02,
                              iconColor: AppColors.primaryColor,
                              title: 'Recordatorio de Pago',
                              subtitle: 'Tu factura mensual está lista. Realiza el pago antes del 30 de septiembre.',
                              time: '8 Sep',
                              isRead: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Botón de acción inferior
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26), // 0.1 * 255 ≈ 26
                            blurRadius: 12,
                            offset: const Offset(0, -4),
                          ),
                        ],
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                              ),
                              child: Text(
                                'Marcar leídas',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                                shadowColor: AppColors.primaryColor.withAlpha(102), // 0.4 * 255 ≈ 102
                              ),
                              child: const Text(
                                'Limpiar todo',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
