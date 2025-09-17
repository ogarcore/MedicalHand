const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Cambiamos la región para optimizar la latencia y añadimos más memoria
exports.notificarCitaConfirmada = functions
    .region("us-central1") // Define una región específica
    .runWith({ memory: "512MB", timeoutSeconds: 30 }) // Asigna más recursos
    .firestore.document("citas/{citaId}")
    .onUpdate(async (change, context) => {
      console.log(`Función activada para la cita: ${context.params.citaId}`);

      const datosAntes = change.before.data();
      const datosDespues = change.after.data();

      // Condición de envío: solo si el estado cambia a 'confirmada'
      if (datosAntes.status !== "confirmada" && datosDespues.status === "confirmada") {
        const userId = datosDespues.uid;
        console.log(`La cita fue confirmada para el usuario: ${userId}`);

        const userDoc = await admin.firestore().collection("usuarios_movil").doc(userId).get();
        if (!userDoc.exists) {
          console.error(`Error: No se encontró al usuario ${userId}`);
          return null;
        }

        const fcmToken = userDoc.data().fcmToken;
        // Verificación clave: nos aseguramos de que el token exista y sea válido
        if (!fcmToken || typeof fcmToken !== "string" || fcmToken.length === 0) {
          console.warn(`El usuario ${userId} no tiene un token FCM válido.`);
          return null;
        }

        const payload = {
          notification: {
            title: "¡Tu Cita ha sido Confirmada!",
            body: `Tu cita de ${datosDespues.specialty || "General"} en ${datosDespues.hospital} ha sido agendada. ¡Revisa los detalles!`,
          },
          token: fcmToken,
        };

        try {
          console.log(`Intentando enviar notificación al token: ${fcmToken}`);
          await admin.messaging().send(payload);
          console.log(`Notificación enviada con éxito a ${userId}.`);
        } catch (error) {
          console.error("Error CRÍTICO al enviar la notificación:", error);
        }
      } else {
        console.log("La actualización no cumplió la condición para enviar notificación.");
      }
      return null;
    });