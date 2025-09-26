import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/commission/commission_service.dart';
import '../../domain/models/commission.dart';

/// Provider für die Verwaltung von Provisionen im Admin-Bereich
class CommissionProvider extends ChangeNotifier {
  final CommissionService _commissionService;

  CommissionProvider({CommissionService? commissionService})
      : _commissionService = commissionService ?? CommissionService(Supabase.instance.client);

  // State
  List<Commission> _commissions = [];
  Commission? _selectedCommission;
  List<Commission> _filteredCommissions = [];
  Map<String, dynamic> _statistics = {};
  List<Commission> _overdueCommissions = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentFilter = 'all';
  String _searchTerm = '';

  // Filter state
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedPeriod = 'month';

  // Getters
  List<Commission> get commissions => _commissions;
  Commission? get selectedCommission => _selectedCommission;
  List<Commission> get filteredCommissions => _filteredCommissions;
  Map<String, dynamic> get statistics => _statistics;
  List<Commission> get overdueCommissions => _overdueCommissions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentFilter => _currentFilter;
  String get searchTerm => _searchTerm;

  // Filter getters
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get selectedPeriod => _selectedPeriod;

  /// Set loading state and optionally clear error
  void setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  /// Set error message and stop loading
  void setErrorMessage(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  /// Load commissions for a specific company
  Future<void> loadCommissionsForCompany(String companyId) async {
    setLoading(true);
    
    try {
      final commissions = await _commissionService.getCommissionsForCompany(companyId);
      _commissions = commissions;
      _applyFilters();
    } catch (e) {
      log('Error loading commissions for company $companyId: $e');
      setErrorMessage('Failed to load commissions: ${e.toString()}');
      _commissions = [];
      _filteredCommissions = [];
    } finally {
      setLoading(false);
    }
  }

  /// Set status filter
  void setFilter(String filter) {
    _currentFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  /// Set search term
  void setSearchTerm(String searchTerm) {
    _searchTerm = searchTerm;
    _applyFilters();
    notifyListeners();
  }

  /// Set date range for filtering
  void setDateRange(DateTime? startDate, DateTime? endDate) {
    _startDate = startDate;
    _endDate = endDate;
    _applyFilters();
    notifyListeners();
  }

  /// Load commission statistics for company
  Future<void> loadStatistics(String companyId) async {
    try {
      final stats = await _commissionService.getCommissionStatistics(companyId);
      _statistics = stats;
      notifyListeners();
    } catch (e) {
      log('Error loading commission statistics: $e');
      setErrorMessage('Failed to load statistics: ${e.toString()}');
      _statistics = {};
    }
  }

  /// Update commission status
  Future<void> updateCommissionStatus(int commissionId, CommissionStatus status) async {
    try {
      final updatedCommission = await _commissionService.updateCommissionStatus(commissionId, status);
      
      // Update local commission list
      final index = _commissions.indexWhere((c) => c.id == commissionId);
      if (index >= 0) {
        _commissions[index] = updatedCommission;
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      log('Error updating commission status: $e');
      setErrorMessage('Failed to update commission status: ${e.toString()}');
    }
  }

  /// Load overdue commissions for company
  Future<void> loadOverdueCommissions(String companyId) async {
    try {
      final overdue = await _commissionService.getOverdueCommissions(companyId);
      _overdueCommissions = overdue;
      notifyListeners();
    } catch (e) {
      log('Error loading overdue commissions: $e');
      setErrorMessage('Failed to load overdue commissions: ${e.toString()}');
      _overdueCommissions = [];
    }
  }

  /// Apply current filters to commission list
  void _applyFilters() {
    var filtered = _commissions.toList();

    // Apply status filter
    if (_currentFilter != 'all') {
      final statusFilter = _parseStatusFilter(_currentFilter);
      if (statusFilter != null) {
        filtered = filtered.where((c) => c.status == statusFilter).toList();
      }
    }

    // Apply search filter
    if (_searchTerm.isNotEmpty) {
      filtered = filtered.where((c) => 
        c.companyId.toLowerCase().contains(_searchTerm.toLowerCase()) ||
        c.orderId.toLowerCase().contains(_searchTerm.toLowerCase())
      ).toList();
    }

    // Apply date range filter
    if (_startDate != null && _endDate != null) {
      filtered = filtered.where((c) => 
        c.createdAt.isAfter(_startDate!) && 
        c.createdAt.isBefore(_endDate!)
      ).toList();
    }

    _filteredCommissions = filtered;
  }

  /// Parse string status filter to CommissionStatus enum
  CommissionStatus? _parseStatusFilter(String filter) {
    switch (filter.toLowerCase()) {
      case 'pending':
        return CommissionStatus.pending;
      case 'calculated':
        return CommissionStatus.calculated;
      case 'paid':
        return CommissionStatus.paid;
      case 'cancelled':
        return CommissionStatus.cancelled;
      default:
        return null;
    }
  }

  /// Clear all data
  void clear() {
    _commissions = [];
    _filteredCommissions = [];
    _statistics = {};
    _overdueCommissions = [];
    _selectedCommission = null;
    _errorMessage = null;
    _isLoading = false;
    _currentFilter = 'all';
    _searchTerm = '';
    _startDate = null;
    _endDate = null;
    _selectedPeriod = 'month';
    notifyListeners();
  }

  @visibleForTesting
  set commissions(List<Commission> commissions) {
    _commissions = commissions;
    _applyFilters();
    notifyListeners();
  }
}