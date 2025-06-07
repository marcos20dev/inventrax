import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VentaListItem extends StatelessWidget {
  final Map<String, dynamic> venta;
  final Color primaryColor;
  final Function(int id) onEdit;

  const VentaListItem({
    Key? key,
    required this.venta,
    required this.primaryColor,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: isDark ? Colors.grey[800] : Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onEdit(venta['idVenta']), // Solo permitir la edición al tocar
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.shopping_cart,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Venta #${venta['idVenta']}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Total: S/ ${venta['total'].toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 6),
                      // Formato de la fecha
                      Text(
                        'Fecha: ${DateFormat('dd/MM/yyyy').format(venta['fecha_venta'])}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
