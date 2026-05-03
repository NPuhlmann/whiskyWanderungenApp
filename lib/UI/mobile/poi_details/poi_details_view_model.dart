import 'dart:developer';
import 'package:flutter/foundation.dart';
import '../../../domain/models/waypoint.dart';

class PoiDetailsViewModel extends ChangeNotifier {
  PoiDetailsViewModel({required this.waypoint});

  final Waypoint waypoint;

  bool _isAddedToOrder = false;
  bool get isAddedToOrder => _isAddedToOrder;

  // Stub: records intent locally; network call wired in payment ticket.
  void addToOrder() {
    if (_isAddedToOrder) return;
    _isAddedToOrder = true;
    log('Stub order_item queued: waypoint ${waypoint.id} (${waypoint.name})');
    notifyListeners();
  }
}
