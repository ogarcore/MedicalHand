// lib/view/screens/history/clinical_history_screen.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'widgets/history_card.dart';
import 'widgets/empty_history_view.dart';
import 'widgets/filter_history_modal.dart';

class ClinicalHistoryScreen extends StatefulWidget {
  const ClinicalHistoryScreen({super.key});

  @override
  State<ClinicalHistoryScreen> createState() => _ClinicalHistoryScreenState();
}

class _ClinicalHistoryScreenState extends State<ClinicalHistoryScreen> {
  final List<Map<String, String>> allHistoryEntries = [
    {
      'date': '12 Jul, 2025',
      'specialty': 'Medicina General',
      'doctor': 'Dra. Ana Pérez',
      'diagnosis': 'Faringitis Aguda',
      'prescription': 'Amoxicilina 500mg, Ibuprofeno 400mg',
      'lab_results': 'No aplica',
      'hospital': 'Hospital Manolo Morales',
      'has_downloadable': 'false',
    },
    {
      'date': '05 Jun, 2025',
      'specialty': 'Dermatología',
      'doctor': 'Dr. Luis Castro',
      'diagnosis': 'Dermatitis de Contacto',
      'prescription': 'Crema con hidrocortisona al 1%',
      'lab_results': 'Prueba de alergia positiva a níquel',
      'hospital': 'Hospital Vélez Paiz',
      'has_downloadable': 'true',
    },
    {
      'date': '18 Mar, 2025',
      'specialty': 'Cardiología',
      'doctor': 'Dr. Roberto Morales',
      'diagnosis': 'Hipertensión Leve',
      'prescription': 'Enalapril 10mg, Dieta baja en sodio',
      'lab_results':
          'Colesterol total: 210 mg/dL\nTriglicéridos: 150 mg/dL\nHDL: 45 mg/dL',
      'hospital': 'Centro Cardiológico Nacional',
      'has_downloadable': 'true',
    },
  ];

  late List<Map<String, String>> filteredHistoryEntries;
  late List<bool> isExpandedList;
  final Map<int, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();
    filteredHistoryEntries = List.from(allHistoryEntries);
    _updateExpandedList();
  }

  void _updateExpandedList() {
    isExpandedList = List.generate(
      filteredHistoryEntries.length,
      (index) => false,
    );
    for (int i = 0; i < filteredHistoryEntries.length; i++) {
      _itemKeys[i] = GlobalKey();
    }
  }

  void _applyFilters(String specialty, bool withResults) {
    setState(() {
      List<Map<String, String>> tempList = List.from(allHistoryEntries);
      if (specialty != 'Todas') {
        tempList = tempList
            .where((entry) => entry['specialty'] == specialty)
            .toList();
      }
      if (withResults) {
        tempList = tempList
            .where((entry) => entry['has_downloadable'] == 'true')
            .toList();
      }
      filteredHistoryEntries = tempList;
      _updateExpandedList();
    });
  }

  void _resetFilters() {
    setState(() {
      filteredHistoryEntries = List.from(allHistoryEntries);
      _updateExpandedList();
    });
  }

  void _showFilterDialog() {
    final specialties = [
      'Todas',
      ...allHistoryEntries.map((e) => e['specialty']!).toSet(),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return FilterHistoryModal(
          specialties: specialties,
          onApplyFilters: _applyFilters,
          onResetFilters: _resetFilters,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
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
              Row(
                children: [
                  InkWell(
                    onTap: _showFilterDialog,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Filtrar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryColor(context),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      HugeIcons.strokeRoundedFilter,
                      color: AppColors.primaryColor(context),
                      size: 26,
                    ),
                    onPressed: _showFilterDialog,
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          filteredHistoryEntries.isEmpty
              ? const SliverToBoxAdapter(child: EmptyHistoryView())
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final entry = filteredHistoryEntries[index];
                      return HistoryCard(
                        cardKey: _itemKeys[index]!,
                        index: index,
                        date: entry['date']!,
                        specialty: entry['specialty']!,
                        doctor: entry['doctor']!,
                        diagnosis: entry['diagnosis']!,
                        prescription: entry['prescription']!,
                        labResults: entry['lab_results']!,
                        hospital: entry['hospital']!,
                        hasDownloadable: entry['has_downloadable'] == 'true',
                        isExpanded: isExpandedList[index],
                        onExpansionChanged: (expanded) {
                          setState(() {
                            isExpandedList[index] = expanded;
                          });
                        },
                      );
                    }, childCount: filteredHistoryEntries.length),
                  ),
                ),
        ],
      ),
    );
  }
}
