// lib/data/models/cita_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CitaModel {
  final String? id;
  final String uid;
  final String fullName;
  final String idNumber;
  final DateTime dateOfBirth;
  final String phoneNumber;
  final String idHospital;
  final String hospital;
  final String reason;
  final DateTime requestTimestamp;
  final String status;
  final String requestType;
  final bool isActive;
  final DateTime? assignedDate;
  final String? assignedDoctor;
  final String? clinicOffice;
  final String? specialty;
  final bool requiereExpediente;
  final Map<String, String>? verificationUrls;
  final List<Map<String, dynamic>>? rescheduleHistory;
  final bool? reminder24hSent;
  final bool? reminder48hSent;

  CitaModel({
    this.id,
    required this.uid,
    required this.fullName,
    required this.idNumber,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.hospital,
    required this.idHospital,
    required this.reason,
    required this.requestTimestamp,
    this.status = 'pendiente',
    this.requestType = 'solicitud',
    this.isActive = true,
    this.assignedDate,
    this.assignedDoctor,
    this.clinicOffice,
    this.specialty = 'Consulta Externa',
    required this.requiereExpediente,
    this.verificationUrls,
    this.rescheduleHistory,
    this.reminder24hSent,
    this.reminder48hSent,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'idNumber': idNumber,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'phoneNumber': phoneNumber,
      'idHospital': idHospital,
      'hospital': hospital,
      'reason': reason,
      'requestTimestamp': Timestamp.fromDate(requestTimestamp),
      'status': status,
      'requestType': requestType,
      'isActive': isActive,
      'assignedDate': assignedDate != null
          ? Timestamp.fromDate(assignedDate!)
          : null,
      'assignedDoctor': assignedDoctor,
      'clinicOffice': clinicOffice,
      'specialty': specialty,
      'requiereExpediente': requiereExpediente,
      'verificationUrls': verificationUrls,
      'rescheduleHistory': rescheduleHistory,
      'reminder24hSent': reminder24hSent,
      'reminder48hSent': reminder48hSent,
    };
  }

  factory CitaModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CitaModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      fullName: data['fullName'] ?? '',
      idNumber: data['idNumber'] ?? '',
      dateOfBirth: (data['dateOfBirth'] as Timestamp).toDate(),
      phoneNumber: data['phoneNumber'] ?? '',
      hospital: data['hospital'] ?? '',
      idHospital: data['idHospital'] ?? '',
      reason: data['reason'] ?? '',
      requestTimestamp: (data['requestTimestamp'] as Timestamp).toDate(),
      status: data['status'] ?? 'desconocido',
      requestType: data['requestType'] ?? '',
      isActive: data['isActive'] ?? false,
      assignedDate: data['assignedDate'] != null
          ? (data['assignedDate'] as Timestamp).toDate()
          : null,
      assignedDoctor: data['assignedDoctor'],
      clinicOffice: data['clinicOffice'],
      specialty: data['specialty'] ?? 'Consulta Externa',
      requiereExpediente: data['requiereExpediente'] ?? false,
      verificationUrls: data['verificationUrls'] != null
          ? Map<String, String>.from(data['verificationUrls'])
          : null,
      rescheduleHistory: data['rescheduleHistory'] != null
          ? List<Map<String, dynamic>>.from(data['rescheduleHistory'])
          : null,
      reminder24hSent: data['reminder24hSent'] ?? false,
      reminder48hSent: data['reminder48hSent'] ?? false,
    );
  }
}
