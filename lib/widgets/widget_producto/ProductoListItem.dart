import 'package:flutter/material.dart';

// Formateo simple de fecha
class DateFormat {
  static String format(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class ProductoListItem extends StatelessWidget {
  final Map<String, dynamic> producto;
  final Color primaryColor;
  final Function(int id)? onEdit; // ← ahora opcional
  final Function(int id) onDelete;

  const ProductoListItem({
    Key? key,
    required this.producto,
    required this.primaryColor,
    this.onEdit, // ← ya no es requerido
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Dismissible(
        key: Key(producto['id_producto'].toString()),
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          child: const Icon(Icons.delete, color: Colors.red),
        ),
        secondaryBackground: Container(
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: Icon(Icons.edit, color: primaryColor),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            onDelete(producto['id_producto']);
            return false;
          } else {
            if (onEdit != null) {
              onEdit!(producto['id_producto']);
            }
            return false;
          }
        },
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: isDark ? Colors.grey[800] : Colors.white,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.inventory_2_rounded,
                      size: 24,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          producto['nombre_producto'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Código: ${producto['codigo_barras'] ?? '-'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Cantidad: ${producto['cantidad_disponible'] ?? 0}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Precio Venta: \$${producto['precio_venta']?.toStringAsFixed(2) ?? '0.00'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (producto['unidad_medida'] != null && producto['unidad_medida'].toString().isNotEmpty)
                          Text(
                            'Unidad: ${producto['unidad_medida']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        const SizedBox(height: 6),
                        if (producto['fecha_creacion'] != null)
                          Text(
                            'Creado: ${DateFormat.format(producto['fecha_creacion'])}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.grey),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (context) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (onEdit != null)
                              ListTile(
                                leading: Icon(Icons.edit, color: primaryColor),
                                title: const Text('Editar'),
                                onTap: () {
                                  Navigator.pop(context);
                                  onEdit!(producto['id_producto']);
                                },
                              ),
                            ListTile(
                              leading: const Icon(Icons.delete, color: Colors.red),
                              title: const Text('Eliminar'),
                              onTap: () {
                                Navigator.pop(context);
                                onDelete(producto['id_producto']);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
