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

  void clearUser() {
    _currentUser = null;
    _activeProfile = null;
    notifyListeners();
  }
}
