import 'package:flutter/material.dart';
import '../../models/cliente.dart';
import '../../models/venta.dart';
import '../../repositories/venta_repository.dart';
import '../../widgets/widget_notification/Notification_Toast.dart';

class RegistroVentaViewModel extends ChangeNotifier {
  final VentaRepository _ventaRepository;


  RegistroVentaViewModel(this._ventaRepository);

  Cliente? clienteSeleccionado;
  String? idUsuario; // Puede ser UUID string
  bool isLoading = false;
  List<Map<String, dynamic>> detallesVenta = [];
  Map<String, dynamic>? ventaData;

  DateTime fechaVenta = DateTime.now();
  List<Map<String, dynamic>> productos = [];
  List<Venta> ventas = [];  // Cambiado a tipo Venta

  void Function(String message, NotificationType type)? onShowToast;

  // Función para obtener las ventas
  Future<void> obtenerVentas() async {
    try {
      isLoading = true;
      // Evitamos llamar a notifyListeners directamente aquí
      final data = await _ventaRepository.obtenerVentas();
      ventas = data;

      // Usamos `WidgetsBinding` para asegurarnos de que notifyListeners se llame después de la construcción.
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        notifyListeners(); // Esto se ejecutará después de que el widget esté construido.
      });
    } catch (e) {
      print('Error al obtener ventas: $e');
    } finally {
      isLoading = false;
    }
  }

  Future<void> obtenerVentaDetalle(int idVenta) async {
    try {
      isLoading = true;
      notifyListeners();

      // Llamar al repositorio para obtener los detalles de la venta
      final detalles = await _ventaRepository.obtenerDetallesVenta(idVenta);

      // Actualizamos ambos campos con la nueva estructura
      ventaData = detalles;
      productos = detalles['productos'] ?? [];

      isLoading = false;
      notifyListeners();
    } catch (e) {
      print("Error al obtener los detalles de la venta: $e");
      isLoading = false;
      notifyListeners();

      // Opcional: puedes manejar el error de forma más específica aquí
      rethrow; // Si quieres que la pantalla también capture el error
    }
  }

  // Función para eliminar una venta
  Future<void> eliminarVenta(int idVenta) async {
    try {
      isLoading = true;
      notifyListeners();

      // Llamada para eliminar la venta y sus detalles
      await _ventaRepository.eliminarVenta(idVenta);

      // Después de eliminar, recargamos las ventas
      await obtenerVentas(); // Recargar ventas

      isLoading = false;
      notifyListeners();

    } catch (e) {
      print('Error al eliminar venta: $e');
      isLoading = false;
      notifyListeners();
      throw e; // Propaga el error para manejarlo en la UI si es necesario
    }
  }

  // Función para establecer el cliente seleccionado
  void setClienteSeleccionado(Cliente cliente) {
    clienteSeleccionado = cliente;
    notifyListeners();
  }

  // Función para establecer los productos de la venta
  void setProductos(List<Map<String, dynamic>> listaProductos) {
    productos = listaProductos;
    notifyListeners();
  }

  // Método para registrar la venta
  Future<int?> registrarVenta(BuildContext context) async {
    if (isLoading) return null; // Evitar múltiples clics

    if (clienteSeleccionado == null) {
      onShowToast?.call('Debe seleccionar un cliente', NotificationType.error);
      return null;
    }
    if (idUsuario == null) {
      onShowToast?.call('Usuario no autenticado', NotificationType.error);
      return null;
    }
    if (productos.isEmpty) {
      onShowToast?.call('Debe agregar productos', NotificationType.error);
      return null;
    }

    isLoading = true;
    notifyListeners();

    double totalVenta = 0;
    for (var p in productos) {
      totalVenta += (p['cantidad'] as int) * (p['precio'] as double);
    }

    try {
      // Llamada al repositorio para registrar la venta y obtener el id_venta
      final response = await _ventaRepository.registrarVenta(
        idCliente: clienteSeleccionado!.idCliente!,
        idUsuario: idUsuario!,
        fechaVenta: fechaVenta,
        total: totalVenta,
        detalles: productos,
      );

      // Asegurándonos de que 'response' sea el ID de la venta
      if (response is int) {
        // Si el resultado es un entero (id_venta)
        return response; // Regresamos el ID de la venta
      } else {
        showNotificationToast(
          context,
          message: 'No se pudo registrar la venta correctamente',
          type: NotificationType.error,
        );
      }
    } catch (e) {
      // Notificación de error
      showNotificationToast(
        context,
        message: 'Error al registrar venta: $e',
        type: NotificationType.error,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }

    return null; // Si no se pudo registrar la venta
  }

  // Reinicia los datos del formulario
  void resetForm() {
    clienteSeleccionado = null;
    productos.clear();
    fechaVenta = DateTime.now();
    notifyListeners();
  }
}
