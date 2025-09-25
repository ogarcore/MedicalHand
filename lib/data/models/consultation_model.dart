import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// --- Modelos para los datos anidados (se mantienen igual) ---
class Prescription {
  final String nombre;
  final String dosis;
  final String frecuencia;
  final String duracion;

  Prescription({
    required this.nombre,
    required this.dosis,
    required this.frecuencia,
    required this.duracion,
  });

  factory Prescription.fromMap(Map<String, dynamic> map) {
    return Prescription(
      nombre: map['nombre'] ?? 'N/A',
      dosis: map['dosis'] ?? 'N/A',
      frecuencia: map['frecuencia'] ?? 'N/A',
      duracion: map['duracion'] ?? 'N/A',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'dosis': dosis,
      'frecuencia': frecuencia,
      'duracion': duracion,
    };
  }
}

class ExamRequested {
  final String nombre;
  final String estado;

  ExamRequested({required this.nombre, required this.estado});

  factory ExamRequested.fromMap(Map<String, dynamic> map) {
    return ExamRequested(
      nombre: map['nombre'] ?? 'N/A',
      estado: map['estado'] ?? 'solicitado',
    );
  }

  Map<String, dynamic> toMap() {
    return {'nombre': nombre, 'estado': estado};
  }
}

// --- Modelo principal de la Consulta (adaptado a tu estructura) ---
class ConsultationModel {
  // Datos que vienen del documento de la subcolección 'consultas'
  final String id;
  final String diagnostico;
  final Timestamp fechaConsulta;
  final String motivoConsulta;
  final String tratamiento;
  final String doctorName;
  final String specialty;
  final List<Prescription> prescriptions;
  final List<ExamRequested> examsRequested;
  final String observaciones;

  // Datos que vienen del documento 'padre' en la colección 'expedientes'
  final String hospital;

  ConsultationModel({
    required this.id,
    required this.diagnostico,
    required this.fechaConsulta,
    required this.motivoConsulta,
    required this.tratamiento,
    required this.doctorName,
    required this.specialty,
    required this.prescriptions,
    required this.examsRequested,
    required this.observaciones,
    required this.hospital,
  });

  // Constructor Factory para crear el modelo desde Firestore
  factory ConsultationModel.fromFirestore({
    required DocumentSnapshot consultaDoc,
    required Map<String, dynamic> expedienteData,
  }) {
    final data = consultaDoc.data() as Map<String, dynamic>;

    return ConsultationModel(
      id: consultaDoc.id,
      // Leyendo los campos del documento de consulta
      fechaConsulta: data['fechaConsulta'] ?? Timestamp.now(),
      diagnostico: data['diagnostico'] ?? 'Sin diagnóstico',
      motivoConsulta: data['motivoConsulta'] ?? 'Sin motivo',
      tratamiento: data['tratamiento'] ?? 'Sin tratamiento',
      observaciones: data['observaciones'] ?? '',
      doctorName: data['doctorName'] ?? 'No especificado', // Campo que añadirás
      specialty: data['specialty'] ?? 'No especificada', // Campo que añadirás
      // Mapeando los arrays
      prescriptions:
          (data['prescriptions'] as List<dynamic>?)
              ?.map((p) => Prescription.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [],
      examsRequested:
          (data['examsRequested'] as List<dynamic>?)
              ?.map((e) => ExamRequested.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],

      // Leyendo el nombre del hospital desde los datos del expediente 'padre'
      hospital: expedienteData['hospitalName'] ?? 'Hospital no especificado',
    );
  }

  String get formattedDate {
    final date = fechaConsulta.toDate();
    return DateFormat('d \'de\' MMMM, y', 'es_ES').format(date);
  }

  // Método para pasar los datos a la pantalla de detalles (no necesita cambios)
  Map<String, dynamic> toMap() {
    return {
      'hospital': hospital,
      'specialty': specialty,
      'date': formattedDate,
      'motivoConsulta': motivoConsulta,
      'diagnostico': diagnostico,
      'tratamiento': tratamiento,
      'doctor': doctorName,
      'prescriptions': prescriptions.map((p) => p.toMap()).toList(),
      'examsRequested': examsRequested.map((e) => e.toMap()).toList(),
      'observaciones': observaciones,
    };
  }
}
