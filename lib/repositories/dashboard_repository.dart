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
}