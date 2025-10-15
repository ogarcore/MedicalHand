// lib/data/network/firebase_storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Sube un archivo a Firebase Storage y retorna la URL de descarga.
  Future<String> uploadFile(String userId, String fileName, File file) async {
    try {
      // Definimos la ruta donde se guardará el archivo
      final ref = _storage.ref('user_identity_documents/$userId/$fileName');

      // Subimos el archivo
      final uploadTask = ref.putFile(file);

      // Esperamos a que la subida se complete
      final snapshot = await uploadTask.whenComplete(() => {});

      // Obtenemos la URL de descarga
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException {

      return '';
    }
  }
}
