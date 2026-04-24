import 'package:flutter/foundation.dart';
import '../services/admin/admin_service.dart';

/// Provider für Admin-Dashboard-Daten
class AdminProvider extends ChangeNotifier {
  final AdminService _adminService;

  AdminProvider({AdminService? adminService})
    : _adminService = adminService ?? AdminService();

  // Dashboard-Daten
  Map<String, dynamic> _dashboardKPIs = {};
  List<Map<String, dynamic>> _recentOrders = [];
  List<Map<String, dynamic>> _revenueTrend = [];
  List<Map<String, dynamic>> _topRoutes = [];

  // Loading-States
  bool _isLoadingKPIs = false;
  bool _isLoadingOrders = false;
  bool _isLoadingTrend = false;
  bool _isLoadingRoutes = false;

  // Getters
  Map<String, dynamic> get dashboardKPIs => _dashboardKPIs;
  List<Map<String, dynamic>> get recentOrders => _recentOrders;
  List<Map<String, dynamic>> get revenueTrend => _revenueTrend;
  List<Map<String, dynamic>> get topRoutes => _topRoutes;

  bool get isLoadingKPIs => _isLoadingKPIs;
  bool get isLoadingOrders => _isLoadingOrders;
  bool get isLoadingTrend => _isLoadingTrend;
  bool get isLoadingRoutes => _isLoadingRoutes;

  /// Lädt alle Dashboard-Daten
  Future<void> loadDashboardData() async {
    await Future.wait([
      loadDashboardKPIs(),
      loadRecentOrders(),
      loadRevenueTrend(),
      loadTopRoutes(),
    ]);
  }

  /// Lädt Dashboard-KPIs
  Future<void> loadDashboardKPIs() async {
    _isLoadingKPIs = true;
    notifyListeners();

    try {
      _dashboardKPIs = await _adminService.getDashboardKPIs();
    } catch (e) {
      debugPrint('Fehler beim Laden der Dashboard-KPIs: $e');
      _dashboardKPIs = {
        'monthlyRoutes': 0,
        'monthlyRevenue': 0.0,
        'activeOrders': 0,
        'averageRating': 0.0,
        'weeklyRevenue': 0.0,
        'dailyRevenue': 0.0,
      };
    } finally {
      _isLoadingKPIs = false;
      notifyListeners();
    }
  }

  /// Lädt aktuelle Bestellungen
  Future<void> loadRecentOrders() async {
    _isLoadingOrders = true;
    notifyListeners();

    try {
      _recentOrders = await _adminService.getRecentOrders(limit: 10);
    } catch (e) {
      debugPrint('Fehler beim Laden der aktuellen Bestellungen: $e');
      _recentOrders = [];
    } finally {
      _isLoadingOrders = false;
      notifyListeners();
    }
  }

  /// Lädt Umsatz-Entwicklung
  Future<void> loadRevenueTrend() async {
    _isLoadingTrend = true;
    notifyListeners();

    try {
      _revenueTrend = await _adminService.getRevenueTrend(days: 30);
    } catch (e) {
      debugPrint('Fehler beim Laden der Umsatz-Entwicklung: $e');
      _revenueTrend = [];
    } finally {
      _isLoadingTrend = false;
      notifyListeners();
    }
  }

  /// Lädt beliebteste Routen
  Future<void> loadTopRoutes() async {
    _isLoadingRoutes = true;
    notifyListeners();

    try {
      _topRoutes = await _adminService.getTopRoutes(limit: 5);
    } catch (e) {
      debugPrint('Fehler beim Laden der beliebtesten Routen: $e');
      _topRoutes = [];
    } finally {
      _isLoadingRoutes = false;
      notifyListeners();
    }
  }

  /// Aktualisiert eine Bestellung
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      // Hier würde der API-Call erfolgen
      // await _adminService.updateOrderStatus(orderId, newStatus);

      // Aktualisiere lokale Daten
      final orderIndex = _recentOrders.indexWhere(
        (order) => order['id'] == orderId,
      );
      if (orderIndex != -1) {
        _recentOrders[orderIndex]['status'] = newStatus;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Fehler beim Aktualisieren des Bestellstatus: $e');
    }
  }

  /// Löscht alle Daten (für Logout)
  void clearData() {
    _dashboardKPIs = {};
    _recentOrders = [];
    _revenueTrend = [];
    _topRoutes = [];
    notifyListeners();
  }
}
