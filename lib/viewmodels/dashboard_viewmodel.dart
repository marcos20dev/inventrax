import 'package:flutter/material.dart';
import '../repositories/dashboard_repository.dart';


class DashboardViewModel extends ChangeNotifier {
  final DashboardRepository _repository;
  Map<String, dynamic> _dashboardData = {};
  List<Map<String, dynamic>> _productosCriticos = [];

  List<Map<String, dynamic>> get productosCriticos => _productosCriticos;
  List<Map<String, dynamic>> _ventasPorDia = [];
  List<Map<String, dynamic>> get ventasPorDia => _ventasPorDia;

  DashboardViewModel(this._repository);

  Map<String, dynamic> get dashboardData => _dashboardData;

  List<Map<String, dynamic>> _productosTopVendidos = [];
  List<Map<String, dynamic>> get productosTopVendidos => _productosTopVendidos;

  List<Map<String, dynamic>> _clientesTop = [];
  List<Map<String, dynamic>> get clientesTop => _clientesTop;

  Future<void> fetchDashboardData() async {
    try {
      final data = await _repository.getDashboardData();
      _dashboardData = data;
      notifyListeners();
    } catch (e) {
      print('Error fetching dashboard data: $e');
    }
  }

  Future<void> fetchProductosCriticos() async {
    try {
      final productos = await _repository.getProductosConStockCritico();
      _productosCriticos = productos;
      notifyListeners();
    } catch (e) {
      print("Error al obtener productos críticos: $e");
    }
  }


  Future<void> fetchClientesTopCompradores() async {
    try {
      final data = await _repository.getClientesTopCompradores();
      _clientesTop = data;
      notifyListeners();
    } catch (e) {
      print("❌ Error al cargar los mejores clientes: $e");
    }
  }

  Future<void> fetchProductosMasVendidos() async {
    try {
      final productos = await _repository.getProductosMasVendidos();
      _productosTopVendidos = productos;
      notifyListeners();
    } catch (e) {
      print("❌ Error al cargar productos más vendidos: $e");
    }
  }


  Future<void> fetchVentasPorDia() async {
    try {
      final data = await _repository.getVentasPorDia();
      _ventasPorDia = data;
      notifyListeners();
    } catch (e) {
      print("❌ Error al cargar ventas por día: $e");
    }
  }



}
