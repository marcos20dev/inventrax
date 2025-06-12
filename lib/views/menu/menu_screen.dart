import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/dashboard_viewmodel.dart';  // Asegúrate de importar el ViewModel
import '../../widgets/widget_notification/Notification_Toast.dart';
import 'drawer_widget.dart';

class MenuScreen extends StatefulWidget {
  final String uid;
  final bool showWelcomeNotification;

  const MenuScreen({
    Key? key,
    required this.uid,
    this.showWelcomeNotification = false,
  }) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().fetchDashboardData();
    });

    if (widget.showWelcomeNotification) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showNotificationToast(
          context,
          message: "Inicio de sesión exitoso",
          type: NotificationType.success,
        );
      });
    }
  }
  List<Map<String, dynamic>> productosAgotandose = [
    {
      'nombre': 'Laptop Lenovo',
      'cantidad_disponible': 3,
      'precio_venta': 2500.00,
    },
    {
      'nombre': 'Protector Case',
      'cantidad_disponible': 2,
      'precio_venta': 35.00,
    },
    {
      'nombre': 'Monitor 24"',
      'cantidad_disponible': 4,
      'precio_venta': 1200.00,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF373940);
    final accentColor = const Color(0xFF00C9A7);
    final appbarColor = const Color(0xFFF8F9FA);
    final cardColor = Colors.white;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Menú'),
        backgroundColor: appbarColor,
        scrolledUnderElevation: 0, // Elimina el efecto al hacer scroll.
        surfaceTintColor: Colors.transparent,
      ),
      drawer: const MenuDrawer(),
      body: Consumer<DashboardViewModel>(
        builder: (context, viewModel, child) {
          final dashboardData = viewModel.dashboardData;
          final ingresos = dashboardData['ingresos'] ?? "0";
          final ventas = dashboardData['ventas'] ?? "0";
          final clientes = dashboardData['clientes'] ?? "0";

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección de resumen principal
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, const Color(0xFF393B42)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem2(
                          Row(
                            children: [
                              Text(
                                "S/", // Solo el símbolo del Sol peruano
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          "S/ $ingresos", // Aquí pasamos el valor de ingresos, con el símbolo S/ ya incluido
                          "Ingresos", // La etiqueta que representa el valor
                        ),

                        _buildSummaryItem(Icons.shopping_cart, ventas, "Ventas"),
                        _buildSummaryItem(Icons.people_alt, clientes, "Clientes"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Ingresos y gastos
              _buildSectionCard(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // **Título minimalista en mayúsculas**
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        "RESUMEN FINANCIERO",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                          letterSpacing: 1.8,
                        ),
                      ),
                    ),

                    // **Métricas en tarjeta neumórfica sutil**
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildUltraModernMetric(
                                "1,999.00",
                                "INGRESOS",
                                Colors.greenAccent[700]!,
                                Icons.trending_up_rounded,
                              ),
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.grey[200],
                            ),
                            Expanded(
                              child: _buildUltraModernMetric(
                                "450.00",
                                "GASTOS",
                                Colors.redAccent[400]!,
                                Icons.trending_down_rounded,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // **Sección de productos con scroll horizontal**
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "STOCK CRÍTICO",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[500],
                                  letterSpacing: 1.8,
                                ),
                              ),
                              Icon(
                                Icons.more_horiz,
                                color: Colors.grey[400],
                                size: 20,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          height: 160,
                          child: productosAgotandose.isEmpty
                              ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: Colors.greenAccent.withOpacity(0.6),
                                  size: 36,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "STOCK ÓPTIMO",
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 10,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          )
                              : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: productosAgotandose.length,
                            itemBuilder: (context, index) {
                              final producto = productosAgotandose[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: index == productosAgotandose.length - 1 ? 0 : 12,
                                ),
                                child: _buildUltraModernProductCard(producto),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

// **Componente de métrica ultra moderna**



// Lista de productos agotándose (datos de prueba)

              const SizedBox(height: 2),

                  // Objetivo y oportunidades
                  Row(
                    children: [
                      Expanded(
                        child: _buildSectionCard(
                          Column(
                            children: [
                              const Text(
                                "Objetivo",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 90,
                                    height: 90,
                                    child: CircularProgressIndicator(
                                      value: 0.75,
                                      strokeWidth: 8,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        accentColor,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: const [
                                      Text(
                                        "75%",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        "18.750",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSectionCard(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Oportunidades",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildOpportunityItem("Proyecto Alpha", "Juan Pérez"),
                              _buildOpportunityItem(
                                "Proyecto Beta",
                                "María García",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // Nuevos contactos
                  _buildSectionCard(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Nuevos contactos",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildContactItem(Icons.person, "3 Clientes", primaryColor),
                        _buildContactItem(Icons.flag, "1 Lead", accentColor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // UID
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Tu ID de usuario",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 24,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            widget.uid,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard(Widget child) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }

// Componente para métricas modernas
  Widget _buildModernMetricItem(
      BuildContext context, String value, String label, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

// Tarjeta de producto moderna
  Widget _buildProductCard(BuildContext context, Map<String, dynamic> producto) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 200),
        tween: Tween(begin: 0.95, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value as double,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                        Colors.redAccent.withOpacity(0.2),
                        Colors.orange.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: Colors.redAccent.withOpacity(0.8),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  producto['nombre'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${producto['cantidad_disponible']} units",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  "S/ ${producto['precio_venta']}",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.white70),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSummaryItem2(Widget icon, String value, String label) {
    return Column(
      children: [
        icon, // El icono solo muestra el símbolo "S/"
        const SizedBox(height: 4), // Reducir el espacio entre el valor y el label
        Text(
          value, // Aquí pasamos el valor de los ingresos
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label, // Aquí pasamos la etiqueta (Ej. "Ingresos")
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }


  Widget _buildUltraModernMetric(String value, String label, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

// **Tarjeta de producto ultra minimalista**
  Widget _buildUltraModernProductCard(Map<String, dynamic> producto) {
    return MouseRegion(
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.redAccent.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.redAccent,
                  size: 16,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                producto['nombre'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${producto['cantidad_disponible']} u.",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                "S/ ${producto['precio_venta']}",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpportunityItem(String project, String contact) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFF00C9A7),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                contact,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

