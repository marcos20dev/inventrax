import 'dart:math';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class TestDashboard extends StatelessWidget {
  const TestDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de prueba
    final ventasEsteMes = generarVentas(DateTime.now().month);
    final ventasMesPasado = generarVentas(DateTime.now().month - 1);
    final productosMasVendidos = obtenerProductosMasVendidos(ventasEsteMes);
    final productosMasVendidosMesPasado = obtenerProductosMasVendidos(ventasMesPasado);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Ventas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Estadísticas rápidas
            _buildEstadisticasRapidas(ventasEsteMes, ventasMesPasado),
            const SizedBox(height: 20),

            // Gráficos
            _buildGraficosComparativos(ventasEsteMes, ventasMesPasado),
            const SizedBox(height: 20),

            // Productos más vendidos
            _buildProductosMasVendidos(productosMasVendidos, productosMasVendidosMesPasado),
            const SizedBox(height: 20),

            // Listado completo de ventas
            _buildListadoVentas(ventasEsteMes),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticasRapidas(List<Venta> esteMes, List<Venta> mesPasado) {
    final totalEsteMes = calcularTotalVentas(esteMes);
    final totalMesPasado = calcularTotalVentas(mesPasado);
    final diferenciaPorcentaje = ((totalEsteMes - totalMesPasado) / totalMesPasado * 100);

    return Row(
      children: [
        Expanded(
          child: _buildTarjetaEstadistica(
            titulo: 'Ventas este mes',
            valor: '\$${totalEsteMes.toStringAsFixed(2)}',
            subtexto: '${diferenciaPorcentaje.toStringAsFixed(1)}% vs mes pasado',
            esPositivo: diferenciaPorcentaje >= 0,
            icono: Icons.trending_up,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTarjetaEstadistica(
            titulo: 'N° de ventas',
            valor: esteMes.length.toString(),
            subtexto: '${esteMes.length - mesPasado.length} vs mes pasado',
            esPositivo: esteMes.length >= mesPasado.length,
            icono: Icons.receipt,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildTarjetaEstadistica({
    required String titulo,
    required String valor,
    required String subtexto,
    required bool esPositivo,
    required IconData icono,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icono, color: color, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  esPositivo ? Icons.arrow_upward : Icons.arrow_downward,
                  color: esPositivo ? Colors.green : Colors.red,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  subtexto,
                  style: TextStyle(
                    color: esPositivo ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraficosComparativos(List<Venta> esteMes, List<Venta> mesPasado) {
    final ventasPorDiaEsteMes = agruparVentasPorDia(esteMes);
    final ventasPorDiaMesPasado = agruparVentasPorDia(mesPasado);

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comparativo de ventas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                legend: Legend(isVisible: true),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  ColumnSeries<VentaPorDia, String>(
                    name: 'Este mes',
                    dataSource: ventasPorDiaEsteMes,
                    xValueMapper: (VentaPorDia venta, _) => venta.dia.toString(),
                    yValueMapper: (VentaPorDia venta, _) => venta.total,
                    color: Colors.blue,
                  ),
                  ColumnSeries<VentaPorDia, String>(
                    name: 'Mes pasado',
                    dataSource: ventasPorDiaMesPasado,
                    xValueMapper: (VentaPorDia venta, _) => venta.dia.toString(),
                    yValueMapper: (VentaPorDia venta, _) => venta.total,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductosMasVendidos(List<ProductoVendido> esteMes, List<ProductoVendido> mesPasado) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Productos más vendidos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Este mes',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...esteMes.take(3).map((producto) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                producto.nombre,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Text(
                              '${producto.cantidad} unid.',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mes pasado',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...mesPasado.take(3).map((producto) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                producto.nombre,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Text(
                              '${producto.cantidad} unid.',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListadoVentas(List<Venta> ventas) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Últimas ventas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...ventas.take(5).map((venta) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      venta.fecha.day.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Venta #${venta.id}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${venta.productos.length} productos',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${venta.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )),
            if (ventas.length > 5) TextButton(
              onPressed: () {},
              child: const Text('Ver todas las ventas'),
            ),
          ],
        ),
      ),
    );
  }
}

// Modelos y funciones de ayuda

class Venta {
  final String id;
  final DateTime fecha;
  final List<ProductoVenta> productos;
  final double total;

  Venta({
    required this.id,
    required this.fecha,
    required this.productos,
    required this.total,
  });
}

class ProductoVenta {
  final String id;
  final String nombre;
  final int cantidad;
  final double precio;

  ProductoVenta({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.precio,
  });
}

class VentaPorDia {
  final int dia;
  final double total;

  VentaPorDia({
    required this.dia,
    required this.total,
  });
}

class ProductoVendido {
  final String nombre;
  final int cantidad;

  ProductoVendido({
    required this.nombre,
    required this.cantidad,
  });
}

// Funciones para generar datos de prueba

List<Venta> generarVentas(int mes) {
  final random = Random(mes);
  final now = DateTime.now();
  final diasEnMes = DateTime(now.year, mes + 1, 0).day;

  return List.generate(random.nextInt(15) + 10, (index) {
    final productos = List.generate(
      random.nextInt(5) + 1,
          (i) => ProductoVenta(
        id: 'P${random.nextInt(1000)}',
        nombre: ['Laptop', 'Teléfono', 'Tablet', 'Monitor', 'Teclado'][random.nextInt(5)],
        cantidad: random.nextInt(3) + 1,
        precio: [499.99, 299.99, 199.99, 149.99, 59.99][random.nextInt(5)],
      ),
    );

    final total = productos.fold(0.0, (sum, p) => sum + (p.precio * p.cantidad));

    return Venta(
      id: 'V${1000 + index}',
      fecha: DateTime(now.year, mes, random.nextInt(diasEnMes) + 1),
      productos: productos,
      total: total,
    );
  });
}

List<VentaPorDia> agruparVentasPorDia(List<Venta> ventas) {
  final mapa = <int, double>{};

  for (var venta in ventas) {
    final dia = venta.fecha.day;
    mapa[dia] = (mapa[dia] ?? 0) + venta.total;
  }

  return mapa.entries
      .map((e) => VentaPorDia(dia: e.key, total: e.value))
      .toList()
    ..sort((a, b) => a.dia.compareTo(b.dia));
}

List<ProductoVendido> obtenerProductosMasVendidos(List<Venta> ventas) {
  final mapa = <String, int>{};

  for (var venta in ventas) {
    for (var producto in venta.productos) {
      mapa[producto.nombre] = (mapa[producto.nombre] ?? 0) + producto.cantidad;
    }
  }

  return mapa.entries
      .map((e) => ProductoVendido(nombre: e.key, cantidad: e.value))
      .toList()
    ..sort((a, b) => b.cantidad.compareTo(a.cantidad));
}

double calcularTotalVentas(List<Venta> ventas) {
  return ventas.fold(0.0, (sum, venta) => sum + venta.total);
}