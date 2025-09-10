import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:p_hn25/data/models/user_model.dart';

class FamilyViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<UserModel>> getFamilyMembers() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('usuarios_movil')
        .where('managedBy', isEqualTo: currentUser.uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserModel.fromFirestore(doc))
              .toList();
        });
  }

  // CAMBIO: Nuevo método para añadir un familiar
  Future<bool> addFamilyMember(UserModel newMember) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final docRef = _firestore.collection('usuarios_movil').doc();

      final memberWithManagement = UserModel(
        uid: docRef.id,
        email: '',
        firstName: newMember.firstName,
        lastName: newMember.lastName,
        sex: newMember.sex,
        idNumber: newMember.idNumber,
        dateOfBirth: newMember.dateOfBirth,
        phoneNumber: newMember.phoneNumber,
        address: newMember.address,
        medicalInfo: newMember.medicalInfo,
        isTutor: false,
        managedBy: currentUser.uid,
      );

      await docRef.set(memberWithManagement.toMap());
      return true;
    } catch (e) {
      print("Error al añadir familiar: $e");
      return false;
    }
  }

  // CAMBIO: Nuevo método para eliminar un familiar
  Future<bool> deleteFamilyMember(String memberId) async {
    try {
      await _firestore.collection('usuarios_movil').doc(memberId).delete();
      return true;
    } catch (e) {
      print("Error al eliminar familiar: $e");
      return false;
    }
  }

  void clearData() {}
}
