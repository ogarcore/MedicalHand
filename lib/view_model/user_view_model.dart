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

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchCurrentUser() async {
    // Obtenemos el usuario de Firebase Auth
    final user = _auth.currentUser;
    if (user == null) {
      return; // No hay nadie logueado, no hacemos nada.
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
      } else {
        print("Error: No se encontró el documento del usuario en Firestore.");
        _currentUser = null;
      }
    } catch (e) {
      print("Ocurrió un error al cargar los datos del usuario: $e");
      _currentUser = null;
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
      // Después de actualizar, volvemos a cargar los datos para refrescar la UI
      await fetchCurrentUser();
      return true;
    } catch (e) {
      print("Error al actualizar el perfil: $e");
      return false;
    }
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}
