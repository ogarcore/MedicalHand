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
     //pasa nada
    }
  }

  Future<List<String>> getSignInMethodsForEmail(String email) async {
    try {
      // Intentamos crear el usuario con una contraseña temporal
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: "temporary_password_123456",
      );

      // Si llega aquí significa que NO existía ese correo.
      // Eliminamos inmediatamente al usuario recién creado
      await _auth.currentUser?.delete();

      return []; // No había métodos de inicio de sesión
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // Si el correo ya existe, devolvemos ['password'] como antes
        return ['password'];
      }
      // Otros errores (ej: formato inválido)
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<String> getAuthProviderFromFirestore(String email) async {
    try {
      final query = await _firestore
          .collection('usuarios_movil')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        // Si encontramos al usuario, devolvemos el valor del campo 'authProvider'.
        // Si el campo no existiera, devolvemos 'password' por defecto.
        return query.docs.first.data()['authProvider'] ?? 'password';
      }
      // Si no encontramos un documento, devolvemos 'desconocido'
      return 'desconocido';
    } catch (e) {
      // En caso de error, devolvemos 'password' para no bloquear al usuario.
      return 'password';
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
     //pasa nada
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
      //pasa nada
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

  Future<bool> doesEmailExistInFirestore(String email) async {
    try {
      final query = await _firestore
          .collection(
            'usuarios_movil',
          ) // ¡Importante! Usar el nombre correcto de tu colección
          .where('email', isEqualTo: email)
          .limit(1) // Optimización: solo necesitamos saber si existe al menos 1
          .get();
      return query
          .docs
          .isNotEmpty; // Si la lista de documentos no está vacía, el correo existe
    } catch (e) {
      print("Error al verificar email en Firestore: ${e.toString()}");
      return false; // En caso de error, asumimos que no existe para evitar bloqueos
    }
  }

  // --- CORRECCIÓN DE BUG MENOR ---
  // El método que tenías antes apuntaba a una colección 'users' que no existe.
  // Lo he corregido para que use la lógica robusta que ya implementamos.
  Future<bool> checkIfEmailInUse(String emailAddress) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailAddress,
        password:
            "a_deliberately_wrong_password_${DateTime.now().millisecondsSinceEpoch}",
      );
      return false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return false;
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return true;
      }
      return false;
    }
  }

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException {
      // Dejamos que el ViewModel maneje el tipo de excepción
      rethrow;
    }
  }

  Future<void> updateUserAuthProvider(String uid, String provider) async {
  try {
    await _firestore
        .collection('usuarios_movil')
        .doc(uid)
        .update({'authProvider': provider}); // Actualiza solo este campo
  } catch (e) {
    print("Error al actualizar el authProvider: ${e.toString()}");
  }
}


  // NUEVO: Enviar correo para restablecer contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      // Dejamos que el ViewModel maneje el tipo de excepción
      rethrow;
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
