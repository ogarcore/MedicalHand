import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// --- Modelos anidados (Prescription no necesita cambios) ---
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

// =======================================================================
// 🔥 INICIO DE LA CORRECCIÓN: Modelo de Examen ajustado
// =======================================================================
class ExamRequested {
  final String nombre;
  final String estado;
  // 1. AÑADIR LA PROPIEDAD QUE FALTABA
  final List<dynamic> resultados;

  ExamRequested({
    required this.nombre,
    required this.estado,
    required this.resultados, // 2. AÑADIR AL CONSTRUCTOR
  });

  factory ExamRequested.fromMap(Map<String, dynamic> map) {
    return ExamRequested(
      nombre: map['nombre'] ?? 'N/A',
      estado: map['estado'] ?? 'solicitado',
      // 3. LEER LA LISTA DE RESULTADOS DESDE EL MAPA
      resultados: map['resultados'] as List<dynamic>? ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'estado': estado,
      // 4. INCLUIR LA LISTA DE RESULTADOS AL CONVERTIR A MAPA
      'resultados': resultados,
    };
  }
}
// =======================================================================
// 🔥 FIN DE LA CORRECCIÓN
// =======================================================================

// --- Modelo principal de la Consulta (sin cambios necesarios aquí) ---
class ConsultationModel {
  final String id;
  final String diagnostico;
  final Timestamp fechaConsulta;
  final String motivoConsulta;
  final String tratamiento;
  final String doctorName;
  final String especialidad;
  final String hospitalName;
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
    required this.hospitalName,
    required this.prescriptions,
    required this.examsRequested,
    required this.observaciones,
  });

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
      
      hospitalName: hospitalName,

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
      'hospital': hospitalName,
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