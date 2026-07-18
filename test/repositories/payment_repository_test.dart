import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:whisky_hikes/data/repositories/payment_repository.dart';
import 'package:whisky_hikes/domain/models/basic_order.dart';

import '../mocks/mock_repositories.mocks.dart';

// Focused unit tests for `PaymentRepository`. The wider checkout flow will
// get end-to-end coverage from WHI-6 once the cart UI exists and can be
// exercised against a seeded Supabase fixture; until then these tests pin
// the non-DB invariants: argument validation on
// `createOrder`. Purchase execution now lives in PurchaseIntakeRepository
// and is covered by its own tests.
void main() {
  group('PaymentRepository', () {
    late MockSupabaseClient mockSupabaseClient;
    late MockMultiPaymentService mockMultiPaymentService;
    late PaymentRepository paymentRepository;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockMultiPaymentService = MockMultiPaymentService();

      paymentRepository = PaymentRepository(
        supabaseClient: mockSupabaseClient,
        multiPaymentService: mockMultiPaymentService,
      );
    });

    group('createOrder parameter validation', () {
      test('rejects hikeId <= 0', () async {
        expect(
          () => paymentRepository.createOrder(
            hikeId: 0,
            userId: 'user_1',
            amount: 25.0,
            deliveryType: DeliveryType.pickup,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('rejects empty userId', () async {
        expect(
          () => paymentRepository.createOrder(
            hikeId: 1,
            userId: '',
            amount: 25.0,
            deliveryType: DeliveryType.pickup,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('rejects amount <= 0', () async {
        expect(
          () => paymentRepository.createOrder(
            hikeId: 1,
            userId: 'user_1',
            amount: 0,
            deliveryType: DeliveryType.pickup,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}
