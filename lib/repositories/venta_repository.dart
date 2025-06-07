import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/venta.dart';

class VentaRepository {
  final SupabaseClient _supabase;

  VentaRepository(this._supabase);

  Future<int?> registrarVenta({
    required int idCliente,
    required String idUsuario,
    required DateTime fechaVenta,
    required double total,
    required List<Map<String, dynamic>> detalles,
  }) async {
    try {
      final response = await _supabase.rpc('fn_registrar_venta', params: {
        'p_id_cliente': idCliente,
        'p_id_usuario': idUsuario,
        'p_fecha_venta': fechaVenta.toIso8601String(),
        'p_total': total,
        'p_detalles': detalles.map((d) => {
          'id_producto': d['id_producto'],
          'cantidad': d['cantidad'],
          'precio_unitario': d['precio'],
        }).toList(),
      });

      // Suponiendo que la respuesta es un ID de venta
      final idVenta = response as int?; // Asegúrate de que sea un int

      return idVenta;
    } catch (e) {
      print('Error al registrar venta: $e');
      return null;
    }
  }


  Future<List<Venta>> obtenerVentas() async {
    try {
      final response = await _supabase
          .from('ventas')
          .select('*')
          .order('fecha_venta', ascending: false)
          .limit(100);

      if (response.isEmpty) {
        print('No hay ventas registradas');
        return [];
      }

      // Convertir la respuesta a una lista de objetos Venta
      return List<Venta>.from(
        response.map((map) {
          try {
            return Venta.fromMap(map as Map<String, dynamic>);
          } catch (e) {
            print('Error al convertir mapa a Venta: $e');
            return null;
          }
        }).where((venta) => venta != null), // Filtra los valores null
      );
    } catch (e) {
      print('Error en obtenerVentas: $e');
      return [];
    }
  }


  Future<void> eliminarDetallesVenta(int idVenta) async {
    try {
      final response = await _supabase
          .from('detalle_ventas')
          .delete()
          .eq('id_venta', idVenta); // Asegúrate de que 'id_venta' sea el campo correcto

      // Verifica si hubo un error en la respuesta
      if (response == null) {
        throw Exception('No response from Supabase when trying to delete details');
      }

      // Si la respuesta tiene un error, lo mostramos
      if (response.error != null) {
        throw Exception('Error al eliminar detalles de la venta: ${response.error?.message}');
      }
    } catch (e) {
      print('Error al eliminar detalles de la venta: $e');
      throw e; // Propaga el error para manejarlo en el ViewModel
    }
  }


  Future<void> eliminarVenta(int idVenta) async {
    try {
      // Primero elimina los detalles de la venta
      await eliminarDetallesVenta(idVenta);

      // Ahora elimina la venta
      final response = await _supabase
          .from('ventas')
          .delete()
          .eq('id_venta', idVenta); // Asegúrate de que 'id_venta' sea el campo correcto

      if (response == null) {
        throw Exception('No response from Supabase when trying to delete sale');
      }

      // Verifica si hubo un error en la respuesta
      if (response.error != null) {
        throw Exception('Error al eliminar venta: ${response.error?.message}');
      }
    } catch (e) {
      print('Error al eliminar venta: $e');
      throw e; // Propaga el error para manejarlo en el ViewModel
    }
  }


  Future<Map<String, dynamic>> obtenerDetallesVenta(int idVenta) async {
    try {
      // 1. Obtenemos datos básicos de la venta
      final ventaResponse = await _supabase
          .from('ventas')
          .select('id_cliente, total, fecha_venta')
          .eq('id_venta', idVenta)
          .single();

      final idCliente = ventaResponse['id_cliente'] as int?;
      final totalVenta = ventaResponse['total'] as double?;
      final fechaVenta = ventaResponse['fecha_venta'] as String?;

      // 2. Obtenemos datos del cliente
      Map<String, dynamic> infoCliente = {
        'nombre_cliente': 'Cliente no encontrado',
        'correo': 'No especificado',
        'telefono': 'No especificado'
      };

      if (idCliente != null) {
        // En tu VentaRepository, modifica la consulta del cliente:
        final clienteResponse = await _supabase
            .from('clientes')
            .select('nombre, apellido, razon_social, tipo_cliente, correo, telefono')
            .eq('id_cliente', idCliente)
            .maybeSingle();

        if (clienteResponse != null) {
          // Si es una persona natural
          if (clienteResponse['tipo_cliente'] == 'persona') {
            final nombre = clienteResponse['nombre'] ?? '';
            final apellido = clienteResponse['apellido'] ?? '';
            infoCliente = {
              'nombre_cliente': '$nombre $apellido'.trim(),
              'correo': clienteResponse['correo'] ?? 'No especificado',
              'telefono': clienteResponse['telefono'] ?? 'No especificado',
            };
          } else {
            // Si es una empresa
            infoCliente = {
              'nombre_cliente': clienteResponse['razon_social'] ?? 'Cliente no especificado',
              'correo': clienteResponse['correo'] ?? 'No especificado',
              'telefono': clienteResponse['telefono'] ?? 'No especificado',
            };
          }
        }
      }

      // 3. Obtenemos TODOS los productos de la venta
      final detallesResponse = await _supabase
          .from('detalle_ventas')
          .select('''
        id_producto,
        cantidad,
        precio_unitario,
        subtotal,
        productos:productos(nombre_producto)
      ''')
          .eq('id_venta', idVenta);

      return {
        'info_venta': {
          'id_venta': idVenta,
          'fecha': fechaVenta,
          'total': totalVenta,
        },
        'cliente': infoCliente,
        'productos': detallesResponse,
      };
    } catch (e) {
      print('Error obteniendo detalles: $e');
      rethrow;
    }
  }


}
