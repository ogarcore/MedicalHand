import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/consultation_model.dart';
import 'package:p_hn25/view_model/history_view_model.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart'; // 🔥 1. ASEGURARSE DE QUE SHIMMER ESTÉ IMPORTADO
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
  List<ConsultationModel> _allHistoryEntries = [];
  late List<ConsultationModel> _filteredHistoryEntries;
  bool _isFilterActive = false;
  String? _lastLoadedProfileId;

  @override
  void initState() {
    super.initState();
    _filteredHistoryEntries = [];
  }

  void _applyFilters(String specialty, DateTime? date, bool withResults) {
    setState(() {
      List<ConsultationModel> tempList = List.from(_allHistoryEntries);

      if (specialty != 'Todas') {
        tempList = tempList
            .where((entry) => entry.especialidad == specialty)
            .toList();
      }

      if (date != null) {
        tempList = tempList.where((entry) {
          final data = entry.toMap();
          final timestamp = data['fecha'];
          if (timestamp is Timestamp) {
            final entryDate = timestamp.toDate();
            return entryDate.year == date.year &&
                entryDate.month == date.month &&
                entryDate.day == date.day;
          }
          return false;
        }).toList();
      }

      if (withResults) {
        tempList = tempList
            .where((entry) => entry.diagnostico.trim().isNotEmpty)
            .toList();
      }

      _filteredHistoryEntries = tempList;
      _isFilterActive = (specialty != 'Todas' || date != null || withResults);
    });
  }

  void _resetFilters() {
    setState(() {
      _filteredHistoryEntries = List.from(_allHistoryEntries);
      _isFilterActive = false;
    });
  }

  void _showFilterDialog() {
    if (_allHistoryEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay historial para filtrar.')),
      );
      return;
    }

    final specialties = [
      'Todas',
      ..._allHistoryEntries
          .map((e) => e.especialidad)
          .where((e) => e.isNotEmpty)
          .toSet(),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return FilterHistoryModal(
          specialties: specialties.toList(),
          onApplyFilters: (specialty, date, withResults) =>
              _applyFilters(specialty, date, withResults),
          onResetFilters: _resetFilters,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyViewModel = context.read<HistoryViewModel>();
    final userViewModel = context.watch<UserViewModel>();
    final activeProfile = userViewModel.activeProfile;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          if (activeProfile == null)
            const _HistoryShimmer() // Muestra shimmer si no hay perfil
          else
            FutureBuilder<List<ConsultationModel>>(
              key: ValueKey(activeProfile.uid),
              future: historyViewModel.getHistory(activeProfile.uid),
              builder: (context, snapshot) {
                // 🔥 2. SE REEMPLAZA EL CIRCULARPROGRESSINDICATOR POR EL WIDGET DE SHIMMER.
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _HistoryShimmer();
                }

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

                if (snapshot.hasData) {
                  if (_lastLoadedProfileId != activeProfile.uid) {
                    _allHistoryEntries = snapshot.data!;
                    _filteredHistoryEntries = List.from(_allHistoryEntries);
                    _isFilterActive = false;
                    _lastLoadedProfileId = activeProfile.uid;
                  }

                  if (_filteredHistoryEntries.isEmpty) {
                    if (_allHistoryEntries.isNotEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  HugeIcons.strokeRoundedSearch02,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Sin Resultados',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColor(context),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No se encontraron registros que coincidan con los filtros seleccionados.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textLightColor(context),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return const SliverToBoxAdapter(child: EmptyHistoryView());
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final entry = _filteredHistoryEntries[index];
                        return HistoryCard(
                          hospital: entry.hospitalName,
                          specialty: entry.especialidad,
                          date: entry.formattedDate,
                          diagnostico: entry.diagnostico,
                          onDetailsPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ConsultationDetailScreen(
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
          const SizedBox(height: 16),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isFilterActive
                ? HugeIcons.strokeRoundedFilterEdit
                : HugeIcons.strokeRoundedFilter,
            color: _isFilterActive
                ? AppColors.warningColor(context)
                : AppColors.primaryColor(context),
            size: 26,
          ),
          onPressed: _showFilterDialog,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

// 🔥 3. NUEVO WIDGET PARA EL EFECTO SHIMMER
class _HistoryShimmer extends StatelessWidget {
  const _HistoryShimmer();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: 5, // Muestra 5 tarjetas de carga
          itemBuilder: (context, index) => const _ShimmerHistoryCard(),
        ),
      ),
    );
  }
}

// 🔥 4. NUEVO WIDGET PARA LA TARJETA PLACEHOLDER
class _ShimmerHistoryCard extends StatelessWidget {
  const _ShimmerHistoryCard();

  Widget _buildPlaceholderLine({required double width, double height = 14}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPlaceholderLine(width: 150, height: 18),
              _buildPlaceholderLine(width: 80, height: 16),
            ],
          ),
          const SizedBox(height: 8),
          _buildPlaceholderLine(width: 120, height: 14),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          _buildPlaceholderLine(width: 100, height: 16),
          const SizedBox(height: 8),
          _buildPlaceholderLine(width: double.infinity),
          const SizedBox(height: 6),
          _buildPlaceholderLine(width: 200),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: _buildPlaceholderLine(width: 120, height: 40),
          ),
        ],
      ),
    );
  }
}
