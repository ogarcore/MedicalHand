// lib/view_model/appointment_view_model.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../data/models/cita_model.dart';
import '../data/models/hospital_model.dart';

class AppointmentViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CitaModel? initialDashboardAppointment;
  CitaModel? _nextAppointment;
  CitaModel? get nextAppointment => _nextAppointment;
  bool _isDashboardLoading = true;
  bool get isDashboardLoading => _isDashboardLoading;
  StreamSubscription? _appointmentSubscription;
  String? _listeningForUserId;

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

  Future<void> checkForMissedAppointments(String userId) async {
    final now = DateTime.now();
    try {
      final query = await _firestore
          .collection('citas')
          .where('uid', isEqualTo: userId)
          .where('status', isEqualTo: 'confirmada')
          .where('assignedDate', isLessThan: Timestamp.fromDate(now))
          .get();

      if (query.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in query.docs) {
        batch.update(doc.reference, {'status': 'no_asistio'});
      }
      await batch.commit();
      print('${query.docs.length} cita(s) marcada(s) como "No Asistió".');
    } catch (e) {
      print('Error al verificar citas perdidas: $e');
    }
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
          location: doc.data()['location'] as GeoPoint,
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
      return false;
    }
  }

  Stream<List<CitaModel>> getUpcomingAppointments(String userId) {
    return _firestore
        .collection('citas')
        .where('uid', isEqualTo: userId)
        .where(
          'status',
          whereIn: ['pendiente', 'confirmada', 'pendiente_reprogramacion'],
        )
        .snapshots()
        .map((snapshot) {
          var citas = snapshot.docs
              .map((doc) => CitaModel.fromFirestore(doc))
              .toList();
          citas.sort((a, b) {
            if (a.status == 'confirmada' && b.status == 'pendiente') return -1;
            if ((a.status == 'pendiente' ||
                    a.status == 'pendiente_reprogramacion') &&
                b.status == 'confirmada') {
              return 1;
            }
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

 Future<void> fetchInitialDashboardAppointment(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('citas')
          .where('uid', isEqualTo: userId) // Corregido de 'userId' a 'uid'
          .where('status', whereIn: ['confirmada', 'pendiente', 'pendiente_reprogramacion'])
          .orderBy('assignedDate', descending: false)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        initialDashboardAppointment = CitaModel.fromFirestore(querySnapshot.docs.first);
      } else {
        initialDashboardAppointment = null;
      }
    } catch (e) {
      print("Error al pre-cargar la cita del dashboard: $e");
      initialDashboardAppointment = null;
    }
  }
  


  Future<bool> updateAppointmentStatus(
    String appointmentId,
    String newStatus,
  ) async {
    try {
      await _firestore.collection('citas').doc(appointmentId).update({
        'status': newStatus,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<List<CitaModel>> getPastAppointments(String userId) {
    return _firestore
        .collection('citas')
        .where('uid', isEqualTo: userId)
        .where('status', whereIn: ['finalizada', 'cancelada', 'reprogramada', 'no_asistio'])
        .orderBy('requestTimestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CitaModel.fromFirestore(doc))
          .toList();
    });
  }


  Future<bool> requestReschedule({
    required String appointmentId,
    required String reason,
    required DateTime previousDate,
  }) async {
    try {
      final formattedPreviousDate = DateFormat(
        'd MMM, y - hh:mm a',
        'es_ES',
      ).format(previousDate);
      final historyEntry = {
        'requestedAt': Timestamp.now(),
        'reason': reason,
        'previousDate': formattedPreviousDate,
      };

      await _firestore.collection('citas').doc(appointmentId).update({
        'status': 'pendiente_reprogramacion',
        'rescheduleHistory': FieldValue.arrayUnion([historyEntry]),
        'assignedDate': null,
        'assignedDoctor': null,
        'clinicOffice': null,
      });
      return true;
    } catch (e) {
      print('Error al solicitar reprogramación: $e');
      return false;
    }
  }

  Stream<CitaModel?> getDashboardAppointmentStream(String userId) {
    final query = _firestore
        .collection('citas')
        .where('uid', isEqualTo: userId)
        .where('status', isEqualTo: 'confirmada')
        // El filtro 'isGreaterThanOrEqualTo' se ha eliminado.
        .orderBy('assignedDate')
        .limit(1);

    return query.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }
      return CitaModel.fromFirestore(snapshot.docs.first);
    });
  }

  void listenToNextAppointment(String userId) {
    if (_listeningForUserId == userId) return;

    _appointmentSubscription?.cancel();
    _listeningForUserId = userId;

    _isDashboardLoading = true;
    notifyListeners();

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
        _isDashboardLoading = false;
        _nextAppointment = null;
        notifyListeners();
      },
    );
  }

  Future<bool> checkIfExpedienteExists({
    required String userId,
    required String hospitalId,
  }) async {
    try {
      final query = await _firestore
          .collection('expedientes')
          .where('userId', isEqualTo: userId)
          .where('hospitalId', isEqualTo: hospitalId)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      print("Error verificando expediente: $e");
      return false;
    }
  }

  void disposeListeners() {
    _appointmentSubscription?.cancel();
    _appointmentSubscription = null;
    _nextAppointment = null;
    _listeningForUserId = null;
    _isDashboardLoading = true;
  }
}
