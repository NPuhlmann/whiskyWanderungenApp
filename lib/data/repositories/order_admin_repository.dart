import '../services/admin/order_management_service.dart';

/// Repository für die Bestellverwaltung im Admin-Bereich (ADR-0004).
///
/// Reiner Pass-through auf [OrderManagementService]; Query- und
/// Validierungslogik bleiben dort. Das Repository verschiebt nur die
/// Abhängigkeitskante, damit der Provider keinen Supabase-Service hält.
class OrderAdminRepository {
  final OrderManagementService _service;

  OrderAdminRepository(this._service);

  Future<List<Map<String, dynamic>>> getAllOrdersForAdmin() =>
      _service.getAllOrdersForAdmin();

  Future<Map<String, dynamic>> getOrderById(int orderId) =>
      _service.getOrderById(orderId);

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) =>
      _service.createOrder(orderData);

  Future<Map<String, dynamic>> updateOrder(
    int orderId,
    Map<String, dynamic> updateData,
  ) => _service.updateOrder(orderId, updateData);

  Future<void> deleteOrder(int orderId) => _service.deleteOrder(orderId);

  Future<Map<String, dynamic>> updateOrderStatus(
    int orderId,
    String newStatus,
  ) => _service.updateOrderStatus(orderId, newStatus);

  Future<List<Map<String, dynamic>>> getOrdersByStatus(String status) =>
      _service.getOrdersByStatus(status);

  Future<List<Map<String, dynamic>>> searchOrders(String searchTerm) =>
      _service.searchOrders(searchTerm);

  Future<List<Map<String, dynamic>>> getOrdersByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) => _service.getOrdersByDateRange(startDate, endDate);

  Future<Map<String, dynamic>> getOrderStatistics() =>
      _service.getOrderStatistics();

  Future<List<Map<String, dynamic>>> getRecentOrders({int limit = 10}) =>
      _service.getRecentOrders(limit: limit);

  bool validateOrderData(Map<String, dynamic> orderData) =>
      _service.validateOrderData(orderData);

  bool validateUpdateData(Map<String, dynamic> updateData) =>
      _service.validateUpdateData(updateData);

  bool validateOrderStatus(String status) =>
      _service.validateOrderStatus(status);

  List<String> getValidStatuses() => _service.getValidStatuses();

  bool isCompletedStatus(String status) => _service.isCompletedStatus(status);

  bool isPendingStatus(String status) => _service.isPendingStatus(status);
}
