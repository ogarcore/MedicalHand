// lib/data/models/user_model.dart
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
  final bool isTutor;
  final String? managedBy;
  final Map<String, dynamic>? verification;
  final Timestamp? createdAt;

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
    required this.isTutor,
    this.managedBy,
    this.verification,
    this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      firstName: data['personalInfo']?['firstName'] ?? '',
      lastName: data['personalInfo']?['lastName'] ?? '',
      sex: data['personalInfo']?['sex'] ?? '',
      idNumber: data['personalInfo']?['idNumber'] ?? '',
      dateOfBirth: data['personalInfo']?['dateOfBirth'] ?? Timestamp.now(),
      phoneNumber: data['contactInfo']?['phoneNumber'] ?? '',
      address: data['contactInfo']?['address'] ?? '',
      emergencyContact: data['contactInfo']?['emergencyContact'] != null
          ? Map<String, String>.from(data['contactInfo']!['emergencyContact'])
          : null,
      medicalInfo: data['medicalInfo'],
      isTutor: data['isTutor'] ?? false,
      managedBy: data['managedBy'],
      verification: data['verification'],
      createdAt: data['createdAt'],
    );
  }

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
      'isTutor': isTutor,
      'managedBy': managedBy,
      'verification': verification,
    };
  }
}
