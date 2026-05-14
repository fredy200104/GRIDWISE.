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

  // Registrar usuario y guardar datos en Firestore
  Future<User?> registerWithEmailPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      if (!_isValidEmail(email) || password.length < 6) return null;
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Guardamos el nombre también en el perfil de Firebase Auth
        await user.updateDisplayName(name);

        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email.trim(),
          'phone': phone.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (_) {
      return null;
    }
  }

  // Iniciar sesión
  Future<User?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (!_isValidEmail(email) || password.length < 6) return null;
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return result.user;
    } catch (_) {
      return null;
    }
  }

  // Iniciar sesión con Google
  Future<User?> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // Flujo recomendado para Flutter Web
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.setCustomParameters({'prompt': 'select_account'});

        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // Flujo para Android / iOS / escritorio
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          // El usuario canceló el inicio de sesión
          return null;
        }

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
      // Ignorar si falla el cierre de sesión de Google (p. ej. no estaba logueado con Google)
    }
    await _auth.signOut();
  }
}
