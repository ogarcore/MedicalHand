import 'package:easy_localization/easy_localization.dart';
// lib/view/screens/history/consultation_detail_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

// NUEVOS IMPORTS para abrir archivos
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;

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

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
    );

    // Inicializar con callback para cuando el usuario toca la notificación
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
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'downloads_channel',
          'Descargas',
          channelDescription: 'Notificaciones de descargas completadas',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          // Si quieres que al tocar abra la app, payload es filePath
        );

    final NotificationDetails details = NotificationDetails(
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

  /// Muestra un diálogo genérico para solicitar permisos o abrir la configuración.
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

  /// Determina si un archivo es una imagen basándose en su extensión.
  bool _isImageFile(String fileName) {
    final lowercased = fileName.toLowerCase();
    return lowercased.endsWith('.png') ||
        lowercased.endsWith('.jpg') ||
        lowercased.endsWith('.jpeg') ||
        lowercased.endsWith('.gif') ||
        lowercased.endsWith('.webp');
  }

  /// Maneja la solicitud del permiso correcto según la versión de Android.
  Future<bool> _handleStoragePermission(bool isImage) async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      // Para Android 13 (SDK 33) y superior
      if (deviceInfo.version.sdkInt >= 33) {
        // Si es imagen, pide permiso de fotos. Si no, no se necesita permiso específico para la carpeta de Descargas.
        status = isImage
            ? await Permission.photos.request()
            : PermissionStatus.granted;
      } else {
        // Para versiones antiguas, pide permiso de almacenamiento general.
        status = await Permission.storage.request();
      }
    } else {
      // Para iOS, se usa el permiso de fotos/galería.
      status = await Permission.photos.request();
    }

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      await _showPermissionDialog(
        title: 'permiso_requerido'.tr(),
        content: 'el_acceso_ha_sido_denegado_permanentemente_para_descargar_po'
            .tr(),
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

  /// Abre un archivo local usando OpenFilex
  Future<void> _openFile(String path) async {
    try {
      if (!await File(path).exists()) {
        // Si no existe, intentamos mostrar un mensaje
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

  /// Devuelve la carpeta "Downloads" en Android de forma fiable.
  /// Nota: getDownloadsDirectory() de path_provider en Android puede ser null en algunos casos,
  /// así que usamos un fallback a la ruta típica '/storage/emulated/0/Download'.
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
      // Intentar crear la carpeta si no existe (requiere permiso)
      try {
        await fallback.create(recursive: true);
        return fallback;
      } catch (_) {
        return null;
      }
    }

    // iOS / otros: usar documentos
    try {
      return await getApplicationDocumentsDirectory();
    } catch (_) {
      return null;
    }
  }

  /// Inicia el proceso de descarga del archivo.
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

      // --- INICIO DE LA MODIFICACIÓN ---
      if (isImage) {
        // CAMBIO 1: Obtener el directorio temporal de la app.
        final tempDir = await getTemporaryDirectory();
        // CAMBIO 2: Crear una ruta de archivo VÁLIDA y REAL dentro del directorio temporal.
        final tempPath = p.join(tempDir.path, fileName);

        // CAMBIO 3: Escribir los bytes de la imagen en este archivo temporal.
        await File(tempPath).writeAsBytes(fileBytes);

        // CAMBIO 4: Pedir a la galería que guarde una copia del archivo temporal.
        final result = await ImageGallerySaverPlus.saveFile(
          tempPath,
          name: fileName,
        );

        // CAMBIO 5: La ruta que usaremos para abrir el archivo es la de nuestra copia temporal,
        // que sabemos que es una ruta de archivo real.
        savedPath = tempPath;

        if (result == null || !(result['isSuccess'] as bool? ?? false)) {
          throw Exception("No se pudo guardar la imagen en la galería.");
        }
      } else {
        // --- FIN DE LA MODIFICACIÓN ---

        // La lógica para archivos que NO son imágenes permanece igual.
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
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('confirmar_descarga'.tr()),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('ests_a_punto_de_descargar_el_siguiente_archivo'.tr()),
                const SizedBox(height: 10),
                Text(
                  fileName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('¿Deseas continuar?'),
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
    final List prescriptions = prescriptionsData is List
        ? prescriptionsData
        : [];

    final examsData = widget.consultationData['examsRequested'];
    final List exams = examsData is List ? examsData : [];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          'detalles_de_consulta'.tr(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textColor(context),
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: AppColors.backgroundColor(context),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textColor(context), size: 22),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCompactHeader(context, hospital, date, doctor, specialty),
            const SizedBox(height: 20),
            Column(
              children: [
                _buildCompactSection(
                  context,
                  icon: HugeIcons.strokeRoundedQuestion,
                  title: 'motivo_de_la_consulta'.tr(),
                  content: motivoConsulta,
                  accentColor: Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildCompactSection(
                  context,
                  icon: HugeIcons.strokeRoundedHealth,
                  title: 'diagnstico'.tr(),
                  content: diagnostico,
                  accentColor: AppColors.primaryColor(context),
                ),
                const SizedBox(height: 12),
                _buildCompactSection(
                  context,
                  icon: HugeIcons.strokeRoundedGivePill,
                  title: 'tratamiento_indicado'.tr(),
                  content: tratamiento,
                  accentColor: AppColors.secondaryColor(context),
                ),
                if (prescriptions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildCompactListSection(
                    context,
                    icon: HugeIcons.strokeRoundedPinLocation01,
                    title: 'recetas_mdicas'.tr(),
                    items: prescriptions,
                    itemBuilder: (item) => Text(
                      '${item['nombre']} (${item['dosis']}) - ${item['frecuencia']}, por ${item['duracion']}.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: AppColors.textColor(context).withAlpha(220),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    accentColor: Colors.purple,
                  ),
                ],
                if (exams.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildCompactListSection(
                    context,
                    icon: HugeIcons.strokeRoundedMicroscope,
                    title: 'exmenes_solicitados'.tr(),
                    items: exams,
                    itemBuilder: (item) => _buildExamItem(context, item),
                    accentColor: AppColors.graceColor(context),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamItem(BuildContext context, Map<String, dynamic> exam) {
    final String examName = exam['nombre'] as String? ?? 'Examen sin nombre';
    final String status = exam['estado'] as String? ?? 'solicitado';
    List<dynamic> results = [];
    if (exam.containsKey('resultados') && exam['resultados'] is List) {
      results = exam['resultados'] as List;
    }
    final bool isDownloadable =
        status.toLowerCase() == 'completado' && results.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          examName,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (isDownloadable)
          Align(
            alignment: Alignment.centerRight,
            child: (() {
              final firstResult = results.first as Map<String, dynamic>;
              final String? url = firstResult['url'] as String?;
              final String fileName =
                  firstResult['name'] as String? ?? 'resultado.pdf';
              final bool isCurrentlyDownloading =
                  _isDownloading && _downloadingFileUrl == url;

              if (isCurrentlyDownloading) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.successColor(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'descargando'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.successColor(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return OutlinedButton.icon(
                  onPressed: _isDownloading
                      ? null
                      : () {
                          if (url != null && url.isNotEmpty) {
                            _showDownloadConfirmationDialog(url, fileName);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'no_se_encontr_un_archivo_vlido_para_descargar'
                                      .tr(),
                                ),
                              ),
                            );
                          }
                        },
                  icon: Icon(
                    HugeIcons.strokeRoundedDownload01,
                    size: 16,
                    color: _isDownloading
                        ? Colors.grey
                        : AppColors.successColor(context),
                  ),
                  label: Text(
                    'descargar_resultados'.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _isDownloading
                          ? Colors.grey
                          : AppColors.successColor(context),
                      fontSize: 12,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    side: BorderSide(
                      color:
                          (_isDownloading
                                  ? Colors.grey
                                  : AppColors.successColor(context))
                              .withOpacity(0.5),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                );
              }
            })(),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.warningColor(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  HugeIcons.strokeRoundedClock01,
                  size: 12,
                  color: AppColors.warningColor(context),
                ),
                const SizedBox(width: 4),
                Text(
                  'resultados_pendientes'.tr(),
                  style: TextStyle(
                    color: AppColors.warningColor(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // --- El resto de los widgets de construcción permanecen igual ---
  Widget _buildCompactHeader(
    BuildContext context,
    String hospital,
    String date,
    String doctor,
    String specialty,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primaryColor(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? Colors.white.withAlpha(8) : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(15) : Colors.grey.shade100,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 15 : 5),
            blurRadius: 12,
            offset: const Offset(0, 3),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withAlpha(isDark ? 25 : 12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: primaryColor.withAlpha(isDark ? 40 : 20),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  HugeIcons.strokeRoundedArcBrowser,
                  size: 12,
                  color: primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  specialty,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withAlpha(30),
                      primaryColor.withAlpha(15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: primaryColor.withAlpha(25),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  HugeIcons.strokeRoundedHospital01,
                  size: 18,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor(context),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'centro_mdico'.tr(),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textColor(context).withAlpha(130),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCompactDetailCard(
                  context,
                  icon: HugeIcons.strokeRoundedCalendar01,
                  title: 'fecha'.tr(),
                  value: date,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactDetailCard(
                  context,
                  icon: HugeIcons.strokeRoundedDoctor01,
                  title: 'mdico'.tr(),
                  value: doctor,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDetailCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isDark ? Colors.white.withAlpha(6) : color.withAlpha(6),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(12) : color.withAlpha(15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor(context),
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required Color accentColor,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isDark ? Colors.white.withAlpha(8) : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(15) : Colors.grey.shade100,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 12 : 4),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor.withAlpha(40),
                        accentColor.withAlpha(20),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: accentColor.withAlpha(30),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(icon, size: 16, color: accentColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(
              children: [
                Container(
                  height: 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        isDark
                            ? Colors.white.withAlpha(30)
                            : Colors.grey.shade300,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.textColor(context).withAlpha(220),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactListSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List items,
    required Widget Function(Map<String, dynamic>) itemBuilder,
    required Color accentColor,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isDark ? Colors.white.withAlpha(8) : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(15) : Colors.grey.shade100,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 12 : 4),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor.withAlpha(40),
                        accentColor.withAlpha(20),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: accentColor.withAlpha(30),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(icon, size: 16, color: accentColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(
              children: [
                Container(
                  height: 1,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        isDark
                            ? Colors.white.withAlpha(30)
                            : Colors.grey.shade300,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                ...items.asMap().entries.map((entry) {
                  final item = Map<String, dynamic>.from(entry.value as Map);
                  final isLast = entry.key == items.length - 1;
                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: isDark
                                  ? Colors.white.withAlpha(6)
                                  : Colors.grey.shade50,
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withAlpha(12)
                                    : Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: itemBuilder(item),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
