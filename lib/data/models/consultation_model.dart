import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// --- Modelos anidados (no necesitan cambios) ---
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

// --- Modelo principal de la Consulta (AJUSTADO) ---
class ConsultationModel {
  final String id;
  final String diagnostico;
  final Timestamp fechaConsulta;
  final String motivoConsulta;
  final String tratamiento;
  final String doctorName;
  final String especialidad;
  final String hospitalName; // <--- CAMBIO: Ahora es el nombre, no el ID
  final List<Prescription> prescriptions;
  final List<ExamRequested> examsRequested;
  final String observaciones;

  ConsultationModel({
    required this.id,
    required this.diagnostico,
    required this.fechaConsulta,
    required this.motivoConsulta,
    required this.tratamiento,
    required this.doctorName,
    required this.especialidad,
    required this.hospitalName, // <--- CAMBIO
    required this.prescriptions,
    required this.examsRequested,
    required this.observaciones,
  });

  // --- CONSTRUCTOR AJUSTADO ---
  // Ahora recibe el nombre del hospital como un parámetro extra.
  factory ConsultationModel.fromFirestore(DocumentSnapshot doc, String hospitalName) {
    final data = doc.data() as Map<String, dynamic>;

    return ConsultationModel(
      id: doc.id,
      fechaConsulta: data['fechaConsulta'] ?? Timestamp.now(),
      diagnostico: data['diagnostico'] ?? 'Sin diagnóstico',
      motivoConsulta: data['motivoConsulta'] ?? 'Sin motivo',
      tratamiento: data['tratamiento'] ?? 'Sin tratamiento',
      observaciones: data['observaciones'] ?? '',
      doctorName: data['doctor_name'] ?? 'No especificado',
      especialidad: data['especialidad'] ?? 'No especificada',
      
      hospitalName: hospitalName, // <--- CAMBIO: Usa el nombre que le pasamos

      prescriptions: (data['medicamentos'] as List<dynamic>?)
              ?.map((p) => Prescription.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [],
      examsRequested: (data['examsRequested'] as List<dynamic>?)
              ?.map((e) => ExamRequested.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String get formattedDate {
    initializeDateFormatting('es_ES', null); 
    final date = fechaConsulta.toDate();
    return DateFormat('d \'de\' MMMM, y', 'es_ES').format(date);
  }
  
  Map<String, dynamic> toMap() {
    return {
      'hospital': hospitalName, // <--- CAMBIO: Pasamos el nombre
      'specialty': especialidad,
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