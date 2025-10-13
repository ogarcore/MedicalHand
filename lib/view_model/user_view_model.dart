// lib/view_model/user_view_model.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:p_hn25/data/models/user_model.dart';

class UserViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  UserModel? _activeProfile;
  UserModel? get activeProfile => _activeProfile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final userDoc = await _firestore
          .collection('usuarios_movil')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        _currentUser = UserModel.fromFirestore(userDoc);
        _activeProfile = _currentUser;
      }
    } catch (e) {
      _currentUser = null;
      _activeProfile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUserProfile(Map<String, dynamic> updatedData) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      await _firestore
          .collection('usuarios_movil')
          .doc(user.uid)
          .update(updatedData);
      await fetchCurrentUser();
      return true;
    } catch (e) {
      print("Error al actualizar el perfil: $e");
      return false;
    }
  }

  Future<void> changeActiveProfileById(String profileId) async {
    // Si el perfil solicitado ya es el activo, no hacemos nada.
    if (_activeProfile?.uid == profileId) return;

    // Si el perfil solicitado es el del tutor, lo cambiamos directamente.
    if (_currentUser?.uid == profileId) {
      _activeProfile = _currentUser;
      notifyListeners();
      return;
    }

    // Si es otro (un familiar), lo buscamos en Firestore.
    try {
      final userDoc = await _firestore
          .collection('usuarios_movil')
          .doc(profileId)
          .get();
      if (userDoc.exists) {
        _activeProfile = UserModel.fromFirestore(userDoc);
        notifyListeners();
      }
    } catch (e) {
      print("Error al cambiar al perfil del familiar: $e");
    }
  }

Future<bool> updateEmergencyContact(String name, String phone) async {
  final user = _auth.currentUser;
  if (user == null) {
    print("Error: Usuario no autenticado.");
    return false;
  }

  try {

    final String emergencyContactPath = 'contactInfo.emergencyContact';

    // 2. Se crea el mapa únicamente con la nueva información.
    final Map<String, dynamic> newEmergencyContactData = {
      'name': name,
      'phone': phone,
    };

    // 3. Se ejecuta la actualización directa en Firestore sobre el campo específico.
    // Firestore se encarga de encontrar la ruta y actualizar solo esa parte.
    await _firestore
        .collection('usuarios_movil')
        .doc(user.uid)
        .update({emergencyContactPath: newEmergencyContactData});

    // 4. Una vez la base de datos está actualizada, refrescamos los datos locales del usuario.
    await fetchCurrentUser();

    return true;
  } catch (e) {
    print("Error al actualizar contacto de emergencia: $e");
    return false;
  }
}


  Future<void> saveFcmToken(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('usuarios_movil').doc(user.uid).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
    } catch (e) {}
  }

  void changeActiveProfile(UserModel newProfile) {
    _activeProfile = newProfile;
    notifyListeners();
  }

  Future<void> updateNotificationPreference(String key, bool value) async {
    if (currentUser == null) return;

    // Actualiza el modelo local para que la UI reaccione inmediatamente
    currentUser!.notificationPreferences?[key] = value;
    notifyListeners();

    try {
      final userRef = _firestore
          .collection('usuarios_movil')
          .doc(currentUser!.uid);
      await userRef.update({'notificationPreferences.$key': value});
    } catch (e) {
      currentUser!.notificationPreferences?[key] = !value;
      notifyListeners();
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
  final user = _auth.currentUser;
  if (user == null || user.email == null) return false;

  try {
    _isLoading = true;
    notifyListeners();
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);

    print("Contraseña actualizada correctamente.");
    return true;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'wrong-password') {
      print('La contraseña actual es incorrecta.');
    } else if (e.code == 'requires-recent-login') {
      print('El usuario debe iniciar sesión nuevamente antes de cambiar la contraseña.');
    } else {
      print('Error de FirebaseAuth al cambiar contraseña: ${e.code}');
    }
    return false;
  } catch (e) {
    print("Error al cambiar la contraseña: $e");
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}


  Future<bool> deleteAccount() async {
  final user = _auth.currentUser;
  if (user == null) return false;

  try {
    _isLoading = true;
    notifyListeners();
    await _firestore.collection('usuarios_movil').doc(user.uid).update({
      'cuenta_eliminada': true,
    });
    await user.delete();
    clearUser();

    return true;
  } on FirebaseAuthException catch (e) {
    print('Error de autenticación al eliminar cuenta: $e');
    return false;
  } catch (e) {
    print('Error al eliminar cuenta: $e');
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}


Future<bool> reauthenticate(String email, String password) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final credential = EmailAuthProvider.credential(email: email, password: password);
    await user.reauthenticateWithCredential(credential);

    print('Usuario reautenticado correctamente');
    return true;
  } catch (e) {
    print('Error al reautenticar: $e');
    return false;
  }
}


  void clearUser() {
    _currentUser = null;
    _activeProfile = null;
    notifyListeners();
  }
}
