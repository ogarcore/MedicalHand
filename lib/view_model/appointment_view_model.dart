// lib/view_model/appointment_view_model.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/cita_model.dart';
import '../data/models/hospital_model.dart';

class AppointmentViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Propiedades para gestionar el estado del dashboard
  CitaModel? _nextAppointment;
  CitaModel? get nextAppointment => _nextAppointment;
  bool _isDashboardLoading = true;
  bool get isDashboardLoading => _isDashboardLoading;
  StreamSubscription? _appointmentSubscription;

  // ... (Tus métodos de getHospitals y getNicaraguaDepartments no cambian)
  List<String> getNicaraguaDepartments() {
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
    try {
      await _firestore.collection('citas').add(cita.toMap());
      return true;
    } catch (e) {
      print("Error al enviar la solicitud: $e");
      return false;
    }
  }

  // Tu método para obtener citas próximas (sin cambios)
  Stream<List<CitaModel>> getUpcomingAppointments(String userId) {
    return _firestore
        .collection('citas')
        .where('uid', isEqualTo: userId)
        .where('status', whereIn: ['pendiente', 'confirmada'])
        .snapshots()
        .map((snapshot) {
          var citas = snapshot.docs
              .map((doc) => CitaModel.fromFirestore(doc))
              .toList();
          citas.sort((a, b) {
            if (a.status == 'confirmada' && b.status == 'pendiente') return -1;
            if (a.status == 'pendiente' && b.status == 'confirmada') return 1;
            if (a.status == 'confirmada' && b.status == 'confirmada') {
              if (a.assignedDate != null && b.assignedDate != null) {
                return a.assignedDate!.compareTo(b.assignedDate!);
              }
            }
            return 0;
          });
          return citas;
        });
  }

  // Tu método para obtener citas pasadas (sin cambios)
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

  // Lógica del Dashboard que evita parpadeos y se actualiza en tiempo real
  void listenToNextAppointment(String userId) {
    if (_appointmentSubscription != null) {
      return;
    }

    Future.microtask(() {
      if (_isDashboardLoading)
        return; // Evita re-ejecutar si ya está en proceso
      _isDashboardLoading = true;
      notifyListeners();
    });

    final now = DateTime.now();
    final query = _firestore
        .collection('citas')
        .where('uid', isEqualTo: userId)
        .where('status', isEqualTo: 'confirmada')
        .where('assignedDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .orderBy('assignedDate')
        .limit(1);

    _appointmentSubscription = query.snapshots().listen(
      (snapshot) {
        if (snapshot.docs.isEmpty) {
          _nextAppointment = null;
        } else {
          _nextAppointment = CitaModel.fromFirestore(snapshot.docs.first);
        }
        _isDashboardLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print("Error al escuchar la próxima cita: $error");
        _isDashboardLoading = false;
        _nextAppointment = null;
        notifyListeners();
      },
    );
  }

  void disposeListeners() {
    _appointmentSubscription?.cancel();
    _appointmentSubscription = null;
    _nextAppointment = null;
    _isDashboardLoading = true;
  }
}
