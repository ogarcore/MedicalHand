// lib/data/network/image_picker_service.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickAndCompressImage() async {
    // 1. Abre la cámara para tomar la foto
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile == null) return null;

    // 2. Comprime la imagen
    final File originalFile = File(pickedFile.path);
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(
      dir.path,
      "${DateTime.now().millisecondsSinceEpoch}.jpg",
    );

    final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
      originalFile.absolute.path,
      targetPath,
      quality: 75,
      minWidth: 1024,
    );

    return compressedFile;
  }
}
