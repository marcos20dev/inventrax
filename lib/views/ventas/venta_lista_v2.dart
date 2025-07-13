import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventrax/views/ventas/venta_detail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:supabase/supabase.dart';

import '../../widgets/widget_drawer/base_scaffold.dart';

class VentaListScreen extends StatefulWidget {
  @override
  _VentaListScreenState createState() => _VentaListScreenState();
}

class _VentaListScreenState extends State<VentaListScreen> {
  late final SupabaseClient _supabase;
  List<Map<String, dynamic>> allSalesData = [];
  List<Map<String, dynamic>> filteredSalesData = [];
  TextEditingController searchController = TextEditingController();
  DateTimeRange? dateRange;
  final primaryColor = Colors.teal.shade400;
  final accentColor = Colors.teal.shade100;
  bool isLoading = true;
  Set<int> seenSales = Set<int>();  // Usamos un Set para evitar duplicados por el ID de la venta
  List<Map<String, dynamic>> uniqueSalesData = [];

  @override
  void initState() {
    super.initState();
    _supabase = Supabase.instance.client;
    _fetchSalesData();
    searchController.addListener(_filterSales);
  }

  int _calculateTotalProducts() {
    return filteredSalesData.fold(0, (total, sale) {
      final cantidad = sale['Cantidad de Productos'];
      return total +
          (cantidad is int ? cantidad : int.tryParse(cantidad.toString()) ?? 0);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSalesData() async {
    setState(() {
      isLoading = true;
    });

    // Hacer la consulta RPC
    final response = await _supabase.rpc('get_sales_data');

    // Imprimir el tipo de la respuesta y su contenido
    print('Response: $response');
    print('Response Type: ${response.runtimeType}');

    // Verificar si la respuesta es una lista o tiene la estructura esperada
    if (response is List) {
      print('Respuesta es una lista con ${response.length} elementos');
    } else {
      print('Respuesta no es una lista');
    }

    // Ahora, verificamos si la respuesta tiene los datos que necesitamos
    try {
      // Si la respuesta es válida, se espera que `data` esté en la respuesta
      if (response != null && response is List) {
        print('Datos recibidos: ${response.toString()}');

        // Deduplicar los datos de ventas basándonos en "Venta #"
        uniqueSalesData = [];
        seenSales.clear();  // Limpiamos los IDs vistos para empezar de nuevo
        for (var sale in response) {
          int saleId = sale['Venta #'];
          if (!seenSales.contains(saleId)) {
            seenSales.add(saleId);
            uniqueSalesData.add(sale);
          }
        }

        setState(() {
          allSalesData = List<Map<String, dynamic>>.from(uniqueSalesData);
          filteredSalesData = List.from(allSalesData);
          isLoading = false;
        });
      } else {
        print('Error: No se recibió una lista válida.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar los datos de ventas')),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error procesando la respuesta: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hubo un error al procesar los datos')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterSales() {
    final query = searchController.text.toLowerCase();

    setState(() {
      filteredSalesData = allSalesData.where((sale) {
        final matchesSearch = query.isEmpty ||
            sale["Cliente"].toString().toLowerCase().contains(query) ||
            sale["Venta #"].toString().contains(query);

        final matchesDate = dateRange == null ||
            (_parseDateTime(sale["Fecha de Venta"]).isAfter(dateRange!.start) &&
                _parseDateTime(sale["Fecha de Venta"]).isBefore(dateRange!.end));

        return matchesSearch && matchesDate;
      }).toList();
    });
  }

  DateTime _parseDateTime(dynamic dateTimeValue) {
    if (dateTimeValue is DateTime) {
      return dateTimeValue;
    } else if (dateTimeValue is String) {
      return DateTime.parse(dateTimeValue);
    }
    return DateTime.now();
  }

  String _formatDateTime(dynamic dateTimeValue) {
    try {
      final dateTime = _parseDateTime(dateTimeValue);
      return DateFormat('dd MMM, HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeValue.toString();
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = dateRange ?? DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 7)),
      end: DateTime.now(),
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: initialDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.zero,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dateRange = picked;
        _filterSales();
      });
    }
  }

  void _clearFilters() {
    setState(() {
      dateRange = null;
      searchController.clear();
      filteredSalesData = List.from(allSalesData);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isLoading) {
      return Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
      );
    }

    final totalSales = filteredSalesData.isNotEmpty ?
    filteredSalesData.first["Total Generado por Todas las Ventas"]?.toString() ?? "0" : "0";
    final topProduct = filteredSalesData.isNotEmpty ?
    filteredSalesData.first["Producto Más Vendido"]?.toString() ?? "N/A" : "N/A";
    final timesSold = filteredSalesData.isNotEmpty ?
    filteredSalesData.first["Veces Vendido"]?.toString() ?? "0" : "0";

    return BaseScaffold(
      title: 'Historial de Ventas',
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _fetchSalesData,
        color: primaryColor,
        child: CustomScrollView(
          slivers: [

            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : accentColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Producto Destacado',
                                  style: TextStyle(
                                    color: isDark ? Colors.grey[300] : Colors.teal[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  topProduct,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Vendido $timesSold veces',
                                  style: TextStyle(
                                    color: isDark ? Colors.grey[400] : Colors.teal[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'S/$totalSales',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total generado',
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatChip(
                                context,
                                '${filteredSalesData.length}',
                                'Ventas',
                                Icons.receipt,
                                isDark,
                              ),
                              _buildStatChip(
                                context,
                                _calculateTotalProducts().toString(),
                                'Productos',
                                Icons.shopping_bag,
                                isDark,
                              ),
                              _buildStatChip(
                                context,
                                timesSold,
                                'Top Ventas',
                                Icons.star,
                                isDark,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar ventas...',
                          prefixIcon: Icon(Icons.search, color: primaryColor),
                          filled: true,
                          fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.calendar_today, color: primaryColor),
                        onPressed: () => _selectDateRange(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (filteredSalesData.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 50, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No se encontraron ventas',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      TextButton(
                        onPressed: _clearFilters,
                        child: Text(
                          'Limpiar filtros',
                          style: TextStyle(color: primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final sale = filteredSalesData[index];
                    return _buildSaleCard(context, sale, isDark);
                  },
                  childCount: filteredSalesData.length,
                ),
              ),
          ],
        ),
      ),

    );
  }

  Widget _buildStatChip(BuildContext context, String value, String label, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[700] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: primaryColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaleCard(BuildContext context, Map<String, dynamic> sale, bool isDark) {
    final isPaid = sale["Estado de la Venta"] == "pagado";
    final saleId = sale["Venta #"];

    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDark
    ? [Colors.grey[800]!, Colors.grey[850]!]
        : [Colors.white, Colors.grey[50]!],
    ),
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 10,
    offset: const Offset(0, 4),
    ),
    ],
    ),
    child: Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: () {
    // Navegar a la pantalla de detalles de la venta
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) => VentaDetailScreen(idVenta: saleId), // Pasamos el ID de la venta
    ),
    );
    },
    child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Text(
    'Venta #${sale["Venta #"]?.toString() ?? "N/A"}', // Validación para nulos
    style: TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: isDark ? Colors.white : Colors.grey[800],
    ),
    ),
    Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
    color: isPaid
    ? Colors.green.withOpacity(isDark ? 0.2 : 0.1)
        : Colors.orange.withOpacity(isDark ? 0.2 : 0.1),
    borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
    sale["Estado de la Venta"]?.toString().toUpperCase() ?? "Desconocido", // Validación para nulos
    style: TextStyle(
    color: isPaid ? Colors.green : Colors.orange,
    fontSize: 12,
    fontWeight: FontWeight.bold,
    ),
    ),
    ),
    ],
    ),
    const SizedBox(height: 12),
    Row(
    children: [
    Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
    colors: isDark
    ? [Colors.blueGrey[700]!, Colors.grey[800]!]
        : [accentColor, Colors.grey[100]!],
    ),
    ),
    child: Icon(
    Icons.person_outline,
    color: isDark ? Colors.teal[200] : primaryColor,
    ),
    ),
    const SizedBox(width: 12),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    getClientName(sale),
    style: TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 15,
    color: isDark ? Colors.white : Colors.grey[800],
    ),
    ),
    const SizedBox(height: 4),
    Text(
    _formatDateTime(sale["Fecha de Venta"]) ?? "Fecha no disponible", // Validación para nulos
    style: TextStyle(
    color: isDark ? Colors.grey[400] : Colors.grey[600],
    fontSize: 12,
    ),
    ),
    ],
    ),
    ),
    Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
    Text(
    'S/${sale["Total de Venta"]?.toString() ?? "0.00"}', // Validación para nulos
    style: TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: primaryColor,
    ),
    ),
    const SizedBox(height: 4),
    Text(
    '${sale["Cantidad de Productos"]?.toString() ?? "0"} producto(s)', // Validación para nulos
    style: TextStyle(
    color: isDark ? Colors.grey[400] : Colors.grey[600],
    fontSize: 12,
    ),
    ),
    ],
    ),
    ],
    ),
    const SizedBox(height: 12),

    ],
    ),
    ),
    ),
    ),
    );
  }






  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon, bool isDark, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? Colors.blueGrey[800] : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? Colors.teal[200] : primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isHighlighted
                        ? primaryColor
                        : isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
String getClientName(Map<String, dynamic> sale) {
  // Verifica si hay apellido, de lo contrario solo devuelve el nombre
  return sale["Apellido"]?.isNotEmpty == true
      ? '${sale["Cliente"]} ${sale["Apellido"]}'
      : sale["Cliente"] ?? 'Nombre no disponible';
}
