import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> handleCameraPermission(BuildContext context) async {
    var status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {

      await _showPermissionDialog(
        context,
        title: 'Permiso Requerido',
        content:
            'El acceso a la cámara ha sido denegado permanentemente. Por favor, actívalo desde la configuración de tu teléfono.',
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
        title: 'Acceso a la Cámara',
        content:
            'MedicalHand necesita acceso a tu cámara para tomar fotos de tus documentos y verificar tu identidad.',
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
              child: const Text('Cancelar'),
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