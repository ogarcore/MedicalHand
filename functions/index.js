const {onDocumentCreated, onDocumentUpdated} = require("firebase-functions/v2/firestore");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, Timestamp} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const {logger} = require("firebase-functions");

// Inicializa Firebase Admin
initializeApp();

// Función Reutilizable para Enviar Notificaciones
async function sendNotificationToTutor(patientId, notificationPayload, dataPayload = {}) {
  const patientDoc = await getFirestore().collection("usuarios_movil").doc(patientId).get();
  if (!patientDoc.exists) {
    logger.error(`Error: No se encontró al paciente ${patientId}`);
    return;
  }
  
  const patientData = patientDoc.data();
  const tutorId = patientData.managedBy || patientId;

  const tutorDoc = await getFirestore().collection("usuarios_movil").doc(tutorId).get();
  if (!tutorDoc.exists) {
    logger.error(`Error: No se encontró al tutor ${tutorId}`);
    return;
  }

  const fcmToken = tutorDoc.data().fcmToken;
  if (!fcmToken) {
    logger.warn(`El tutor ${tutorId} no tiene un token FCM.`);
    return;
  }

  dataPayload.patientProfileId = patientId;
  dataPayload.click_action = "FLUTTER_NOTIFICATION_CLICK";

  const payload = {
    notification: notificationPayload,
    data: dataPayload,
    token: fcmToken,
  };

  try {
    logger.info(`Enviando notificación al tutor ${tutorId} para el paciente ${patientId}`);
    await getMessaging().send(payload);
    logger.info("Notificación enviada con éxito.");
  } catch (error) {
    logger.error(`Error al enviar notificación para ${tutorId}:`, error);
  }
}


// Notificaciones Transaccionales 

// Notificación: Solicitud de Cita Enviada
exports.notificarSolicitudRecibida = onDocumentCreated("citas/{citaId}", async (event) => {
  const cita = event.data.data();
  
  const notification = {
    title: "¡Solicitud Enviada!",
    body: `Hemos enviado tu petición para ${cita.specialty} al ${cita.hospital}. Te avisaremos cuando sea asignada.`,
  };

  const data = {type: "solicitud_recibida"};

  await sendNotificationToTutor(cita.uid, notification, data);
});

// Notificación: Cita Asignada o Reprogramada
exports.notificarCitaActualizada = onDocumentUpdated("citas/{citaId}", async (event) => {
  const datosAntes = event.data.before.data();
  const datosDespues = event.data.after.data();

  if (datosAntes.status !== "confirmada" && datosDespues.status === "confirmada") {
    const pacienteDoc = await getFirestore().collection("usuarios_movil").doc(datosDespues.uid).get();
    if (!pacienteDoc.exists) return;
    
    const fecha = new Date(datosDespues.assignedDate.seconds * 1000).toLocaleString("es-NI", {
        timeZone: "America/Managua",
        month: "long", day: "numeric", hour: "numeric", minute: "2-digit", hour12: true,
    });
    
    const title = datosAntes.status === "pendiente_reprogramacion" ? "¡Cita Reprogramada!" : "¡Cita Asignada!";
    
    let notification = {
        title: title,
        body: `Tu cita de ${datosDespues.specialty} en el ${datosDespues.hospital} ha sido confirmada para el ${fecha}.`,
    };

    const patientName = pacienteDoc.data().personalInfo.firstName;
    if (datosDespues.uid !== (pacienteDoc.data().managedBy || datosDespues.uid)) {
        notification.title = `${notification.title.split('!')[0]} para ${patientName}!`;
    }

    const data = {type: "cita_confirmada"};

    await sendNotificationToTutor(datosDespues.uid, notification, data);
  }
});


// Notificación de Recordatorio
exports.enviarRecordatorios = onSchedule({
  schedule: "every 15 minutes", 
  timeZone: "America/Managua",
}, async (event) => {
  logger.info("Ejecutando la función de recordatorios...");
  const db = getFirestore();
  const now = Timestamp.now();

  // Lógica para recordatorios de 48 horas
  const a48HorasInicio = Timestamp.fromMillis(now.toMillis() + (48 * 60 - 15) * 60 * 1000); 
  const a48HorasFin = Timestamp.fromMillis(now.toMillis() + 48 * 60 * 60 * 1000); 

  const citas48h = await db.collection("citas")
      .where("status", "==", "confirmada")
      .where("reminder48hSent", "==", false)
      .where("assignedDate", ">=", a48HorasInicio)
      .where("assignedDate", "<=", a48HorasFin)
      .get();

  const promises48h = citas48h.docs.map(async (doc) => {
    const cita = doc.data();
    const dia = new Date(cita.assignedDate.seconds * 1000).toLocaleString("es-NI", { timeZone: "America/Managua", weekday: "long", day: "numeric", month: "long" });
    const notification = {
      title: "Recordatorio Próximo",
      body: `Tienes una cita de ${cita.specialty} programada en ${cita.hospital} para pasado mañana, ${dia}.`,
    };
    const data = {type: "recordatorio"};
    
    await sendNotificationToTutor(cita.uid, notification, data);
    return doc.ref.update({ reminder48hSent: true });
  });

  // Lógica para recordatorios de 24 horas
  const a24HorasInicio = Timestamp.fromMillis(now.toMillis() + (24 * 60 - 15) * 60 * 1000); 
  const a24HorasFin = Timestamp.fromMillis(now.toMillis() + 24 * 60 * 60 * 1000); 

  const citas24h = await db.collection("citas")
      .where("status", "==", "confirmada")
      .where("reminder24hSent", "==", false)
      .where("assignedDate", ">=", a24HorasInicio)
      .where("assignedDate", "<=", a24HorasFin)
      .get();
      
  const promises24h = citas24h.docs.map(async (doc) => {
    const cita = doc.data();
    const fecha = new Date(cita.assignedDate.seconds * 1000).toLocaleString("es-NI", { timeZone: "America/Managua", hour: "numeric", minute: "2-digit", hour12: true });
    const notification = {
      title: "Recordatorio: Tu Cita es Mañana",
      body: `No olvides tu cita de ${cita.specialty} mañana a las ${fecha} en ${cita.hospital}.`,
    };
  
    const data = {type: "recordatorio"};
    
    await sendNotificationToTutor(cita.uid, notification, data);
    return doc.ref.update({ reminder24hSent: true });
  });

  await Promise.all([...promises48h, ...promises24h]);
  logger.info(`Proceso de recordatorios finalizado. Se encontraron ${citas48h.size} (48h) y ${citas24h.size} (24h) citas.`);
});