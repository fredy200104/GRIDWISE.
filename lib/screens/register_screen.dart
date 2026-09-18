import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/service_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  String name = '';
  String email = '';
  String password = '';
  String phone = '';
  bool loading = false;
  bool _obscurePassword = true;

  bool _isValidEmail(String value) {
    return RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value.trim());
  }

  bool _isValidPassword(String value) {
    if (value.length < 8) return false;
    return RegExp(r'[0-9]').hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Registro", style: TextStyle(color: isDark ? Colors.white : colorScheme.onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : colorScheme.onSurface),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                elevation: isDark ? 8 : 2,
                shadowColor: isDark ? Colors.black : colorScheme.outline.withValues(alpha: 0.1),
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_add, size: 80, color: colorScheme.primary),
                        const SizedBox(height: 24),
                        TextFormField(
                          style: TextStyle(color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            labelText: "Nombre",
                            labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                            prefixIcon: Icon(Icons.badge, color: colorScheme.outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: isDark ? colorScheme.surface : const Color(0xFFF1F3F4),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: colorScheme.primary, width: 2),
                            ),
                          ),
                          onChanged: (val) => name = val,
                          validator: (val) => val!.isEmpty ? 'Ingresa tu nombre' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          style: TextStyle(color: colorScheme.onSurface),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Correo electrónico",
                            labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                            prefixIcon: Icon(Icons.email_outlined, color: colorScheme.outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: isDark ? colorScheme.surface : const Color(0xFFF1F3F4),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: colorScheme.primary, width: 2),
                            ),
                          ),
                          onChanged: (val) => email = val.trim(),
                          validator: (val) {
                            final value = (val ?? '').trim();
                            if (value.isEmpty) return 'Ingresa tu correo';
                            if (!_isValidEmail(value)) {
                              return 'Ingresa un correo válido (ej: usuario@gmail.com)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          style: TextStyle(color: colorScheme.onSurface),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(15),
                          ],
                          decoration: InputDecoration(
                            labelText: "Teléfono",
                            labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                            prefixIcon: Icon(Icons.phone_outlined, color: colorScheme.outline),
                            hintText: 'Solo números',
                            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.4), fontSize: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: isDark ? colorScheme.surface : const Color(0xFFF1F3F4),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: colorScheme.primary, width: 2),
                            ),
                          ),
                          onChanged: (val) => phone = val,
                          validator: (val) {
                            final value = (val ?? '').trim();
                            if (value.isEmpty) return 'Ingresa tu número de teléfono';
                            if (value.length < 7) return 'El teléfono debe tener al menos 7 dígitos';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          obscureText: _obscurePassword,
                          style: TextStyle(color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            labelText: "Contraseña",
                            labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                            prefixIcon: Icon(Icons.lock_outline, color: colorScheme.outline),
                            hintText: 'Mín. 8 caracteres y 1 número',
                            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.4), fontSize: 11),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: colorScheme.outline,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: isDark ? colorScheme.surface : const Color(0xFFF1F3F4),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: colorScheme.primary, width: 2),
                            ),
                          ),
                          onChanged: (val) => password = val,
                          validator: (val) {
                            final value = val ?? '';
                            if (value.isEmpty) return 'Ingresa una contraseña';
                            if (value.length < 8) return 'Mínimo 8 caracteres';
                            if (!RegExp(r'[0-9]').hasMatch(value)) {
                              return 'Debe contener al menos 1 número';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: loading ? null : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => loading = true);
                                try {
                                  final user = await _authService.registerWithEmailPassword(
                                    email: email.trim(),
                                    password: password,
                                    name: name.trim(),
                                    phone: phone.trim(),
                                  );
                                  if (user != null && context.mounted) {
                                    Navigator.pushReplacementNamed(context, '/home');
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    final msg = e.toString().replaceFirst('Exception: ', '');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(msg),
                                        backgroundColor: Theme.of(context).colorScheme.error,
                                        behavior: SnackBarBehavior.floating,
                                        duration: const Duration(seconds: 5),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) setState(() => loading = false);
                                }
                              }
                            },
                            child: loading 
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                                : const Text("Registrarse", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final user = await _authService.signInWithGoogle();
                              if (user != null && context.mounted) {
                                Navigator.pushReplacementNamed(context, '/home');
                              }
                            },
                            icon: Image.asset('assets/images/google_logo.png', height: 24),
                            label: Text(
                              "Continuar con Google",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: colorScheme.surface,
                              side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3), width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: Text('¿Ya tienes cuenta? Inicia sesión', style: TextStyle(color: colorScheme.primary)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
