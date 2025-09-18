const {onDocumentCreated, onDocumentUpdated} = require("firebase-functions/v2/firestore");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, Timestamp} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const {logger} = require("firebase-functions");

initializeApp();

// --- Función Reutilizable para Enviar Notificaciones ---
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

// --- Notificaciones Transaccionales ---

// 1. Notificación: Solicitud de Cita Enviada
exports.notificarSolicitudRecibida = onDocumentCreated("citas/{citaId}", async (event) => {
  const cita = event.data.data();
  
  const notification = {
    title: "✅ ¡Solicitud Recibida!",
    body: `Hemos enviado tu petición para ${cita.specialty} al ${cita.hospital}. Te avisaremos cuando sea asignada.`,
  };

  await sendNotificationToTutor(cita.uid, notification);
});

// 2. Notificación: Cita Asignada o Reprogramada
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
    
    const title = datosAntes.status === "pendiente_reprogramacion"
        ? "🗓️ ¡Cita Reprogramada!"
        : "🗓️ ¡Cita Asignada!";

    let notification = {
        title: title,
        body: `Tu cita de ${datosDespues.specialty} ha sido confirmada para el ${fecha}.`,
    };

    const patientName = pacienteDoc.data().personalInfo.firstName;
    if (datosDespues.uid !== (pacienteDoc.data().managedBy || datosDespues.uid)) {
        notification.title = `${notification.title.split('!')[0]} para ${patientName}!`;
    }

    await sendNotificationToTutor(datosDespues.uid, notification);
  }
});


// --- Notificaciones de Recordatorio ---

// 3. Notificación: Recordatorio de Cita
exports.enviarRecordatoriosDeCitas = onSchedule("every 60 minutes", async (event) => {
  logger.info("Ejecutando la función de recordatorios de citas...");

  const now = Timestamp.now();
  const a24Horas = Timestamp.fromMillis(now.toMillis() + 24 * 60 * 60 * 1000);
  const a48Horas = Timestamp.fromMillis(now.toMillis() + 48 * 60 * 60 * 1000);

  const citasProximas = await getFirestore().collection("citas")
      .where("status", "==", "confirmada")
      .where("assignedDate", ">=", a24Horas)
      .where("assignedDate", "<", a48Horas)
      .get();

  if (citasProximas.empty) {
    logger.info("No hay citas para enviar recordatorios de 24h.");
    return;
  }
  
  const promises = citasProximas.docs.map(doc => {
    const cita = doc.data();
    const fecha = new Date(cita.assignedDate.seconds * 1000).toLocaleString("es-NI", {
        timeZone: "America/Managua", 
        weekday: "long", hour: "numeric", minute: "2-digit", hour12: true,
    });

    const notification = {
        title: "⏰ Recordatorio de Cita",
        body: `No olvides tu cita de ${cita.specialty} mañana ${fecha} en ${cita.hospital}.`,
    };
    
    return sendNotificationToTutor(cita.uid, notification);
  });

  await Promise.all(promises);
});