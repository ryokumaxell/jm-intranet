import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_intranet/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:j_intranet/features/auth/presentation/providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _passwordVisible = false;
  bool _emailValid = false;
  bool _passwordValid = false;

  bool get _canSubmit => _emailValid && _passwordValid && !_loading;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _validateFormLive() {
    setState(() {
      _emailValid = _validateEmail(_email.text) == null;
      _passwordValid = _validatePassword(_password.text) == null;
    });
  }

  String? _validateEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Ingresa tu correo';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) return 'Correo no válido';
    return null;
  }

  String? _validatePassword(String? v) {
    final value = v ?? '';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  Future<void> _performLogin() async {
    setState(() {
      _loading = true;
    });
    try {
      HapticFeedback.lightImpact();
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      // Obtener la sesión del usuario
      if (mounted) {
        final loginUseCase = ref.read(loginUseCaseProvider);
        final session = await loginUseCase.call(
          _email.text.trim(),
          _password.text,
        );
        ref.read(authSessionProvider.notifier).setSession(session);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Ocurrió un error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final outerPadding = EdgeInsets.all(isMobile ? 16 : 24);
    final logoSize = isMobile ? 140.0 : 200.0;

    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Fondo claro
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SingleChildScrollView(
                padding: outerPadding,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Card(
                    elevation: 8, // Sombra del contenedor
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Bordes redondeados
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24), // Padding general
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: _validateFormLive,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header
                            Center(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Image.asset(
                                      'images/logo.png',
                                      height: logoSize,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Accede a tu intranet corporativa',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Campo de correo
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              decoration: const InputDecoration(
                                labelText: 'Correo',
                                prefixIcon: Icon(Icons.email_outlined),
                                hintText: 'tu@empresa.com',
                              ),
                              validator: _validateEmail,
                              onChanged: (_) => _validateFormLive(),
                            ),
                            const SizedBox(height: 16),

                            // Campo de contraseña
                            TextFormField(
                              controller: _password,
                              obscureText: !_passwordVisible,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  tooltip:
                                      _passwordVisible ? 'Ocultar' : 'Mostrar',
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                ),
                              ),
                              validator: _validatePassword,
                              onChanged: (_) => _validateFormLive(),
                              onFieldSubmitted: (_) {
                                if (_canSubmit) _performLogin();
                              },
                            ),

                            const SizedBox(height: 24),

                            // Botón de acceso
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _canSubmit ? _performLogin : null,
                                style: ButtonStyle(
                                  animationDuration: const Duration(
                                      milliseconds: 250), // Transiciones suaves
                                  elevation:
                                      WidgetStateProperty.resolveWith<double>(
                                    (states) {
                                      if (states
                                          .contains(WidgetState.pressed)) {
                                        return 8; // Sombra más pronunciada
                                      }
                                      return 3;
                                    },
                                  ),
                                  backgroundColor:
                                      WidgetStateProperty.resolveWith<Color>(
                                    (states) {
                                      if (states
                                          .contains(WidgetState.disabled)) {
                                        return Colors.black.withValues(
                                            alpha: 0.5); // Deshabilitado 50%
                                      }
                                      if (states
                                          .contains(WidgetState.hovered)) {
                                        return Colors.grey
                                            .shade900; // Hover ligeramente más oscuro
                                      }
                                      return Colors.black; // Normal
                                    },
                                  ),
                                  foregroundColor:
                                      WidgetStateProperty.all<Color>(
                                          Colors.white),
                                  overlayColor:
                                      WidgetStateProperty.resolveWith<Color?>(
                                    (states) {
                                      if (states
                                          .contains(WidgetState.pressed)) {
                                        return Colors
                                            .white10; // Feedback táctil visual
                                      }
                                      return null;
                                    },
                                  ),
                                  shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  padding: WidgetStateProperty.all<EdgeInsets>(
                                    const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  switchInCurve: Curves.easeOut,
                                  switchOutCurve: Curves.easeIn,
                                  child: _loading
                                      ? const SizedBox(
                                          key: ValueKey('loading'),
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Row(
                                          key: const ValueKey('label'),
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.arrow_forward_rounded,
                                                size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              'Acceder',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
