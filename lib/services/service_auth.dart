import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isValidEmail(String email) {
    final value = email.trim();
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(value);
  }

  /// Convierte errores de Firebase a mensajes legibles en español
  String _firebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Este correo ya está registrado. Intenta iniciar sesión.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'weak-password':
        return 'La contraseña es muy débil. Usa al menos 8 caracteres y un número.';
      case 'operation-not-allowed':
        return 'El registro con correo no está habilitado. Contacta al soporte.';
      case 'network-request-failed':
        return 'Sin conexión a internet. Verifica tu red e intenta de nuevo.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera unos minutos e intenta de nuevo.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'user-not-found':
        return 'No existe una cuenta con este correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      default:
        return 'Error: ${e.message ?? e.code}';
    }
  }

  // Registrar usuario y guardar datos en Firestore
  // Lanza [Exception] con mensaje legible si falla
  Future<User?> registerWithEmailPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    // Validaciones previas (doble capa de seguridad)
    if (!_isValidEmail(email)) {
      throw Exception('El correo electrónico no es válido.');
    }
    if (password.length < 8) {
      throw Exception('La contraseña debe tener al menos 8 caracteres.');
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      throw Exception('La contraseña debe contener al menos un número.');
    }

    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final User? user = result.user;

      if (user != null) {
        // Actualizamos el nombre en Firebase Auth
        await user.updateDisplayName(name.trim());

        // Guardamos el perfil en Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name.trim(),
          'email': email.trim(),
          'phone': phone.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_firebaseErrorMessage(e));
    } catch (e) {
      throw Exception('Error inesperado al registrar. Intenta de nuevo.');
    }
  }

  // Iniciar sesión — lanza [Exception] con mensaje legible si falla
  Future<User?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    if (!_isValidEmail(email)) {
      throw Exception('El correo electrónico no es válido.');
    }
    if (password.length < 8) {
      throw Exception('La contraseña debe tener al menos 8 caracteres.');
    }

    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_firebaseErrorMessage(e));
    } catch (e) {
      throw Exception('Error inesperado al iniciar sesión. Intenta de nuevo.');
    }
  }

  // Iniciar sesión con Google
  Future<User?> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      final User? user = userCredential.user;

      if (user != null &&
          userCredential.additionalUserInfo?.isNewUser == true) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': user.displayName ?? 'Usuario de Google',
          'email': user.email,
          'phone': user.phoneNumber ?? '',
          'photoUrl': user.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } catch (_) {
      return null;
    }
  }

  // Enviar correo de restablecimiento de contraseña
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      if (_isValidEmail(email)) {
        await _auth.sendPasswordResetEmail(email: email.trim());
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  // Buscar por teléfono y enviar correo de recuperación al email asociado
  Future<bool> sendPasswordResetByPhone(String phone) async {
    try {
      final normalizedPhone = phone.trim();
      final query = await _firestore
          .collection('users')
          .where('phone', isEqualTo: normalizedPhone)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final email = query.docs.first.data()['email'] as String?;
        if (email != null && _isValidEmail(email)) {
          await _auth.sendPasswordResetEmail(email: email.trim());
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
      }
    } catch (_) {
      // Ignorar si falla el cierre de sesión de Google
    }
    await _auth.signOut();
  }
}
