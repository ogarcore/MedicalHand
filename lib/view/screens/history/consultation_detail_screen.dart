import 'dart:io';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'widgets/consultation_detail_header.dart';
import 'widgets/consultation_info_card.dart';
import 'widgets/consultation_list_card.dart';
import 'widgets/exam_item_widget.dart';

class ConsultationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> consultationData;

  const ConsultationDetailScreen({super.key, required this.consultationData});

  @override
  State<ConsultationDetailScreen> createState() =>
      _ConsultationDetailScreenState();
}

class _ConsultationDetailScreenState extends State<ConsultationDetailScreen> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Variables de estado para la descarga
  bool _isDownloading = false;
  String? _downloadingFileUrl;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  // TODA LA LÓGICA DE NOTIFICACIONES, PERMISOS Y DESCARGAS SE MANTIENE AQUÍ
  // SIN NINGÚN CAMBIO FUNCIONAL.

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          await _openFile(payload);
        }
      },
    );
  }

  Future<void> _showDownloadNotification(
    String fileName,
    String filePath,
  ) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'downloads_channel', 'Descargas',
        channelDescription: 'Notificaciones de descargas completadas',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true);

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Descarga completada',
      fileName,
      details,
      payload: filePath,
    );
  }

  Future<void> _showPermissionDialog({
    required String title,
    required String content,
    required String buttonText,
    required VoidCallback onPressed,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text('cancelar'.tr()),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(onPressed: onPressed, child: Text(buttonText)),
          ],
        );
      },
    );
  }

  bool _isImageFile(String fileName) {
    final lowercased = fileName.toLowerCase();
    return lowercased.endsWith('.png') ||
        lowercased.endsWith('.jpg') ||
        lowercased.endsWith('.jpeg') ||
        lowercased.endsWith('.gif') ||
        lowercased.endsWith('.webp');
  }

  Future<bool> _handleStoragePermission(bool isImage) async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      if (deviceInfo.version.sdkInt >= 33) {
        status = isImage
            ? await Permission.photos.request()
            : PermissionStatus.granted;
      } else {
        status = await Permission.storage.request();
      }
    } else {
      status = await Permission.photos.request();
    }

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      await _showPermissionDialog(
        title: 'permiso_requerido'.tr(),
        content:
            'el_acceso_ha_sido_denegado_permanentemente_para_descargar_po'.tr(),
        buttonText: 'Abrir Configuración',
        onPressed: () {
          Navigator.of(context).pop();
          openAppSettings();
        },
      );
      return false;
    }

    return false;
  }

  Future<void> _openFile(String path) async {
    try {
      if (!await File(path).exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('el_archivo_ya_no_est_disponible'.tr())),
          );
        }
        return;
      }
      await OpenFilex.open(path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'no_se_pudo_abrir_el_archivo'.tr(namedArgs: {"e": e.toString()}),
            ),
          ),
        );
      }
    }
  }

  Future<Directory?> _getDownloadsDirectorySafe() async {
    try {
      final dir = await getDownloadsDirectory();
      if (dir != null) return dir;
    } catch (_) {
      // Ignorar y usar fallback
    }

    if (Platform.isAndroid) {
      final fallback = Directory('/storage/emulated/0/Download');
      if (await fallback.exists()) return fallback;
      try {
        await fallback.create(recursive: true);
        return fallback;
      } catch (_) {
        return null;
      }
    }

    try {
      return await getApplicationDocumentsDirectory();
    } catch (_) {
      return null;
    }
  }

  Future<void> _downloadFile(String urlString, String fileName) async {
    final isImage = _isImageFile(fileName);
    final hasPermission = await _handleStoragePermission(isImage);

    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('permiso_denegado_no_se_puede_descargar'.tr()),
          ),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isDownloading = true;
        _downloadingFileUrl = urlString;
      });
    }

    try {
      final dio = Dio();
      final response = await dio.get<List<int>>(
        urlString,
        options: Options(responseType: ResponseType.bytes),
      );
      final fileBytes = response.data;

      if (fileBytes == null) {
        throw Exception("No se recibieron datos del archivo.");
      }

      String savedPath = '';

      if (isImage) {
        final tempDir = await getTemporaryDirectory();
        final tempPath = p.join(tempDir.path, fileName);

        await File(tempPath).writeAsBytes(fileBytes);

        final result = await ImageGallerySaverPlus.saveFile(
          tempPath,
          name: fileName,
        );
        savedPath = tempPath;

        if (result == null || !(result['isSuccess'] as bool? ?? false)) {
          throw Exception("No se pudo guardar la imagen en la galería.");
        }
      } else {
        final dir = await _getDownloadsDirectorySafe();
        if (dir == null) {
          throw Exception("No se pudo acceder a la carpeta de descargas.");
        }
        final safeName = fileName.isNotEmpty ? fileName : 'archivo_descargado';
        savedPath = p.join(dir.path, safeName);

        final f = File(savedPath);
        await f.writeAsBytes(fileBytes, flush: true);
      }

      if (!mounted) return;

      await _showDownloadNotification(fileName, savedPath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isImage
                  ? 'Guardado en la galería: $fileName'
                  : 'Guardado en Descargas: $fileName',
            ),
            action: SnackBarAction(
              label: 'Abrir',
              onPressed: () {
                _openFile(savedPath);
              },
            ),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al descargar el archivo: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadingFileUrl = null;
        });
      }
    }
  }

  Future<void> _showDownloadConfirmationDialog(
    String url,
    String fileName,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text('confirmar_descarga'.tr()),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('ests_a_punto_de_descargar_el_siguiente_archivo'.tr()),
                SizedBox(height: 10.h),
                Text(
                  fileName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.h),
                const Text('¿Deseas continuar?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('cancelar'.tr()),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            FilledButton(
              child: Text('descargar'.tr()),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _downloadFile(url, fileName);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String hospital =
        widget.consultationData['hospital'] ?? 'No disponible';
    final String specialty =
        widget.consultationData['specialty'] ?? 'No disponible';
    final String date = widget.consultationData['date'] ?? 'No disponible';
    final String doctor = widget.consultationData['doctor'] ?? 'No disponible';
    final String motivoConsulta =
        widget.consultationData['motivoConsulta'] ?? 'No disponible';
    final String diagnostico =
        widget.consultationData['diagnostico'] ?? 'No disponible';
    final String tratamiento =
        widget.consultationData['tratamiento'] ?? 'No disponible';

    final prescriptionsData = widget.consultationData['prescriptions'];
    final List prescriptions =
        prescriptionsData is List ? prescriptionsData : [];

    final examsData = widget.consultationData['examsRequested'];
    final List exams = examsData is List ? examsData : [];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          'detalles_de_consulta'.tr(),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textColor(context),
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: AppColors.backgroundColor(context),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textColor(context), size: 22.sp),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            ConsultationDetailHeader(
              hospital: hospital,
              date: date,
              doctor: doctor,
              specialty: specialty,
            ),
            SizedBox(height: 20.h),
            ConsultationInfoCard(
              icon: HugeIcons.strokeRoundedQuestion,
              title: 'motivo_de_la_consulta'.tr(),
              content: motivoConsulta,
              accentColor: Colors.blue,
            ),
            SizedBox(height: 12.h),
            ConsultationInfoCard(
              icon: HugeIcons.strokeRoundedHealth,
              title: 'diagnstico'.tr(),
              content: diagnostico,
              accentColor: AppColors.primaryColor(context),
            ),
            SizedBox(height: 12.h),
            ConsultationInfoCard(
              icon: HugeIcons.strokeRoundedGivePill,
              title: 'tratamiento_indicado'.tr(),
              content: tratamiento,
              accentColor: AppColors.secondaryColor(context),
            ),
            if (prescriptions.isNotEmpty) ...[
              SizedBox(height: 12.h),
              ConsultationListCard(
                icon: HugeIcons.strokeRoundedPinLocation01,
                title: 'recetas_mdicas'.tr(),
                items: prescriptions,
                accentColor: Colors.purple,
                itemBuilder: (item) => Text(
                  '${item['nombre']} (${item['dosis']}) - ${item['frecuencia']}, por ${item['duracion']}.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.4,
                    color: AppColors.textColor(context).withAlpha(220),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
            if (exams.isNotEmpty) ...[
              SizedBox(height: 12.h),
              ConsultationListCard(
                icon: HugeIcons.strokeRoundedMicroscope,
                title: 'exmenes_solicitados'.tr(),
                items: exams,
                accentColor: AppColors.graceColor(context),
                itemBuilder: (item) => ExamItemWidget(
                  exam: item,
                  isDownloading: _isDownloading,
                  downloadingFileUrl: _downloadingFileUrl,
                  onDownloadPressed: (url, fileName) {
                    _showDownloadConfirmationDialog(url, fileName);
                  },
                ),
              ),
            ],
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
