import 'package:easy_localization/easy_localization.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  late final MobileScannerController _scannerController;
  bool _isScanCompleted = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _toggleTorch() async {
    await _scannerController.toggleTorch();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isTorchOn = _scannerController.value.torchState == TorchState.on;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Scanner de cámara
          MobileScanner(
            controller: _scannerController,
            onDetect: (BarcodeCapture capture) {
              if (!_isScanCompleted && capture.barcodes.isNotEmpty) {
                final String? code = capture.barcodes.first.rawValue;
                if (code != null) {
                  _isScanCompleted = true;
                  Navigator.of(context).pop(code);
                }
              }
            },
          ),
          
          // Overlay oscuro con recorte
          _buildScannerOverlay(context),
          
          // Header
          _buildHeader(context, isTorchOn),
          
          // Marco de escaneo estilo Google Lens
          _buildGoogleLensFrame(context),
          
          // Instrucciones
          _buildInstructions(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isTorchOn) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(150),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(150),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                isTorchOn ? Icons.flash_on : Icons.flash_off,
                color: isTorchOn ? Colors.yellow : Colors.white,
              ),
              onPressed: _toggleTorch,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withAlpha(180),
            Colors.black.withAlpha(120),
            Colors.black.withAlpha(120),
            Colors.black.withAlpha(180),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleLensFrame(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 280,
            height: 280,
            child: CustomPaint(
              painter: _GoogleLensFramePainter(),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInstructions(BuildContext context) {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Icon(
            Icons.qr_code_2,
            size: 32,
            color: Colors.white.withAlpha(180),
          ),
          const SizedBox(height: 16),
          Text(
            'encuadra_el_cdigo_qr_en_el_marco'.tr(),
            style: TextStyle(
              color: Colors.white.withAlpha(200),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'el_escaneo_es_automtico'.tr(),
            style: TextStyle(
              color: Colors.white.withAlpha(150),
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleLensFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cornerPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cornerLength = 35.0;
    final borderRadius = 16.0;

    final path = Path();

    // Esquina superior izquierda - LÍNEA CONTINUA
    path.moveTo(borderRadius, 0);
    path.lineTo(cornerLength, 0);
    path.moveTo(0, borderRadius);
    path.lineTo(0, cornerLength);

    // Esquina superior derecha - LÍNEA CONTINUA
    path.moveTo(size.width - cornerLength, 0);
    path.lineTo(size.width - borderRadius, 0);
    path.moveTo(size.width, borderRadius);
    path.lineTo(size.width, cornerLength);

    // Esquina inferior izquierda - LÍNEA CONTINUA
    path.moveTo(0, size.height - cornerLength);
    path.lineTo(0, size.height - borderRadius);
    path.moveTo(borderRadius, size.height);
    path.lineTo(cornerLength, size.height);

    // Esquina inferior derecha - LÍNEA CONTINUA
    path.moveTo(size.width - cornerLength, size.height);
    path.lineTo(size.width - borderRadius, size.height);
    path.moveTo(size.width, size.height - cornerLength);
    path.lineTo(size.width, size.height - borderRadius);

    canvas.drawPath(path, cornerPaint);

    // Arcos redondeados en las esquinas (para hacerlas continuas)
    final arcPaint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    // Arco superior izquierdo
    canvas.drawArc(
      Rect.fromCircle(center: Offset(borderRadius, borderRadius), radius: borderRadius),
      -pi, 
      pi / 2, 
      false, 
      arcPaint
    );

    // Arco superior derecho
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width - borderRadius, borderRadius), radius: borderRadius),
      -pi / 2, 
      pi / 2, 
      false, 
      arcPaint
    );

    // Arco inferior izquierdo
    canvas.drawArc(
      Rect.fromCircle(center: Offset(borderRadius, size.height - borderRadius), radius: borderRadius),
      pi / 2, 
      pi / 2, 
      false, 
      arcPaint
    );

    // Arco inferior derecho
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width - borderRadius, size.height - borderRadius), radius: borderRadius),
      0, 
      pi / 2, 
      false, 
      arcPaint
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}