import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/privacy_policy_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Deshabilitar descarga de fuentes en tiempo de ejecución (web perf).
  // Las fuentes ya están disponibles localmente vía google_fonts package.
  GoogleFonts.config.allowRuntimeFetching = false;

  // Arrancar la UI inmediatamente — el bootstrap ocurre en _AppBootstrap.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = GoogleFonts.interTextTheme();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GridWise',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF9F9FF),
        primaryColor: const Color(0xFF005BBF),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF005BBF),
          secondary: Color(0xFF1A73E8),
          surface: Color(0xFFECEDF7),
          onSurface: Color(0xFF191C23),
          onSurfaceVariant: Color(0xFF414754),
          error: Color(0xFFBA1A1A),
          outline: Color(0xFF727785),
        ),
        textTheme: baseTextTheme,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1626),
        primaryColor: const Color(0xFF1565C0),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1565C0),
          secondary: Color(0xFF00C853),
          surface: Color(0xFF1E2336),
          onSurface: Colors.white,
          onSurfaceVariant: Colors.white70,
        ),
        textTheme: baseTextTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const _AppBootstrap(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/privacy-policy': (context) => const PrivacyPolicyScreen(),
      },
    );
  }
}

class _AppBootstrap extends StatefulWidget {
  const _AppBootstrap();

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  late final Future<void> _bootstrapFuture;

  @override
  void initState() {
    super.initState();
    _bootstrapFuture = _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Ejecutar Firebase init y carga de locale EN PARALELO.
    // Antes eran secuenciales (Firebase → locale). Ahora corren simultáneamente.
    await Future.wait([
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
      initializeDateFormatting('es', null),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LoadingScreen();
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error de inicialización: ${snapshot.error}'),
            ),
          );
        }
        return const _AuthGate();
      },
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mientras esperamos la respuesta inicial de Firebase Auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        // Si hay un error en el stream
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error de autenticación: ${snapshot.error}'),
            ),
          );
        }

        // Usuario autenticado → Dashboard
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }

        // No autenticado → Pantalla de bienvenida
        return WelcomeScreen();
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F1626),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.energy_savings_leaf, color: Color(0xFF00C853), size: 64),
            SizedBox(height: 24),
            Text(
              'GRIDWISE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            SizedBox(height: 48),
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: Color(0xFF00C853),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
