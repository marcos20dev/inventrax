import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../../services/ChangeNotifier.dart';
import '../../widgets/widget_notification/Notification_Toast.dart';
import 'drawer_widget.dart';
import 'package:provider/provider.dart';

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
      context.read<UserSession>().setUid(widget.uid);
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Menú'),
        backgroundColor: appbarColor,
        scrolledUnderElevation: 0, // Elimina el efecto al hacer scroll.
        surfaceTintColor: Colors.transparent,
      ),
      drawer: const MenuDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
                    _buildSummaryItem(
                      Icons.attach_money,
                      "12.345,67",
                      "Ingresos",
                    ),
                    _buildSummaryItem(Icons.shopping_cart, "14", "Ventas"),
                    _buildSummaryItem(Icons.people_alt, "12", "Contactos"),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Filtros de tiempo
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children:
                      [
                            _buildTimeFilter("1 semana", false),
                            _buildTimeFilter("4 semanas", true),
                            _buildTimeFilter("1 año", false),
                            _buildTimeFilter("MTD", false),
                          ]
                          .map(
                            (widget) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: widget,
                            ),
                          )
                          .toList(),
                ),
              ),
              const SizedBox(height: 8),

              // Ingresos y gastos
              _buildSectionCard(
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMetricItem("1.999,00", "Ingresos", accentColor),
                          _buildMetricItem(
                            "450,00",
                            "Gastos",
                            Colors.redAccent,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentColor.withOpacity(0.1),
                            accentColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.show_chart,
                            size: 40,
                            color: accentColor.withOpacity(0.3),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Gráfico interactivo",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

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

  Widget _buildTimeFilter(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const
        Color(0xFF323337) :
        Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ?
          const Color(0xFF2E394B) :
          Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.grey[700],
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildMetricItem(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
      ],
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
