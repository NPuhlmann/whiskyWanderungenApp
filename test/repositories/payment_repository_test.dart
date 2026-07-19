import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/data/repositories/payment_repository.dart';
import 'package:whisky_hikes/domain/models/delivery_address.dart';

import '../mocks/mock_repositories.mocks.dart';

// Focused unit tests for `PaymentRepository`. Plain orders are created
// server-side by the `create-payment-intent` Edge Function (ADR-0006), so the
// repository has no order-insert left to test; purchase execution lives in
// PurchaseIntakeRepository and is covered by its own tests. What remains here
// is the argument validation on `createEnhancedOrder`, which runs before any
// Supabase call.
const _address = DeliveryAddress(
  firstName: 'Nico',
  lastName: 'Puhlmann',
  addressLine1: 'Hauptstraße 1',
  city: 'Berlin',
  postalCode: '10115',
  countryCode: 'DE',
  countryName: 'Deutschland',
);

void main() {
  group('PaymentRepository', () {
    late PaymentRepository paymentRepository;

    setUp(() {
      paymentRepository = PaymentRepository(
        supabaseClient: MockSupabaseClient(),
        multiPaymentService: MockMultiPaymentService(),
      );
    });

    group('createEnhancedOrder parameter validation', () {
      Future<void> create({
        int hikeId = 1,
        String userId = 'user_1',
        String companyId = 'company_1',
        double baseAmount = 25.0,
      }) => paymentRepository.createEnhancedOrder(
        hikeId: hikeId,
        userId: userId,
        companyId: companyId,
        baseAmount: baseAmount,
        deliveryAddress: _address,
      );

      test('rejects hikeId <= 0', () {
        expect(() => create(hikeId: 0), throwsA(isA<ArgumentError>()));
      });

      test('rejects empty userId', () {
        expect(() => create(userId: ''), throwsA(isA<ArgumentError>()));
      });

      test('rejects empty companyId', () {
        expect(() => create(companyId: ''), throwsA(isA<ArgumentError>()));
      });

      test('rejects baseAmount <= 0', () {
        expect(() => create(baseAmount: 0), throwsA(isA<ArgumentError>()));
      });
    });
  });
}
