# MedicalHand

Aplicación móvil para facilitar la programación, gestión y recordatorio de citas médicas, con enfoque en accesibilidad, transparencia y eficiencia en la atención médica.

---

## 📋 Descripción

MedicalHand es una app desarrollada en **Flutter** con **Firebase** como backend, diseñada para pacientes, familiares y cuidadores que buscan una experiencia de atención médica más ágil, confiable y transparente. La aplicación permite:

- Programar y gestionar citas médicas fácilmente.  
- Acceso al historial clínico básico.  
- Notificaciones de recordatorios para citas próximas (24h / 48h).  
- Perfil de usuario personalizado.  
- Registro y autenticación segura.  
- Sistema de filas virtuales para la atención. 

El público objetivo incluye:  
- Pacientes con poco tiempo disponible.  
- Familias y cuidadores con múltiples dependientes.  
- Pacientes crónicos que requieren seguimiento continuo.  
- Adultos mayores, que pueden tener barreras digitales o de movilidad.

---

## 🛠 Funcionalidades principales

| Funcionalidad | Descripción |
|---------------|-------------|
| Programación de citas | Selección de especialidad, centro u hospital, fecha y hora. |
| Gestión de citas | Ver, modificar o cancelar citas confirmadas. |
| Historial clínico básico | Ver diagnósticos, citas pasadas y tratamientos registrados. |
| Perfil de usuario | Datos personales, información de contacto, preferencia de centro/tutor. |
| Recordatorios | Notificaciones automáticas de cita (24h / 48h antes). |
| Filas virtuales | Permite “poner en fila” o cola virtual para atención administrativa. |
| Registro / Login | Email/password, Google Sign-In, Firebase Auth. |
| Almacenamiento de archivos / imágenes | Subir fotos de documentos, imágenes pertinentes. |
| Conectividad | Aviso si no hay internet, manejo básico de estado de conexión. |

---

## 🧪 Requisitos técnicos

- **Lenguaje / Framework**: Dart / Flutter (versión 3.35.3)  
- **Backend / servicios**: Firebase (Auth, Firestore, Storage, Messaging, App Check,Functions)  
- **Dependencias principales**:

  ```yaml
  dependencies:
    flutter:
      sdk: flutter
    cupertino_icons: ^1.0.8
    provider: ^6.1.2
    get_it: ^7.6.7
    firebase_core: ^4.0.0
    cloud_firestore: ^6.0.0
    firebase_auth: ^6.0.1
    google_sign_in: ^6.3.0
    lottie: ^3.3.1
    flutter_native_splash: ^2.4.6
    hugeicons: ^0.0.11
    image_picker: ^1.2.0
    connectivity_plus: ^6.1.5
    intl: ^0.20.2
    shimmer: ^3.0.0
    flutter_image_compress: ^2.4.0
    path_provider: ^2.1.5
    path: ^1.9.1
    firebase_storage: ^13.0.1
    firebase_app_check: ^0.4.0+1
    firebase_messaging: ^16.0.1
    shared_preferences: ^2.5.3
    flutter_local_notifications: ^19.4.2
    google_fonts: ^6.3.1

  dev_dependencies:
    flutter_test:
      sdk: flutter
    flutter_lints: ^5.0.0
    flutter_launcher_icons: ^0.14.4
  ```

- **Flutter SDK**: 3.35.3  
- **Dart**: versión compatible con Flutter 3.35.3.

---

## 🚀 Instalación

Aquí un paso a paso para configurar el proyecto localmente:

1. Instala el SDK de Flutter (versión ≥ 3.35.3) y Dart, en tu máquina.
    Una vez instalado, verifica que la versión sea compatible con este proyecto (3.35.3 o superior) ejecutando el siguiente comando en tu terminal:
   -flutter --version
    También, ejecuta el flutter doctor para asegurarte de que tu entorno de desarrollo esté configurado correctamente:
   -flutter doctor
2. Clona este repositorio:
   ```bash
   git clone <https://github.com/ogarcore/MedicalHand>
   cd medicalhand
   ```
3. Instala las dependencias:
   ```bash
   flutter pub get
   ```
4. Configura Firebase:
   - Crea un proyecto en la consola de Firebase.  
   - Agrega las credenciales para Android / iOS (google-services.json / GoogleService-Info.plist).  
   - Habilita los servicios necesarios: **Firestore**, **Authentication**, **Storage**, **Messaging**, **App Check**, **Functions** .  
   - Configura reglas de seguridad apropiadas.  
5. Si usas notificaciones, asegúrate de configurar permisos para iOS / Android (Firebase Messaging, Firebase Functions, notificaciones locales).  
6. Para ejecutar en emulador o dispositivo:
   ```bash
   flutter run
   ```

---

## 📱 Uso

- Al abrir la app, el usuario registra su cuenta (o inicia sesión), completa perfil.  
- Luego puede realizar una cita, seleccionar ubicacion/hospital/descripcion para agendar cita.  
- Recibe notificaciones de recordatorio 24h / 48h antes.  
- Puede ver historial clínico, reprogramar / cancelar citas.  
- Filas virtuales: ver cuántos pacientes están antes que el usuario.  

---

## 🧼 Estructura del proyecto

```text
android/
assets/
ios/
functions/
/lib
  ├── app/
  ├── data/
  ├── view/
  ├── view_model/
    firebase_options.dart
    main.dart
pubspec.yaml
README.md
```

---

## 💡 Buenas prácticas y posibles mejoras

- Manejador de errores robusto, con fallback si no hay conexión.  
- Internacionalización (i18n) para múltiples idiomas.  
- Accesibilidad: diseño para personas con limitaciones visuales / motoras.  
- Mejora de UI/UX para adultos mayores.  
- Versionamiento del backend, ambientes de desarrollo / producción.  

---

## ℹ️ Licencia

Este proyecto está bajo la licencia **MIT**. Puedes usarlo y adaptarlo libremente, aunque no ofrezco garantía de ningún tipo.

---

## 🤝 Contribuciones

Si quieres ayudar:  

1. Haz un fork del repositorio.  
2. Crea una rama nueva (`feature/nombre`, `bugfix/nombre`).  
3. Haz los cambios, asegúrate de que todo funcione.  
4. Envía un Pull Request describiendo qué mejoras has hecho.  

---

## 🚧 Información adicional

- Si haces cambio en esquemas de datos en Firestore, asegúrate de migrar o documentar esos cambios.  
- Verifica las reglas de seguridad Firestore antes de desplegar a producción.  
- Usa `flutter analyze` / `flutter format` para mantener el código limpio.  

---

## 🎯 Créditos

- Desarrollado por: *Alter Default*  
