import 'package:flutter/material.dart';
import '../repositories/dashboard_repository.dart';


class DashboardViewModel extends ChangeNotifier {
  final DashboardRepository _repository;
  Map<String, dynamic> _dashboardData = {};

  DashboardViewModel(this._repository);

  Map<String, dynamic> get dashboardData => _dashboardData;

  Future<void> fetchDashboardData() async {
    try {
      final data = await _repository.getDashboardData();
      _dashboardData = data;
      notifyListeners();
    } catch (e) {
      print('Error fetching dashboard data: $e');
    }
  }
}
