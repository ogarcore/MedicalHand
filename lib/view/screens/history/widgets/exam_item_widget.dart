import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:p_hn25/app/core/constants/app_colors.dart';

class ExamItemWidget extends StatelessWidget {
  final Map<String, dynamic> exam;
  final bool isDownloading;
  final String? downloadingFileUrl;
  final Function(String url, String fileName) onDownloadPressed;

  const ExamItemWidget({
    super.key,
    required this.exam,
    required this.isDownloading,
    this.downloadingFileUrl,
    required this.onDownloadPressed,
  });

  @override
  Widget build(BuildContext context) {
    final String examName = exam['nombre'] as String? ?? 'Examen sin nombre';
    final String status = exam['estado'] as String? ?? 'solicitado';
    final List<dynamic> results =
        exam.containsKey('resultados') && exam['resultados'] is List
            ? exam['resultados'] as List
            : [];
    final bool isDownloadable =
        status.toLowerCase() == 'completado' && results.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          examName,
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.textColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        if (isDownloadable)
          Align(
            alignment: Alignment.centerRight,
            child: _buildDownloadButton(context, results),
          )
        else
          _buildPendingStatus(context),
      ],
    );
  }

  Widget _buildPendingStatus(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.warningColor(context).withAlpha(26),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            HugeIcons.strokeRoundedClock01,
            size: 12.sp,
            color: AppColors.warningColor(context),
          ),
          SizedBox(width: 4.w),
          Text(
            'resultados_pendientes'.tr(),
            style: TextStyle(
              color: AppColors.warningColor(context),
              fontWeight: FontWeight.w600,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context, List<dynamic> results) {
    final firstResult = results.first as Map<String, dynamic>;
    final String? url = firstResult['url'] as String?;
    final String fileName = firstResult['name'] as String? ?? 'resultado.pdf';
    final bool isCurrentlyDownloading =
        isDownloading && downloadingFileUrl == url;

    if (isCurrentlyDownloading) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16.w,
              height: 16.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.successColor(context),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'descargando'.tr(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.successColor(context),
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      );
    } else {
      return OutlinedButton.icon(
        onPressed: isDownloading
            ? null
            : () {
                if (url != null && url.isNotEmpty) {
                  onDownloadPressed(url, fileName);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'no_se_encontr_un_archivo_vlido_para_descargar'
                              .tr()),
                    ),
                  );
                }
              },
        icon: Icon(
          HugeIcons.strokeRoundedDownload01,
          size: 16.sp,
          color:
              isDownloading ? Colors.grey : AppColors.successColor(context),
        ),
        label: Text(
          'descargar_resultados'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color:
                isDownloading ? Colors.grey : AppColors.successColor(context),
            fontSize: 12.sp,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          side: BorderSide(
            color: (isDownloading
                    ? Colors.grey
                    : AppColors.successColor(context))
                .withAlpha(13),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }
  }
}