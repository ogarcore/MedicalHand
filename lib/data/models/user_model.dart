import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String sex;
  final String idNumber;
  final Timestamp dateOfBirth;
  final String phoneNumber;
  final String address;
  final Map<String, String>? emergencyContact;
  final Map<String, dynamic>? medicalInfo;

  UserModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.sex,
    required this.idNumber,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.address,
    this.emergencyContact,
    this.medicalInfo,
  });

  // Método para convertir nuestra clase a un mapa que Firestore entienda
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'personalInfo': {
        'firstName': firstName,
        'lastName': lastName,
        'sex': sex,
        'idNumber': idNumber,
        'dateOfBirth': dateOfBirth,
      },
      'contactInfo': {
        'phoneNumber': phoneNumber,
        'address': address,
        'emergencyContact': emergencyContact,
      },
      'medicalInfo': medicalInfo,
    };
  }
}