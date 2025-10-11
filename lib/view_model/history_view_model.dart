import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/consultation_model.dart'; // Asegúrate que la ruta sea correcta

class HistoryViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<ConsultationModel>>? _historyFuture;
  Future<List<ConsultationModel>>? get historyFuture => _historyFuture;

  HistoryViewModel() {
    fetchClinicalHistory();
  }

  Future<void> fetchClinicalHistory() async {
    final user = _auth.currentUser;
    if (user == null) {
      _historyFuture = Future.value([]);
      notifyListeners();
      return;
    }
    _historyFuture = _getHistoryFromFirestore(user.uid);
    notifyListeners();
  }

  // --- LÓGICA MODIFICADA PARA BUSCAR NOMBRE DE HOSPITAL ---
  Future<List<ConsultationModel>> _getHistoryFromFirestore(String userId) async {
    try {
      // 1. Obtiene todas las consultas del usuario (igual que antes)
      final consultationsSnapshot = await _firestore
          .collection('consultas')
          .where('patient_uid', isEqualTo: userId)
          .orderBy('fechaConsulta', descending: true)
          .get();

      if (consultationsSnapshot.docs.isEmpty) {
        return [];
      }

      // 2. Crea una lista de "futuros" para buscar cada nombre de hospital en paralelo
      final futures = consultationsSnapshot.docs.map((doc) async {
        final data = doc.data();
        final hospitalId = data['hospital_id'] as String?;
        String hospitalName = 'Hospital no especificado'; // Nombre por defecto

        // 3. Si hay un ID, búscalo en la colección de hospitales
        if (hospitalId != null && hospitalId.isNotEmpty) {
          final hospitalDoc = await _firestore
              .collection('hospitales_MedicalHand')
              .doc(hospitalId)
              .get();
          
          if (hospitalDoc.exists) {
            // Si encuentra el hospital, extrae el campo 'name'
            hospitalName = hospitalDoc.data()?['name'] ?? 'Nombre no encontrado';
          }
        }

        // 4. Crea el modelo pasándole el documento y el nombre del hospital ya resuelto
        return ConsultationModel.fromFirestore(doc, hospitalName);
      }).toList();

      // 5. Espera a que todas las búsquedas de nombres terminen y devuelve la lista completa
      final allConsultations = await Future.wait(futures);
      return allConsultations;

    } on FirebaseException catch (e) {
      debugPrint("Error de Firebase al cargar el historial: $e");
      throw Exception("No se pudo cargar el historial. Inténtalo de nuevo.");
    } catch (e) {
      debugPrint("Error inesperado: $e");
      throw Exception("Ocurrió un error inesperado.");
    }
  }

  Future<List<ConsultationModel>> getHistory(String userId) async {
    // Simplemente llama a la función privada que ya contiene toda la lógica correcta.
    return _getHistoryFromFirestore(userId);
  }

  Future<void> refreshHistory() async {
    await fetchClinicalHistory();
  }
}