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

  Future<List<ConsultationModel>> _getHistoryFromFirestore(String userId) async {
    try {
      final consultationsSnapshot = await _firestore
          .collection('consultas')
          .where('patient_uid', isEqualTo: userId)
          .orderBy('fechaConsulta', descending: true)
          .get();

      if (consultationsSnapshot.docs.isEmpty) {
        return [];
      }

      final futures = consultationsSnapshot.docs.map((doc) async {
        final data = doc.data();
        final hospitalId = data['hospital_id'] as String?;
        String hospitalName = 'Hospital no especificado';

        if (hospitalId != null && hospitalId.isNotEmpty) {
          final hospitalDoc = await _firestore
              .collection('hospitales_MedicalHand')
              .doc(hospitalId)
              .get();
          
          if (hospitalDoc.exists) {
            hospitalName = hospitalDoc.data()?['name'] ?? 'Nombre no encontrado';
          }
        }
        
        // Asumiendo que tu modelo tiene este constructor
        return ConsultationModel.fromFirestore(doc, hospitalName);
      }).toList();

      final allConsultations = await Future.wait(futures);
      return allConsultations;

    } on FirebaseException {
      throw Exception("No se pudo cargar el historial. Inténtalo de nuevo.");
    } catch (e) {
      throw Exception("Ocurrió un error inesperado.");
    }
  }


  Stream<List<ConsultationModel>> getHistoryStream(String userId) {
    final consultationsStream = _firestore
        .collection('consultas')
        .where('patient_uid', isEqualTo: userId)
        .orderBy('fechaConsulta', descending: true)
        .snapshots();

    // Transformamos el stream de snapshots de consulta en un stream de List<ConsultationModel>
    return consultationsStream.asyncMap((consultationsSnapshot) async {
      if (consultationsSnapshot.docs.isEmpty) {
        return []; // Retorna una lista vacía si no hay consultas
      }

      // Mapea cada documento a un Future que resuelve el modelo completo (con nombre de hospital)
      final futures = consultationsSnapshot.docs.map((doc) async {
        final data = doc.data();
        final hospitalId = data['hospital_id'] as String?;
        String hospitalName = 'Hospital no especificado'; // Valor por defecto

        if (hospitalId != null && hospitalId.isNotEmpty) {
          final hospitalDoc = await _firestore
              .collection('hospitales_MedicalHand')
              .doc(hospitalId)
              .get();
          
          if (hospitalDoc.exists) {
            hospitalName = hospitalDoc.data()?['name'] ?? 'Nombre no encontrado';
          }
        }
        
        // Crea la instancia del modelo con los datos de la consulta y el nombre del hospital
        return ConsultationModel.fromFirestore(doc, hospitalName);
      }).toList();

      // Espera a que todos los nombres de hospital se resuelvan y devuelve la lista completa
      return await Future.wait(futures);
    });
  }

  // =======================================================================
  // 🔥 FIN DEL CAMBIO
  // =======================================================================

  Future<List<ConsultationModel>> getHistory(String userId) async {
    return _getHistoryFromFirestore(userId);
  }

  Future<void> refreshHistory() async {
    await fetchClinicalHistory();
  }
}