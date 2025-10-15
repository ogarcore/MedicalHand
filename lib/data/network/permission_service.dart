import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> handleCameraPermission(BuildContext context, {String? reason}) async {
    var status = await Permission.camera.status;

    if (!context.mounted) return false;
    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {

      await _showPermissionDialog(
        context,
        title: 'permiso_requerido'.tr(),
        content:
            'el_acceso_a_la_cmara_ha_sido_denegado_permanentemente_por_fa'.tr(),
        buttonText: 'Abrir Configuración',
        onPressed: openAppSettings,
      );
      return false;
    }

    // Si el permiso fue denegado antes, mostramos nuestro diálogo explicativo.
    if (status.isDenied) {
      // ignore: use_build_context_synchronously
      bool granted = false;
      await _showPermissionDialog(
        context,
        title: 'acceso_a_la_cmara'.tr(),
        content:
            'medicalhand_necesita_acceso_a_tu_cmara_para_tomar_fotos_de_t'.tr(),
        buttonText: 'Permitir',
        onPressed: () async {
          Navigator.of(context).pop();
          // Solicitamos el permiso ahora.
          final newStatus = await Permission.camera.request();
          if (newStatus.isGranted) {
            granted = true;
          }
        },
      );
      return granted;
    }

    // Si es la primera vez que se pide el permiso.
    final newStatus = await Permission.camera.request();
    return newStatus.isGranted;
  }

  Future<void> _showPermissionDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String buttonText,
    required VoidCallback onPressed,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text('cancelar'.tr()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: onPressed,
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }
}