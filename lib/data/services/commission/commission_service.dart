import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/domain/models/commission.dart';

/// Service for managing commission data and business logic
class CommissionService {
  final SupabaseClient _client;

  CommissionService(this._client);

  /// Create a commission record for a completed order
  Future<Commission> createCommissionForOrder({
    required int hikeId,
    required String companyId,
    required String orderId,
    required double baseAmount,
    required double commissionRate,
    String? notes,
  }) async {
    try {
      // Validate commission rate (0-100%)
      if (commissionRate < 0 || commissionRate > 1.0) {
        throw ArgumentError(
          'Commission rate must be between 0 and 1.0 (0% - 100%), got: $commissionRate',
        );
      }

      // Calculate commission amount
      final commissionAmount = baseAmount * commissionRate;
      
      final now = DateTime.now();
      
      final data = {
        'hike_id': hikeId,
        'company_id': companyId,
        'order_id': orderId,
        'commission_rate': commissionRate,
        'base_amount': baseAmount,
        'commission_amount': commissionAmount,
        'status': CommissionStatus.pending.name,
        'created_at': now.toIso8601String(),
        'notes': notes,
      };

      final response = await _client
          .from('commissions')
          .insert(data)
          .select()
          .single();

      return Commission.fromJson(response);
    } catch (e) {
      log('Error creating commission for order $orderId: $e');
      rethrow;
    }
  }

  /// Get all commissions for a specific company
  Future<List<Commission>> getCommissionsForCompany(String companyId) async {
    try {
      final response = await _client
          .from('commissions')
          .select()
          .eq('company_id', companyId)
          .order('created_at', ascending: false);

      return response.map<Commission>((data) => Commission.fromJson(data)).toList();
    } catch (e) {
      log('Error getting commissions for company $companyId: $e');
      rethrow;
    }
  }

  /// Get commissions by status for a company
  Future<List<Commission>> getCommissionsByStatus(
    String companyId, 
    CommissionStatus status,
  ) async {
    try {
      final response = await _client
          .from('commissions')
          .select()
          .eq('company_id', companyId)
          .eq('status', status.name)
          .order('created_at', ascending: false);

      return response.map<Commission>((data) => Commission.fromJson(data)).toList();
    } catch (e) {
      log('Error getting commissions by status for company $companyId: $e');
      rethrow;
    }
  }

  /// Get a specific commission by ID
  Future<Commission?> getCommissionById(int id) async {
    try {
      final response = await _client
          .from('commissions')
          .select()
          .eq('id', id)
          .single();

      return Commission.fromJson(response);
    } catch (e) {
      if (e is PostgrestException && e.code == 'PGRST116') {
        // No rows found
        return null;
      }
      log('Error getting commission by ID $id: $e');
      rethrow;
    }
  }

  /// Mark a commission as paid
  Future<Commission> markCommissionAsPaid(
    int commissionId, {
    String? billingPeriodId,
    String? notes,
  }) async {
    try {
      final now = DateTime.now();
      
      final updateData = {
        'status': CommissionStatus.paid.name,
        'paid_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      if (billingPeriodId != null) {
        updateData['billing_period_id'] = billingPeriodId;
      }

      if (notes != null) {
        updateData['notes'] = notes;
      }

      final response = await _client
          .from('commissions')
          .update(updateData)
          .eq('id', commissionId)
          .select()
          .single();

      return Commission.fromJson(response);
    } catch (e) {
      log('Error marking commission $commissionId as paid: $e');
      rethrow;
    }
  }

  /// Update commission status
  Future<Commission> updateCommissionStatus(
    int commissionId,
    CommissionStatus status, {
    String? notes,
  }) async {
    try {
      final now = DateTime.now();
      
      final updateData = {
        'status': status.name,
        'updated_at': now.toIso8601String(),
      };

      if (notes != null) {
        updateData['notes'] = notes;
      }

      // Set paid_at when marking as paid
      if (status == CommissionStatus.paid) {
        updateData['paid_at'] = now.toIso8601String();
      }

      final response = await _client
          .from('commissions')
          .update(updateData)
          .eq('id', commissionId)
          .select()
          .single();

      return Commission.fromJson(response);
    } catch (e) {
      log('Error updating commission $commissionId status: $e');
      rethrow;
    }
  }

  /// Cancel a commission
  Future<Commission> cancelCommission(int commissionId, {String? reason}) async {
    try {
      return await updateCommissionStatus(
        commissionId,
        CommissionStatus.cancelled,
        notes: reason,
      );
    } catch (e) {
      log('Error cancelling commission $commissionId: $e');
      rethrow;
    }
  }

  /// Get commission statistics for a company
  Future<Map<String, dynamic>> getCommissionStatistics(String companyId) async {
    try {
      final commissions = await getCommissionsForCompany(companyId);

      if (commissions.isEmpty) {
        return {
          'totalCommissions': 0,
          'totalAmount': 0.0,
          'pendingAmount': 0.0,
          'paidAmount': 0.0,
          'averageCommissionRate': 0.0,
        };
      }

      final totalCommissions = commissions.length;
      final totalAmount = commissions.fold<double>(
        0.0, 
        (sum, commission) => sum + commission.commissionAmount,
      );

      final pendingCommissions = commissions
          .where((c) => c.status == CommissionStatus.pending)
          .toList();
      final pendingAmount = pendingCommissions.fold<double>(
        0.0, 
        (sum, commission) => sum + commission.commissionAmount,
      );

      final paidCommissions = commissions
          .where((c) => c.status == CommissionStatus.paid)
          .toList();
      final paidAmount = paidCommissions.fold<double>(
        0.0, 
        (sum, commission) => sum + commission.commissionAmount,
      );

      final averageCommissionRate = commissions.fold<double>(
        0.0, 
        (sum, commission) => sum + commission.commissionRate,
      ) / commissions.length;

      return {
        'totalCommissions': totalCommissions,
        'totalAmount': totalAmount,
        'pendingAmount': pendingAmount,
        'paidAmount': paidAmount,
        'averageCommissionRate': averageCommissionRate,
        'pendingCommissions': pendingCommissions.length,
        'paidCommissions': paidCommissions.length,
      };
    } catch (e) {
      log('Error getting commission statistics for company $companyId: $e');
      rethrow;
    }
  }

  /// Get commissions for a specific date range
  Future<List<Commission>> getCommissionsForDateRange(
    String companyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _client
          .from('commissions')
          .select()
          .eq('company_id', companyId)
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .order('created_at', ascending: false);

      return response.map<Commission>((data) => Commission.fromJson(data)).toList();
    } catch (e) {
      log('Error getting commissions for date range: $e');
      rethrow;
    }
  }

  /// Get overdue commissions (older than 30 days and not paid)
  Future<List<Commission>> getOverdueCommissions(String companyId) async {
    try {
      final overdueThreshold = DateTime.now().subtract(const Duration(days: 30));

      final response = await _client
          .from('commissions')
          .select()
          .eq('company_id', companyId)
          .neq('status', CommissionStatus.paid.name)
          .lte('created_at', overdueThreshold.toIso8601String())
          .order('created_at', ascending: true); // Oldest first

      return response.map<Commission>((data) => Commission.fromJson(data)).toList();
    } catch (e) {
      log('Error getting overdue commissions for company $companyId: $e');
      rethrow;
    }
  }

  /// Process batch payment for multiple commissions
  Future<List<Commission>> processBatchPayment(
    List<int> commissionIds, {
    String? billingPeriodId,
    String? notes,
  }) async {
    try {
      final now = DateTime.now();
      
      final updateData = {
        'status': CommissionStatus.paid.name,
        'paid_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      if (billingPeriodId != null) {
        updateData['billing_period_id'] = billingPeriodId;
      }

      if (notes != null) {
        updateData['notes'] = notes;
      }

      final response = await _client
          .from('commissions')
          .update(updateData)
          .inFilter('id', commissionIds)
          .select();

      return response.map<Commission>((data) => Commission.fromJson(data)).toList();
    } catch (e) {
      log('Error processing batch payment for commissions $commissionIds: $e');
      rethrow;
    }
  }

  /// Calculate total commission amount for a billing period
  Future<double> getTotalCommissionForPeriod(String billingPeriodId) async {
    try {
      final response = await _client
          .from('commissions')
          .select('commission_amount')
          .eq('billing_period_id', billingPeriodId)
          .eq('status', CommissionStatus.paid.name);

      if (response.isEmpty) {
        return 0.0;
      }

      return response.fold<double>(
        0.0, 
        (sum, row) => sum + (row['commission_amount'] as num).toDouble(),
      );
    } catch (e) {
      log('Error getting total commission for period $billingPeriodId: $e');
      rethrow;
    }
  }

  /// Get commission summary by hike for a company
  Future<Map<int, Map<String, dynamic>>> getCommissionSummaryByHike(
    String companyId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _client
          .from('commissions')
          .select()
          .eq('company_id', companyId);

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query;
      final commissions = response.map<Commission>((data) => Commission.fromJson(data)).toList();

      final Map<int, Map<String, dynamic>> summary = {};

      for (final commission in commissions) {
        if (!summary.containsKey(commission.hikeId)) {
          summary[commission.hikeId] = {
            'hikeId': commission.hikeId,
            'totalCommissions': 0,
            'totalAmount': 0.0,
            'pendingAmount': 0.0,
            'paidAmount': 0.0,
            'commissions': <Commission>[],
          };
        }

        final hikeSummary = summary[commission.hikeId]!;
        hikeSummary['totalCommissions'] += 1;
        hikeSummary['totalAmount'] += commission.commissionAmount;
        
        if (commission.isPaid) {
          hikeSummary['paidAmount'] += commission.commissionAmount;
        } else if (commission.isPending) {
          hikeSummary['pendingAmount'] += commission.commissionAmount;
        }
        
        (hikeSummary['commissions'] as List<Commission>).add(commission);
      }

      return summary;
    } catch (e) {
      log('Error getting commission summary by hike for company $companyId: $e');
      rethrow;
    }
  }
}