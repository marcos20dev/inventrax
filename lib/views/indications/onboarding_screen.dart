import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../usuarios_auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  static const String _prefKey = 'dont_show_onboarding';

  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_prefKey) ?? false);
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  late AnimationController _animationController;
  bool _animateElements = false;

  final List<Map<String, dynamic>> _pages = [
    {
      'image': 'assets/stock.svg',
      'title': 'Bienvenido a Inventrax',
      'subtitle': 'La solución inteligente para tu inventario',
      'text':
      'Optimiza la gestión de tu almacén con nuestra plataforma intuitiva y poderosa. Reduce tiempos de gestión en un 70% con nuestras herramientas especializadas.',
      'color': Color(0xFFB0BEC5),
      'textColor': Color(0xFF263238),
      'features': [
        'Control de stock en tiempo real',
        'Alertas automáticas de bajo inventario',
        'Reportes personalizados'
      ],
    },
    {
      'image': 'assets/soportes.svg',
      'title': 'Acceso Multinivel',
      'subtitle': 'Diferentes roles, mismo poder',
      'text':
      'Administradores, supervisores y empleados tendrán acceso controlado según sus necesidades. Configura permisos granularmente para cada miembro de tu equipo.',
      'color': Color(0xFFCFD8DC),
      'textColor': Color(0xFF37474F),
      'features': [
        'Perfiles personalizables',
        'Soporte técnico prioritario',
        'Sincronización en la nube'
      ],
    },
    {
      'image': 'assets/contrato.svg',
      'title': 'Transforma tu Negocio',
      'subtitle': 'El futuro de la gestión de inventarios',
      'text':
      'Con Inventrax podrás tomar decisiones basadas en datos precisos y actualizados. Nuestra tecnología predictiva te ayuda a anticipar demandas y optimizar compras.',
      'color': Color(0xFFECEFF1),
      'textColor': Color(0xFF455A64),
      'features': [
        'Analítica avanzada',
        'Integración con otros sistemas',
        'Backup automático diario'
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() => _animateElements = true);
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _setDontShowAgain() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(OnboardingScreen._prefKey, true);
  }

  void _goToNext() {
    if (_currentIndex < _pages.length - 1) {
      setState(() => _animateElements = false);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      Future.delayed(300.ms, () {
        setState(() => _animateElements = true);
      });
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      setState(() => _animateElements = false);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      Future.delayed(300.ms, () {
        setState(() => _animateElements = true);
      });
    }
  }

  Future<void> _close({bool dontShow = false}) async {
    if (dontShow) {
      await _setDontShowAgain();
    }
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _pages[_currentIndex]['color'],
      body: Stack(
        children: [
          // Efecto de partículas decorativas
          Positioned.fill(
            child: CustomPaint(
              painter: _DotsPainter(color: _pages[_currentIndex]['textColor'].withOpacity(0.1)),
            ),
          ),

          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                // Header con botón de cerrar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: _pages[_currentIndex]['textColor'].withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.close, size: 24),
                          color: _pages[_currentIndex]['textColor'],
                          onPressed: () => _close(),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 600.ms),
                ),

                // Páginas
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Imagen con animación
                            _animateElements
                                ? SvgPicture.asset(
                              page['image']!,
                              height: size.height * 0.25,
                              fit: BoxFit.contain,

                            )
                                .animate()
                                .fadeIn(duration: 300.ms)
                                .then()
                                .shake(duration: 600.ms, hz: 2)
                                : SvgPicture.asset(
                              page['image']!,
                              height: size.height * 0.25,
                              fit: BoxFit.contain,

                            ),

                            const SizedBox(height: 40),

                            // Título principal
                            _animateElements
                                ? Column(
                              children: [
                                Text(
                                  page['title'],
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    color: page['textColor'],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                  ),
                                )
                                    .animate()
                                    .fadeIn(duration: 300.ms)
                                    .slideY(begin: 0.2, end: 0),
                                const SizedBox(height: 8),
                                Text(
                                  page['subtitle'],
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: page['textColor'].withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                                    .animate()
                                    .fadeIn(duration: 400.ms)
                                    .slideY(begin: 0.2, end: 0),
                              ],
                            )
                                : Column(
                              children: [
                                Text(
                                  page['title'],
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    color: page['textColor'],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  page['subtitle'],
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: page['textColor'].withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Texto descriptivo
                            _animateElements
                                ? Text(
                              page['text'],
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: page['textColor'].withOpacity(0.9),
                                height: 1.6,
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 500.ms)
                                .slideY(begin: 0.3, end: 0)
                                : Text(
                              page['text'],
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: page['textColor'].withOpacity(0.9),
                                height: 1.6,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Lista de características
                            _animateElements
                                ? Column(
                              children: [
                                ...page['features'].map<Widget>((feature) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: page['textColor'].withOpacity(0.8),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        feature,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: page['textColor'],
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                              ],
                            )
                                .animate()
                                .fadeIn(duration: 600.ms)
                                .slideY(begin: 0.2, end: 0)
                                : Column(
                              children: [
                                ...page['features'].map<Widget>((feature) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: page['textColor'].withOpacity(0.8),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        feature,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: page['textColor'],
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Indicador de página y botones
                Column(
                  children: [
                    // Indicador de página
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: _pages.length,
                        effect: ExpandingDotsEffect(
                          dotWidth: 10,
                          dotHeight: 10,
                          activeDotColor: _pages[_currentIndex]['textColor'],
                          dotColor: _pages[_currentIndex]['textColor'].withOpacity(0.3),
                          spacing: 8,
                          expansionFactor: 3,
                        ),
                      ).animate().fadeIn(duration: 500.ms),
                    ),

                    // Botones de navegación
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 40,
                        left: 32,
                        right: 32,
                      ),
                      child: _animateElements
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Botón de retroceso
                          if (_currentIndex > 0)
                            TextButton(
                              onPressed: _goToPrevious,
                              style: TextButton.styleFrom(
                                foregroundColor: _pages[_currentIndex]['textColor'],
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.chevron_left),
                                  Text('Atrás'),
                                ],
                              ),
                            )
                                .animate()
                                .fadeIn()
                          else
                            const SizedBox(width: 80),

                          // Botón principal
                          if (_currentIndex < _pages.length - 1)
                            ElevatedButton(
                              onPressed: _goToNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _pages[_currentIndex]['textColor'],
                                foregroundColor: _pages[_currentIndex]['color'],
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 2,
                                shadowColor: _pages[_currentIndex]['textColor']
                                    .withOpacity(0.3),
                              ),
                              child: const Text(
                                'Continuar',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                                .animate()
                                .fadeIn()
                                .scale()
                          else
                            ElevatedButton(
                              onPressed: () => _close(dontShow: true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _pages[_currentIndex]['textColor'],
                                foregroundColor: _pages[_currentIndex]['color'],
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 2,
                                shadowColor: _pages[_currentIndex]['textColor']
                                    .withOpacity(0.3),
                              ),
                              child: const Text(
                                'Empezar Ahora',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                                .animate()
                                .fadeIn()
                                .scale(),
                        ],
                      )
                          : const SizedBox(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Pintor personalizado para el fondo de puntos
class _DotsPainter extends CustomPainter {
  final Color color;

  _DotsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    final radius = 2.0;

    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        if ((i + j) % (spacing * 2) == 0) {
          canvas.drawCircle(Offset(i, j), radius, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}