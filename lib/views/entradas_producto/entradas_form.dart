import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

import '../../repositories/producto_repository.dart';
import '../../services/ChangeNotifier.dart';
import '../../viewmodels/producto_viewmodel.dart';
import '../../widgets/widget_drawer/base_scaffold.dart';
import '../../widgets/widget_notification/Notification_Toast.dart';
import '../catologo/productos_form.dart';

class InventarioScreen extends StatefulWidget {
  @override
  _InventarioScreenState createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> productos = [];
  List<Map<String, dynamic>> productosFiltrados = [];
  final ProductoRepository _productoRepository = ProductoRepository();  // Añadir el repositorio aquí

  // Variables para búsqueda y filtros
  String _tipoBusqueda = 'Producto';
  String _terminoBusqueda = '';
  String _filtroStock = 'TODO';
  final TextEditingController _busquedaController = TextEditingController();

  // Variables para el refresh
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  bool _isRefreshing = false;

  Future<void> getProductos() async {
    try {
      final response = await _supabase.rpc('get_all_productos');
      if (response != null && response is List) {
        setState(() {
          productos = response
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          _aplicarFiltros();
        });
      }
    } catch (e) {
      print('Error al obtener productos: $e');
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    await getProductos();

    setState(() {
      _isRefreshing = false;
    });
  }

  void _aplicarFiltros() {
    List<Map<String, dynamic>> resultados = List.from(productos);

    if (_terminoBusqueda.isNotEmpty) {
      resultados = resultados.where((producto) {
        switch (_tipoBusqueda) {
          case 'Producto':
            return producto['nombre_producto']
                .toString()
                .toLowerCase()
                .contains(_terminoBusqueda.toLowerCase());
          case 'Proveedor':
            return producto['nombre_proveedor']
                .toString()
                .toLowerCase()
                .contains(_terminoBusqueda.toLowerCase());
          case 'Categoría':
            return producto['nombre_categoria']
                .toString()
                .toLowerCase()
                .contains(_terminoBusqueda.toLowerCase());
          default:
            return true;
        }
      }).toList();
    }

    switch (_filtroStock) {
      case 'STOCK BAJO':
        resultados = resultados
            .where((p) => int.parse(p["stock_actual"].toString()) < 5)
            .toList();
        break;
      case 'STOCK MEDIO':
        resultados = resultados.where((p) {
          int stock = int.parse(p["stock_actual"].toString());
          int stockInicial = int.parse(p["cantidad_inicial"].toString());
          double porcentaje = (stock / stockInicial) * 100;
          return porcentaje >= 20 && porcentaje < 50;
        }).toList();
        break;
      case 'STOCK ALTO':
        resultados = resultados.where((p) {
          int stock = int.parse(p["stock_actual"].toString());
          int stockInicial = int.parse(p["cantidad_inicial"].toString());
          double porcentaje = (stock / stockInicial) * 100;
          return porcentaje >= 50;
        }).toList();
        break;
      case 'TODO':
      default:
        break;
    }

    setState(() {
      productosFiltrados = resultados;
    });
  }


  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Evita cerrar tocando fuera
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final primaryColor = Colors.teal.shade400;

        return PopScope(
          canPop: false, // Bloquea el cierre con gesto
          child: Dialog(
            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
            elevation: 0,
            insetAnimationDuration: const Duration(milliseconds: 300),
            insetAnimationCurve: Curves.easeOutQuint,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ícono animado
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.delete_rounded,
                      size: 48,
                      color: Colors.red.shade400,
                      key: ValueKey(isDarkMode),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Título con tipografía moderna
                  Text(
                    'Eliminar Producto',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : Colors.grey[900],
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtítulo con opacidad dinámica
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: 0.8,
                    child: Text(
                      'Esta acción no se puede deshacer. ¿Estás seguro?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botones con diseño moderno
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botón Cancelar
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isDarkMode
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!,
                              ),
                            ),
                            backgroundColor: Colors.transparent,
                          ),
                          child: Text(
                            'CANCELAR',
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey[300]
                                  : Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Botón Eliminar
                      Expanded(
                        child: Material(
                          borderRadius: BorderRadius.circular(12),
                          elevation: 0,
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.pop(context, true),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.red.shade400,
                                    Colors.red.shade600,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'ELIMINAR',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    getProductos();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = Colors.teal.shade400;
    final Color cardColor = isDarkMode ? Colors.grey[850]! : Colors.white;

    return BaseScaffold(
      title: 'Inventario',
      backgroundColor: isDarkMode ? Colors.grey[900]! : Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: productos.isEmpty
            ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)))
            : RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _handleRefresh,
          displacement: 40,
          color: primaryColor,
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
          strokeWidth: 3,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Improved search bar
                Container(
                  margin: EdgeInsets.only(top: 16, bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFFDFDFD),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        height: 48,
                        child: DropdownButton<String>(
                          value: _tipoBusqueda,
                          items: ['Producto', 'Proveedor', 'Categoría'].map(
                                (String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _tipoBusqueda = newValue!;
                              _aplicarFiltros();
                            });
                          },
                          underline: Container(),
                          icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                          dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[800] : Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: TextField(
                            controller: _busquedaController,
                            decoration: InputDecoration(
                              hintText: 'Buscar...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),  // Adjust padding to center vertically
                              suffixIcon: _terminoBusqueda.isNotEmpty
                                  ? IconButton(
                                icon: Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _terminoBusqueda = '';
                                    _busquedaController.clear();
                                    _aplicarFiltros();
                                  });
                                },
                              )
                                  : Icon(Icons.search, size: 20),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _terminoBusqueda = value;
                                _aplicarFiltros();
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Improved filter chips
                Container(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      SizedBox(width: 8),
                      _buildFilterChip('TODO', _filtroStock == 'TODO'),
                      _buildFilterChip('STOCK BAJO', _filtroStock == 'STOCK BAJO'),
                      _buildFilterChip('STOCK MEDIO', _filtroStock == 'STOCK MEDIO'),
                      _buildFilterChip('STOCK ALTO', _filtroStock == 'STOCK ALTO'),
                      SizedBox(width: 8),
                    ],
                  ),
                ),

                // Stats cards
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          Icons.inventory_2,
                          productosFiltrados.length.toString(),
                          "Productos",
                          primaryColor,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          Icons.warning,
                          productosFiltrados
                              .where((p) => int.parse(p["stock_actual"].toString()) < 5)
                              .length
                              .toString(),
                          "Bajo Stock",
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),

                // Product list
                _isRefreshing
                    ? Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)),
                )
                    : ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: productosFiltrados.length,
                  separatorBuilder: (context, index) => Divider(height: 20),
                  itemBuilder: (context, index) {
                    final producto = productosFiltrados[index];
                    final stockActual = int.parse(producto["stock_actual"].toString());
                    final stockInicial = int.parse(producto["cantidad_inicial"].toString());
                    final porcentajeStock = (stockActual / stockInicial) * 100;

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      producto["nombre_producto"],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      producto["nombre_categoria"],
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Proveedor: ${producto["nombre_proveedor"]}",
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Stock",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "$stockActual/$stockInicial",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Compra",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "S/${producto["precio_compra"].toString()}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Venta",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "S/${producto["precio_venta"].toString()}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: porcentajeStock / 100,
                                        backgroundColor: isDarkMode
                                            ? Colors.grey[800]!
                                            : Colors.grey[200]!,
                                        color: _getStockColor(porcentajeStock),
                                        minHeight: 8,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "${porcentajeStock.toStringAsFixed(0)}%",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: _getStockColor(porcentajeStock),
                                    ),
                                  ),
                                  Spacer(),


                                  IconButton(
                                    icon: Icon(Icons.delete, size: 20),
                                    color: Colors.red[400],
                                    onPressed: () async {
                                      final productoId = producto['id_producto'].toString(); // Convertir a String
                                      print("Producto ID: $productoId");

                                      final bool? confirmed = await _showDeleteConfirmationDialog(context);
                                      if (confirmed == true) {
                                        final success = await _productoRepository.eliminarProducto(productoId);

                                        if (success) {
                                          // Eliminar localmente de la lista
                                          setState(() {
                                            productosFiltrados.removeWhere((p) => p['id_producto'].toString() == productoId);
                                          });

                                          // Usar el NotificationToast para mostrar el mensaje de éxito
                                          showNotificationToast(
                                            context,
                                            message: "Producto eliminado correctamente",
                                            type: NotificationType.success,
                                          );
                                        } else {
                                          // Usar el NotificationToast para mostrar el mensaje de error
                                          showNotificationToast(
                                            context,
                                            message: "No se pudo eliminar el producto",
                                            type: NotificationType.error,
                                          );
                                        }
                                      }
                                    },
                                  ),

                                  IconButton(
                                    icon: Icon(Icons.add, size: 20),
                                    color: primaryColor,
                                    onPressed: () => _mostrarDialogoAgregarStock(
                                      context,
                                      producto,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductosFormScreen()),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        elevation: 4,
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String text, bool isSelected) {
    final Color primaryColor = Colors.teal.shade400;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(text),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            _filtroStock = selected ? text : 'TODO';
            _aplicarFiltros();
          });
        },
        selectedColor: primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontSize: 13,
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  void _mostrarDialogoAgregarStock(BuildContext context, Map<String, dynamic> producto) {
    final TextEditingController cantidadController = TextEditingController();
    final primaryColor = Colors.teal.shade400;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          elevation: 0,
          insetPadding: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con icono
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.inventory_rounded,
                            color: primaryColor, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "Añadir Stock",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.white : Colors.grey[900],
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Información del producto
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          producto["nombre_producto"],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : Colors.grey[900],
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                            children: [
                              const TextSpan(text: "Stock actual: "),
                              TextSpan(
                                text: "${producto["stock_actual"]}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Campo de entrada
                  TextField(
                    controller: cantidadController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.grey[900],
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      labelText: "Cantidad a añadir",
                      labelStyle: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      filled: true,
                      fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 18),
                      suffixIcon: Icon(Icons.exposure_plus_1_rounded,
                          color: primaryColor),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botones
                  Row(
                    children: [
                      // Botón Cancelar
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "CANCELAR",
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Botón Añadir
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final cantidad = int.tryParse(cantidadController.text) ?? 0;

                            if (cantidad > 0) {
                              final int idProducto = producto['id_producto'];
                              final int idProveedor = 1; // ← Reemplaza con proveedor real
                              final double precioCompra = double.tryParse(producto['precio_venta'].toString()) ?? 0;
                              final String? idUsuario = Provider.of<UserSession>(context, listen: false).uid;

                              if (idUsuario == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("⚠️ Usuario no autenticado")),
                                );
                                return;
                              }

                              try {
                                await ProductoRepository().aumentarStockProducto(
                                  idProducto: idProducto,
                                  cantidad: cantidad,
                                  idProveedor: idProveedor,
                                  precioCompra: precioCompra,
                                  idUsuario: idUsuario,
                                );

                                Navigator.pop(context); // Cierra el diálogo si todo fue bien
                                _mostrarSnackbarConfirmacion(context, cantidad);
                              } catch (e) {
                                print("❌ Error al actualizar stock: $e");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("❌ Error al actualizar stock")),
                                );
                              }
                            } else {
                              HapticFeedback.lightImpact(); // feedback si no se ingresó cantidad válida
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: const Text(
                            "AÑADIR",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }



  void _mostrarSnackbarConfirmacion(BuildContext context, int cantidad) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "✅ Stock actualizado (+$cantidad unidades)",
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        elevation: 0,
        duration: const Duration(seconds: 2),
      ),
    );
  }



  Color _getStockColor(double porcentaje) {
    if (porcentaje < 20) return Colors.red[600]!;
    if (porcentaje < 50) return Colors.orange[600]!;
    return Colors.green[600]!;
  }
}
