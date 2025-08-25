import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> signOut() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
      }
      await _auth.signOut();
    } catch (e) {
      print("Error al cerrar sesión: ${e.toString()}");
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '818500504209-vn67582a72oa8l06t6f0qfb17ta3tkvq.apps.googleusercontent.com',
  );

  /// Registro con correo y contraseña
  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.sendEmailVerification();
      return credential.user;
    } on FirebaseAuthException catch (e) {
      print("Error en el registro: ${e.message}");
      return null;
    }
  }

  /// Guardar datos del usuario en Firestore
  Future<void> saveUserData(UserModel userModel) async {
    try {
      await _firestore
          .collection('usuarios_movil')
          .doc(userModel.uid)
          .set(userModel.toMap());
    } catch (e) {
      print("Error al guardar datos: ${e.toString()}");
    }
  }

  /// Iniciar sesión con Google (Lógica para v6.3.0)
  Future<User?> signInWithGoogle() async {
    try {
      // 1. El método para iniciar el flujo es .signIn()
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // El usuario canceló
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 2. La credencial necesita ambos tokens en esta versión
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      return userCredential.user;
    } catch (e) {
      print("Error con Google Sign In: ${e.toString()}");
      return null;
    }
  }

  Future<void> signOutFromGoogle() async {
    try {
      await _googleSignIn.disconnect();
      await _auth.signOut();
    } catch (e) {
      print("Error al desconectar de Google: ${e.toString()}");
    }
  }

  /// Verificar si un usuario ya existe en Firestore
  Future<bool> doesUserExist(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('usuarios_movil')
          .doc(uid)
          .get();
      return doc.exists;
    } catch (e) {
      print("Error al verificar usuario: ${e.toString()}");
      return false;
    }
  }
}
