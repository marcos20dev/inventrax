import 'package:flutter/material.dart';
import 'package:inventrax/repositories/categoria_repository.dart';
import 'package:inventrax/repositories/cliente_repository.dart';
import 'package:inventrax/repositories/dashboard_repository.dart';
import 'package:inventrax/repositories/producto_repository.dart';
import 'package:inventrax/services/ChangeNotifier.dart';
import 'package:inventrax/viewmodels/categoria_viewmodel.dart';
import 'package:inventrax/viewmodels/cliente_viewmodel.dart';
import 'package:inventrax/viewmodels/dashboard_viewmodel.dart';
import 'package:inventrax/viewmodels/producto_viewmodel.dart';
import 'package:inventrax/viewmodels/venta/registro_venta_viewmodel.dart';
import 'package:inventrax/views/indications/onboarding_screen.dart';
import 'package:inventrax/views/menu/menu_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'repositories/user_repository.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'repositories/proveedor_repository.dart';
import 'viewmodels/proveedor_viewmodel.dart';
import 'repositories/venta_repository.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://putgmymnacszfvykckml.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1dGdteW1uYWNzemZ2eWtja21sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc4OTM0MjUsImV4cCI6MjA2MzQ2OTQyNX0.SNBRe_wBtk74tc5K2502kKU8SY4bRw6FNTKC5RagtMQ',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserSession()),

        Provider<SupabaseClient>(create: (_) => Supabase.instance.client),
        Provider<UserRepository>(
          create: (context) => UserRepository(context.read<SupabaseClient>()),
        ),
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(context.read<UserRepository>()),
        ),

        // Repositorios y ViewModels existentes
        Provider<CategoriaRepository>(
          create: (context) =>
              CategoriaRepository(context.read<SupabaseClient>()),
        ),
        ChangeNotifierProxyProvider2<AuthViewModel, CategoriaRepository,
            CategoriaViewModel>(
          create: (context) =>
              CategoriaViewModel(context.read<CategoriaRepository>()),
          update: (context, auth, categoriaRepository, categoriaVM) {
            categoriaVM ??= CategoriaViewModel(categoriaRepository);
            categoriaVM.updateAuth(auth);
            return categoriaVM;
          },
        ),

        // Nuevo: ProveedorRepository y ProveedorViewModel
        Provider<ProveedorRepository>(
          create: (context) =>
              ProveedorRepository(supabase: context.read<SupabaseClient>()),
        ),
        ChangeNotifierProvider<ProveedorViewModel>(
          create: (context) =>
              ProveedorViewModel(repository: context.read<ProveedorRepository>()),
        ),

        Provider<ProductoRepository>(
          create: (context) => ProductoRepository(),
        ),
        ChangeNotifierProvider<ProductoViewModel>(
          create: (context) => ProductoViewModel(repository: context.read<ProductoRepository>()),
        ),
        Provider<ClientesRepository>(
          create: (context) => ClientesRepository(context.read<SupabaseClient>()),
        ),
        ChangeNotifierProvider<ClienteViewModel>(
          create: (context) => ClienteViewModel(repository: context.read<ClientesRepository>()),
        ),

        // Nuevo: VentaRepository y RegistroVentaViewModel
        Provider<VentaRepository>(
          create: (context) => VentaRepository(context.read<SupabaseClient>()),
        ),
        ChangeNotifierProvider<RegistroVentaViewModel>(
          create: (context) => RegistroVentaViewModel(context.read<VentaRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(DashboardRepository(Supabase.instance.client)),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventrax',
      home:      MenuScreen(uid: 'c5ead8ec-bd66-4d9f-81a1-2399ed4fb3c9'),

      //OnboardingScreen(),
      //MenuScreen(uid: 'c5ead8ec-bd66-4d9f-81a1-2399ed4fb3c9'),
      //
    );
  }
}
