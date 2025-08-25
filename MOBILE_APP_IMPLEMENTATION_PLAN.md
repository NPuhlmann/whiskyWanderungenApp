# 📱 Mobile App - Implementierungsplan

## 🎯 Übersicht

Dieser Plan beschreibt die Implementierung aller fehlenden Features für die Whisky Hikes Mobile App, basierend auf der aktuellen Codebase-Analyse.

## 📊 Aktueller Status

### ✅ Bereits implementiert:
- **Authentifizierung**: Login/Signup mit Supabase
- **Grundstruktur**: MVVM-Architektur, Routing, Navigation
- **Datenmodelle**: Hike, Profile, Waypoint (mit Freezed)
- **Basis-UI**: Home, Profile, Hike Details, My Hikes
- **Kartenintegration**: Flutter Map mit Wegpunkt-Anzeige
- **Datenbank**: Supabase mit RLS-Policies
- **Lokalisierung**: Deutsch/Englisch

### ❌ Fehlende Features:
- **Payment & Checkout**: Stripe-Integration, Bestellabwicklung
- **Tasting-Set-Management**: Abholung vs. Lieferung
- **Bestellstatus-Tracking**: Bestellverfolgung
- **Offline-Funktionalität**: Lokales Caching
- **Push-Benachrichtigungen**: Bestell-Updates
- **Bewertungssystem**: Hike-Reviews
- **Erweiterte Navigation**: GPS-Tracking, Routenführung

## 🚀 Phase 1: Payment & Checkout System

### 1.1 Stripe-Integration einrichten

#### Schritt 1: Dependencies hinzufügen
```yaml
# pubspec.yaml
dependencies:
  stripe_platform_interface: ^8.0.0
  flutter_stripe_android: ^8.0.0
  flutter_stripe_ios: ^8.0.0
  flutter_stripe_web: ^8.0.0
```

#### Schritt 2: Stripe-Service erstellen
```dart
// lib/data/services/payment/stripe_service.dart
class StripeService {
  static const String publishableKey = 'pk_test_...';
  
  Future<void> initialize() async {
    Stripe.publishableKey = publishableKey;
  }
  
  Future<PaymentIntent> createPaymentIntent(double amount, String currency) async {
    // API-Call zu deinem Backend für Payment Intent
  }
  
  Future<void> confirmPayment(String clientSecret, PaymentMethodParams params) async {
    // Payment bestätigen
  }
}
```

#### Schritt 3: Payment-Repository implementieren
```dart
// lib/data/repositories/payment_repository.dart
class PaymentRepository {
  final StripeService _stripeService;
  final BackendApiService _backendApi;
  
  Future<PaymentResult> processHikePurchase(int hikeId, PaymentMethod paymentMethod) async {
    // 1. Hike-Preis abrufen
    // 2. Payment Intent erstellen
    // 3. Payment bestätigen
    // 4. Bestellung in Datenbank speichern
  }
}
```

### 1.2 Checkout-UI implementieren

#### Schritt 4: Checkout-Page erstellen
```dart
// lib/UI/checkout/checkout_page.dart
class CheckoutPage extends StatelessWidget {
  final Hike hike;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checkout')),
      body: Column(
        children: [
          HikeSummaryCard(hike: hike),
          DeliveryOptionsCard(),
          PaymentMethodCard(),
          CheckoutButton(),
        ],
      ),
    );
  }
}
```

#### Schritt 5: Delivery-Options implementieren
```dart
// lib/UI/checkout/widgets/delivery_options_card.dart
class DeliveryOptionsCard extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          RadioListTile<DeliveryType>(
            title: Text('Vor Ort abholen'),
            subtitle: Text('Kostenlos'),
            value: DeliveryType.pickup,
            groupValue: _selectedDelivery,
            onChanged: (value) => setState(() => _selectedDelivery = value),
          ),
          RadioListTile<DeliveryType>(
            title: Text('Per Post versenden'),
            subtitle: Text('+5,00 € Versandkosten'),
            value: DeliveryType.shipping,
            groupValue: _selectedDelivery,
            onChanged: (value) => setState(() => _selectedDelivery = value),
          ),
        ],
      ),
    );
  }
}
```

### 1.3 Datenbank-Schema erweitern

#### Schritt 6: Neue Tabellen erstellen
```sql
-- lib/terraform-supabase/sql/04_orders_tables.sql
CREATE TABLE IF NOT EXISTS public.orders (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    hike_id INTEGER REFERENCES public.hikes(id) ON DELETE CASCADE,
    order_number TEXT UNIQUE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    delivery_type TEXT NOT NULL CHECK (delivery_type IN ('pickup', 'shipping')),
    delivery_address JSONB,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled')),
    payment_intent_id TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES public.orders(id) ON DELETE CASCADE,
    hike_id INTEGER REFERENCES public.hikes(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 🚀 Phase 2: Tasting-Set-Management

### 2.1 Tasting-Set-Model erstellen

#### Schritt 7: Tasting-Set-Datenmodell
```dart
// lib/domain/models/tasting_set.dart
@freezed
class TastingSet with _$TastingSet {
  const factory TastingSet({
    required int id,
    required int hikeId,
    required String name,
    required String description,
    required List<WhiskySample> samples,
    required double price,
    required String imageUrl,
    @Default(false) bool isIncluded,
  }) = _TastingSet;
}

@freezed
class WhiskySample with _$WhiskySample {
  const factory WhiskySample({
    required int id,
    required String name,
    required String distillery,
    required int age,
    required String region,
    required String tastingNotes,
    required String imageUrl,
  }) = _WhiskySample;
}
```

### 2.2 Tasting-Set-Repository implementieren

#### Schritt 8: Repository für Tasting-Sets
```dart
// lib/data/repositories/tasting_set_repository.dart
class TastingSetRepository {
  final BackendApiService _backendApi;
  
  Future<List<TastingSet>> getTastingSetsForHike(int hikeId) async {
    final response = await _backendApi.get('/tasting-sets?hike_id=$hikeId');
    return (response as List).map((json) => TastingSet.fromJson(json)).toList();
  }
  
  Future<void> addTastingSetToOrder(int orderId, int tastingSetId) async {
    await _backendApi.post('/orders/$orderId/tasting-sets', {
      'tasting_set_id': tastingSetId,
    });
  }
}
```

## 🚀 Phase 3: Bestellstatus-Tracking

### 3.1 Order-Status-Model

#### Schritt 9: Order-Status implementieren
```dart
// lib/domain/models/order.dart
@freezed
class Order with _$Order {
  const factory Order({
    required int id,
    required String orderNumber,
    required int hikeId,
    required double totalAmount,
    required DeliveryType deliveryType,
    required OrderStatus status,
    required DateTime createdAt,
    DateTime? estimatedDelivery,
    String? trackingNumber,
    Map<String, dynamic>? deliveryAddress,
  }) = _Order;
}

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled
}

enum DeliveryType {
  pickup,
  shipping
}
```

### 3.2 Order-Tracking-UI

#### Schritt 10: Order-Tracking-Page
```dart
// lib/UI/orders/order_tracking_page.dart
class OrderTrackingPage extends StatelessWidget {
  final int orderId;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bestellverfolgung')),
      body: Consumer<OrderTrackingViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              OrderStatusTimeline(order: viewModel.order),
              if (viewModel.order.deliveryType == DeliveryType.shipping)
                ShippingInfoCard(order: viewModel.order),
              if (viewModel.order.status == OrderStatus.shipped)
                TrackingInfoCard(order: viewModel.order),
            ],
          );
        },
      ),
    );
  }
}
```

## 🚀 Phase 4: Offline-Funktionalität

### 4.1 Lokales Caching implementieren

#### Schritt 11: Offline-Service erweitern
```dart
// lib/data/services/cache/offline_service.dart
class OfflineService {
  final LocalCacheService _localCache;
  
  Future<void> cacheHikeData(Hike hike) async {
    await _localCache.set('hike_${hike.id}', hike.toJson());
  }
  
  Future<void> cacheWaypoints(int hikeId, List<Waypoint> waypoints) async {
    await _localCache.set('waypoints_$hikeId', 
      waypoints.map((w) => w.toJson()).toList());
  }
  
  Future<Hike?> getCachedHike(int hikeId) async {
    final data = await _localCache.get('hike_$hikeId');
    return data != null ? Hike.fromJson(data) : null;
  }
}
```

### 4.2 Offline-First-Repository

#### Schritt 12: Offline-First-Pattern implementieren
```dart
// lib/data/repositories/offline_first_hike_repository.dart
class OfflineFirstHikeRepository {
  final HikeRepository _onlineRepository;
  final OfflineService _offlineService;
  
  Future<Hike> getHike(int hikeId) async {
    try {
      // Erst online versuchen
      final hike = await _onlineRepository.getHike(hikeId);
      await _offlineService.cacheHikeData(hike);
      return hike;
    } catch (e) {
      // Fallback auf offline
      final cachedHike = await _offlineService.getCachedHike(hikeId);
      if (cachedHike != null) {
        return cachedHike;
      }
      throw Exception('Hike nicht verfügbar (online/offline)');
    }
  }
}
```

## 🚀 Phase 5: Push-Benachrichtigungen

### 5.1 Supabase Realtime & Push-Benachrichtigungen

#### Schritt 13: Supabase Realtime Dependencies
```yaml
# pubspec.yaml
dependencies:
  flutter_local_notifications: ^16.3.2
  # Supabase hat bereits Realtime-Funktionalität integriert
```

#### Schritt 14: Supabase Realtime Notification Service
```dart
// lib/data/services/notifications/supabase_notification_service.dart
class SupabaseNotificationService {
  final SupabaseClient _supabase;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  Future<void> initialize() async {
    // Supabase Realtime für Order-Updates abonnieren
    await _subscribeToOrderUpdates();
    
    // Lokale Benachrichtigungen konfigurieren
    await _configureLocalNotifications();
  }
  
  Future<void> _subscribeToOrderUpdates() async {
    // Realtime-Subscription für Order-Status-Änderungen
    _supabase
      .channel('order_updates')
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'orders',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: _supabase.auth.currentUser?.id,
        ),
        callback: (payload) => _handleOrderUpdate(payload),
      )
      .subscribe();
  }
}
```

### 5.2 Notification-Handling

#### Schritt 15: Notification-Handler implementieren
```dart
// lib/data/services/notifications/notification_handler.dart
class NotificationHandler {
  static void handleOrderStatusUpdate(Map<String, dynamic> data) {
    final orderId = data['order_id'];
    final newStatus = data['status'];
    
    // Lokale Benachrichtigung anzeigen
    _showLocalNotification(
      title: 'Bestellstatus aktualisiert',
      body: 'Deine Bestellung #$orderId hat den Status: $newStatus',
      payload: 'order_$orderId',
    );
  }
  
  static void handleDeliveryUpdate(Map<String, dynamic> data) {
    final orderId = data['order_id'];
    final trackingNumber = data['tracking_number'];
    
    _showLocalNotification(
      title: 'Versand-Updates',
      body: 'Bestellung #$orderId wurde versendet. Tracking: $trackingNumber',
      payload: 'delivery_$orderId',
    );
  }
}
```

## 🚀 Phase 6: Bewertungssystem

### 6.1 Review-Model erstellen

#### Schritt 16: Review-Datenmodell
```dart
// lib/domain/models/review.dart
@freezed
class Review with _$Review {
  const factory Review({
    required int id,
    required int hikeId,
    required int userId,
    required double rating,
    required String comment,
    required DateTime createdAt,
    String? userFirstName,
    String? userLastName,
  }) = _Review;
}
```

### 6.2 Review-UI implementieren

#### Schritt 17: Review-Page
```dart
// lib/UI/reviews/review_page.dart
class ReviewPage extends StatelessWidget {
  final int hikeId;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bewertung schreiben')),
      body: Column(
        children: [
          RatingStars(),
          ReviewTextField(),
          SubmitReviewButton(),
        ],
      ),
    );
  }
}
```

## 🚀 Phase 7: Erweiterte Navigation

### 7.1 GPS-Tracking implementieren

#### Schritt 18: Location-Service
```dart
// lib/data/services/location/location_service.dart
class LocationService {
  final Geolocator _geolocator = Geolocator();
  
  Stream<Position> getCurrentLocation() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Nur Updates alle 10 Meter
    );
    
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }
  
  Future<double> calculateDistanceToWaypoint(
    Position currentPosition, 
    Waypoint waypoint
  ) async {
    return Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      waypoint.latitude,
      waypoint.longitude,
    );
  }
}
```

### 7.2 Routenführung implementieren

#### Schritt 19: Navigation-Service
```dart
// lib/data/services/navigation/navigation_service.dart
class NavigationService {
  final LocationService _locationService;
  
  Stream<NavigationInstruction> getNavigationInstructions(
    int hikeId, 
    List<Waypoint> waypoints
  ) async* {
    await for (final position in _locationService.getCurrentLocation()) {
      final nextWaypoint = _findNextWaypoint(position, waypoints);
      if (nextWaypoint != null) {
        final distance = await _locationService.calculateDistanceToWaypoint(
          position, 
          nextWaypoint
        );
        
        yield NavigationInstruction(
          waypoint: nextWaypoint,
          distance: distance,
          direction: _calculateDirection(position, nextWaypoint),
        );
      }
    }
  }
}
```

## 🚀 Phase 8: Integration & Testing

### 8.1 Alle Features integrieren

#### Schritt 20: Main-App erweitern
```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Services initialisieren
  await Supabase.initialize(/* bereits konfiguriert */);
  await SupabaseNotificationService().initialize();
  await StripeService().initialize();
  
  // App starten
  runApp(MyApp());
}
```

### 8.2 Umfassende Tests schreiben

#### Schritt 21: Test-Suite erweitern
```dart
// test/UI/checkout/checkout_page_test.dart
void main() {
  group('CheckoutPage', () {
    testWidgets('should display hike summary', (tester) async {
      // Test-Implementation
    });
    
    testWidgets('should handle payment method selection', (tester) async {
      // Test-Implementation
    });
    
    testWidgets('should process payment successfully', (tester) async {
      // Test-Implementation
    });
  });
}
```

## 📅 Implementierungszeitplan

### **Woche 1-2: Payment & Checkout**
- Stripe-Integration
- Checkout-UI
- Datenbank-Schema

### **Woche 3-4: Tasting-Set & Orders**
- Tasting-Set-Models
- Bestellverwaltung
- Order-Tracking

### **Woche 5-6: Offline & Notifications**
- Offline-Caching
- Push-Benachrichtigungen
- FCM-Integration

### **Woche 7-8: Reviews & Navigation**
- Bewertungssystem
- GPS-Tracking
- Routenführung

### **Woche 9-10: Integration & Testing**
- Alle Features integrieren
- Umfassende Tests
- Bugfixes & Optimierungen

## 🔧 Technische Anforderungen

### **Neue Dependencies:**
- `stripe_platform_interface`
- `flutter_local_notifications`
- `geolocator`
- `permission_handler`
- `supabase_flutter` (bereits vorhanden, für Realtime)

### **Backend-Erweiterungen:**
- Stripe-Webhook-Endpoints (über Supabase Edge Functions)
- Supabase Realtime für Order-Updates
- Order-Management-APIs (über Supabase RPC Functions)
- Review-System-APIs (über Supabase RPC Functions)

### **Datenbank-Erweiterungen:**
- Orders-Tabelle
- Order-Items-Tabelle
- Reviews-Tabelle
- Tasting-Sets-Tabelle
- Whisky-Samples-Tabelle

## 🎯 Erfolgsmetriken

- ✅ Payment-Flow funktioniert end-to-end
- ✅ Offline-Funktionalität bei 90% der Features
- ✅ Push-Benachrichtigungen funktionieren zuverlässig
- ✅ GPS-Tracking ist präzise (≤5m Abweichung)
- ✅ Alle Tests bestehen (≥90% Coverage)
- ✅ App-Performance bleibt unter 2s Ladezeit

---

# 📋 TRACKABLE IMPLEMENTATION CHECKLIST

## 🎯 How to Use This Plan

**Für Claude Code**: Diese erweiterte Struktur ermöglicht es dir, jeden Schritt systematisch abzuarbeiten:
1. Markiere Tasks als `[ ]` (pending), `[🟡]` (in progress), oder `[✅]` (completed)
2. Validiere jeden Task mit den angegebenen Kriterien
3. Führe die Tests aus bevor du zum nächsten Task gehst
4. Überprüfe Dependencies und Imports

**Für den User**: Prompte mich einfach mit "Nächster Schritt" und ich arbeite den nächsten pending Task ab.

---

## 🚀 PHASE 1: PAYMENT & CHECKOUT SYSTEM
**Status**: ⏳ Pending | **Geschätzte Zeit**: 2 Wochen

### Task 1.1: Stripe Dependencies Setup
**Status**: [ ] **Files**: `pubspec.yaml`

**Implementation**:
```yaml
# ADD TO pubspec.yaml dependencies:
stripe_platform_interface: ^8.0.0
flutter_stripe_android: ^8.0.0
flutter_stripe_ios: ^8.0.0
flutter_stripe_web: ^8.0.0
```

**Validation Criteria**:
- [ ] Dependencies added to pubspec.yaml
- [ ] `flutter pub get` runs successfully
- [ ] No version conflicts in pubspec.lock
- [ ] flutter analyze shows no errors

---

### Task 1.2: Stripe Service Implementation
**Status**: [ ] **Files**: `lib/data/services/payment/stripe_service.dart`

**Implementation**: Create new file with full Stripe integration:
```dart
// lib/data/services/payment/stripe_service.dart
import 'package:stripe_platform_interface/stripe_platform_interface.dart';
import 'package:flutter_stripe_android/flutter_stripe_android.dart';

class StripeService {
  static const String _publishableKey = 'pk_test_...';
  late final StripeApi _stripe;
  
  Future<void> initialize() async {
    // Platform-specific initialization
    if (Platform.isAndroid) {
      _stripe = StripeAndroid();
    } else if (Platform.isIOS) {
      _stripe = StripeIos();
    }
    
    await _stripe.initialize(publishableKey: _publishableKey);
  }
  
  Future<PaymentIntent> createPaymentIntent({
    required double amount,
    required String currency,
    required Map<String, dynamic> metadata,
  }) async {
    // Implementation
  }
  
  Future<PaymentMethodData> confirmPayment({
    required String clientSecret,
    required PaymentMethodParams params,
  }) async {
    // Implementation
  }
}
```

**Validation Criteria**:
- [ ] File created at correct path
- [ ] All imports resolve correctly
- [ ] Methods compile without errors
- [ ] flutter analyze shows no warnings
- [ ] Unit tests pass

---

### Task 1.3: Payment Models Creation
**Status**: [ ] **Files**: `lib/domain/models/payment.dart`, `lib/domain/models/order.dart`

**Implementation**: Create Freezed models
```dart
// lib/domain/models/order.dart
@freezed
class Order with _$Order {
  const factory Order({
    required int id,
    required String orderNumber,
    required int hikeId,
    required String userId,
    required double totalAmount,
    required DeliveryType deliveryType,
    required OrderStatus status,
    required DateTime createdAt,
    DateTime? estimatedDelivery,
    String? trackingNumber,
    Map<String, dynamic>? deliveryAddress,
    String? paymentIntentId,
  }) = _Order;
  
  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}

enum OrderStatus {
  @JsonValue('pending') pending,
  @JsonValue('confirmed') confirmed,
  @JsonValue('processing') processing,
  @JsonValue('shipped') shipped,
  @JsonValue('delivered') delivered,
  @JsonValue('cancelled') cancelled
}

enum DeliveryType {
  @JsonValue('pickup') pickup,
  @JsonValue('shipping') shipping
}
```

**Validation Criteria**:
- [ ] Models created with proper Freezed annotations
- [ ] JSON serialization works correctly
- [ ] Generated files (.freezed.dart, .g.dart) created
- [ ] flutter pub run build_runner build runs successfully
- [ ] Model tests pass

---

### Task 1.4: Payment Repository Implementation
**Status**: [ ] **Files**: `lib/data/repositories/payment_repository.dart`

**Implementation**:
```dart
class PaymentRepository {
  final StripeService _stripeService;
  final BackendApiService _backendApi;
  
  PaymentRepository(this._stripeService, this._backendApi);
  
  Future<PaymentResult> processHikePurchase({
    required int hikeId,
    required DeliveryType deliveryType,
    required Map<String, dynamic>? deliveryAddress,
  }) async {
    try {
      // 1. Get hike price from backend
      final hike = await _backendApi.getHike(hikeId);
      
      // 2. Calculate total (base price + delivery)
      final deliveryCost = deliveryType == DeliveryType.shipping ? 5.0 : 0.0;
      final totalAmount = hike.price + deliveryCost;
      
      // 3. Create payment intent
      final paymentIntent = await _stripeService.createPaymentIntent(
        amount: totalAmount,
        currency: 'eur',
        metadata: {
          'hike_id': hikeId.toString(),
          'delivery_type': deliveryType.name,
        },
      );
      
      // 4. Create order record
      final order = await _createOrder(
        hikeId: hikeId,
        totalAmount: totalAmount,
        deliveryType: deliveryType,
        deliveryAddress: deliveryAddress,
        paymentIntentId: paymentIntent.id,
      );
      
      return PaymentResult.success(
        order: order,
        clientSecret: paymentIntent.clientSecret,
      );
    } catch (e) {
      return PaymentResult.failure(error: e.toString());
    }
  }
  
  Future<Order> _createOrder({...}) async {
    // Implementation
  }
}
```

**Validation Criteria**:
- [ ] Repository follows existing patterns
- [ ] Error handling implemented
- [ ] Integration with BackendApiService works
- [ ] Unit tests cover all methods
- [ ] Integration test with mock Stripe service passes

---

### Task 1.5: Checkout Page UI Implementation
**Status**: [ ] **Files**: `lib/UI/checkout/checkout_page.dart`

**Implementation**: Create complete checkout flow
```dart
class CheckoutPage extends StatelessWidget {
  final Hike hike;
  
  const CheckoutPage({Key? key, required this.hike}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CheckoutViewModel(
        hike: hike,
        paymentRepository: context.read<PaymentRepository>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.checkout),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Consumer<CheckoutViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HikeSummaryCard(hike: hike),
                  const SizedBox(height: 16),
                  DeliveryOptionsCard(
                    selectedDelivery: viewModel.selectedDeliveryType,
                    onDeliveryChanged: viewModel.updateDeliveryType,
                  ),
                  const SizedBox(height: 16),
                  if (viewModel.selectedDeliveryType == DeliveryType.shipping)
                    DeliveryAddressCard(
                      address: viewModel.deliveryAddress,
                      onAddressChanged: viewModel.updateDeliveryAddress,
                    ),
                  const SizedBox(height: 16),
                  PaymentSummaryCard(
                    basePrice: hike.price,
                    deliveryCost: viewModel.deliveryCost,
                    totalAmount: viewModel.totalAmount,
                  ),
                  const SizedBox(height: 24),
                  CheckoutButton(
                    onPressed: viewModel.canProceed ? viewModel.processPayment : null,
                    isLoading: viewModel.isProcessingPayment,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
```

**Validation Criteria**:
- [ ] UI follows app design patterns
- [ ] Responsive design works on different screen sizes
- [ ] Localization strings added to ARB files
- [ ] Accessibility features implemented
- [ ] Widget tests created and passing

---

### Task 1.6: Delivery Options Widget
**Status**: [ ] **Files**: `lib/UI/checkout/widgets/delivery_options_card.dart`

**Validation Criteria**:
- [ ] Radio buttons work correctly
- [ ] Price updates dynamically
- [ ] Widget follows Material Design guidelines
- [ ] Unit tests cover all user interactions

---

### Task 1.7: Checkout ViewModel Implementation
**Status**: [ ] **Files**: `lib/UI/checkout/checkout_view_model.dart`

**Validation Criteria**:
- [ ] State management follows MVVM pattern
- [ ] Error states handled properly
- [ ] Loading states implemented
- [ ] Unit tests cover all state changes

---

### Task 1.8: Database Schema Extension
**Status**: [ ] **Files**: `terraform-supabase/sql/05_orders_tables.sql`

**Implementation**:
```sql
-- Orders table
CREATE TABLE IF NOT EXISTS public.orders (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    hike_id INTEGER REFERENCES public.hikes(id) ON DELETE CASCADE,
    order_number TEXT UNIQUE NOT NULL DEFAULT ('WH' || EXTRACT(YEAR FROM NOW()) || '-' || LPAD(nextval('order_sequence')::TEXT, 6, '0')),
    total_amount DECIMAL(10,2) NOT NULL,
    delivery_type TEXT NOT NULL CHECK (delivery_type IN ('pickup', 'shipping')),
    delivery_address JSONB,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled')),
    payment_intent_id TEXT,
    tracking_number TEXT,
    estimated_delivery TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Order items table
CREATE TABLE IF NOT EXISTS public.order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES public.orders(id) ON DELETE CASCADE,
    hike_id INTEGER REFERENCES public.hikes(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Order sequence for unique order numbers
CREATE SEQUENCE IF NOT EXISTS order_sequence START 1;

-- Indexes
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON public.orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON public.orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON public.orders(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON public.order_items(order_id);

-- RLS Policies
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own orders" ON public.orders
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own orders" ON public.orders
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own orders" ON public.orders
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view order items for their orders" ON public.order_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.orders 
            WHERE id = order_items.order_id AND user_id = auth.uid()
        )
    );
```

**Validation Criteria**:
- [ ] SQL script executes without errors
- [ ] Tables created with correct structure
- [ ] Indexes improve query performance
- [ ] RLS policies secure data access
- [ ] Migration script tested

---

### Task 1.9: Backend API Integration
**Status**: [ ] **Files**: `lib/data/services/database/backend_api.dart`

**Implementation**: Extend existing BackendApiService
```dart
// ADD TO BackendApiService class:

// Orders
Future<Order> createOrder({
  required int hikeId,
  required DeliveryType deliveryType,
  Map<String, dynamic>? deliveryAddress,
  required double totalAmount,
  String? paymentIntentId,
}) async {
  final response = await _supabase
    .from('orders')
    .insert({
      'user_id': _supabase.auth.currentUser!.id,
      'hike_id': hikeId,
      'delivery_type': deliveryType.name,
      'delivery_address': deliveryAddress,
      'total_amount': totalAmount,
      'payment_intent_id': paymentIntentId,
    })
    .select()
    .single();
    
  return Order.fromJson(response);
}

Future<List<Order>> getUserOrders() async {
  final response = await _supabase
    .from('orders')
    .select('*, hikes(*)')
    .eq('user_id', _supabase.auth.currentUser!.id)
    .order('created_at', ascending: false);
    
  return response.map((json) => Order.fromJson(json)).toList();
}

Future<Order> updateOrderStatus(int orderId, OrderStatus status) async {
  final response = await _supabase
    .from('orders')
    .update({'status': status.name})
    .eq('id', orderId)
    .select()
    .single();
    
  return Order.fromJson(response);
}
```

**Validation Criteria**:
- [ ] Methods integrate with existing BackendApiService
- [ ] Error handling matches existing patterns
- [ ] Type safety maintained
- [ ] Integration tests pass

---

### Task 1.10: Payment Flow Integration
**Status**: [ ] **Files**: Multiple UI and service files

**Validation Criteria**:
- [ ] Complete payment flow works end-to-end
- [ ] Error scenarios handled gracefully
- [ ] Success/failure states clear to user
- [ ] Integration test covers full flow

---

### Task 1.11: Routing Integration
**Status**: [ ] **Files**: `lib/config/routing/routes.dart`

**Implementation**: Add checkout routes
```dart
// ADD TO routes.dart:
class AppRoutes {
  // ... existing routes ...
  static const checkout = '/checkout';
  static const paymentSuccess = '/payment-success';
  static const paymentFailure = '/payment-failure';
}

// ADD TO router configuration:
GoRoute(
  path: AppRoutes.checkout,
  name: 'checkout',
  builder: (context, state) {
    final hike = state.extra as Hike;
    return CheckoutPage(hike: hike);
  },
),
GoRoute(
  path: AppRoutes.paymentSuccess,
  name: 'payment-success',
  builder: (context, state) {
    final orderId = state.pathParameters['orderId']!;
    return PaymentSuccessPage(orderId: int.parse(orderId));
  },
),
```

**Validation Criteria**:
- [ ] Routes added to router configuration
- [ ] Navigation works from hike details
- [ ] Deep linking works correctly
- [ ] Route guards implemented if needed

---

### Task 1.12: Phase 1 Testing & Validation
**Status**: [ ] **Files**: `test/integration/payment_flow_test.dart`

**Testing Requirements**:
- [ ] Unit tests for all new services (≥90% coverage)
- [ ] Widget tests for all new UI components
- [ ] Integration test for complete payment flow
- [ ] Mock Stripe service for testing
- [ ] Database integration tests

**Performance Requirements**:
- [ ] Checkout page loads in <2 seconds
- [ ] Payment processing completes in <5 seconds
- [ ] UI remains responsive during payment

**Validation Criteria**:
- [ ] All tests pass
- [ ] flutter analyze shows no issues
- [ ] Performance benchmarks met
- [ ] User acceptance testing completed

---

## 🚀 PHASE 2: TASTING-SET-MANAGEMENT
**Status**: ⏳ Pending | **Geschätzte Zeit**: 1.5 Wochen

### Task 2.1: Tasting Set Models
**Status**: [ ] **Files**: `lib/domain/models/tasting_set.dart`

**Implementation**:
```dart
@freezed
class TastingSet with _$TastingSet {
  const factory TastingSet({
    required int id,
    required int hikeId,
    required String name,
    required String description,
    required List<WhiskySample> samples,
    required double price,
    required String imageUrl,
    @Default(false) bool isIncluded,
    @Default(true) bool isAvailable,
    DateTime? availableFrom,
    DateTime? availableUntil,
  }) = _TastingSet;
  
  factory TastingSet.fromJson(Map<String, dynamic> json) => _$TastingSetFromJson(json);
}

@freezed
class WhiskySample with _$WhiskySample {
  const factory WhiskySample({
    required int id,
    required String name,
    required String distillery,
    required int age,
    required String region,
    required String tastingNotes,
    required String imageUrl,
    required double abv, // Alcohol by volume
    String? category, // Single Malt, Blend, etc.
    @Default(5.0) double sampleSizeMl,
  }) = _WhiskySample;
  
  factory WhiskySample.fromJson(Map<String, dynamic> json) => _$WhiskySampleFromJson(json);
}
```

**Validation Criteria**:
- [ ] Models follow Freezed best practices
- [ ] JSON serialization works correctly
- [ ] All required fields present
- [ ] Generated files created successfully
- [ ] Model tests pass

---

### Task 2.2: Tasting Set Database Schema
**Status**: [ ] **Files**: `terraform-supabase/sql/06_tasting_sets_tables.sql`

**Implementation**:
```sql
-- Tasting Sets table
CREATE TABLE IF NOT EXISTS public.tasting_sets (
    id SERIAL PRIMARY KEY,
    hike_id INTEGER REFERENCES public.hikes(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    image_url TEXT,
    is_included BOOLEAN DEFAULT FALSE,
    is_available BOOLEAN DEFAULT TRUE,
    available_from TIMESTAMP WITH TIME ZONE,
    available_until TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Whisky Samples table
CREATE TABLE IF NOT EXISTS public.whisky_samples (
    id SERIAL PRIMARY KEY,
    tasting_set_id INTEGER REFERENCES public.tasting_sets(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    distillery TEXT NOT NULL,
    age INTEGER,
    region TEXT,
    tasting_notes TEXT,
    image_url TEXT,
    abv DECIMAL(4,2),
    category TEXT,
    sample_size_ml DECIMAL(5,2) DEFAULT 5.0,
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Order Tasting Sets junction table
CREATE TABLE IF NOT EXISTS public.order_tasting_sets (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES public.orders(id) ON DELETE CASCADE,
    tasting_set_id INTEGER REFERENCES public.tasting_sets(id) ON DELETE CASCADE,
    quantity INTEGER DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_tasting_sets_hike_id ON public.tasting_sets(hike_id);
CREATE INDEX IF NOT EXISTS idx_whisky_samples_tasting_set_id ON public.whisky_samples(tasting_set_id);
CREATE INDEX IF NOT EXISTS idx_whisky_samples_order ON public.whisky_samples(tasting_set_id, order_index);

-- RLS Policies
ALTER TABLE public.tasting_sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.whisky_samples ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_tasting_sets ENABLE ROW LEVEL SECURITY;

-- Public read access for tasting sets and samples
CREATE POLICY "Anyone can view tasting sets" ON public.tasting_sets FOR SELECT USING (true);
CREATE POLICY "Anyone can view whisky samples" ON public.whisky_samples FOR SELECT USING (true);

-- Users can only manage their own order tasting sets
CREATE POLICY "Users can manage their order tasting sets" ON public.order_tasting_sets
    USING (
        EXISTS (
            SELECT 1 FROM public.orders 
            WHERE id = order_tasting_sets.order_id AND user_id = auth.uid()
        )
    );
```

**Validation Criteria**:
- [ ] Tables created without errors
- [ ] Foreign key constraints work
- [ ] Indexes improve performance
- [ ] RLS policies secure access
- [ ] Sample data can be inserted

---

### Task 2.3: Tasting Set Repository
**Status**: [ ] **Files**: `lib/data/repositories/tasting_set_repository.dart`

**Validation Criteria**:
- [ ] Repository follows existing patterns
- [ ] CRUD operations implemented
- [ ] Error handling consistent
- [ ] Caching strategy implemented
- [ ] Unit tests cover all methods

---

### Task 2.4: Tasting Set Selection UI
**Status**: [ ] **Files**: `lib/UI/tasting_sets/tasting_set_selection_page.dart`

**Validation Criteria**:
- [ ] UI allows selection of multiple sets
- [ ] Price calculations update correctly
- [ ] Images load efficiently
- [ ] Responsive design implemented
- [ ] Widget tests pass

---

### Task 2.5: Whisky Sample Detail View
**Status**: [ ] **Files**: `lib/UI/tasting_sets/whisky_sample_detail_page.dart`

**Validation Criteria**:
- [ ] Detailed sample information displayed
- [ ] Tasting notes formatted properly
- [ ] Images optimized and cached
- [ ] Navigation works correctly
- [ ] Accessibility features implemented

---

### Task 2.6: Integration with Checkout
**Status**: [ ] **Files**: Multiple checkout-related files

**Validation Criteria**:
- [ ] Tasting sets appear in checkout flow
- [ ] Price calculations include sets
- [ ] Order creation handles tasting sets
- [ ] Integration tests updated

---

### Task 2.7: Backend API Extensions
**Status**: [ ] **Files**: `lib/data/services/database/backend_api.dart`

**Validation Criteria**:
- [ ] API methods for tasting sets implemented
- [ ] Relationship queries optimized
- [ ] Error handling consistent
- [ ] Performance acceptable

---

### Task 2.8: Phase 2 Testing & Validation
**Status**: [ ] **Files**: `test/integration/tasting_sets_test.dart`

**Validation Criteria**:
- [ ] All tasting set functionality tested
- [ ] Performance requirements met
- [ ] UI/UX validated
- [ ] Database queries optimized

---

## 🚀 PHASE 3: BESTELLSTATUS-TRACKING
**Status**: ⏳ Pending | **Geschätzte Zeit**: 1 Woche

[Similar detailed breakdown continues for all remaining phases...]

---

# 🎯 OVERALL VALIDATION CHECKLIST

## Pre-Implementation Requirements
- [ ] Current codebase analysis completed
- [ ] All dependencies compatibility verified
- [ ] Database backup created
- [ ] Development environment prepared

## Code Quality Standards
- [ ] All new code follows existing patterns
- [ ] flutter analyze shows 0 issues
- [ ] Test coverage ≥90% for new features
- [ ] Performance benchmarks met
- [ ] Accessibility guidelines followed

## Documentation Requirements
- [ ] CLAUDE.md updated with new dependencies
- [ ] README.md updated if needed
- [ ] API documentation created
- [ ] Deployment notes updated

## Final Integration Testing
- [ ] End-to-end user flows tested
- [ ] Cross-platform compatibility verified
- [ ] Performance under load tested
- [ ] Security vulnerabilities checked

---

**Nächster Schritt**: Prompte mit "Nächster Schritt" um mit Task 1.1 zu beginnen.

**Für Claude Code**: Jeder Task hat klare Validierungskriterien. Führe jeden Task vollständig aus und validiere vor dem nächsten Schritt.

**Nächster Schritt nach Completion**: Implementierung der Web-App für Unternehmen (siehe `WEBAPP_IMPLEMENTATION_PLAN.md`)
