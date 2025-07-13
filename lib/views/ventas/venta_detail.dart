import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import '../../repositories/venta_repository.dart';
import 'package:path_provider/path_provider.dart';

class VentaDetailScreen extends StatefulWidget {
  final int idVenta;

  const VentaDetailScreen({required this.idVenta});

  @override
  _VentaDetailScreenState createState() => _VentaDetailScreenState();
}

class _VentaDetailScreenState extends State<VentaDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic> ventaData = {};
  List<dynamic> productos = [];
  final WidgetsToImageController controller = WidgetsToImageController();
  final primaryColor = Colors.teal.shade400;
  final accentColor = Colors.teal.shade100;

  @override
  void initState() {
    super.initState();
    _fetchVentaDetail();
  }

  Future<void> _fetchVentaDetail() async {
    try {
      final ventaRepository = VentaRepository(Supabase.instance.client);
      final detalles = await ventaRepository.obtenerDetallesVenta(widget.idVenta);
      setState(() {
        ventaData = detalles;
        productos = detalles['productos'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print("Error al obtener los detalles: $e");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los detalles')),
      );
    }
  }

  Future<void> _shareReceipt() async {
    try {
      final size = MediaQuery.of(context).size;
      final pixelRatio = MediaQuery.of(context).devicePixelRatio;

      final bytes = await controller.capture(
        pixelRatio: pixelRatio * 0.8,
      );

      if (bytes != null) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/recibo_${ventaData['info_venta']?['id_venta']}.jpg');
        await file.writeAsBytes(bytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Recibo de compra #${ventaData['info_venta']?['id_venta']}',
          sharePositionOrigin: Rect.fromLTWH(0, 0, size.width, size.height * 0.7),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al compartir el recibo')),
        );
      }
      print('Error al compartir recibo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoadingScreen();
    if (ventaData.isEmpty) return _buildErrorScreen();

    final infoVenta = ventaData['info_venta'] ?? {};
    final cliente = ventaData['cliente'] ?? {};

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Recibo #${infoVenta['id_venta']}',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black87),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: primaryColor),
            onPressed: _shareReceipt,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: WidgetsToImage(
                controller: controller,
                child: _buildReceiptContent(infoVenta, cliente),
              ),
            ),
          ),
          _buildShareButton(),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Recibo de Venta', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(primaryColor)),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Recibo no disponible', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(child: Text('No se encontró el recibo solicitado')),
    );
  }

  Widget _buildReceiptContent(Map<String, dynamic> infoVenta, Map<String, dynamic> cliente) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Encabezado
          Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: accentColor, width: 2))),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.shopping_cart, size: 30, color: primaryColor),
                  ),
                  SizedBox(height: 2),
                  Text('Inversiones TECLUK ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      )),
                  SizedBox(height: 4),
                  Text(DateFormat('dd/MM/yyyy - HH:mm').format(DateTime.parse(infoVenta['fecha']))),
                ],
              ),
            ),
          ),

          SizedBox(height: 12),

          // Información de venta
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recibo:', style: TextStyle(color: Colors.grey[600])),
              Text('#${infoVenta['id_venta']}',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),

          SizedBox(height: 16),

          // Información del cliente
          Container(
            width: double.infinity, // Asegura que el contenedor ocupe todo el ancho
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CLIENTE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    )),
                SizedBox(height: 8),
                Text(cliente['nombre_cliente'] ?? 'Cliente no especificado',
                    style: TextStyle(fontSize: 16)),
                if (cliente['telefono'] != null)
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text('Tel: ${cliente['telefono']}',
                        style: TextStyle(color: Colors.grey[600])),
                  ),
                if (cliente['correo'] != null)
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text('Email: ${cliente['correo']}',
                        style: TextStyle(color: Colors.grey[600])),
                  ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Productos
          Text('PRODUCTOS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              )),
          SizedBox(height: 8),

          ...productos.map((producto) {
            final infoProducto = producto['productos'] ?? {};
            return Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(infoProducto['nombre_producto'] ?? 'Producto',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                      ),
                      Text('S/ ${producto['precio_unitario']?.toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Cantidad: ${producto['cantidad']}'),
                      Text('Subtotal: S/ ${producto['subtotal']?.toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),

          SizedBox(height: 16),

          // Total
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal:', style: TextStyle(fontSize: 14)),
                    Text('S/ ${infoVenta['total']?.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 14)),
                  ],
                ),
                SizedBox(height: 8),

                Divider(height: 16, thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TOTAL:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                    Text('S/ ${infoVenta['total']?.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        )),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Pie de página
          Text('¡Gracias por su compra!',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              )),
          SizedBox(height: 8),
        ],
      ),
    );
  }




  Widget _buildShareButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'COMPARTIR RECIBO',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          onPressed: _shareReceipt,
        ),
      ),
    );
  }
}