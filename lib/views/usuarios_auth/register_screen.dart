import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../models/roles.dart';
import '../../models/user.dart';
import '../../utils/auth/validators.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/widgets_auth/auth_button.dart';
import '../../widgets/widgets_auth/auth_password_field.dart';
import '../../widgets/widgets_auth/auth_textfield.dart';
import '../../widgets/widgets_auth/step_indicator.dart';
import 'package:flutter/services.dart';

import '../usuarios_roles/gestion_usuarios/usuarios_list.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _dniController =  TextEditingController();
  final TextEditingController _telefonoController =  TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repetirPasswordController = TextEditingController();


  List<Role> _roles = [];
  Role? _selectedRol;
  bool _loadingRoles = true;


  int _currentStep = 0;
  final primaryColor = const Color(0xFF26A69A);
  final accentColor = Color(0xFF26A69A);
  final darkColor = const Color(0xFF26A69A);

  @override
  void initState() {
    super.initState();
    _fetchRoles();
  }

  Future<void> _fetchRoles() async {
    try {
      final response = await Supabase.instance.client.from('roles').select();
      final roles = (response as List)
          .map((e) => Role.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _roles = roles;
        _loadingRoles = false;
      });
    } catch (e) {
      print('Error al cargar roles: $e');
      setState(() {
        _loadingRoles = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    if (authVM.isLoading) {
      return Scaffold(
        backgroundColor: Colors.white.withOpacity(0.9),
        body: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset('assets/loading_animation.json', height: 100),
                  const SizedBox(height: 16),
                  const Text(
                    'Creando tu cuenta',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Esto solo tomará un momento...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: darkColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Crear cuenta',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: darkColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Completa tus datos para registrarte',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  StepIndicator(
                    stepIndex: 0,
                    currentStep: _currentStep,
                    label: 'Datos personales',
                    primaryColor: _currentStep == 1 && !_isPersonalDataValid()
                        ? Colors.orange
                        : primaryColor,
                    darkColor: darkColor,
                    hasWarning: _currentStep == 1 && !_isPersonalDataValid(),
                  ),
                  SizedBox(width: 8),
                  StepIndicator(
                    stepIndex: 1,
                    currentStep: _currentStep,
                    label: 'Credenciales',
                    primaryColor: primaryColor,
                    darkColor: darkColor,
                  ),
                ],
              ),
              SizedBox(height: 21),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: PageView(
                    controller: _pageController,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      // Paso 1: Datos personales
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 3),
                            AuthTextField(
                              controller: _nombreController,
                              labelText: 'Nombre',
                              borderColor: accentColor,
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: Color(0xFF26A69A),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Ingrese nombre';
                                if (!isValidNameOrSurname(value))
                                  return 'Nombre inválido, solo letras y espacios permitidos (2-20 caracteres)';
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            AuthTextField(
                              controller: _apellidoController,
                              labelText: 'Apellido',
                              borderColor: accentColor,
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: Color(0xFF26A69A),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Ingrese apellido';
                                if (!isValidNameOrSurname(value))
                                  return 'Apellido inválido, solo letras y espacios permitidos (2-20 caracteres)';
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            AuthTextField(
                              controller: _dniController,
                              labelText: 'Documento de identidad',
                              borderColor: accentColor,
                              prefixIcon: Icon(
                                Icons.credit_card,
                                color:Color(0xFF26A69A),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(8),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Ingrese DNI';
                                if (!isValidDNI(value))
                                  return 'DNI inválido (8 dígitos, sin secuencias repetidas)';
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            AuthTextField(
                              controller: _telefonoController,
                              labelText: 'Celular',
                              borderColor: accentColor,
                              prefixIcon: Icon(Icons.phone, color: Color(0xFF26A69A)),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(9),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Ingrese teléfono';
                                if (!isValidMobilePhone(value))
                                  return 'Teléfono inválido (9 dígitos, empieza con 9, sin secuencias repetidas)';
                                return null;
                              },
                            ),
                            SizedBox(height: 21),
                          ],
                        ),
                      ),
                      // Paso 2: Credenciales
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 3),
                            _loadingRoles
                                ? CircularProgressIndicator()
                                : DropdownButtonFormField<Role>(
                              value: _selectedRol,
                              decoration: InputDecoration(
                                labelText: 'Selecciona un rol',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: accentColor),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: accentColor, width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: _roles.map((rol) {
                                return DropdownMenuItem<Role>(
                                  value: rol,
                                  child: Text(rol.nombre ?? 'Sin nombre'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRol = value;
                                });
                              },
                              validator: (value) =>
                              value == null ? 'Seleccione un rol' : null,
                            ),


                            SizedBox(height: 16),

                            AuthTextField(
                              controller: _correoController,
                              labelText: 'Correo electrónico',
                              keyboardType: TextInputType.emailAddress,
                              borderColor: accentColor,
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Color(0xFF26A69A),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Ingrese correo';
                                if (!isValidEmail(value))
                                  return 'Correo inválido';
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            AuthPasswordField(
                              controller: _passwordController,
                              labelText: 'Contraseña',
                              prefixIcon: Icon(
                                Icons.password,
                                color: Color(0xFF26A69A),
                              ),
                              borderColor: accentColor,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Ingrese contraseña';
                                if (!isValidPassword(value))
                                  return 'Mínimo 6 caracteres';
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            AuthPasswordField(
                              controller: _repetirPasswordController,
                              labelText: 'Confirmar contraseña',
                              prefixIcon: Icon(
                                Icons.password,
                                color: Color(0xFF26A69A),
                              ),
                              borderColor: accentColor,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Confirme su contraseña';
                                if (value != _passwordController.text)
                                  return 'Las contraseñas no coinciden';
                                return null;
                              },
                            ),
                            SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_currentStep == 0)
                AuthButton(
                  text: 'Continuar',
                  onPressed: _nextStep,
                  backgroundColor: primaryColor,
                  borderRadius: 12,
                  height: 50,
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _prevStep,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Atrás',
                          style: TextStyle(color: primaryColor),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                        child: AuthButton(
                          text: 'Registrarse',
                          onPressed: _submit,
                          isLoading: authVM.isLoading,
                          backgroundColor: primaryColor,
                          borderRadius: 12,
                          height: 50,
                        )
                    ),
                  ],
                ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  bool _isPersonalDataValid() {
    final nombre = _nombreController.text;
    final apellido = _apellidoController.text;
    final dni = _dniController.text;
    final telefono = _telefonoController.text;
    if (nombre.isEmpty || apellido.isEmpty || dni.isEmpty || telefono.isEmpty)
      return false;
    if (!isValidNameOrSurname(nombre) ||
        !isValidNameOrSurname(apellido) ||
        !isValidDNI(dni) ||
        !isValidMobilePhone(telefono))
      return false;
    return true;
  }

  void _submit() async {
    final emailClean = _correoController.text.trim().replaceAll('"', '');

    if (!isValidEmail(emailClean)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Correo electrónico inválido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final user = User(
        name: _nombreController.text.trim(),
        lastName: _apellidoController.text.trim(),
        email: emailClean,
        password: _passwordController.text,
        identityDocument: _dniController.text.trim(),
        phone: _telefonoController.text.trim(),
        rolId: _selectedRol!.idRoles!, // Asegúrate de que no sea null

      );

      try {
        await context.read<AuthViewModel>().registerUser(user);

        final authVM = context.read<AuthViewModel>();

        if (authVM.error == null) {
          // Limpiar campos antes de navegar (opcional)
          _nombreController.clear();
          _apellidoController.clear();
          _dniController.clear();
          _telefonoController.clear();
          _correoController.clear();
          _passwordController.clear();
          _repetirPasswordController.clear();

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => UsuariosList(), // Asegúrate de que no tenga `const` si no lo necesita
            ),
          );



        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${authVM.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
    _pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _prevStep() {
    setState(() {
      _currentStep--;
    });
    _pageController.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
