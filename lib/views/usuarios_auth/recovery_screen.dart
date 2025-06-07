import 'package:flutter/material.dart';
import '../../utils/auth/validators.dart';
import '../../widgets/widgets_auth/auth_button.dart';
import '../../widgets/widgets_auth/auth_textfield.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({Key? key}) : super(key: key);

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final primaryColor = Color(0xFF26A69A); // Color primario consistente
  final accentColor = Color(0xFF26A69A); // Color de acento

  void _recoverPassword() {
    if (_formKey.currentState!.validate()) {
      // Aquí la lógica para recuperar la contraseña
      final email = _emailController.text.trim();
      print('Solicitando recuperación de contraseña para: $email');

      // Mostrar feedback al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Instrucciones enviadas a $email'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF26A69A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recupera tu acceso',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Color(0xFF26A69A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ingresa tu correo electrónico asociado a tu cuenta y te enviaremos instrucciones para restablecer tu contraseña.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),
                AuthTextField(
                  controller: _emailController,
                  labelText: 'Correo electrónico',
                  borderColor: accentColor,
                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF26A69A)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu correo';
                    }
                    if (!isValidEmail(value)) {
                      return 'Ingresa un correo válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                AuthButton(
                  text: 'Enviar instrucciones',
                  onPressed: _recoverPassword,
                  backgroundColor: primaryColor,
                  textColor: Colors.white,
                  borderRadius: 12,
                  height: 50,
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Revisa tu bandeja de entrada y la carpeta de spam',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}