const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.notificarCitaConfirmada = functions
    .region("us-central1")
    .runWith({ memory: "512MB", timeoutSeconds: 30 })
    .firestore.document("citas/{citaId}")
    .onUpdate(async (change, context) => {
      console.log(`Función activada para la cita: ${context.params.citaId}`);
      const datosAntes = change.before.data();
      const datosDespues = change.after.data();

      if (datosAntes.status !== "confirmada" && datosDespues.status === "confirmada") {
        const patientId = datosDespues.uid; // ID del paciente (puede ser el tutor o un familiar)
        console.log(`Cita confirmada para el paciente: ${patientId}`);

        // --- INICIO DE LA NUEVA LÓGICA ---
        const patientDoc = await admin.firestore().collection("usuarios_movil").doc(patientId).get();
        if (!patientDoc.exists) {
          console.error(`Error: No se encontró al paciente ${patientId}`);
          return null;
        }

        const patientData = patientDoc.data();
        // Determinamos a quién enviarle la notificación.
        // Si el paciente es gestionado por alguien (managedBy), ese es el tutor.
        // Si no, el paciente es su propio tutor.
        const tutorId = patientData.managedBy || patientId;
        console.log(`El tutor responsable es: ${tutorId}`);

        // Buscamos el documento del tutor para obtener su token FCM.
        const tutorDoc = await admin.firestore().collection("usuarios_movil").doc(tutorId).get();
        if (!tutorDoc.exists) {
          console.error(`Error: No se encontró al tutor ${tutorId}`);
          return null;
        }

        const fcmToken = tutorDoc.data().fcmToken;
        if (!fcmToken) {
          console.warn(`El tutor ${tutorId} no tiene un token FCM válido.`);
          return null;
        }
        
        // Creamos un título personalizado si es para un familiar
        const notificationTitle = tutorId === patientId 
            ? "¡Tu Cita ha sido Confirmada!" 
            : `¡Cita Confirmada para ${patientData.personalInfo.firstName}!`;

        const payload = {
          notification: {
            title: notificationTitle,
            body: `La cita de ${datosDespues.specialty || "General"} en ${datosDespues.hospital} ha sido agendada.`,
          },
          // Esta es la "etiqueta" con el ID del paciente para que la app sepa a quién mostrar
          data: {
            "patientProfileId": patientId,
          },
          token: fcmToken,
        };
        // --- FIN DE LA NUEVA LÓGICA ---

        try {
          console.log(`Enviando notificación al token del tutor: ${fcmToken}`);
          await admin.messaging().send(payload);
          console.log("Notificación enviada con éxito.");
        } catch (error) {
          console.error("Error CRÍTICO al enviar la notificación:", error);
        }
      }
      return null;
    });