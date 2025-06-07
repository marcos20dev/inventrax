import 'package:flutter/material.dart';

class ClienteListItem extends StatelessWidget {
  final Map<String, dynamic> cliente;
  final Color primaryColor;
  final Function(int id) onEdit;
  final Function(int id) onDelete;

  const ClienteListItem({
    Key? key,
    required this.cliente,
    required this.primaryColor,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Dismissible(
        key: Key(cliente['id'].toString()),
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
            onDelete(cliente['id']);
            return false; // no eliminar automáticamente para controlar manualmente
          } else {
            onEdit(cliente['id']);
            return false; // no eliminar para abrir edición
          }
        },
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: isDark ? Colors.grey[800] : Colors.white,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onEdit(cliente['id']),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cliente['nombre'] ?? '',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          cliente['tipo_cliente'] ?? '',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        if (cliente['telefono'] != null && cliente['telefono'].isNotEmpty)
                          Text(
                            cliente['telefono'],
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        if (cliente['correo'] != null && cliente['correo'].isNotEmpty)
                          Text(
                            cliente['correo'],
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        if (cliente['direccion'] != null && cliente['direccion'].isNotEmpty)
                          Text(
                            cliente['direccion'],
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        const SizedBox(height: 6),
                        Text(
                          'Creado: ${cliente['fecha_creacion'] != null ? DateFormat.format(cliente['fecha_creacion']) : '-'}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.grey),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (context) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(Icons.edit, color: primaryColor),
                              title: const Text('Editar'),
                              onTap: () {
                                Navigator.pop(context);
                                onEdit(cliente['id']);
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.delete, color: Colors.red),
                              title: const Text('Eliminar'),
                              onTap: () {
                                Navigator.pop(context);
                                onDelete(cliente['id']);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Puedes reutilizar el DateFormat del ejemplo proveedor_list_item.dart
class DateFormat {
  static String format(DateTime date) {
    return '${date.day.toString().padLeft(2,'0')}/${date.month.toString().padLeft(2,'0')}/${date.year}';
  }
}
