import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../services/ChangeNotifier.dart';
import '../../viewmodels/dashboard_viewmodel.dart';  // Asegúrate de importar el ViewModel
import '../../widgets/widget_notification/Notification_Toast.dart';
import 'drawer_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MenuScreen extends StatefulWidget {
  final String uid;
  final int rolId;

  final bool showWelcomeNotification;

  const MenuScreen({
    Key? key,
    required this.uid,
    required this.rolId,

    this.showWelcomeNotification = false,
  }) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();

    context.read<DashboardViewModel>().fetchProductosCriticos();
    context.read<DashboardViewModel>().fetchClientesTopCompradores();
    context.read<DashboardViewModel>().fetchProductosMasVendidos();
    context.read<DashboardViewModel>().fetchVentasPorDia();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userSession = context.read<UserSession>();

      // Inicializar el provider con UID y RolID
      userSession.setUid(widget.uid);
      userSession.setRolId(widget.rolId);

      print("✅ Provider inicializado correctamente");

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



  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF373940);
    final accentColor = const Color(0xFF00C9A7);
    final appbarColor = const Color(0xFFF8F9FA);
    final cardColor = Colors.white;
    final productosAgotandose = context.watch<DashboardViewModel>().productosCriticos;

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
          final productosAgotandose = viewModel.productosCriticos;
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
                                "S/",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          "S/ $ingresos",
                          "Ingresos",
                        ),
                        _buildSummaryItem(Icons.shopping_cart, ventas, "Ventas"),
                        _buildSummaryItem(Icons.people_alt, clientes, "Clientes"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStockCriticoSection(productosAgotandose),
                  const SizedBox(height: 2),
                  _buildTopClientesSection(context.watch<DashboardViewModel>().clientesTop),
                  const SizedBox(height: 2),
                  _buildTopProductosSection(context.watch<DashboardViewModel>().productosTopVendidos),
                  const SizedBox(height: 2),
                  _buildVentasChart(context.watch<DashboardViewModel>().ventasPorDia),
                  const SizedBox(height: 2),
                  _buildProductosMasVendidosChart(context.watch<DashboardViewModel>().productosTopVendidos),
                  const SizedBox(height: 24),

                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildStockCriticoSection(List<Map<String, dynamic>> productosAgotandose) {
    return _buildSectionCard(
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
            height: 180, // ligeramente más alto para evitar overflow
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
  Widget _buildTopClientesSection(List<Map<String, dynamic>> clientesTop) {
    return _buildSectionCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber[700], size: 20),
              const SizedBox(width: 8),
              Text(
                "TOP CLIENTES",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lista
          ...clientesTop.map((cliente) {
            final telefono = cliente['telefono'];
            final nombre = cliente['cliente'];
            final productos = cliente['total_productos_comprados'];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE0F2F1),
                      border: Border.all(color: const Color(0xFF26A69A), width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      nombre?.isNotEmpty == true ? nombre[0].toUpperCase() : "?",
                      style: const TextStyle(
                        color: Color(0xFF26A69A),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nombre y datos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombre ?? "Cliente sin nombre",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "$productos unidades compradas",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Menú de acciones
                  if (telefono != null && telefono.toString().isNotEmpty)
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(Icons.phone, color: Color(0xFF383A41), size: 20),
                              const SizedBox(width: 10),
                              const Text("Llamar"),
                            ],
                          ),
                          onTap: () {
                            final uri = Uri.parse('tel:$telefono');
                            launchUrl(uri);
                          },
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/whatsapp.svg',
                                height: 20,
                                width: 20,
                              ),
                              const SizedBox(width: 10),
                              const Text("WhatsApp"),
                            ],
                          ),
                          onTap: () {
                            final uri = Uri.parse('https://wa.me/$telefono');
                            launchUrl(uri);
                          },
                        ),
                      ],
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
  Widget _buildTopProductosSection(List<Map<String, dynamic>> productosTop) {
    return _buildSectionCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.orangeAccent, Colors.deepOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.trending_up_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                "PRODUCTOS DESTACADOS",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[800],
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 8),
          ...productosTop.asMap().entries.map((entry) {
            final index = entry.key;
            final producto = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: index < 3
                      ? _getRankingColor(index)
                      : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "${index + 1}",
                  style: TextStyle(
                    color: index < 3 ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto['nombre_producto'] ?? 'Producto',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${producto['total_vendido']} unidades vendidas",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    "${(producto['total_vendido'] as num).toInt()} u.",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Color _getRankingColor(int index) {
    switch (index) {
      case 0: return Colors.amber[700]!;
      case 1: return Colors.blueGrey[500]!;
      case 2: return Colors.brown[400]!;
      default: return Colors.grey[200]!;
    }
  }


  Widget _buildVentasChart(List<Map<String, dynamic>> ventasPorDia) {
    if (ventasPorDia.isEmpty) {
      return const Text("Sin datos de ventas recientes");
    }

    return _buildSectionCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "VENTAS ÚLTIMOS 7 DÍAS",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index >= 0 && index < ventasPorDia.length) {
                          final fecha = ventasPorDia[index]['fecha'];
                          return Text(fecha.substring(5), style: const TextStyle(fontSize: 10));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                barGroups: ventasPorDia.asMap().entries.map((entry) {
                  final i = entry.key;
                  final data = entry.value;
                  return BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                      toY: double.tryParse(data['total_ventas'].toString()) ?? 0,
                      width: 14,
                      color: Colors.teal,
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildProductosMasVendidosChart(List<Map<String, dynamic>> productosTop) {
    if (productosTop.isEmpty) {
      return _buildSectionCard(const Text("Sin datos de productos más vendidos"));
    }

    return _buildSectionCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.bar_chart_rounded, color: Colors.deepOrange),
              SizedBox(width: 8),
              Text(
                "TOP PRODUCTOS MÁS VENDIDOS",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: productosTop.length * 40, // dinámico según número de productos
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 120,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < productosTop.length) {
                          final nombre = productosTop[index]['nombre_producto'];
                          return Text(
                            nombre,
                            style: const TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: productosTop.asMap().entries.map((entry) {
                  final index = entry.key;
                  final producto = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: double.tryParse(producto['total_vendido'].toString()) ?? 0,
                        color: Colors.teal,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: productosTop.first['total_vendido'].toDouble() + 2,
                          color: Colors.grey[200],
                        ),
                      )
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
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
                producto['nombre_producto'] ?? 'Sin nombre',
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
                "${producto['cantidad_disponible'] ?? 0} u.",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                "S/ ${producto['precio_venta'] ?? 0}",
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

