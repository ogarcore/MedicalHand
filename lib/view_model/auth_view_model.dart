import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:p_hn25/app/core/utils/validators.dart';
import 'package:p_hn25/data/network/notification_service.dart';
import 'package:p_hn25/view_model/appointment_view_model.dart';
import 'package:p_hn25/view_model/family_view_model.dart';
import 'package:p_hn25/view_model/notification_view_model.dart';
import '../data/network/firebase_storage_service.dart';
import '../data/network/firebase_auth_service.dart';
import '../data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'user_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService.instance;

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

  XFile? idFrontImage;
  XFile? idBackImage;

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

  void setIdFrontImage(XFile? file) {
    idFrontImage = file;
    notifyListeners();
  }

  void setIdBackImage(XFile? file) {
    idBackImage = file;
    notifyListeners();
  }

  Future<String?> signInWithGoogleLogin(BuildContext context) async {
    setLoading(true);
    setErrorMessage(null);

    try {
      final User? user = await _authService.signInWithGoogle();

      if (user == null) {
        setLoading(false);
        return null;
      }

      final provider = await _authService.getAuthProviderFromFirestore(
        user.email!,
      );

      switch (provider) {
        case 'google.com':
          final userViewModel = Provider.of<UserViewModel>(
            context,
            listen: false,
          );
          final notificationViewModel = Provider.of<NotificationViewModel>(
            context,
            listen: false,
          );

          final postLoginTasks = <Future>[
            userViewModel.fetchCurrentUser(),
            _notificationService.initNotifications(
              userViewModel: userViewModel,
              notificationViewModel: notificationViewModel,
            ),
          ];

          await Future.wait(postLoginTasks);

          final currentUser = userViewModel.currentUser;
          if (currentUser != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('last_active_user_id', currentUser.uid);
          }

          setLoading(false);
          return 'HOME';

        case 'password':
          setErrorMessage(
            'Ese correo ya está registrado con contraseña. Por favor, inicia sesión con tu contraseña.',
          );
          await _authService.signOut();
          setLoading(false);
          return null;

        default:
          setErrorMessage(
            'Este correo no se encuentra registrado. Por favor, crea una cuenta.',
          );
          await _authService.signOut();
          setLoading(false);
          return null;
      }
    } on FirebaseAuthException {
      setErrorMessage(
        'Ocurrió un error al intentar iniciar sesión con Google.',
      );
      setLoading(false);
      return null;
    }
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

    final bool userExists = await _authService.doesUserExist(user.uid);

    if (userExists) {
      await _authService.signOutFromGoogle();
      setLoading(false);
      return 'EXIST';
    } else {
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

  Future<void> signOut(BuildContext context) async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final appointmentViewModel = Provider.of<AppointmentViewModel>(
      context,
      listen: false,
    );
    final familyViewModel = Provider.of<FamilyViewModel>(
      context,
      listen: false,
    );
    final notificationViewModel = Provider.of<NotificationViewModel>(
      context,
      listen: false,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_active_user_id');

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('usuarios_movil').doc(user.uid).update({
          'fcmToken': FieldValue.delete(),
        });
        print('Token FCM borrado para el usuario: ${user.uid}');
      } catch (e) {
        print('Error al borrar el token FCM: $e');
      }
    }

    _notificationService.dispose();
    userViewModel.clearUser();
    appointmentViewModel.disposeListeners();
    familyViewModel.clearData();
    notificationViewModel.clearDataOnSignOut();
    clearControllers();

    await _authService.signOut();

    await FirebaseFirestore.instance.terminate();
    await FirebaseFirestore.instance.clearPersistence();
    await FirebaseFirestore.instance.enableNetwork();
  }

  Future<void> cancelGoogleRegistration() async {
    await _authService.signOutFromGoogle();
    clearControllers();
  }

  Future<String?> finalizeRegistration(BuildContext context) async {
    setLoading(true);
    setErrorMessage(null);

    User? user = _authService.getCurrentUser();

    // Esta parte se mantiene igual
    if (user == null) {
      if (passwordController.text != confirmPasswordController.text) {
        setErrorMessage("Las contraseñas no coinciden.");
        setLoading(false);
        return null;
      }
      try {
        user = await _authService.signUpWithEmailAndPassword(
          emailController.text,
          passwordController.text,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          setErrorMessage(
            'Este correo ya está registrado. Intenta iniciar sesión con Google.',
          );
        } else {
          setErrorMessage('No se pudo crear la cuenta. Inténtalo de nuevo.');
        }
        setLoading(false);
        return null;
      }
    }

    if (user != null) {
      final Map<String, String> imageUrls = {};

      try {
        final List<Future<String>> uploadTasks = [];
        final List<String> taskKeys = [];

        if (idFrontImage != null) {
          uploadTasks.add(
            _storageService.uploadFile(
              user.uid,
              'id_front.jpg',
              File(idFrontImage!.path),
            ),
          );
          taskKeys.add('idFrontUrl');
        }
        if (idBackImage != null) {
          uploadTasks.add(
            _storageService.uploadFile(
              user.uid,
              'id_back.jpg',
              File(idBackImage!.path),
            ),
          );
          taskKeys.add('idBackUrl');
        }

        final List<String> uploadedUrls = await Future.wait(uploadTasks);
        for (int i = 0; i < taskKeys.length; i++) {
          imageUrls[taskKeys[i]] = uploadedUrls[i];
        }
      } finally {
        if (idFrontImage != null) {
          await File(idFrontImage!.path).delete();
        }
        if (idBackImage != null) {
          await File(idBackImage!.path).delete();
        }
      }

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
        verification: {
          'idFrontUrl': imageUrls['idFrontUrl'] ?? '',
          'idBackUrl': imageUrls['idBackUrl'] ?? '',
        },
        isTutor: true,
        managedBy: null,
      );

      await _authService.saveUserData(userModel);

      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      await userViewModel.fetchCurrentUser();

      if (user.providerData.any((p) => p.providerId == 'password')) {
        await _authService.updateUserAuthProvider(user.uid, 'password');
        await _authService.signOut();
        setLoading(false);
        return 'VERIFY';
      } else {
        await _authService.updateUserAuthProvider(user.uid, 'google.com');

        // Se añade el guardado de SharedPreferences aquí también
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_active_user_id', user.uid);

        setLoading(false);
        return 'SPLASH';
      }
    } else {
      setErrorMessage("No se pudo crear la cuenta. Inténtalo de nuevo.");
      setLoading(false);
      return null;
    }
  }

  Future<bool> checkEmailExists() async {
    setLoading(true);
    setErrorMessage(null);
    try {
      final emailExists = await _authService.doesEmailExistInFirestore(
        emailController.text.trim(),
      );

      if (emailExists) {
        setErrorMessage('Este correo electrónico ya se encuentra registrado.');
        setLoading(false);
        return true; // Sí, existe
      }

      setLoading(false);
      return false;
    } catch (e) {
      setErrorMessage('Error al verificar el correo. Intenta de nuevo.');
      setLoading(false);
      return true;
    }
  }

  Future<bool> signInUser(
    BuildContext context,
    String email,
    String password,
  ) async {
    setLoading(true);
    setErrorMessage(null);

    try {
      final bool emailExists = await _authService.doesEmailExistInFirestore(
        email,
      );
      if (!emailExists) {
        setErrorMessage('El correo electrónico no se encuentra registrado.');
        setLoading(false);
        return false;
      }
      final provider = await _authService.getAuthProviderFromFirestore(email);
      if (provider == 'google.com') {
        setErrorMessage(
          'Ese correo está registrado con Google. Por favor, inicia sesión con Google.',
        );
        setLoading(false);
        return false;
      }

      final user = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );

      if (user != null && !user.emailVerified) {
        setErrorMessage("Por favor, verifica tu correo electrónico.");
        setLoading(false);
        return false;
      }

      if (user != null) {
        final userViewModel = Provider.of<UserViewModel>(
          context,
          listen: false,
        );
        final notificationViewModel = Provider.of<NotificationViewModel>(
          context,
          listen: false,
        );
        final postLoginTasks = <Future>[
          userViewModel.fetchCurrentUser(),
          SharedPreferences.getInstance().then(
            (prefs) => prefs.setString('last_active_user_id', user.uid),
          ),
          _notificationService.initNotifications(
            userViewModel: userViewModel,
            notificationViewModel: notificationViewModel,
          ),
        ];

        await Future.wait(postLoginTasks);
      }

      setLoading(false);
      return user != null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        setErrorMessage('La contraseña es incorrecta.');
      } else {
        setErrorMessage('Ocurrió un error inesperado.');
      }
      setLoading(false);
      return false;
    }
  }

  // NUEVO: Lógica para recuperar contraseña
  Future<String?> sendPasswordResetLink(String email) async {
    setLoading(true);
    setErrorMessage(null);
    try {
      // Validamos el formato del correo antes de enviarlo
      if (AppValidators.validateEmail(email) != null) {
        setLoading(false);
        return 'Por favor, ingresa un correo válido.';
      }
      await _authService.sendPasswordResetEmail(email);
      setLoading(false);
      return null; // Nulo significa éxito
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No se encontró un usuario con ese correo.';
          break;
        case 'invalid-email':
          message = 'El formato del correo no es válido.';
          break;
        default:
          message = 'Ocurrió un error. Inténtalo de nuevo.';
      }
      setLoading(false);
      return message; // Devolvemos el mensaje de error
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
    idFrontImage = null;
    idBackImage = null;
    notifyListeners();
  }
}
