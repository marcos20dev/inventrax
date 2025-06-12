import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VentasScreen extends StatelessWidget {
  final List<Map<String, dynamic>> ventas = [
    {
      "id_venta": 12,
      "fecha_venta": "2025-06-10 16:05:26.439324+00",
      "cliente_nombre": "Pedro Miguel",
      "cliente_apellido": "Garcia Gonzalez",
      "cliente_razon_social": null,
      "cliente_documento_identidad": "71045066",
      "cliente_telefono": "962415167",
      "cliente_correo": "miguelgonzalez16_25@gmail.com",
      "cliente_direccion": "Tadeo Monagas#880 - La esperanza",
      "total": "46.0",
      "estado": "pagado",
      "fecha_registro": "2025-06-10 21:06:19.307409+00",
      "usuario_nombre": "Pedro Miguel",
      "usuario_apellido": "Garcia Gonzalez"
    },
    {
      "id_venta": 11,
      "fecha_venta": "2025-06-10 15:24:22.641412+00",
      "cliente_nombre": "Pedro Miguel",
      "cliente_apellido": "Garcia Gonzalez",
      "cliente_razon_social": null,
      "cliente_documento_identidad": "71045066",
      "cliente_telefono": "962415167",
      "cliente_correo": "miguelgonzalez16_25@gmail.com",
      "cliente_direccion": "Tadeo Monagas#880 - La esperanza",
      "total": "51.0",
      "estado": "pagado",
      "fecha_registro": "2025-06-10 20:24:51.165987+00",
      "usuario_nombre": "Pedro Miguel",
      "usuario_apellido": "Garcia Gonzalez"
    }
  ];

  VentasScreen({super.key});

  String _formatearFecha(String fecha) {
    try {
      final dateTime = DateTime.parse(fecha);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime.toLocal());
    } catch (e) {
      return fecha;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Ventas', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Lógica para refrescar
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: ventas.length,
                itemBuilder: (context, index) {
                  final venta = ventas[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Venta #${venta["id_venta"]}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Chip(
                                backgroundColor: venta["estado"] == "pagado"
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.orange.withOpacity(0.2),
                                label: Text(
                                  venta["estado"].toString().toUpperCase(),
                                  style: TextStyle(
                                    color: venta["estado"] == "pagado"
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatearFecha(venta["fecha_venta"]),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                '${venta["cliente_nombre"]} ${venta["cliente_apellido"]}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.credit_card, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                venta["cliente_documento_identidad"],
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                '\$${venta["total"]}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
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
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navegar a la pantalla de registrar nueva venta
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Nueva Venta',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}