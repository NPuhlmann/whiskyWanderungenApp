import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:whisky_hikes/data/repositories/payment_repository.dart';
import 'package:whisky_hikes/domain/models/basic_order.dart';
import 'package:whisky_hikes/domain/models/basic_payment_result.dart';
import 'package:whisky_hikes/domain/models/payment_intent.dart'
    show PaymentMethodType;

import '../mocks/mock_repositories.mocks.dart';

// Focused unit tests for `PaymentRepository`. The wider checkout flow will
// get end-to-end coverage from WHI-6 once the cart UI exists and can be
// exercised against a seeded Supabase fixture; until then these tests pin
// the non-DB invariants: argument validation on `createOrder` and the
// payment-failure branch of `processPayment`.
void main() {
  group('PaymentRepository', () {
    late MockSupabaseClient mockSupabaseClient;
    late MockStripeService mockStripeService;
    late MockMultiPaymentService mockMultiPaymentService;
    late PaymentRepository paymentRepository;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockStripeService = MockStripeService();
      mockMultiPaymentService = MockMultiPaymentService();

      paymentRepository = PaymentRepository(
        supabaseClient: mockSupabaseClient,
        stripeService: mockStripeService,
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

    group('processPayment', () {
      late BasicOrder order;

      setUp(() {
        order = BasicOrder(
          id: 1,
          orderNumber: 'ORD-001',
          hikeId: 1,
          userId: 'user_1',
          totalAmount: 25.99,
          deliveryType: DeliveryType.pickup,
          status: OrderStatus.pending,
          createdAt: DateTime.now(),
        );
      });

      test('returns a failure result when MultiPaymentService throws', () async {
        when(
          mockMultiPaymentService.processPayment(
            amount: anyNamed('amount'),
            currency: anyNamed('currency'),
            paymentMethod: anyNamed('paymentMethod'),
            metadata: anyNamed('metadata'),
          ),
        ).thenThrow(Exception('Card declined'));

        final result = await paymentRepository.processPayment(
          order: order,
          paymentMethod: PaymentMethodType.card,
        );

        expect(result.isSuccess, isFalse);
        expect(result.status, equals(PaymentStatus.failed));
        expect(result.errorMessage, contains('Payment processing failed'));
      });
    });
  });
}
