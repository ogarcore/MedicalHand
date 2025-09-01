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

  /// Busca en Firestore los datos del usuario actualmente autenticado y los carga en el ViewModel.
  /// Este método se debe llamar DESPUÉS de un inicio de sesión exitoso.
  Future<void> fetchCurrentUser() async {
    // Obtenemos el usuario de Firebase Auth
    final user = _auth.currentUser;
    if (user == null) {
      return; // No hay nadie logueado, no hacemos nada.
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Usamos el UID del usuario para buscar su documento en nuestra colección 'usuarios_movil'
      final userDoc = await _firestore.collection('usuarios_movil').doc(user.uid).get();

      if (userDoc.exists) {
        // Si el documento existe, lo convertimos a nuestro objeto UserModel y lo guardamos.
        _currentUser = UserModel.fromFirestore(userDoc);
      } else {
        // Opcional: Manejar el caso raro de que un usuario esté en Auth pero no en Firestore.
        print("Error: No se encontró el documento del usuario en Firestore.");
        _currentUser = null;
      }
    } catch (e) {
      print("Ocurrió un error al cargar los datos del usuario: $e");
      _currentUser = null;
    } finally {
      _isLoading = false;
      // Notificamos a todos los widgets que escuchan que hemos terminado de cargar.
      notifyListeners();
    }
  }

  /// Limpia los datos del usuario al cerrar sesión.
  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}