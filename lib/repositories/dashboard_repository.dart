import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardRepository {
  final SupabaseClient supabaseClient;

  DashboardRepository(this.supabaseClient);

  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      // Obtener los ingresos (sumando el total de ventas)
      final ingresosResponse = await supabaseClient
          .from('ventas')
          .select('total');
      final ingresos = ingresosResponse.fold(0.0, (sum, item) => sum + item['total']);

      // Obtener el número de ventas
      final ventasResponse = await supabaseClient
          .from('ventas')
          .select('id_venta');
      final ventas = ventasResponse.length;

      // Obtener el número de clientes
      final clientesResponse = await supabaseClient
          .from('clientes')
          .select('id_cliente');
      final clientes = clientesResponse.length;

      return {
        'ingresos': ingresos.toString(),
        'ventas': ventas.toString(),
        'clientes': clientes.toString(),
      };
    } catch (error) {
      throw Exception('Failed to fetch dashboard data: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getProductosConStockCritico() async {
    try {
      final response = await supabaseClient.rpc('rpc_stock_critico');

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print("❌ Error al obtener productos críticos: $error");
      throw Exception('Error al obtener productos con stock crítico: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getClientesTopCompradores() async {
    try {
      final response = await supabaseClient.rpc('rpc_clientes_top_compradores');

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print("❌ Error al obtener clientes top compradores: $error");
      throw Exception('Error al obtener los mejores clientes: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getProductosMasVendidos() async {
    try {
      final response = await supabaseClient.rpc('productos_mas_vendidos');

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print("❌ Error al obtener productos más vendidos: $error");
      throw Exception('Error al obtener productos más vendidos: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getVentasPorDia() async {
    try {
      final response = await supabaseClient.rpc('ventas_por_dia');

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print("❌ Error al obtener ventas por día: $error");
      throw Exception('Error al obtener ventas por día: $error');
    }
  }




}