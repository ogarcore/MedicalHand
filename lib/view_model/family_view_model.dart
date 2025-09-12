// lib/view_model/family_view_model.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:p_hn25/data/models/user_model.dart';
import 'package:p_hn25/data/network/firebase_storage_service.dart';

class FamilyViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorageService _storageService = FirebaseStorageService();

  // Controladores para el formulario
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final idController = TextEditingController();
  final birthDateController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  // CAMBIO: Añadidos los controladores para la información médica
  final bloodTypeController = TextEditingController();
  final allergiesController = TextEditingController();

  String? selectedKinship;

  // Archivos de imagen para verificación
  XFile? idFrontImage;
  XFile? idBackImage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void updateSelectedKinship(String? newValue) {
    selectedKinship = newValue;
    notifyListeners();
  }

  void setIdFrontImage(XFile? file) {
    idFrontImage = file;
    notifyListeners();
  }

  void setIdBackImage(XFile? file) {
    idBackImage = file;
    notifyListeners();
  }

  Future<bool> saveFamilyMember(BuildContext context) async {
    setLoading(true);
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      setLoading(false);
      return false;
    }

    try {
      final dateParts = birthDateController.text.split('/');
      final birthDate = DateTime(
        int.parse(dateParts[2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
      );

      Map<String, String> imageUrls = {};
      final docId = _firestore.collection('usuarios_movil').doc().id;
      final newMemberDoc = _firestore.collection('usuarios_movil').doc();

      if (idFrontImage != null) {
        final path = 'family/${newMemberDoc.id}/id_front.jpg';
        imageUrls['idFrontUrl'] = await _storageService.uploadFile(
          currentUser.uid,
          path,
          File(idFrontImage!.path),
        );
      }
      if (idBackImage != null) {
        final path = 'family/${newMemberDoc.id}/id_back.jpg';
        imageUrls['idBackUrl'] = await _storageService.uploadFile(
          currentUser.uid,
          path,
          File(idBackImage!.path),
        );
      }

      final newMember = UserModel(
        uid: docId,
        email: '',
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        idNumber: idController.text.trim(),
        dateOfBirth: Timestamp.fromDate(birthDate),
        sex: 'No especificado',
        phoneNumber: phoneController.text.trim(),
        address: addressController.text.trim(),
        // CAMBIO: Se añade la información médica al mapa
        medicalInfo: {
          'kinship': selectedKinship,
          'bloodType': bloodTypeController.text.trim(),
          'knownAllergies': allergiesController.text.trim(),
          'chronicDiseases': [],
        },
        verification: {
          'status': 'verified_by_tutor',
          'idFrontUrl': imageUrls['idFrontUrl'] ?? '',
          'idBackUrl': imageUrls['idBackUrl'] ?? '',
        },
        isTutor: false,
        managedBy: currentUser.uid,
      );

      await _firestore
          .collection('usuarios_movil')
          .doc(docId)
          .set(newMember.toMap());
      clearControllers();
      setLoading(false);
      return true;
    } catch (e) {
      print("Error al guardar familiar: $e");
      setLoading(false);
      return false;
    }
  }

  void clearControllers() {
    firstNameController.clear();
    lastNameController.clear();
    idController.clear();
    birthDateController.clear();
    phoneController.clear();
    addressController.clear();
    // CAMBIO: Se limpian los nuevos controladores
    bloodTypeController.clear();
    allergiesController.clear();
    selectedKinship = null;
    idFrontImage = null;
    idBackImage = null;
    // Notificamos para que el dropdown se resetee en la UI si es necesario
    notifyListeners();
  }

  Stream<List<UserModel>> getFamilyMembers() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('usuarios_movil')
        .where('managedBy', isEqualTo: currentUser.uid)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList(),
        );
  }

  Future<bool> deleteFamilyMember(String memberId) async {
    try {
      await _firestore.collection('usuarios_movil').doc(memberId).delete();
      return true;
    } catch (e) {
      print("Error al eliminar familiar: $e");
      return false;
    }
  }

  void clearData() {
    // Método para la limpieza al cerrar sesión
  }
}
