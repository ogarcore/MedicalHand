// lib/view_model/appointment_view_model.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/cita_model.dart';
import '../data/models/hospital_model.dart';

class AppointmentViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  

  // ... (tus otros métodos como getNicaraguaDepartments, getHospitals, etc., no cambian)
  List<String> getNicaraguaDepartments() {
    // ... (este método no cambia)
    return [
      'Boaco',
      'Carazo',
      'Chinandega',
      'Chontales',
      'Costa Caribe Norte',
      'Costa Caribe Sur',
      'Estelí',
      'Granada',
      'Jinotega',
      'León',
      'Madriz',
      'Managua',
      'Masaya',
      'Matagalpa',
      'Nueva Segovia',
      'Río San Juan',
      'Rivas',
    ];
  }

  Future<List<HospitalModel>> getHospitals(String department) async {
    // ... (este método no cambia)
    try {
      final snapshot = await _firestore
          .collection('hospitales_MedicalHand')
          .where('city', isEqualTo: department)
          .get();

      final hospitals = snapshot.docs.map((doc) {
        return HospitalModel(
          id: doc.data()['hospitalId'] as String,
          name: doc.data()['name'] as String,
        );
      }).toList();

      hospitals.sort((a, b) => a.name.compareTo(b.name));
      return hospitals;
    } catch (e) {
      print("Error obteniendo hospitales: $e");
      return [];
    }
  }

  Future<bool> submitAppointmentRequest(CitaModel cita) async {
    // ... (este método no cambia)
    try {
      await _firestore.collection('citas').add(cita.toMap());
      return true;
    } catch (e) {
      print("Error al enviar la solicitud: $e");
      return false;
    }
  }

  // CAMBIO: Nuevo método para obtener las citas próximas en tiempo real.
Stream<List<CitaModel>> getUpcomingAppointments(String userId) {
    return _firestore
        .collection('citas')
        .where('uid', isEqualTo: userId)
        .where('status', whereIn: ['pendiente', 'confirmada'])
        // Quitamos el ordenamiento de Firestore para hacerlo manualmente
        .snapshots()
        .map((snapshot) {
      var citas = snapshot.docs
          .map((doc) => CitaModel.fromFirestore(doc))
          .toList();

      // CAMBIO: Lógica de ordenamiento personalizado
      citas.sort((a, b) {
        // Regla 1: 'confirmada' siempre va antes que 'pendiente'
        if (a.status == 'confirmada' && b.status == 'pendiente') {
          return -1; // a va primero
        }
        if (a.status == 'pendiente' && b.status == 'confirmada') {
          return 1; // b va primero
        }

        // Regla 2: Si ambas son 'confirmada', ordenar por fecha más cercana
        if (a.status == 'confirmada' && b.status == 'confirmada') {
          // Nos aseguramos de que las fechas no sean nulas
          if (a.assignedDate != null && b.assignedDate != null) {
            return a.assignedDate!.compareTo(b.assignedDate!); // Orden ascendente
          }
        }

        // Si no aplican las reglas anteriores, mantener el orden
        return 0;
      });

      return citas;
    });
  }

  // CAMBIO: Nuevo método para obtener las citas pasadas en tiempo real.
  Stream<List<CitaModel>> getPastAppointments(String userId) {
    return _firestore
        .collection('citas')
        .where('uid', isEqualTo: userId)
        .where('status', whereIn: ['finalizada', 'cancelada', 'reprogramada'])
        .orderBy('requestTimestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CitaModel.fromFirestore(doc))
              .toList();
        });
  }

  Stream<CitaModel?> getNextConfirmedAppointment(String userId) {
    final now = DateTime.now();

    return _firestore
        .collection('citas')
        .where('uid', isEqualTo: userId)
        .where('status', isEqualTo: 'confirmada')
        .where('assignedDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .orderBy('assignedDate') 
        .limit(1) 
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null; // No hay citas próximas confirmadas
      }
      // Si hay documentos, toma el primero y lo convierte en un objeto CitaModel
      return CitaModel.fromFirestore(snapshot.docs.first);
    });
  }
}
