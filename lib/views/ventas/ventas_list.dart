import 'package:flutter/material.dart';
import 'package:inventrax/views/ventas/venta_detail.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/venta/registro_venta_viewmodel.dart';
import '../../widgets/widget_texfield/venta_list_item.dart';
import '../../widgets/widget_drawer/base_scaffold.dart';
import '../../widgets/widget_notification/Notification_Toast.dart';

class VentaListScreen extends StatefulWidget {
  @override
  _VentaListScreenState createState() => _VentaListScreenState();
}

class _VentaListScreenState extends State<VentaListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _ventas = [];
  List<Map<String, dynamic>> _filteredVentas = [];
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchVentas();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _fetchVentas() async {
    setState(() => _isLoading = true);
    final viewModel = context.read<RegistroVentaViewModel>();
    await viewModel.obtenerVentas();

    setState(() {
      _ventas = viewModel.ventas.map((venta) {
        return {
          'idVenta': venta.idVenta,
          'fecha_venta': venta.fechaVenta,
          'total': venta.total,
        };
      }).toList();
      _filteredVentas = List.from(_ventas);
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty && _selectedDate == null) {
        _filteredVentas = List.from(_ventas);
      } else {
        _filteredVentas = _ventas.where((venta) {
          bool matchesQuery = venta['idVenta'].toString().contains(query) ||
              venta['total'].toString().contains(query);
          bool matchesDate = _selectedDate == null ||
              (_selectedDate != null &&
                  venta['fecha_venta'] != null &&
                  DateFormat('yyyy-MM-dd').format(venta['fecha_venta']) ==
                      DateFormat('yyyy-MM-dd').format(_selectedDate!));
          return matchesQuery && matchesDate;
        }).toList();
      }
    });
  }

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
      _onSearchChanged();
    }
  }

  // Método para ver los detalles de la venta
  void _viewVentaDetails(int idVenta) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VentaDetailScreen(idVenta: idVenta),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.tealAccent.shade400
        : Colors.teal.shade400;

    return BaseScaffold(
      title: 'Ventas',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar ventas por ID o Total...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                hintStyle: TextStyle(color: Colors.grey),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 1.5),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    hintText: 'Seleccionar fecha...',
                    prefixIcon: Icon(Icons.calendar_today, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(top: 8, bottom: 16),
              itemCount: _filteredVentas.length,
              itemBuilder: (context, index) {
                final venta = _filteredVentas[index];
                return VentaListItem(
                  venta: venta,
                  primaryColor: primaryColor,
                  onEdit: (id) => _viewVentaDetails(id), // Redirigir a detalles de la venta
                );
              },
            ),
          )

        ],
      ),
    );
  }
}
