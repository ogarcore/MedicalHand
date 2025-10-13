const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, Timestamp } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const { logger } = require("firebase-functions");

// Inicializa Firebase Admin
initializeApp();

async function sendNotificationToTutor(patientId, notificationPayload, dataPayload = {}, notificationType) {
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

  const tutorData = tutorDoc.data();

  const preferences = tutorData.notificationPreferences;
  if (preferences && preferences[notificationType] === false) {
    logger.info(`Notificación de tipo '${notificationType}' bloqueada para el tutor ${tutorId} según sus preferencias.`);
    return;
  }

  const fcmToken = tutorData.fcmToken;
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

exports.notificarSolicitudRecibida = onDocumentCreated("citas/{citaId}", async (event) => {
  const cita = event.data.data();
  const notification = {
    title: "¡Solicitud Enviada!",
    body: `Hemos enviado tu petición para ${cita.specialty} al ${cita.hospital}. Te avisaremos cuando sea asignada.`,
  };
  const data = { type: "solicitud_recibida" };
  await sendNotificationToTutor(cita.uid, notification, data, "requests");
});

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

    const data = { type: "cita_confirmada" };
    await sendNotificationToTutor(datosDespues.uid, notification, data, "changes");
  }
});

exports.enviarRecordatorios = onSchedule({
  schedule: "every 15 minutes",
  timeZone: "America/Managua",
}, async (event) => {
  logger.info("Ejecutando la función de recordatorios...");
  const db = getFirestore();
  const now = Timestamp.now();

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
    const data = { type: "recordatorio" };

    await sendNotificationToTutor(cita.uid, notification, data, "reminders");
    return doc.ref.update({ reminder48hSent: true });
  });

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

    const data = { type: "recordatorio" };

    await sendNotificationToTutor(cita.uid, notification, data, "reminders");
    return doc.ref.update({ reminder24hSent: true });
  });

  await Promise.all([...promises48h, ...promises24h]);
  logger.info(`Proceso de recordatorios finalizado. Se encontraron ${citas48h.size} (48h) y ${citas24h.size} (24h) citas.`);
});


async function procesarExamenes(event, datosAntes, datosDespues) {
  if (!datosDespues.examsRequested || datosDespues.examsRequested.length === 0) {
    return null;
  }

  const db = getFirestore();
  const examsAntes = datosAntes?.examsRequested || [];
  const examsDespues = datosDespues.examsRequested;
  const patientId = datosDespues.patient_uid;

  // Leemos el documento actual desde Firestore (versión más reciente)
  const consultaRef = db.collection("consultas").doc(event.params.consultaId);
  const consultaSnap = await consultaRef.get();
  const consultaData = consultaSnap.data();

  if (!consultaData) {
    logger.error(` No se encontró la consulta ${event.params.consultaId}`);
    return null;
  }

  const examsActualizados = [...consultaData.examsRequested]; // Copia actual del array

  for (let i = 0; i < examsDespues.length; i++) {
    const examenAntes = examsAntes[i];
    const examenDespues = examsDespues[i];
    if (!examenDespues) continue;

    const cambioACompletado =
      examenDespues.estado === "completado" &&
      (!examenAntes || examenAntes.estado !== "completado");

    const tieneResultados =
      examenDespues.resultados && examenDespues.resultados.length > 0;

    const yaNotificado = examenDespues.estado === "notificado";

    if (cambioACompletado && tieneResultados && !yaNotificado) {
      logger.info(` Resultado detectado para '${examenDespues.nombre}' en consulta ${event.params.consultaId}`);

      const patientDoc = await db.collection("usuarios_movil").doc(patientId).get();
      if (!patientDoc.exists) {
        logger.error(` Paciente ${patientId} no encontrado para notificar.`);
        continue;
      }

      const patientData = patientDoc.data();
      const patientName = patientData.personalInfo?.firstName || "el paciente";
      const tutorId = patientData.managedBy || patientId;

      let notificationBody = `Ya puedes ver los resultados de tu examen de ${examenDespues.nombre}.`;
      if (patientId !== tutorId) {
        notificationBody = `Resultados de ${examenDespues.nombre} listos para ${patientName}.`;
      }

      const notification = {
        title: "Resultados de Examen Disponibles ",
        body: notificationBody,
      };

      const data = {
        type: "resultado_disponible",
        consultaId: event.params.consultaId,
        examName: examenDespues.nombre,
      };

      try {
        await sendNotificationToTutor(patientId, notification, data, "results");

        // Modificar localmente el estado del examen a "notificado"
        examsActualizados[i] = {
          ...examsActualizados[i],
          estado: "notificado",
        };

        logger.info(` Examen '${examenDespues.nombre}' marcado como notificado en memoria.`);
      } catch (error) {
        logger.error(` Error notificando examen '${examenDespues.nombre}':`, error);
      }
    }
  }

  //  Actualizamos el documento completo, solo si hubo cambios
  await consultaRef.update({ examsRequested: examsActualizados });

  logger.info(` Consulta ${event.params.consultaId} actualizada sin pérdida de datos.`);
  return null;
}

//  Trigger cuando se CREA una consulta
exports.notificarResultadoExamenCreado = onDocumentCreated("consultas/{consultaId}", async (event) => {
  const datosDespues = event.data.data();

  try {
    await procesarExamenes(event, null, datosDespues);
  } catch (error) {
    logger.error(` Error procesando consulta creada ${event.params.consultaId}:`, error);
  }

  return null;
});

//  Trigger cuando se ACTUALIZA una consulta existente
exports.notificarResultadoExamenActualizado = onDocumentUpdated("consultas/{consultaId}", async (event) => {
  const datosAntes = event.data.before.data();
  const datosDespues = event.data.after.data();

  try {
    await procesarExamenes(event, datosAntes, datosDespues);
  } catch (error) {
    logger.error(` Error procesando actualización de consulta ${event.params.consultaId}:`, error);
  }

  return null;
});




exports.notificarAvanceDeFila = onDocumentUpdated("filas_virtuales/{queueId}", async (event) => {
  const beforeData = event.data.before.data();
  const afterData = event.data.after.data();

  if (beforeData.currentTurn === afterData.currentTurn) {
    logger.info(`Actualización en ${event.params.queueId} sin cambio de turno. No se envían notificaciones.`);
    return null;
  }

  const newTurn = afterData.currentTurn;
  const queueName = afterData.queueName || "la consulta";
  logger.info(`Cambio de turno detectado en la fila ${event.params.queueId}. Nuevo turno: ${newTurn}`);

  const turnToCall = newTurn;
  const turnToNotifyProximity = newTurn + 2;

  const db = getFirestore();
  const patientsRef = db.collection(`filas_virtuales/${event.params.queueId}/pacientes`);
  const promises = [];

  const patientToCallQuery = await patientsRef.where("turnNumber", "==", turnToCall).limit(1).get();
  if (!patientToCallQuery.empty) {
    const patientDoc = patientToCallQuery.docs[0];
    const patientData = patientDoc.data();

    if (patientData.patientStatus !== "llamado") {
      logger.info(`Preparando notificación de LLAMADA para el turno ${turnToCall}.`);

      const citaDoc = await db.collection("citas").doc(patientData.appointmentId).get();
      const clinicOffice = citaDoc.exists ? (citaDoc.data().clinicOffice || "la recepción") : "la recepción";
      const doctorName = citaDoc.exists ? (citaDoc.data().assignedDoctor || "El personal médico") : "El personal médico";

      const notification = {
        title: `¡Es tu turno!`,
        body: `Pasa al ${clinicOffice}. ${doctorName} te espera.`,
      };

      const data = { type: "queue_call" };

      promises.push(sendNotificationToTutor(patientDoc.id, notification, data, "queue_updates"));
      promises.push(patientDoc.ref.update({ patientStatus: "llamado" }));
    }
  }

  const patientToNotifyQuery = await patientsRef.where("turnNumber", "==", turnToNotifyProximity).limit(1).get();
  if (!patientToNotifyQuery.empty) {
    const patientDoc = patientToNotifyQuery.docs[0];
    const patientData = patientDoc.data();

    if (patientData.patientStatus === "esperando") {
      logger.info(`Preparando notificación de PROXIMIDAD para el turno ${turnToNotifyProximity}.`);

      const notification = {
        title: `¡Prepárate!`,
        body: `Faltan 2 turnos para tu consulta. Por favor, acércate a la sala de espera de ${queueName}.`,
      };

      const data = { type: "queue_proximity" };

      promises.push(sendNotificationToTutor(patientDoc.id, notification, data, "queue_updates"));
      promises.push(patientDoc.ref.update({ patientStatus: "proximidad_notificada" }));
    }
  }

  await Promise.all(promises);
  return null;
});
