// lib/view/screens/history/clinical_history_screen.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/consultation_model.dart';
import 'package:p_hn25/view_model/history_view_model.dart';
import 'package:provider/provider.dart';
import 'widgets/history_card.dart';
import 'widgets/empty_history_view.dart';
import 'widgets/filter_history_modal.dart';
import 'consultation_detail_screen.dart';

class ClinicalHistoryScreen extends StatefulWidget {
  const ClinicalHistoryScreen({super.key});

  @override
  State<ClinicalHistoryScreen> createState() => _ClinicalHistoryScreenState();
}

class _ClinicalHistoryScreenState extends State<ClinicalHistoryScreen> {
  // Lista para los datos originales (una vez cargados)
  List<ConsultationModel> _allHistoryEntries = [];
  // Lista para los datos filtrados que se muestran en la UI
  late List<ConsultationModel> _filteredHistoryEntries;

  @override
  void initState() {
    super.initState();
    // Inicializamos la lista de filtrados como vacía
    _filteredHistoryEntries = [];
  }

  void _applyFilters(String specialty) {
    setState(() {
      if (specialty == 'Todas') {
        _filteredHistoryEntries = List.from(_allHistoryEntries);
      } else {
        _filteredHistoryEntries = _allHistoryEntries
            .where((entry) => entry.specialty == specialty)
            .toList();
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _filteredHistoryEntries = List.from(_allHistoryEntries);
    });
  }

  void _showFilterDialog() {
    // No mostrar el diálogo si no hay datos para filtrar
    if (_allHistoryEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay historial para filtrar.')),
      );
      return;
    }

    final specialties = [
      'Todas',
      ..._allHistoryEntries.map((e) => e.specialty).toSet(),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return FilterHistoryModal(
          specialties: specialties.toList(),
          // Se ajusta para que el filtro solo sea por especialidad por ahora
          onApplyFilters: (specialty, withResults) => _applyFilters(specialty),
          onResetFilters: _resetFilters,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos la instancia del ViewModel
    final historyViewModel = Provider.of<HistoryViewModel>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          // Usamos FutureBuilder para manejar los estados de la carga de datos
          FutureBuilder<List<ConsultationModel>>(
            future: historyViewModel.historyFuture,
            builder: (context, snapshot) {
              // --- ESTADO DE CARGA ---
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // --- ESTADO DE ERROR ---
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Error: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textLightColor(context),
                        ),
                      ),
                    ),
                  ),
                );
              }

              // --- ESTADO CON DATOS (ÉXITO) ---
              if (snapshot.hasData) {
                // Guardamos los datos originales la primera vez que se cargan
                if (_allHistoryEntries.isEmpty) {
                  _allHistoryEntries = snapshot.data!;
                  _filteredHistoryEntries = List.from(_allHistoryEntries);
                }

                // Si la lista (filtrada o no) está vacía, mostramos el mensaje
                if (_filteredHistoryEntries.isEmpty) {
                  return const SliverToBoxAdapter(child: EmptyHistoryView());
                }

                // Si hay datos, construimos la lista
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final entry = _filteredHistoryEntries[index];
                      return HistoryCard(
                        hospital: entry.hospital,
                        specialty: entry.specialty,
                        date: entry.formattedDate,
                        motivoConsulta: entry.motivoConsulta,
                        diagnostico: entry.diagnostico,
                        onDetailsPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ConsultationDetailScreen(
                                // Pasamos el mapa del modelo a la pantalla de detalles
                                consultationData: entry.toMap(),
                              ),
                            ),
                          );
                        },
                      );
                    }, childCount: _filteredHistoryEntries.length),
                  ),
                );
              }

              // --- ESTADO INICIAL O INESPERADO ---
              return const SliverToBoxAdapter(child: EmptyHistoryView());
            },
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.backgroundColor(context),
      surfaceTintColor: Colors.transparent,
      pinned: true,
      floating: true,
      elevation: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 6),
          Text(
            'Mi Historial Clínico',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Consulta tus antecedentes médicos.',
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
        IconButton(
          icon: Icon(
            HugeIcons.strokeRoundedFilter,
            color: AppColors.primaryColor(context),
            size: 26,
          ),
          onPressed: _showFilterDialog,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
