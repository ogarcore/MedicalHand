// lib/view/screens/history/widgets/history_card_details.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class HistoryCardDetails extends StatelessWidget {
  final String specialty;
  final String doctor;
  final String diagnosis;
  final String prescription;
  final String labResults;
  final bool hasDownloadable;

  const HistoryCardDetails({
    super.key,
    required this.specialty,
    required this.doctor,
    required this.diagnosis,
    required this.prescription,
    required this.labResults,
    required this.hasDownloadable,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          const Divider(height: 1, color: Colors.grey),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            HugeIcons.strokeRoundedStethoscope,
            'Especialidad',
            specialty,
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            HugeIcons.strokeRoundedDoctor01,
            'Médico tratante',
            doctor,
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            HugeIcons.strokeRoundedHealth,
            'Diagnóstico',
            diagnosis,
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            HugeIcons.strokeRoundedGivePill,
            'Tratamiento indicado',
            prescription,
          ),
          const SizedBox(height: 16),
          _buildLabResultsSection(context, labResults, hasDownloadable),
        ],
      ),
    );
  }

  // --- MÉTODOS DE TU CÓDIGO ORIGINAL ---
  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryColor(context).withAlpha(35),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryColor(context), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabResultsSection(
    BuildContext context,
    String labResults,
    bool hasDownloadable,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryColor(context).withAlpha(35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                HugeIcons.strokeRoundedMicroscope,
                color: AppColors.primaryColor(context),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resultados de Laboratorio',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                    ),
                    child: Text(
                      labResults,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textColor(context),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (hasDownloadable) _buildDownloadButton(context),
        if (!hasDownloadable)
          Text(
            'No hay documentos disponibles para descargar',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showDownloadOptions(context),
        icon: const Icon(HugeIcons.strokeRoundedDownload01, size: 20),
        label: const Text(
          'Descargar Resultados',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor(context),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showDownloadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                HugeIcons.strokeRoundedDownload01,
                size: 40,
                color: AppColors.primaryColor(context),
              ),
              const SizedBox(height: 16),
              Text(
                'Descargar Resultados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor(context),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecciona el formato deseado',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _buildDownloadOption(
                context,
                'PDF Completo',
                'Documento con todos los resultados',
                HugeIcons.strokeRoundedFile02,
              ),
              _buildDownloadOption(
                context,
                'Imágenes',
                'Descargar imágenes de estudios',
                HugeIcons.strokeRoundedImage02,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDownloadOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.primaryColor(context).withAlpha(40),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primaryColor(context), size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textColor(context),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryColor(context).withAlpha(40),
          shape: BoxShape.circle,
        ),
        child: Icon(
          HugeIcons.strokeRoundedDownload01,
          color: AppColors.primaryColor(context),
          size: 20,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Descargando $title...'),
            backgroundColor: AppColors.primaryColor(context),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}
