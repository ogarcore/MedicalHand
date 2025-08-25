import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/network/firebase_auth_service.dart';
import '../data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();

  // Controladores para todos los campos del registro
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emergencyNameController = TextEditingController();
  final TextEditingController emergencyPhoneController =
      TextEditingController();
  final TextEditingController bloodTypeController = TextEditingController();
  final TextEditingController allergiesController = TextEditingController();

  String? selectedSex;
  final Set<String> selectedDiseases = {};

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void updateSelectedSex(String? newValue) {
    selectedSex = newValue;
    notifyListeners();
  }

  void updateSelectedDiseases(String disease, bool isSelected) {
    if (isSelected) {
      selectedDiseases.add(disease);
    } else {
      selectedDiseases.remove(disease);
    }
    notifyListeners();
  }

  Future<String?> signInWithGoogleFlow() async {
    setLoading(true);
    setErrorMessage(null);

    final User? user = await _authService.signInWithGoogle();

    if (user == null) {
      setErrorMessage("No se pudo iniciar sesión con Google.");
      setLoading(false);
      return null;
    }

    // El "Portero": Verificamos si el usuario ya tiene datos en nuestra base de datos
    final bool userExists = await _authService.doesUserExist(user.uid);

    if (userExists) {
      await _authService.signOutFromGoogle();
      setLoading(false);
      return 'EXIST';
    }  else {
      emailController.text = user.email ?? '';
      final nameParts = user.displayName?.split(' ') ?? [''];
      nameController.text = nameParts.first;
      if (nameParts.length > 1) {
        lastNameController.text = nameParts.sublist(1).join(' ');
      }

      setLoading(false);
      return 'REGISTER_STEP_2';
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    clearControllers();
  }

  Future<void> cancelGoogleRegistration() async {
    await _authService.signOutFromGoogle();
    clearControllers();
  }

  Future<String?> finalizeRegistration() async {
    setLoading(true);
    setErrorMessage(null);

    User? user = _authService.getCurrentUser();

    // Si no hay usuario, es el flujo de correo y contraseña
    if (user == null) {
      if (passwordController.text != confirmPasswordController.text) {
        setErrorMessage("Las contraseñas no coinciden.");
        setLoading(false);
        return null;
      }
      user = await _authService.signUpWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );
    }

    if (user != null) {
      final dateParts = birthDateController.text.split('/');
      final dateOfBirth = Timestamp.fromDate(
        DateTime(
          int.parse(dateParts[2]),
          int.parse(dateParts[1]),
          int.parse(dateParts[0]),
        ),
      );

      final userModel = UserModel(
        uid: user.uid,
        email: emailController.text,
        firstName: nameController.text,
        lastName: lastNameController.text,
        sex: selectedSex ?? 'No especificado',
        idNumber: idController.text,
        dateOfBirth: dateOfBirth,
        phoneNumber: phoneController.text,
        address: addressController.text,
        emergencyContact: emergencyNameController.text.isNotEmpty
            ? {
                'name': emergencyNameController.text,
                'phoneNumber': emergencyPhoneController.text,
              }
            : null,
        medicalInfo: {
          'isComplete':
              bloodTypeController.text.isNotEmpty ||
              allergiesController.text.isNotEmpty ||
              selectedDiseases.isNotEmpty,
          'bloodType': bloodTypeController.text,
          'knownAllergies': allergiesController.text,
          'chronicDiseases': selectedDiseases.toList(),
        },
      );

      await _authService.saveUserData(userModel);
      setLoading(false);

      // Decidimos a dónde navegar basándonos en el proveedor de autenticación
      if (user.providerData.any((p) => p.providerId == 'password')) {
        return 'VERIFY'; // Flujo de correo, va a la pantalla de verificación
      } else {
        return 'SPLASH'; 
      }
    } else {
      setErrorMessage("No se pudo crear la cuenta. Inténtalo de nuevo.");
      setLoading(false);
      return null;
    }
  }
  void clearControllers() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
    lastNameController.clear();
    idController.clear();
    birthDateController.clear();
    phoneController.clear();
    addressController.clear();
    emergencyNameController.clear();
    emergencyPhoneController.clear();
    bloodTypeController.clear();
    allergiesController.clear();
    selectedSex = null;
    selectedDiseases.clear();
    notifyListeners();
  }
}
