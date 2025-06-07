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
  final bool showSuccessMessage;   // <-- Agrega esta línea
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
          SnackBar(content: Text(authViewModel.error!), backgroundColor: Colors.red),
        );
      } else if (authViewModel.user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MenuScreen(
              uid: authViewModel.user!.idUsuarioAsString,
              showWelcomeNotification: true,  // indica que muestre la notificación
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
          ),
        );
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final BorderColor = Color(0xFF26A69A);
    final primaryColor = const Color(0xFF26A69A);
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
                  const SizedBox(height: 15),

                  // Botón de retroceso alineado a la izquierda
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                      );
                    },
                    splashRadius: 20,
                    color: Colors.black,
                  ),
                  Center(
                    child: Image.asset(
                      'assets/icon.png',
                      width: screenWidth * 0.4,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Inicia sesión",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Color(0xFF26A69A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Bienvenido de nuevo, te hemos extrañado",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  AuthTextField(
                    controller: _usernameController,
                    labelText: 'Correo',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(Icons.email, size: 20, color: Color(0xFF26A69A)),
                    ),
                    borderColor: BorderColor,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Ingrese correo';
                      if (!isValidEmail(value)) return 'Correo inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AuthPasswordField(
                    controller: _passwordController,
                    labelText: 'Contraseña',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(Icons.lock, size: 20, color:Color(0xFF26A69A)),
                    ),
                    borderColor: BorderColor,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Ingrese contraseña';
                      if (!isValidPassword(value)) return 'Mínimo 6 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RecoveryScreen()),
                        );
                      },
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(color: Color(0xFF26A69A)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Consumer<AuthViewModel>(
                    builder: (context, auth, child) {
                      return AuthButton(
                        text: 'Iniciar sesión',
                        isLoading: auth.isLoading,
                        onPressed: auth.isLoading ? null : _submit,
                        backgroundColor: primaryColor,
                        borderRadius: 30,
                        height: 50,
                      );
                    },
                  ),


                  const SizedBox(height: 40),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        const Text("¿No tienes cuenta? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            );},
                          child: const Text(
                            "Crea una.",
                            style: TextStyle(
                              color: Color(0xFF26A69A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
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