import 'package:flutter/material.dart';
import 'package:inventrax/views/usuarios_auth/recovery_screen.dart';
import 'package:inventrax/views/usuarios_auth/register_screen.dart';
import 'package:provider/provider.dart';

import '../../utils/auth/validators.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/widgets_auth/auth_button.dart';
import '../../widgets/widgets_auth/auth_password_field.dart';
import '../../widgets/widgets_auth/auth_textfield.dart';
import '../indications/onboarding_screen.dart';
import '../menu/menu_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool showSuccessMessage;
  const LoginScreen({Key? key, this.showSuccessMessage = false}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final authViewModel = context.read<AuthViewModel>();

      await authViewModel.loginUser(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      if (authViewModel.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authViewModel.error!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else if (authViewModel.user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MenuScreen(
              uid: authViewModel.user!.idUsuarioAsString,
              rolId: authViewModel.user!.rolId,
              showWelcomeNotification: true,
            ),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.showSuccessMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registro exitoso!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF26A69A);
    final accentColor = const Color(0xFF80CBC4);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botón de retroceso con mejor estilo
                  IconButton(
                    icon: Icon(Icons.arrow_back_rounded, size: 28),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                      );
                    },
                    splashRadius: 24,
                    color: Colors.black54,
                  ),

                  const SizedBox(height: 20),

                  // Logo mejorado con sombra y gradiente
                  Center(
                    child: Container(
                      width: screenWidth * 0.35,
                      height: screenWidth * 0.35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/icon.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),


                  const SizedBox(height: 30),

                  // Título con mejor tipografía
                  const Text(
                    "Inicia sesión",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 32,
                      color: Color(0xFF424242),
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtítulo más elegante
                  Text(
                    "Bienvenido de nuevo, te hemos extrañado",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 15,
                      letterSpacing: 0.2,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Campos de formulario con mejor diseño
                  AuthTextField(
                    controller: _usernameController,
                    labelText: 'Correo electrónico',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(Icons.email_rounded, size: 22, color: Color(0xFF757575)),
                    ),
                    borderColor: primaryColor,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Ingrese correo';
                      if (!isValidEmail(value)) return 'Correo inválido';
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  AuthPasswordField(
                    controller: _passwordController,
                    labelText: 'Contraseña',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(Icons.lock_rounded, size: 22, color: Color(0xFF757575)),
                    ),
                    borderColor: primaryColor,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Ingrese contraseña';
                      if (!isValidPassword(value)) return 'Mínimo 6 caracteres';
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Enlace para recuperar contraseña
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RecoveryScreen()),
                        );
                      },
                      child: Text(
                        "¿Olvidaste tu contraseña?",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Botón con mejor diseño
                  Consumer<AuthViewModel>(
                    builder: (context, auth, child) {
                      return AuthButton(
                        text: 'Iniciar sesión',
                        isLoading: auth.isLoading,
                        onPressed: auth.isLoading ? null : _submit,
                        backgroundColor: primaryColor,
                        textColor: Colors.white,
                        borderRadius: 12,
                        height: 52,
                        elevation: 3,
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Texto de registro con mejor diseño
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "¿No tienes una cuenta?",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.info_outline_rounded,
                                        size: 48,
                                        color: primaryColor,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "Acceso restringido",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF424242),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "¿No tienes cuenta?\n\nSolicita acceso a tu superior. Solo el personal autorizado puede ser registrado por el administrador general.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      ElevatedButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 32, vertical: 12),
                                        ),
                                        child: const Text(
                                          "Entendido",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 10),
                          ),
                          child: Text(
                            "Solicitar acceso",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}