// lib/services/database_service.dart
// (Puedes poner este archivo donde organices tus servicios)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class DatabaseService {
  
  // Constructor privado para evitar instancias externas
  DatabaseService._privateConstructor();

  // La única instancia (Singleton) de este servicio
  // Esto se inicializa UNA SOLA VEZ y apunta a 'medicalhand'
  static final FirebaseFirestore instance = _getMedicalHandDatabase();

  static FirebaseFirestore _getMedicalHandDatabase() {
    try {
      // 1. Obtenemos la aplicación de Firebase (la 'default' que inicializaste en main.dart)
      FirebaseApp defaultApp = Firebase.app();
      
      // 2. Retornamos la instancia de Firestore para la base de datos 'medicalhand'
      print("Conectando a la base de datos: medicalhand");
      return FirebaseFirestore.instanceFor(
        app: defaultApp, 
        databaseId: '(default)'
      );
    } catch (e) {
      print('Error al obtener la instancia de Firestore (medicalhand): $e');
      // Si falla (ej. Firebase no inicializado), lanza una excepción
      throw Exception('No se pudo conectar a la base de datos "medicalhand". Asegúrate de que Firebase esté inicializado.');
    }
  }
}