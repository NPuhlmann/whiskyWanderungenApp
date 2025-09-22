import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/admin/order_management_service.dart';

/// Provider für die Verwaltung von Bestellungen im Admin-Bereich
class OrderManagementProvider extends ChangeNotifier {
  final OrderManagementService _orderManagementService;

  OrderManagementProvider({OrderManagementService? orderManagementService})
      : _orderManagementService = orderManagementService ?? OrderManagementService();

  // State
  List<Map<String, dynamic>> _orders = [];
  Map<String, dynamic>? _selectedOrder;
  List<Map<String, dynamic>> _filteredOrders = [];
  Map<String, dynamic> _orderStatistics = {};
  List<Map<String, dynamic>> _recentOrders = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentFilter = 'all';
  String _searchTerm = '';

  // Filter state
  DateTime? _startDate;
  DateTime? _endDate;
  double? _minAmount;
  double? _maxAmount;
  String _searchQuery = '';
  String _selectedPeriod = 'month';

  // Getters
  List<Map<String, dynamic>> get orders => _orders;
  Map<String, dynamic>? get selectedOrder => _selectedOrder;
  List<Map<String, dynamic>> get filteredOrders => _filteredOrders;
  Map<String, dynamic> get orderStatistics => _orderStatistics;
  List<Map<String, dynamic>> get recentOrders => _recentOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentFilter => _currentFilter;
  String get searchTerm => _searchTerm;

  // Filter getters
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  double? get minAmount => _minAmount;
  double? get maxAmount => _maxAmount;
  String get searchQuery => _searchQuery;
  String get selectedPeriod => _selectedPeriod;
  Map<String, dynamic> get statistics => _orderStatistics;

  // Setter for testing purposes
  set selectedOrder(Map<String, dynamic>? order) {
    _selectedOrder = order;
    notifyListeners();
  }

  set currentFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  set searchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  // State-Management-Methoden

  /// Setzt den Loading-Status
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Setzt eine Fehlermeldung
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Löscht die aktuelle Fehlermeldung
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Order-Management

  /// Lädt alle Bestellungen
  Future<void> loadOrders() async {
    setLoading(true);
    clearError();

    try {
      log('Loading orders...');
      _orders = await _orderManagementService.getAllOrdersForAdmin();
      _filteredOrders = List.from(_orders);
      log('Loaded ${_orders.length} orders');
    } catch (e) {
      log('Error loading orders: $e');
      setError('Fehler beim Laden der Bestellungen: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Erstellt eine neue Bestellung
  Future<void> createOrder(Map<String, dynamic> orderData) async {
    setLoading(true);
    clearError();

    try {
      log('Creating new order...');

      // Validiere Bestelldaten
      if (!_orderManagementService.validateOrderData(orderData)) {
        throw Exception('Ungültige Bestelldaten');
      }

      await _orderManagementService.createOrder(orderData);

      // Lade Bestellungen neu, um die neue Bestellung anzuzeigen
      await loadOrders();

      log('Order created successfully');
    } catch (e) {
      log('Error creating order: $e');
      setError('Fehler beim Erstellen der Bestellung: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Aktualisiert eine bestehende Bestellung
  Future<void> updateOrder(int orderId, Map<String, dynamic> updateData) async {
    setLoading(true);
    clearError();

    try {
      log('Updating order $orderId');

      // Validiere Update-Daten
      if (!_orderManagementService.validateUpdateData(updateData)) {
        throw Exception('Ungültige Update-Daten');
      }

      await _orderManagementService.updateOrder(orderId, updateData);

      // Lade Bestellungen neu, um die Änderungen anzuzeigen
      await loadOrders();

      // Aktualisiere ausgewählte Bestellung falls sie betroffen ist
      if (_selectedOrder != null && _selectedOrder!['id'] == orderId) {
        _selectedOrder = _orders.firstWhere(
          (order) => order['id'] == orderId,
          orElse: () => _selectedOrder!,
        );
      }

      log('Order updated successfully');
    } catch (e) {
      log('Error updating order: $e');
      setError('Fehler beim Aktualisieren der Bestellung: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Löscht eine Bestellung
  Future<void> deleteOrder(int orderId) async {
    setLoading(true);
    clearError();

    try {
      log('Deleting order $orderId');

      await _orderManagementService.deleteOrder(orderId);

      // Entferne Bestellung aus lokaler Liste
      _orders.removeWhere((order) => order['id'] == orderId);
      _filteredOrders.removeWhere((order) => order['id'] == orderId);

      // Deselektiere Bestellung falls sie ausgewählt war
      if (_selectedOrder != null && _selectedOrder!['id'] == orderId) {
        _selectedOrder = null;
      }

      log('Order deleted successfully');
    } catch (e) {
      log('Error deleting order: $e');
      setError('Fehler beim Löschen der Bestellung: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Wählt eine Bestellung aus und lädt deren Details
  Future<void> selectOrder(Map<String, dynamic> order) async {
    try {
      log('Selecting order: ${order['id']}');

      // Lade vollständige Bestelldetails
      _selectedOrder = await _orderManagementService.getOrderById(order['id']);
      notifyListeners();

      log('Order selected successfully');
    } catch (e) {
      log('Error selecting order: $e');
      setError('Fehler beim Laden der Bestelldetails: $e');
    }
  }

  /// Deselektiert die aktuelle Bestellung
  void deselectOrder() {
    _selectedOrder = null;
    notifyListeners();
  }

  // Order Status Management

  /// Aktualisiert den Status einer Bestellung
  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    setLoading(true);
    clearError();

    try {
      log('Updating order $orderId status to: $newStatus');

      // Validiere Status
      if (!_orderManagementService.validateOrderStatus(newStatus)) {
        throw Exception('Invalid order status: $newStatus');
      }

      await _orderManagementService.updateOrderStatus(orderId, newStatus);

      // Lade Bestellungen neu
      await loadOrders();

      log('Order status updated successfully');
    } catch (e) {
      log('Error updating order status: $e');
      setError('Fehler beim Aktualisieren des Bestellstatus: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Gibt die verfügbaren Bestellstatus zurück
  List<String> getValidOrderStatuses() {
    return _orderManagementService.getValidStatuses();
  }

  // Filtering and Search

  /// Filtert Bestellungen nach Status
  Future<void> filterOrdersByStatus(String status) async {
    clearError();

    try {
      log('Filtering orders by status: $status');

      _currentFilter = status;

      if (status == 'all') {
        _filteredOrders = List.from(_orders);
      } else {
        _filteredOrders = await _orderManagementService.getOrdersByStatus(status);
      }

      notifyListeners();
      log('Filtered to ${_filteredOrders.length} orders');
    } catch (e) {
      log('Error filtering orders by status: $e');
      setError('Fehler beim Filtern der Bestellungen: $e');
    }
  }

  /// Sucht Bestellungen nach Begriff
  Future<void> searchOrders(String searchTerm) async {
    clearError();

    try {
      log('Searching orders with term: $searchTerm');

      _searchTerm = searchTerm;

      if (searchTerm.isEmpty) {
        _filteredOrders = List.from(_orders);
      } else {
        _filteredOrders = await _orderManagementService.searchOrders(searchTerm);
      }

      notifyListeners();
      log('Search returned ${_filteredOrders.length} orders');
    } catch (e) {
      log('Error searching orders: $e');
      setError('Fehler bei der Suche: $e');
    }
  }

  /// Filtert Bestellungen nach Datumsbereich
  Future<void> filterOrdersByDateRange(DateTime startDate, DateTime endDate) async {
    clearError();

    try {
      log('Filtering orders by date range: ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');

      _filteredOrders = await _orderManagementService.getOrdersByDateRange(startDate, endDate);
      notifyListeners();

      log('Date filter returned ${_filteredOrders.length} orders');
    } catch (e) {
      log('Error filtering orders by date: $e');
      setError('Fehler beim Filtern nach Datum: $e');
    }
  }

  /// Löscht alle Filter
  Future<void> clearFilters() async {
    clearError();

    try {
      log('Clearing all filters');

      _currentFilter = 'all';
      _searchTerm = '';
      _filteredOrders = await _orderManagementService.getAllOrdersForAdmin();

      notifyListeners();
      log('Filters cleared, showing ${_filteredOrders.length} orders');
    } catch (e) {
      log('Error clearing filters: $e');
      setError('Fehler beim Zurücksetzen der Filter: $e');
    }
  }

  // Order Statistics

  /// Lädt Bestellstatistiken
  Future<void> loadOrderStatistics() async {
    setLoading(true);
    clearError();

    try {
      log('Loading order statistics...');
      _orderStatistics = await _orderManagementService.getOrderStatistics();
      log('Order statistics loaded');
    } catch (e) {
      log('Error loading order statistics: $e');
      setError('Fehler beim Laden der Statistiken: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Lädt neueste Bestellungen
  Future<void> loadRecentOrders({int limit = 10}) async {
    clearError();

    try {
      log('Loading recent orders (limit: $limit)...');
      _recentOrders = await _orderManagementService.getRecentOrders(limit: limit);
      notifyListeners();
      log('Loaded ${_recentOrders.length} recent orders');
    } catch (e) {
      log('Error loading recent orders: $e');
      setError('Fehler beim Laden der neuesten Bestellungen: $e');
    }
  }

  // Sorting

  /// Sortiert Bestellungen nach verschiedenen Kriterien
  List<Map<String, dynamic>> sortOrders(String sortBy, {bool ascending = true}) {
    final sortedOrders = List<Map<String, dynamic>>.from(_orders);

    sortedOrders.sort((a, b) {
      dynamic valueA, valueB;

      switch (sortBy) {
        case 'id':
          valueA = a['id'] ?? 0;
          valueB = b['id'] ?? 0;
          break;
        case 'total_amount':
          valueA = a['total_amount'] ?? 0.0;
          valueB = b['total_amount'] ?? 0.0;
          break;
        case 'status':
          valueA = a['status'] ?? '';
          valueB = b['status'] ?? '';
          break;
        case 'created_at':
          valueA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime.now();
          valueB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime.now();
          break;
        case 'user_id':
          valueA = a['user_id'] ?? '';
          valueB = b['user_id'] ?? '';
          break;
        default:
          valueA = a['id'] ?? 0;
          valueB = b['id'] ?? 0;
      }

      final comparison = valueA.compareTo(valueB);
      return ascending ? comparison : -comparison;
    });

    return sortedOrders;
  }

  // Helper Methods

  /// Berechnet lokale Statistiken
  Map<String, dynamic> calculateLocalStatistics() {
    if (_orders.isEmpty) {
      return {
        'totalOrders': 0,
        'totalRevenue': 0.0,
        'averageOrderValue': 0.0,
        'pendingOrders': 0,
        'completedOrders': 0,
      };
    }

    final totalOrders = _orders.length;
    final totalRevenue = _orders.fold<double>(0.0, (sum, order) =>
        sum + (order['total_amount'] as num? ?? 0.0).toDouble());
    final averageOrderValue = totalRevenue / totalOrders;

    final pendingOrders = _orders.where((order) =>
        _orderManagementService.isPendingStatus(order['status'] ?? '')).length;
    final completedOrders = _orders.where((order) =>
        _orderManagementService.isCompletedStatus(order['status'] ?? '')).length;

    return {
      'totalOrders': totalOrders,
      'totalRevenue': double.parse(totalRevenue.toStringAsFixed(2)),
      'averageOrderValue': double.parse(averageOrderValue.toStringAsFixed(2)),
      'pendingOrders': pendingOrders,
      'completedOrders': completedOrders,
    };
  }

  /// Aktualisiert alle Daten
  Future<void> refreshData() async {
    await loadOrders();
  }

  /// Löscht alle Daten (für Logout oder Reset)
  void clearData() {
    _orders = [];
    _selectedOrder = null;
    _filteredOrders = [];
    _orderStatistics = {};
    _recentOrders = [];
    _isLoading = false;
    _errorMessage = null;
    _currentFilter = 'all';
    _searchTerm = '';
    notifyListeners();
  }

  /// Prüft ob eine Bestellung bearbeitet werden kann
  bool canModifyOrder(Map<String, dynamic> order) {
    return _orderManagementService.isPendingStatus(order['status'] ?? '');
  }

  /// Formatiert Bestellbetrag
  String formatOrderAmount(Map<String, dynamic> order) {
    final amount = (order['total_amount'] as num? ?? 0.0).toDouble();
    return '€${amount.toStringAsFixed(2)}';
  }

  /// Gibt Farbe für Bestellstatus zurück
  Color getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'shipped':
        return Colors.green;
      case 'delivered':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Gibt Icon für Bestellstatus zurück
  IconData getOrderStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'processing':
        return Icons.sync;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  /// Gibt die Anzahl der Bestellungen pro Status zurück
  Map<String, int> getOrderCountByStatus() {
    final counts = <String, int>{};
    final validStatuses = getValidOrderStatuses();

    for (final status in validStatuses) {
      counts[status] = _orders.where((order) => order['status'] == status).length;
    }

    return counts;
  }

  /// Prüft ob aktuell Änderungen vorgenommen werden
  bool get hasUnsavedChanges => _isLoading;

  /// Gibt die Anzahl der gefilterten Bestellungen zurück
  int get filteredOrderCount => _filteredOrders.length;

  /// Gibt die Anzahl aller Bestellungen zurück
  int get totalOrderCount => _orders.length;

  // Additional filter methods for UI integration

  /// Wendet Status-Filter an
  void applyStatusFilter(String status) {
    _currentFilter = status;
    filterOrdersByStatus(status);
  }

  /// Setzt Mindestbetrag für Filter
  void setMinAmount(double? amount) {
    _minAmount = amount;
    notifyListeners();
  }

  /// Setzt Maximalbetrag für Filter
  void setMaxAmount(double? amount) {
    _maxAmount = amount;
    notifyListeners();
  }

  /// Setzt Datumsbereich für Filter
  void setDateRange(DateTime startDate, DateTime endDate) {
    _startDate = startDate;
    _endDate = endDate;
    notifyListeners();
  }

  /// Löscht Datumsfilter
  void clearDateFilter() {
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  /// Wendet alle Filter an
  Future<void> applyFilters() async {
    // Implementation would apply all active filters
    // For now, just refresh the data
    await loadOrders();
  }

  /// Setzt Zeitraum für Statistiken
  void setStatisticsPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
    // Reload statistics with new period
    loadOrderStatistics();
  }

  /// Setzt Suchbegriff
  void setSearchQuery(String query) {
    _searchQuery = query;
    searchOrders(query);
  }
}