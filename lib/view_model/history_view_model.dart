import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/consultation_model.dart';

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
      _historyFuture = Future.value(
        [],
      ); // Devuelve futuro con lista vacía si no hay usuario
      notifyListeners();
      return;
    }
    _historyFuture = _getHistoryFromFirestore(user.uid);
    notifyListeners();
  }

  // Lógica de obtención de datos adaptada a tu estructura
  Future<List<ConsultationModel>> _getHistoryFromFirestore(
    String userId,
  ) async {
    try {
      // 1. Obtiene los documentos 'expedientes' que pertenecen al usuario.
      final expedientesSnapshot = await _firestore
          .collection('expedientes')
          .where('id_usuario', isEqualTo: userId)
          .get();

      if (expedientesSnapshot.docs.isEmpty) {
        return []; // Si no hay expedientes, devuelve una lista vacía.
      }

      final List<ConsultationModel> allConsultations = [];

      // 2. Itera sobre cada documento 'expediente' del usuario.
      for (final expedienteDoc in expedientesSnapshot.docs) {
        final expedienteData = expedienteDoc.data();

        // 3. Por cada expediente, accede a su subcolección 'consultas'.
        final consultasSnapshot = await expedienteDoc.reference
            .collection('consultas')
            .orderBy('fechaConsulta', descending: true)
            .get();

        // 4. Convierte cada documento de consulta en un ConsultationModel.
        //    Le pasamos los datos del expediente 'padre' para que obtenga el nombre del hospital.
        for (final consultaDoc in consultasSnapshot.docs) {
          allConsultations.add(
            ConsultationModel.fromFirestore(
              consultaDoc: consultaDoc,
              expedienteData: expedienteData,
            ),
          );
        }
      }

      // 5. Ordena la lista combinada de todas las consultas por fecha.
      //    Esto asegura que el historial se vea cronológicamente correcto en la app.
      allConsultations.sort(
        (a, b) => b.fechaConsulta.compareTo(a.fechaConsulta),
      );

      return allConsultations;
    } on FirebaseException catch (e) {
      throw Exception("No se pudo cargar el historial. Inténtalo de nuevo.");
    } catch (e) {
      throw Exception("Ocurrió un error inesperado.");
    }
  }

  // Método para refrescar los datos, no necesita cambios.
  Future<void> refreshHistory() async {
    await fetchClinicalHistory();
  }
}
