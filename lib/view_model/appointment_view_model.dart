// lib/view_model/appointment_view_model.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:p_hn25/data/network/notification_service.dart';
import '../data/models/cita_model.dart';
import '../data/models/hospital_model.dart';

class AppointmentViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService.instance;

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
    } catch (e) {
      //;
    }
  }


Future<CitaModel?> getAppointmentById(String appointmentId) async {
  try {
    final doc = await _firestore.collection('citas').doc(appointmentId).get();
    if (!doc.exists) return null;
    return CitaModel.fromFirestore(doc);
  } catch (e) {
    debugPrint('Error al obtener la cita por ID: $e');
    return null;
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
      //;
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
          whereIn: [
            'pendiente',
            'confirmada',
            'pendiente_reprogramacion',
            'asistencia_confirmada',
          ],
        )
        .snapshots()
        .map((snapshot) {
          var citas = snapshot.docs.map((doc) {
            var cita = CitaModel.fromFirestore(doc);
            if (cita.status == 'asistencia_confirmada') {
              cita.status = 'confirmada';
            }

            return cita;
          }).toList();

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
          .where(
            'status',
            whereIn: ['confirmada', 'pendiente', 'pendiente_reprogramacion'],
          )
          .orderBy('assignedDate', descending: false)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        initialDashboardAppointment = CitaModel.fromFirestore(
          querySnapshot.docs.first,
        );
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
        .where(
          'status',
          whereIn: ['finalizada', 'cancelada', 'reprogramada', 'no_asistio'],
        )
        .orderBy('assignedDate', descending: true)
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

  Future<Map<String, dynamic>> performCheckIn({
    required String qrData,
    required CitaModel appointment,
    required String patientUid,
    required String patientName,
  }) async {
    // 1. Validar y parsear el JSON del QR
    Map<String, dynamic> qrJson;
    try {
      qrJson = json.decode(qrData);
    } catch (e) {
      return {'success': false, 'message': 'El código QR no es válido.'};
    }

    final queueId = qrJson['queueId'] as String?;
    if (queueId == null) {
      return {
        'success': false,
        'message': 'El código QR no tiene el formato correcto.',
      };
    }

    // 2. Construir el ID del documento de la fila
    final today = DateTime.now();
    final formattedDate = DateFormat('dd-MM-yyyy').format(today);
    final queueDocId = '$queueId-$formattedDate';

    // Obtenemos el token de notificación del dispositivo
    final notificationToken = await _notificationService.getFcmToken();
    if (notificationToken == null) {
      return {
        'success': false,
        'message': 'No se pudo obtener el token para notificaciones.',
      };
    }

    // 3. Ejecutar la transacción en Firestore
    try {
      final newTurnNumber = await _firestore.runTransaction((
        transaction,
      ) async {
        final queueRef = _firestore
            .collection('filas_virtuales')
            .doc(queueDocId);
        final patientRef = queueRef.collection('pacientes').doc(patientUid);
        final appointmentRef = _firestore
            .collection('citas')
            .doc(appointment.id);

        // Leemos el documento de la fila actual
        final queueSnapshot = await transaction.get(queueRef);

        int nextTurn;

        if (!queueSnapshot.exists) {
          // Si la fila no existe para hoy, la creamos.
          nextTurn = 1;
          transaction.set(queueRef, {
            'hospitalId': appointment.idHospital,
            'queueName': appointment.specialty ?? 'Consulta General',
            'queueDate': Timestamp.fromDate(
              DateTime(today.year, today.month, today.day),
            ),
            'queueStatus': 'activo',
            'currentTurn': 0,
            'lastAssignedTurn': nextTurn,
          });
        } else {
          // Si ya existe, incrementamos el último turno.
          final currentData = queueSnapshot.data()!;
          final lastTurn = currentData['lastAssignedTurn'] as int;
          nextTurn = lastTurn + 1;
          transaction.update(queueRef, {'lastAssignedTurn': nextTurn});
        }

        // Creamos el documento para el paciente en la sub-colección.
        transaction.set(patientRef, {
          'patientName': patientName,
          'appointmentId': appointment.id,
          'turnNumber': nextTurn,
          'checkInTime': FieldValue.serverTimestamp(),
          'patientStatus': 'esperando',
          'notificationToken': notificationToken,
        });

        // Actualizamos el estado de la cita original.
        transaction.update(appointmentRef, {'status': 'en_fila'});

        return nextTurn;
      });

      return {'success': true, 'turnNumber': newTurnNumber};
    } catch (e) {
      print('Error en la transacción de check-in: $e');
      return {
        'success': false,
        'message':
            'Ocurrió un error al registrar tu llegada. Inténtalo de nuevo.',
      };
    }
  }

  Future<bool> confirmAttendance(String appointmentId) async {
    try {
      await _firestore.collection('citas').doc(appointmentId).update({
        'status': 'asistencia_confirmada',
      });
      return true;
    } catch (e) {
      //;
      return false;
    }
  }

  Stream<CitaModel?> getDashboardAppointmentStream(String userId) {
    final query = _firestore
        .collection('citas')
        .where('uid', isEqualTo: userId)
        .where('status', whereIn: ['confirmada', 'asistencia_confirmada','en_fila'])
        .orderBy('assignedDate')
        .limit(1);

    return query.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }
      return CitaModel.fromFirestore(snapshot.docs.first);
    });
  }

Stream<DocumentSnapshot> getVirtualQueueStream(String queueDocId) {
  return FirebaseFirestore.instance
      .collection('filas_virtuales')
      .doc(queueDocId)
      .snapshots();
}
Stream<DocumentSnapshot> getManagedQueueStream(String queueDocId, String userId) {
    late StreamSubscription patientSubscription;
    late StreamSubscription queueSubscription;
    final controller = StreamController<DocumentSnapshot>();

    controller.onListen = () {
      // 1. Escuchar el estado del paciente
      patientSubscription = getPatientQueueStream(queueDocId, userId).listen(
        (patientSnap) {
          if (patientSnap.exists) {
            final data = patientSnap.data() as Map<String, dynamic>;
            // 2. Si el estado es 'llamado', se cancelan ambas suscripciones y se cierra el stream
            if (data['patientStatus'] == 'llamado') {
              queueSubscription.cancel();
              patientSubscription.cancel();
              controller.close();
            }
          } else {
            // Si el documento del paciente es borrado, también se detiene.
            queueSubscription.cancel();
            patientSubscription.cancel();
            controller.close();
          }
        },
        onError: (e) => controller.addError(e),
      );

      // 3. Escuchar la fila principal para obtener el 'currentTurn'
      queueSubscription = getVirtualQueueStream(queueDocId).listen(
        (queueSnap) {
          // 4. Pasar los datos de la fila a través del controlador
          if (!controller.isClosed) {
            controller.add(queueSnap);
          }
        },
        onError: (e) => controller.addError(e),
      );
    };

    // 5. Asegurarse de limpiar todo si el que escucha se desconecta
    controller.onCancel = () {
      patientSubscription.cancel();
      queueSubscription.cancel();
    };

    return controller.stream;
  }

Stream<DocumentSnapshot> getPatientQueueStream(String queueDocId, String userId) {
  return FirebaseFirestore.instance
      .collection('filas_virtuales')
      .doc(queueDocId)
      .collection('pacientes')
      .doc(userId)
      .snapshots();
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
          .where('id_usuario', isEqualTo: userId)
          .where('id_hospital', isEqualTo: hospitalId)
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
    initialDashboardAppointment = null;
  }
}
