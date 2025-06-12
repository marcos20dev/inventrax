import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventarioScreen extends StatefulWidget {
  @override
  _InventarioScreenState createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> productos = [];

  // Llamar a Supabase para obtener los productos
  Future<void> getProductos() async {
    try {
      final response = await _supabase.rpc('get_all_productos');
      if (response != null && response is List) {
        setState(() {
          productos = response.map((item) => Map<String, dynamic>.from(item)).toList();
        });
      }
    } catch (e) {
      print('Error al obtener productos: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getProductos();  // Obtener productos al cargar la pantalla
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color cardColor = isDarkMode ? Colors.grey[850]! : Color(0xFFF9F5F0);

    return Scaffold(
      backgroundColor:  Color(0xFFF5F0EA),
      appBar: AppBar(
        title: const Text(
          "Inventario",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        actions: [
          IconButton(
            icon: Icon(Icons.add, size: 24),
            onPressed: () => _mostrarDialogoAgregar(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: productos.isEmpty
            ? Center(child: CircularProgressIndicator())  // Muestra un indicador mientras se cargan los datos
            : Column(
          children: [
            // Resumen minimalista
            Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(Icons.inventory, productos.length.toString(), "Productos"),
                  _buildStatItem(Icons.warning_amber_rounded,
                      productos.where((p) => int.parse(p["stock_actual"].toString()) < 5).length.toString(),
                      "Bajo Stock"
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Lista de productos
            Expanded(
              child: ListView.separated(
                itemCount: productos.length,
                separatorBuilder: (context, index) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final producto = productos[index];
                  final stockActual = int.parse(producto["stock_actual"].toString());
                  final stockInicial = int.parse(producto["cantidad_inicial"].toString());
                  final porcentajeStock = (stockActual / stockInicial) * 100;

                  return Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
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
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      producto["nombre_categoria"],
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  InkWell(
                                    onTap: () => _mostrarDialogoAgregarStock(context, producto),
                                    child: Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        size: 18,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Proveedor: ${producto["nombre_proveedor"]}",
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 12),
                          // Barra de progreso con porcentaje
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Stock: $stockActual/$stockInicial",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    "${porcentajeStock.toStringAsFixed(0)}%",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: _getStockColor(porcentajeStock),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: porcentajeStock / 100,
                                  backgroundColor: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                                  color: _getStockColor(porcentajeStock),
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Compra:",
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    "S/${producto["precio_compra"].toString()}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Venta:",
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    "S/${producto["precio_venta"].toString()}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoAgregar(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Agregar Producto"),
        content: const Text("Formulario para agregar nuevo producto..."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoAgregarStock(BuildContext context, Map<String, dynamic> producto) {
    final TextEditingController cantidadController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Añadir stock"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Producto: ${producto["nombre_producto"]}"),
              SizedBox(height: 8),
              Text("Stock actual: ${producto["stock_actual"]}"),
              SizedBox(height: 16),
              TextField(
                controller: cantidadController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Cantidad a añadir",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                final cantidad = int.tryParse(cantidadController.text) ?? 0;
                if (cantidad > 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Stock actualizado (+$cantidad unidades)"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: Text("Añadir"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 22, color: Colors.grey[600]),
        SizedBox(height: 4),
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
    );
  }

  Color _getStockColor(double porcentaje) {
    if (porcentaje < 20) return Colors.red[600]!;
    if (porcentaje < 50) return Colors.orange[600]!;
    return Colors.green[600]!;
  }
}
