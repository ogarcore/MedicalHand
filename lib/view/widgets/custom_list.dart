import 'package:flutter/material.dart';
import '../../../app/core/constants/app_colors.dart';

class ChronicDiseasesList extends StatelessWidget {
  final Set<String> selectedDiseases;
  final Function(String, bool?) onDiseaseSelected;

  const ChronicDiseasesList({
    super.key,
    required this.selectedDiseases,
    required this.onDiseaseSelected,
  });

  final List<String> chronicDiseases = const [
    'Diabetes',
    'Hipertensión',
    'Asma',
    'Enfermedad Cardíaca',
    'Artritis',
    'Epilepsia',
    'Cáncer',
    'Enfermedad Renal',
    'Enfermedad Hepática',
    'VIH/SIDA',
    'Otra',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enfermedades Crónicas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona las que apliquen',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(140),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Scrollbar(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: chronicDiseases.length,
              itemBuilder: (context, index) {
                final disease = chronicDiseases[index];
                return CheckboxListTile(
                  title: Text(
                    disease,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textColor,
                    ),
                  ),
                  value: selectedDiseases.contains(disease),
                  onChanged: (bool? selected) {
                    onDiseaseSelected(disease, selected);
                  },
                  activeColor: AppColors.primaryColor,
                  checkColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${selectedDiseases.length} seleccionadas',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
