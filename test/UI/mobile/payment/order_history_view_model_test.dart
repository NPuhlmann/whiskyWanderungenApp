import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:whisky_hikes/UI/mobile/payment/order_history_view_model.dart';
import 'package:whisky_hikes/data/repositories/payment_repository.dart';
import 'package:whisky_hikes/data/repositories/user_repository.dart';
import 'package:whisky_hikes/domain/models/basic_order.dart';

@GenerateMocks([PaymentRepository, UserRepository])
import 'order_history_view_model_test.mocks.dart';

BasicOrder _order(int id) => BasicOrder(
  id: id,
  orderNumber: 'WH-$id',
  hikeId: 1,
  userId: 'user-1',
  totalAmount: 49.9,
  deliveryType: DeliveryType.standardShipping,
  status: OrderStatus.confirmed,
  createdAt: DateTime(2026, 1, 1),
);

void main() {
  late MockPaymentRepository paymentRepository;
  late MockUserRepository userRepository;

  OrderHistoryViewModel build() => OrderHistoryViewModel(
    paymentRepository: paymentRepository,
    userRepository: userRepository,
  );

  setUp(() {
    paymentRepository = MockPaymentRepository();
    userRepository = MockUserRepository();
  });

  group('OrderHistoryViewModel', () {
    test('load() füllt orders und beendet den Ladezustand', () async {
      when(userRepository.getUserId()).thenReturn('user-1');
      when(
        paymentRepository.getUserOrders('user-1'),
      ).thenAnswer((_) async => [_order(1), _order(2)]);
      final vm = build();

      await vm.load();

      expect(vm.orders, hasLength(2));
      expect(vm.isLoading, isFalse);
      expect(vm.errorMessage, isNull);
      verify(paymentRepository.getUserOrders('user-1')).called(1);
    });

    test('load() liefert eine leere Liste ohne Fehler', () async {
      when(userRepository.getUserId()).thenReturn('user-1');
      when(
        paymentRepository.getUserOrders('user-1'),
      ).thenAnswer((_) async => const []);
      final vm = build();

      await vm.load();

      expect(vm.orders, isEmpty);
      expect(vm.errorMessage, isNull);
      expect(vm.isLoading, isFalse);
    });

    test('load() setzt errorMessage, wenn niemand angemeldet ist', () async {
      when(userRepository.getUserId()).thenReturn(null);
      final vm = build();

      await vm.load();

      expect(vm.errorMessage, contains('nicht angemeldet'));
      expect(vm.orders, isEmpty);
      expect(vm.isLoading, isFalse);
      verifyNever(paymentRepository.getUserOrders(any));
    });

    test('load() faengt Repository-Fehler ab statt zu werfen', () async {
      when(userRepository.getUserId()).thenReturn('user-1');
      when(
        paymentRepository.getUserOrders('user-1'),
      ).thenThrow(Exception('boom'));
      final vm = build();

      await vm.load();

      expect(vm.errorMessage, contains('boom'));
      expect(vm.orders, isEmpty);
      expect(vm.isLoading, isFalse);
    });

    test('load() nach dispose() benachrichtigt nicht mehr', () async {
      when(userRepository.getUserId()).thenReturn('user-1');
      when(
        paymentRepository.getUserOrders('user-1'),
      ).thenAnswer((_) async => [_order(1)]);
      final vm = build();

      vm.dispose();

      // Wirft ohne die _disposed-Wache "was used after being disposed".
      await expectLater(vm.load(), completes);
    });
  });
}
