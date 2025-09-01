import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'dart:developer' as dev;

import '../../../domain/models/hike.dart';
import '../../../domain/models/profile.dart';
import '../../../domain/models/waypoint.dart';
import '../../../domain/models/basic_order.dart';
import '../../../domain/models/enhanced_order.dart';
import '../../../domain/models/delivery_address.dart';
import '../../../domain/models/tasting_set.dart';
import '../shipping/shipping_calculation_service.dart';

class BackendApiService {
  final SupabaseClient client;
  late final ShippingCalculationService _shippingService;
  
  // Constructor für Dependency Injection in Tests
  BackendApiService({SupabaseClient? client}) 
      : client = client ?? Supabase.instance.client {
    _shippingService = ShippingCalculationService(this);
  }

  // Getter für ShippingCalculationService
  String get supabaseUrl => client.supabaseUrl;
  String get supabaseAnonKey => client.supabaseKey;

  // get User Profile by id
  Future<Profile> getUserProfileById(String id) async {
    final response = await client.from('profiles').select().eq('id', id);
    if ((response as List<dynamic>).isEmpty) {
      // Profil nicht gefunden - erstelle ein leeres Profil für die UI
      dev.log('Profil nicht gefunden für Benutzer-ID: $id. Erstelle leeres Profil.');
      return Profile(id: id);
    }
    
    // Konvertiere die Antwort in ein Profil-Objekt
    final Map<String, dynamic> profileData = response.first;
    
    // Erstelle ein neues Profil mit den Daten aus der Datenbank
    return Profile.fromJson(profileData);
  }
  
  // get a list of hikes from the 'hikes' table
  Future<List<Hike>> fetchHikes() async {
    final response = await client.from('hikes').select();
    final List<dynamic> hikeData = response as List<dynamic>;

    return hikeData.map((element) => Hike.fromJson(element as Map<String, dynamic>)).toList();
  }

  // get a list of hikes purchased by a user
  Future<List<Hike>> fetchUserHikes(String userId) async {
    try {
      // Verwende die korrekte Tabelle 'purchased_hikes'
      final response = await client
          .from('purchased_hikes')
          .select('hike_id')
          .eq('user_id', userId);
      
      final List<dynamic> userHikeData = response as List<dynamic>;
      if (userHikeData.isEmpty) {
        return [];
      }

      // Extrahiere die Hike-IDs und behandle mögliche Typprobleme
      final List<int> hikeIds = [];
      for (final element in userHikeData) {
        if (element['hike_id'] != null) {
          // Konvertiere zu int, unabhängig davon, ob es als String oder int gespeichert ist
          hikeIds.add(int.parse(element['hike_id'].toString()));
        }
      }
      
      if (hikeIds.isEmpty) {
        return [];
      }

      // Holen Sie sich die vollständigen Hike-Objekte für die IDs
      List<Hike> userHikes = [];
      for (final hikeId in hikeIds) {
        try {
          final hikeResponse = await client
              .from('hikes')
              .select()
              .eq('id', hikeId);
          
          final List<dynamic> hikeDataList = hikeResponse as List<dynamic>;
          if (hikeDataList.isNotEmpty) {
            final hikeData = hikeDataList.first as Map<String, dynamic>;
            userHikes.add(Hike.fromJson(hikeData));
          }
        } catch (e) {
          // logging: 'Fehler beim Laden der Hike mit ID $hikeId: $e');
          // Fahre mit der nächsten Hike fort
          continue;
        }
      }
      
      return userHikes;
    } catch (e) {
      // logging: 'Fehler beim Laden der Benutzer-Hikes: $e');
      return [];
    }
  }

  // Section for Hike Images
  // Table Structure: hike_images
  // id: int
  // hike_id: int
  // image_url: text
  // created_at: timestamp


  // get images for a hike by hike.id
  Future<List<String>> getHikeImages(int hikeId) async {
    final response = await client.from('hike_images').select().eq('hike_id', hikeId);
    final List<dynamic> hikeImageData = response as List<dynamic>;

    return hikeImageData.map((element) => element['image_url'] as String).toList();
  }

  // upload images for a hike with hike id and image urls
  Future<void> uploadHikeImages(int hikeId, List<String> imageUrls) async {
    final List<Map<String, dynamic>> imageRecords = imageUrls.map((imageUrl) => {
      'hike_id': hikeId,
      'image_url': imageUrl,
    }).toList();

    await client.from('hike_images').upsert(imageRecords);
  }

  // update user profile
  Future<void> updateUserProfile(Profile profile) async {
    // Konvertiere das Profil in JSON und entferne Felder, die in der Datenbank nicht existieren
    final Map<String, dynamic> profileJson = profile.toJson();
    profileJson.remove('email'); // Email-Feld entfernen, da es in der auth.users Tabelle gespeichert wird
    profileJson.remove('imageUrl'); // imageUrl-Feld entfernen, da es in der Datenbank nicht existiert
    
    // Stelle sicher, dass die ID gesetzt ist
    if (profileJson['id'] == null || profileJson['id'].isEmpty) {
      final String? userId = client.auth.currentUser?.id;
      if (userId != null) {
        profileJson['id'] = userId;
      } else {
        throw Exception('Benutzer-ID konnte nicht ermittelt werden');
      }
    }
    
    // Verwende update statt upsert, um die RLS-Policy zu respektieren
    final String userId = profileJson['id'];
    await client.from('profiles')
        .update(profileJson)
        .eq('id', userId);
  }

  // Methode zum Hochladen eines Profilbilds
  Future<String> uploadProfileImage(String userId, Uint8List fileBytes, String fileExt) async {
    final String path = '$userId/profile.$fileExt';
    
    dev.log("Beginne Upload nach $path mit ${fileBytes.length} Bytes");
    
    try {
      // Prüfen, ob der Bucket existiert, bevor wir hochladen
      try {
        final List<Bucket> buckets = await client.storage.listBuckets();
        final bool bucketExists = buckets.any((bucket) => bucket.name == 'avatars');
        if (!bucketExists) {
          dev.log("Der Bucket 'avatars' existiert nicht!");
          throw Exception("Der Storage-Bucket 'avatars' existiert nicht. Bitte erstellen Sie ihn in Supabase.");
        }
        dev.log("Bucket 'avatars' gefunden, fahre mit Upload fort");
      } catch (bucketError) {
        dev.log("Fehler beim Prüfen der Buckets: $bucketError", error: bucketError);
        // Wir versuchen trotzdem hochzuladen, falls es nur ein Berechtigungsproblem war
      }
      
      // Bild in den Storage hochladen
      await client.storage.from('avatars').uploadBinary(
        path,
        fileBytes,
        fileOptions: FileOptions(
          cacheControl: '3600',
          upsert: true,
        ),
      );
      
      dev.log("Upload erfolgreich abgeschlossen");
      
      // Öffentliche URL des Bildes zurückgeben
      final String imageUrl = client.storage.from('avatars').getPublicUrl(path);
      dev.log("Generierte öffentliche URL: $imageUrl");
      return imageUrl;
    } catch (e) {
      dev.log("Fehler beim Hochladen des Profilbilds: $e", error: e);
      
      // Detaillierte Fehleranalyse
      if (e.toString().contains('permission denied')) {
        throw Exception("Keine Berechtigung zum Hochladen in den 'avatars' Bucket. Bitte überprüfen Sie die Supabase-Berechtigungen.");
      } else if (e.toString().contains('network')) {
        throw Exception("Netzwerkfehler beim Hochladen. Bitte überprüfen Sie Ihre Internetverbindung.");
      } else if (e.toString().contains('PlatformException')) {
        throw Exception("Plattformspezifischer Fehler: $e. Dies kann im Simulator auftreten.");
      }
      
      rethrow;
    }
  }

  // Methode zum Abrufen der Profilbild-URL
  Future<String?> getProfileImageUrl(String userId) async {
    try {
      dev.log("🔍 Suche Profilbild für User: $userId");
      
      // Suche nach Dateien im Benutzer-spezifischen Ordner
      final List<FileObject> files = await client.storage.from('avatars')
          .list(path: userId);
      
      dev.log("📁 Gefundene Dateien in $userId/: ${files.length}");
      
      if (files.isNotEmpty) {
        for (var file in files) {
          dev.log("📄 Datei: ${file.name}, Größe: ${file.metadata?['size']}, Typ: ${file.metadata?['mimetype']}");
        }
      }
      
      // Filtere die Dateien nach "profile.*" Dateien
      final List<FileObject> userFiles = files.where(
        (file) => file.name.startsWith('profile.')
      ).toList();
      
      if (userFiles.isNotEmpty) {
        final String filePath = '$userId/${userFiles.first.name}';
        final String publicUrl = client.storage.from('avatars').getPublicUrl(filePath);
        
        dev.log("✅ Profilbild-URL gefunden: $publicUrl");
        return publicUrl;
      } else {
        dev.log("❌ Kein Profilbild für User $userId gefunden");
        return null;
      }
    } catch (e) {
      dev.log("💥 Fehler beim Abrufen des Profilbilds für $userId: $e", error: e);
      
      // Spezifische Fehlerbehandlung
      if (e.toString().contains('permission')) {
        dev.log("🔐 Storage Permission Problem");
      } else if (e.toString().contains('network')) {
        dev.log("🌐 Network Problem beim Storage-Zugriff");
      }
      
      return null;
    }
  }

  // get waypoints for a hike by hike.id from the 'hikes_waypoints' table
  Future<List<Map<String, dynamic>>> _getWaypointDataForHike(int hikeId) async {
    try {
      final response = await client
          .from('hikes_waypoints')
          .select('waypoint_id, order_index')
          .eq('hike_id', hikeId)
          .order('order_index', ascending: true);
      
      return List<Map<String, dynamic>>.from(response as List<dynamic>);
    } catch (e) {
      dev.log('Fehler beim Abrufen der Wegpunkt-Daten: $e', error: e);
      throw Exception('Fehler beim Abrufen der Wegpunkt-Daten für Wanderung $hikeId: $e');
    }
  }

  // get waypoints for for a hike by hike.id from the waypoints table
  Future<List<Waypoint>> getWaypointsForHike(int hikeId) async {
    try {
      // Zuerst die Wegpunkt-Daten mit order_index für die Wanderung abrufen
      final List<Map<String, dynamic>> waypointDataList = await _getWaypointDataForHike(hikeId);
      
      if (waypointDataList.isEmpty) {
        return [];
      }
      
      // Map für orderIndex pro waypoint_id erstellen
      final Map<int, int> waypointOrderMap = {};
      final List<int> waypointIds = [];
      
      for (var data in waypointDataList) {
        final waypointId = int.parse(data['waypoint_id'].toString());
        final orderIndex = int.parse(data['order_index'].toString());
        waypointIds.add(waypointId);
        waypointOrderMap[waypointId] = orderIndex;
      }
      
      // Dann die Wegpunkte für diese IDs abrufen
      final response = await client
          .from('waypoints')
          .select()
          .inFilter('id', waypointIds);
      
      final List<dynamic> waypointData = response as List<dynamic>;
      
      List<Waypoint> waypoints = waypointData.map((element) {
        // Sicherstellen, dass alle erforderlichen Felder vorhanden und vom richtigen Typ sind
        Map<String, dynamic> safeElement = Map<String, dynamic>.from(element);
        
        // Überprüfen und konvertieren der numerischen Werte
        if (safeElement['latitude'] == null) safeElement['latitude'] = 0.0;
        if (safeElement['longitude'] == null) safeElement['longitude'] = 0.0;
        
        // Sicherstellen, dass die Werte den richtigen Typ haben
        safeElement['latitude'] = double.parse(safeElement['latitude'].toString());
        safeElement['longitude'] = double.parse(safeElement['longitude'].toString());
        
        // Füge hikeId und orderIndex hinzu
        safeElement['hikeId'] = hikeId;
        final waypointId = int.parse(safeElement['id'].toString());
        safeElement['orderIndex'] = waypointOrderMap[waypointId] ?? 0;
        
        return Waypoint.fromJson(safeElement);
      }).toList();
      
      // Sortierung nach orderIndex (zusätzliche Sicherheit)
      waypoints.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      
      return waypoints;
    } catch (e) {
      dev.log('Fehler beim Abrufen der Wegpunkte: $e', error: e);
      throw Exception('Fehler beim Abrufen der Wegpunkte für Wanderung $hikeId: $e');
    }
  }

  // Methode zum Hinzufügen eines neuen Wegpunkts
  Future<void> addWaypoint(Waypoint waypoint, int hikeId, {int? orderIndex}) async {
    try {
      // Zuerst den Wegpunkt in die 'waypoints' Tabelle einfügen
      final waypointResponse = await client.from('waypoints').insert({
        'name': waypoint.name,
        'description': waypoint.description,
        'latitude': waypoint.latitude,
        'longitude': waypoint.longitude,
      }).select('id').single();
      
      // Die ID des neu erstellten Wegpunkts abrufen
      final int newWaypointId = waypointResponse['id'];
      
      // Wenn kein orderIndex angegeben, den nächsten verfügbaren verwenden
      int finalOrderIndex = orderIndex ?? waypoint.orderIndex;
      if (finalOrderIndex == 0) {
        // Bestimme den höchsten order_index für diese Wanderung + 1
        final maxOrderResponse = await client
            .from('hikes_waypoints')
            .select('order_index')
            .eq('hike_id', hikeId)
            .order('order_index', ascending: false)
            .limit(1);
        
        if (maxOrderResponse.isNotEmpty) {
          final maxOrder = int.parse(maxOrderResponse.first['order_index'].toString());
          finalOrderIndex = maxOrder + 1;
        } else {
          finalOrderIndex = 1;
        }
      }
      
      // Verknüpfung zwischen Wanderung und Wegpunkt in der 'hikes_waypoints' Tabelle erstellen
      await client.from('hikes_waypoints').insert({
        'hike_id': hikeId,
        'waypoint_id': newWaypointId,
        'order_index': finalOrderIndex,
      });
      
    } catch (e) {
      dev.log('Fehler beim Hinzufügen des Wegpunkts: $e', error: e);
      throw Exception('Fehler beim Hinzufügen des Wegpunkts: $e');
    }
  }
  
  // Methode zum Aktualisieren eines bestehenden Wegpunkts
  Future<void> updateWaypoint(Waypoint waypoint) async {
    try {
      await client.from('waypoints').update({
        'name': waypoint.name,
        'description': waypoint.description,
        'latitude': waypoint.latitude,
        'longitude': waypoint.longitude,
      }).eq('id', waypoint.id);
      
    } catch (e) {
      dev.log('Fehler beim Aktualisieren des Wegpunkts: $e', error: e);
      throw Exception('Fehler beim Aktualisieren des Wegpunkts: $e');
    }
  }
  
  // Methode zum Löschen eines Wegpunkts
  Future<void> deleteWaypoint(int waypointId, int hikeId) async {
    try {
      // Zuerst die Verknüpfung in der 'hikes_waypoints' Tabelle löschen
      await client.from('hikes_waypoints')
          .delete()
          .eq('waypoint_id', waypointId)
          .eq('hike_id', hikeId);
      
      // Dann den Wegpunkt selbst aus der 'waypoints' Tabelle löschen
      await client.from('waypoints')
          .delete()
          .eq('id', waypointId);
      
    } catch (e) {
      dev.log('Fehler beim Löschen des Wegpunkts: $e', error: e);
      throw Exception('Fehler beim Löschen des Wegpunkts: $e');
    }
  }
  
  // Methode zum Aktualisieren der Wegpunkt-Reihenfolge
  Future<void> updateWaypointOrder(int hikeId, int waypointId, int newOrderIndex) async {
    try {
      await client
          .from('hikes_waypoints')
          .update({'order_index': newOrderIndex})
          .eq('hike_id', hikeId)
          .eq('waypoint_id', waypointId);
    } catch (e) {
      dev.log('Fehler beim Aktualisieren der Wegpunkt-Reihenfolge: $e', error: e);
      throw Exception('Fehler beim Aktualisieren der Wegpunkt-Reihenfolge: $e');
    }
  }

  // ======================================
  // PAYMENT EXTENSION METHODS
  // ======================================

  /// Fetch all orders for a specific user
  Future<List<BasicOrder>> fetchUserOrders(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    try {
      dev.log('🔍 Fetching orders for user: $userId');

      final response = await client
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final List<dynamic> orderData = response as List<dynamic>;

      List<BasicOrder> orders = orderData
          .map<BasicOrder>((json) => BasicOrder.fromJson(json as Map<String, dynamic>))
          .toList();

      dev.log('✅ Found ${orders.length} orders for user $userId');
      return orders;

    } catch (e) {
      dev.log('❌ Error fetching user orders: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to fetch user orders: $e');
    }
  }

  /// Fetch a specific order by ID
  Future<BasicOrder> fetchOrderById(int orderId) async {
    if (orderId <= 0) {
      throw ArgumentError('Order ID must be greater than 0');
    }

    try {
      dev.log('🔍 Fetching order by ID: $orderId');

      final response = await client
          .from('orders')
          .select()
          .eq('id', orderId)
          .single();

      dev.log('✅ Order $orderId fetched successfully');
      return BasicOrder.fromJson(response);

    } catch (e) {
      dev.log('❌ Error fetching order $orderId: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to fetch order: $e');
    }
  }

  /// Check if a user has purchased a specific hike
  Future<bool> hasUserPurchasedHike(String userId, int hikeId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    if (hikeId <= 0) {
      throw ArgumentError('Hike ID must be greater than 0');
    }

    try {
      dev.log('🔍 Checking if user $userId purchased hike $hikeId');

      final response = await client
          .from('purchased_hikes')
          .select('id')
          .eq('user_id', userId)
          .eq('hike_id', hikeId);

      final List<dynamic> purchaseData = response as List<dynamic>;
      final bool hasPurchased = purchaseData.isNotEmpty;

      dev.log('✅ User $userId has${hasPurchased ? '' : ' not'} purchased hike $hikeId');
      return hasPurchased;

    } catch (e) {
      dev.log('❌ Error checking hike purchase: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to check hike purchase: $e');
    }
  }

  /// Record a successful hike purchase
  Future<void> recordHikePurchase(String userId, int hikeId, int orderId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    if (hikeId <= 0) {
      throw ArgumentError('Hike ID must be greater than 0');
    }
    if (orderId <= 0) {
      throw ArgumentError('Order ID must be greater than 0');
    }

    try {
      dev.log('💰 Recording hike purchase: user=$userId, hike=$hikeId, order=$orderId');

      final purchaseData = {
        'user_id': userId,
        'hike_id': hikeId,
        'order_id': orderId,
        'purchased_at': DateTime.now().toIso8601String(),
      };

      await client.from('purchased_hikes').insert(purchaseData);

      dev.log('✅ Hike purchase recorded successfully');

    } catch (e) {
      dev.log('❌ Error recording hike purchase: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to record hike purchase: $e');
    }
  }

  /// Fetch order with payment details
  Future<BasicOrder> fetchOrderWithPaymentDetails(int orderId) async {
    if (orderId <= 0) {
      throw ArgumentError('Order ID must be greater than 0');
    }

    try {
      dev.log('🔍 Fetching order $orderId with payment details');

      final response = await client
          .from('orders')
          .select()
          .eq('id', orderId)
          .single();

      dev.log('✅ Order $orderId with payment details fetched');
      return BasicOrder.fromJson(response);

    } catch (e) {
      dev.log('❌ Error fetching order with payment details: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to fetch order with payment details: $e');
    }
  }

  /// Update order status after payment processing
  Future<BasicOrder> updateOrderAfterPayment({
    required int orderId,
    required OrderStatus status,
    required String paymentIntentId,
  }) async {
    if (orderId <= 0) {
      throw ArgumentError('Order ID must be greater than 0');
    }
    if (paymentIntentId.isEmpty) {
      throw ArgumentError('Payment Intent ID cannot be empty');
    }

    try {
      dev.log('💳 Updating order $orderId after payment: status=${status.name}');

      final updateData = {
        'status': status.name,
        'payment_intent_id': paymentIntentId,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await client
          .from('orders')
          .update(updateData)
          .eq('id', orderId)
          .select()
          .single();

      dev.log('✅ Order $orderId updated after payment');
      return BasicOrder.fromJson(response);

    } catch (e) {
      dev.log('❌ Error updating order after payment: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to update order after payment: $e');
    }
  }

  /// Get payment history for a user using JOIN query
  Future<List<Map<String, dynamic>>> getUserPaymentHistory(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    try {
      dev.log('💳 Fetching payment history for user: $userId');

      final response = await client
          .from('payments')
          .select('*, orders!inner(user_id)')
          .eq('orders.user_id', userId)
          .order('created_at', ascending: false);

      final List<dynamic> paymentData = response as List<dynamic>;
      final List<Map<String, dynamic>> payments = paymentData
          .map<Map<String, dynamic>>((json) => Map<String, dynamic>.from(json))
          .toList();

      dev.log('✅ Found ${payments.length} payment records for user $userId');
      return payments;

    } catch (e) {
      dev.log('❌ Error fetching payment history: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to fetch payment history: $e');
    }
  }

  // ======================================
  // TASTING SET EXTENSION METHODS
  // ======================================

  /// Get the tasting set for a specific hike (1:1 relationship)
  Future<TastingSet?> getTastingSetForHike(int hikeId) async {
    if (hikeId <= 0) {
      throw ArgumentError('Hike ID must be greater than 0');
    }

    try {
      dev.log('🔍 Fetching tasting set for hike: $hikeId');

      final response = await client
          .from('tasting_sets')
          .select('*, whisky_samples(*)')
          .eq('hike_id', hikeId)
          .maybeSingle();

      if (response == null) {
        dev.log('❌ No tasting set found for hike $hikeId');
        return null;
      }

      dev.log('✅ Tasting set found for hike $hikeId');
      return TastingSet.fromJson(response);

    } catch (e) {
      dev.log('❌ Error fetching tasting set for hike $hikeId: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to fetch tasting set for hike: $e');
    }
  }

  /// Get a specific tasting set by ID
  Future<TastingSet?> getTastingSetById(int tastingSetId) async {
    if (tastingSetId <= 0) {
      throw ArgumentError('Tasting set ID must be greater than 0');
    }

    try {
      dev.log('🔍 Fetching tasting set by ID: $tastingSetId');

      final response = await client
          .from('tasting_sets')
          .select('*, whisky_samples(*)')
          .eq('id', tastingSetId)
          .maybeSingle();

      if (response == null) {
        dev.log('❌ No tasting set found with ID $tastingSetId');
        return null;
      }

      dev.log('✅ Tasting set $tastingSetId fetched successfully');
      return TastingSet.fromJson(response);

    } catch (e) {
      dev.log('❌ Error fetching tasting set $tastingSetId: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to fetch tasting set: $e');
    }
  }

  /// Get all tasting sets (admin/company management)
  Future<List<TastingSet>> getAllTastingSets() async {
    try {
      dev.log('🔍 Fetching all tasting sets');

      final response = await client
          .from('tasting_sets')
          .select('*, whisky_samples(*)')
          .order('created_at', ascending: false);

      final List<dynamic> tastingSetData = response as List<dynamic>;
      final List<TastingSet> tastingSets = tastingSetData
          .map<TastingSet>((json) => TastingSet.fromJson(json as Map<String, dynamic>))
          .toList();

      dev.log('✅ Found ${tastingSets.length} tasting sets');
      return tastingSets;

    } catch (e) {
      dev.log('❌ Error fetching all tasting sets: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to fetch tasting sets: $e');
    }
  }

  /// Get whisky samples for a specific tasting set
  Future<List<WhiskySample>> getWhiskySamplesForTastingSet(int tastingSetId) async {
    if (tastingSetId <= 0) {
      throw ArgumentError('Tasting set ID must be greater than 0');
    }

    try {
      dev.log('🔍 Fetching whisky samples for tasting set: $tastingSetId');

      final response = await client
          .from('whisky_samples')
          .select()
          .eq('tasting_set_id', tastingSetId)
          .order('order_index', ascending: true);

      final List<dynamic> sampleData = response as List<dynamic>;
      final List<WhiskySample> samples = sampleData
          .map<WhiskySample>((json) => WhiskySample.fromJson(json as Map<String, dynamic>))
          .toList();

      dev.log('✅ Found ${samples.length} whisky samples for tasting set $tastingSetId');
      return samples;

    } catch (e) {
      dev.log('❌ Error fetching whisky samples: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to fetch whisky samples: $e');
    }
  }

  /// Search tasting sets by name or description
  Future<List<TastingSet>> searchTastingSets(String query) async {
    if (query.trim().isEmpty) {
      return getAllTastingSets();
    }

    try {
      dev.log('🔍 Searching tasting sets with query: $query');

      final response = await client
          .from('tasting_sets')
          .select('*, whisky_samples(*)')
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false);

      final List<dynamic> tastingSetData = response as List<dynamic>;
      final List<TastingSet> tastingSets = tastingSetData
          .map<TastingSet>((json) => TastingSet.fromJson(json as Map<String, dynamic>))
          .toList();

      dev.log('✅ Found ${tastingSets.length} tasting sets matching "$query"');
      return tastingSets;

    } catch (e) {
      dev.log('❌ Error searching tasting sets: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to search tasting sets: $e');
    }
  }

  /// Get tasting sets by region
  Future<List<TastingSet>> getTastingSetsByRegion(String region) async {
    if (region.trim().isEmpty) {
      throw ArgumentError('Region cannot be empty');
    }

    try {
      dev.log('🔍 Fetching tasting sets by region: $region');

      final response = await client
          .from('tasting_sets')
          .select('*, whisky_samples!inner(*)')
          .eq('whisky_samples.region', region)
          .order('created_at', ascending: false);

      final List<dynamic> tastingSetData = response as List<dynamic>;
      final List<TastingSet> tastingSets = tastingSetData
          .map<TastingSet>((json) => TastingSet.fromJson(json as Map<String, dynamic>))
          .toList();

      dev.log('✅ Found ${tastingSets.length} tasting sets from region $region');
      return tastingSets;

    } catch (e) {
      dev.log('❌ Error fetching tasting sets by region: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to fetch tasting sets by region: $e');
    }
  }

  /// Get currently available tasting sets
  Future<List<TastingSet>> getCurrentlyAvailableTastingSets() async {
    try {
      dev.log('🔍 Fetching currently available tasting sets');

      final now = DateTime.now().toIso8601String();
      final response = await client
          .from('tasting_sets')
          .select('*, whisky_samples(*)')
          .eq('is_available', true)
          .or('available_from.is.null,available_from.lte.$now')
          .or('available_until.is.null,available_until.gte.$now')
          .order('created_at', ascending: false);

      final List<dynamic> tastingSetData = response as List<dynamic>;
      final List<TastingSet> tastingSets = tastingSetData
          .map<TastingSet>((json) => TastingSet.fromJson(json as Map<String, dynamic>))
          .toList();

      dev.log('✅ Found ${tastingSets.length} currently available tasting sets');
      return tastingSets;

    } catch (e) {
      dev.log('❌ Error fetching available tasting sets: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to fetch available tasting sets: $e');
    }
  }

  /// Update tasting set availability status
  Future<void> updateTastingSetAvailability(int tastingSetId, bool isAvailable) async {
    if (tastingSetId <= 0) {
      throw ArgumentError('Tasting set ID must be greater than 0');
    }

    try {
      dev.log('🔄 Updating tasting set $tastingSetId availability: $isAvailable');

      final updateData = {
        'is_available': isAvailable,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await client
          .from('tasting_sets')
          .update(updateData)
          .eq('id', tastingSetId);

      dev.log('✅ Tasting set $tastingSetId availability updated');

    } catch (e) {
      dev.log('❌ Error updating tasting set availability: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to update tasting set availability: $e');
    }
  }

  /// Get tasting sets with pagination
  Future<List<TastingSet>> getTastingSetsWithPagination({
    int limit = 10,
    int offset = 0,
    String? orderBy = 'created_at',
    bool ascending = false,
  }) async {
    if (limit <= 0) {
      throw ArgumentError('Limit must be greater than 0');
    }
    if (offset < 0) {
      throw ArgumentError('Offset must be non-negative');
    }

    try {
      dev.log('🔍 Fetching tasting sets with pagination: limit=$limit, offset=$offset');

      var query = client
          .from('tasting_sets')
          .select('*, whisky_samples(*)')
          .range(offset, offset + limit - 1);

      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      final response = await query;
      final List<dynamic> tastingSetData = response as List<dynamic>;
      final List<TastingSet> tastingSets = tastingSetData
          .map<TastingSet>((json) => TastingSet.fromJson(json as Map<String, dynamic>))
          .toList();

      dev.log('✅ Found ${tastingSets.length} tasting sets (page ${offset ~/ limit + 1})');
      return tastingSets;

    } catch (e) {
      dev.log('❌ Error fetching tasting sets with pagination: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to fetch tasting sets: $e');
    }
  }

  /// Create a new tasting set (company management)
  Future<TastingSet> createTastingSet({
    required int hikeId,
    required String name,
    required String description,
    String? imageUrl,
    bool isIncluded = true,
    bool isAvailable = true,
    DateTime? availableFrom,
    DateTime? availableUntil,
  }) async {
    if (hikeId <= 0) {
      throw ArgumentError('Hike ID must be greater than 0');
    }
    if (name.trim().isEmpty) {
      throw ArgumentError('Name cannot be empty');
    }
    if (description.trim().isEmpty) {
      throw ArgumentError('Description cannot be empty');
    }

    try {
      dev.log('🆕 Creating new tasting set for hike $hikeId: $name');

      final insertData = {
        'hike_id': hikeId,
        'name': name.trim(),
        'description': description.trim(),
        'price': 0.0, // Always 0 since included in hike price
        'image_url': imageUrl,
        'is_included': isIncluded,
        'is_available': isAvailable,
        'available_from': availableFrom?.toIso8601String(),
        'available_until': availableUntil?.toIso8601String(),
      };

      final response = await client
          .from('tasting_sets')
          .insert(insertData)
          .select('*, whisky_samples(*)')
          .single();

      dev.log('✅ Tasting set created successfully');
      return TastingSet.fromJson(response);

    } catch (e) {
      dev.log('❌ Error creating tasting set: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to create tasting set: $e');
    }
  }

  /// Update an existing tasting set (company management)
  Future<TastingSet> updateTastingSet({
    required int tastingSetId,
    String? name,
    String? description,
    String? imageUrl,
    bool? isIncluded,
    bool? isAvailable,
    DateTime? availableFrom,
    DateTime? availableUntil,
  }) async {
    if (tastingSetId <= 0) {
      throw ArgumentError('Tasting set ID must be greater than 0');
    }

    try {
      dev.log('🔄 Updating tasting set $tastingSetId');

      final Map<String, dynamic> updateData = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null && name.trim().isNotEmpty) updateData['name'] = name.trim();
      if (description != null && description.trim().isNotEmpty) updateData['description'] = description.trim();
      if (imageUrl != null) updateData['image_url'] = imageUrl;
      if (isIncluded != null) updateData['is_included'] = isIncluded;
      if (isAvailable != null) updateData['is_available'] = isAvailable;
      if (availableFrom != null) updateData['available_from'] = availableFrom.toIso8601String();
      if (availableUntil != null) updateData['available_until'] = availableUntil.toIso8601String();

      final response = await client
          .from('tasting_sets')
          .update(updateData)
          .eq('id', tastingSetId)
          .select('*, whisky_samples(*)')
          .single();

      dev.log('✅ Tasting set $tastingSetId updated successfully');
      return TastingSet.fromJson(response);

    } catch (e) {
      dev.log('❌ Error updating tasting set: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to update tasting set: $e');
    }
  }

  /// Delete a tasting set (company management)
  Future<void> deleteTastingSet(int tastingSetId) async {
    if (tastingSetId <= 0) {
      throw ArgumentError('Tasting set ID must be greater than 0');
    }

    try {
      dev.log('🗑️ Deleting tasting set $tastingSetId');

      // First delete associated whisky samples (cascade should handle this, but being explicit)
      await client
          .from('whisky_samples')
          .delete()
          .eq('tasting_set_id', tastingSetId);

      // Then delete the tasting set
      await client
          .from('tasting_sets')
          .delete()
          .eq('id', tastingSetId);

      dev.log('✅ Tasting set $tastingSetId deleted successfully');

    } catch (e) {
      dev.log('❌ Error deleting tasting set: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to delete tasting set: $e');
    }
  }

  // ================================
  // Enhanced Order Management
  // ================================

  /// Create enhanced order with automatic shipping calculation
  Future<EnhancedOrder> createEnhancedOrderWithShipping({
    required String orderNumber,
    required String companyId,
    required String customerId,
    int? hikeId,
    required double baseOrderValue,
    double taxAmount = 0.0,
    String currency = 'EUR',
    required DeliveryAddress deliveryAddress,
    DeliveryType deliveryType = DeliveryType.standardShipping,
    String? customerEmail,
    String? customerPhone,
    String? notes,
    Map<String, dynamic>? metadata,
    List<String>? tags,
  }) async {
    try {
      dev.log('🆕 Creating enhanced order with shipping calculation: $orderNumber');

      // Calculate shipping cost if not pickup
      ShippingCostResult? shippingResult;
      double shippingCost = 0.0;
      
      if (deliveryType != DeliveryType.pickup) {
        shippingResult = await _shippingService.calculateShippingCost(
          companyId: companyId,
          deliveryAddress: deliveryAddress,
          orderValue: baseOrderValue,
          hikeId: hikeId,
        );
        shippingCost = shippingResult.cost;
      }

      final subtotal = baseOrderValue;
      final totalAmount = subtotal + taxAmount + shippingCost;

      return await createEnhancedOrder(
        orderNumber: orderNumber,
        companyId: companyId,
        customerId: customerId,
        hikeId: hikeId,
        subtotal: subtotal,
        taxAmount: taxAmount,
        shippingCost: shippingCost,
        totalAmount: totalAmount,
        currency: currency,
        baseAmount: baseOrderValue,
        deliveryAddress: deliveryAddress,
        deliveryType: deliveryType,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        notes: notes,
        metadata: {
          if (shippingResult != null) 'shipping_calculation_result': {
            'cost': shippingResult.cost,
            'isFreeShipping': shippingResult.isFreeShipping,
            'serviceName': shippingResult.serviceName,
            'estimatedDaysMin': shippingResult.estimatedDaysMin,
            'estimatedDaysMax': shippingResult.estimatedDaysMax,
            'region': shippingResult.region,
            'description': shippingResult.description,
            'trackingAvailable': shippingResult.trackingAvailable,
            'signatureRequired': shippingResult.signatureRequired,
          },
          'auto_calculated_shipping': true,
          ...?metadata,
        },
        tags: tags,
      );

    } catch (e) {
      dev.log('❌ Error creating enhanced order with shipping: $e', error: e);
      throw Exception('Failed to create enhanced order with shipping: $e');
    }
  }

  /// Create a new enhanced order (internal method)
  Future<EnhancedOrder> createEnhancedOrder({
    required String orderNumber,
    required String companyId,
    required String customerId,
    int? hikeId,
    required double subtotal,
    double taxAmount = 0.0,
    double shippingCost = 0.0,
    required double totalAmount,
    String currency = 'EUR',
    double baseAmount = 0.0,
    required DeliveryAddress deliveryAddress,
    DeliveryType deliveryType = DeliveryType.standardShipping,
    String? customerEmail,
    String? customerPhone,
    String? notes,
    Map<String, dynamic>? metadata,
    List<String>? tags,
  }) async {
    if (orderNumber.trim().isEmpty) {
      throw ArgumentError('Order number cannot be empty');
    }
    if (companyId.trim().isEmpty) {
      throw ArgumentError('Company ID cannot be empty');
    }
    if (customerId.trim().isEmpty) {
      throw ArgumentError('Customer ID cannot be empty');
    }
    if (totalAmount <= 0) {
      throw ArgumentError('Total amount must be greater than 0');
    }

    try {
      dev.log('🆕 Creating enhanced order $orderNumber for customer $customerId');

      final insertData = {
        'order_number': orderNumber.trim(),
        'company_id': companyId,
        'customer_id': customerId,
        'hike_id': hikeId,
        'subtotal': subtotal,
        'tax_amount': taxAmount,
        'shipping_cost': shippingCost,
        'total_amount': totalAmount,
        'currency': currency,
        'base_amount': baseAmount > 0 ? baseAmount : subtotal,
        'delivery_type': deliveryType.name,
        'delivery_address': deliveryAddress.toJson(),
        'customer_email': customerEmail,
        'customer_phone': customerPhone,
        'notes': notes,
        'metadata': metadata,
        'tags': tags,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await client
          .from('enhanced_orders')
          .insert(insertData)
          .select('*, companies(*)')
          .single();

      dev.log('✅ Enhanced order $orderNumber created successfully');
      return EnhancedOrder.fromJson(response);

    } catch (e) {
      dev.log('❌ Error creating enhanced order: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to create enhanced order: $e');
    }
  }

  /// Get enhanced order by ID
  Future<EnhancedOrder?> getEnhancedOrderById(int orderId) async {
    if (orderId <= 0) {
      throw ArgumentError('Order ID must be greater than 0');
    }

    try {
      dev.log('🔍 Fetching enhanced order by ID: $orderId');

      final response = await client
          .from('enhanced_orders')
          .select('*, companies(*), order_status_history(*)')
          .eq('id', orderId)
          .maybeSingle();

      if (response == null) {
        dev.log('❌ No enhanced order found with ID $orderId');
        return null;
      }

      dev.log('✅ Enhanced order $orderId fetched successfully');
      return EnhancedOrder.fromJson(response);

    } catch (e) {
      dev.log('❌ Error fetching enhanced order $orderId: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to fetch enhanced order: $e');
    }
  }

  /// Get enhanced order by order number
  Future<EnhancedOrder?> getEnhancedOrderByNumber(String orderNumber) async {
    if (orderNumber.trim().isEmpty) {
      throw ArgumentError('Order number cannot be empty');
    }

    try {
      dev.log('🔍 Fetching enhanced order by number: $orderNumber');

      final response = await client
          .from('enhanced_orders')
          .select('*, companies(*), order_status_history(*)')
          .eq('order_number', orderNumber.trim())
          .maybeSingle();

      if (response == null) {
        dev.log('❌ No enhanced order found with number $orderNumber');
        return null;
      }

      dev.log('✅ Enhanced order $orderNumber fetched successfully');
      return EnhancedOrder.fromJson(response);

    } catch (e) {
      dev.log('❌ Error fetching enhanced order by number: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to fetch enhanced order: $e');
    }
  }

  /// Get all enhanced orders for a customer
  Future<List<EnhancedOrder>> getCustomerEnhancedOrders({
    required String customerId,
    int limit = 50,
    int offset = 0,
    List<String>? statuses,
  }) async {
    if (customerId.trim().isEmpty) {
      throw ArgumentError('Customer ID cannot be empty');
    }

    try {
      dev.log('🔍 Fetching enhanced orders for customer $customerId');

      var query = client
          .from('enhanced_orders')
          .select('*, companies(*)')
          .eq('customer_id', customerId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      if (statuses != null && statuses.isNotEmpty) {
        query = query.inFilter('status', statuses);
      }

      final response = await query;
      final List<dynamic> orderData = response as List<dynamic>;
      final List<EnhancedOrder> orders = orderData
          .map<EnhancedOrder>((json) => EnhancedOrder.fromJson(json as Map<String, dynamic>))
          .toList();

      dev.log('✅ Found ${orders.length} enhanced orders for customer $customerId');
      return orders;

    } catch (e) {
      dev.log('❌ Error fetching customer enhanced orders: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to fetch customer enhanced orders: $e');
    }
  }

  /// Get all enhanced orders for a company
  Future<List<EnhancedOrder>> getCompanyEnhancedOrders({
    required String companyId,
    int limit = 100,
    int offset = 0,
    List<String>? statuses,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    if (companyId.trim().isEmpty) {
      throw ArgumentError('Company ID cannot be empty');
    }

    try {
      dev.log('🔍 Fetching enhanced orders for company $companyId');

      var query = client
          .from('enhanced_orders')
          .select()
          .eq('company_id', companyId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      if (statuses != null && statuses.isNotEmpty) {
        query = query.inFilter('status', statuses);
      }

      if (dateFrom != null) {
        query = query.gte('created_at', dateFrom.toIso8601String());
      }

      if (dateTo != null) {
        query = query.lte('created_at', dateTo.toIso8601String());
      }

      final response = await query;
      final List<dynamic> orderData = response as List<dynamic>;
      final List<EnhancedOrder> orders = orderData
          .map<EnhancedOrder>((json) => EnhancedOrder.fromJson(json as Map<String, dynamic>))
          .toList();

      dev.log('✅ Found ${orders.length} enhanced orders for company $companyId');
      return orders;

    } catch (e) {
      dev.log('❌ Error fetching company enhanced orders: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to fetch company enhanced orders: $e');
    }
  }

  /// Update enhanced order status with automatic history tracking
  Future<EnhancedOrder> updateEnhancedOrderStatus({
    required int orderId,
    required String newStatus,
    String? reason,
    String? notes,
    String? trackingNumber,
    String? trackingUrl,
    String? shippingCarrier,
    DateTime? estimatedDelivery,
    Map<String, dynamic>? metadata,
  }) async {
    if (orderId <= 0) {
      throw ArgumentError('Order ID must be greater than 0');
    }
    if (newStatus.trim().isEmpty) {
      throw ArgumentError('Status cannot be empty');
    }

    try {
      dev.log('🔄 Updating enhanced order $orderId status to $newStatus');

      final updateData = <String, dynamic>{
        'status': newStatus.trim(),
        'updated_at': DateTime.now().toIso8601String(),
        if (trackingNumber != null) 'tracking_number': trackingNumber,
        if (trackingUrl != null) 'tracking_url': trackingUrl,
        if (shippingCarrier != null) 'shipping_carrier': shippingCarrier,
        if (estimatedDelivery != null) 'estimated_delivery': estimatedDelivery.toIso8601String(),
        if (metadata != null) 'metadata': metadata,
      };

      final response = await client
          .from('enhanced_orders')
          .update(updateData)
          .eq('id', orderId)
          .select('*, companies(*)')
          .single();

      dev.log('✅ Enhanced order $orderId status updated to $newStatus');
      return EnhancedOrder.fromJson(response);

    } catch (e) {
      dev.log('❌ Error updating enhanced order status: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to update enhanced order status: $e');
    }
  }

  /// Add tracking information to enhanced order
  Future<EnhancedOrder> addTrackingToEnhancedOrder({
    required int orderId,
    required String trackingNumber,
    String? shippingCarrier,
    String? shippingService,
    DateTime? estimatedDelivery,
    String? trackingUrl,
  }) async {
    if (orderId <= 0) {
      throw ArgumentError('Order ID must be greater than 0');
    }
    if (trackingNumber.trim().isEmpty) {
      throw ArgumentError('Tracking number cannot be empty');
    }

    try {
      dev.log('📦 Adding tracking $trackingNumber to enhanced order $orderId');

      // Auto-generate tracking URL if not provided
      String? finalTrackingUrl = trackingUrl;
      if (finalTrackingUrl == null && shippingCarrier != null) {
        finalTrackingUrl = await _generateTrackingUrl(shippingCarrier, trackingNumber);
      }

      final updateData = {
        'tracking_number': trackingNumber.trim(),
        'tracking_url': finalTrackingUrl,
        'shipping_carrier': shippingCarrier,
        'shipping_service': shippingService,
        'estimated_delivery': estimatedDelivery?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await client
          .from('enhanced_orders')
          .update(updateData)
          .eq('id', orderId)
          .select('*, companies(*)')
          .single();

      dev.log('✅ Tracking information added to enhanced order $orderId');
      return EnhancedOrder.fromJson(response);

    } catch (e) {
      dev.log('❌ Error adding tracking to enhanced order: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to add tracking to enhanced order: $e');
    }
  }

  /// Get order status history
  Future<List<OrderStatusChange>> getOrderStatusHistory(int orderId) async {
    if (orderId <= 0) {
      throw ArgumentError('Order ID must be greater than 0');
    }

    try {
      dev.log('📋 Fetching status history for enhanced order $orderId');

      final response = await client
          .from('order_status_history')
          .select()
          .eq('order_id', orderId)
          .order('changed_at', ascending: true);

      final List<dynamic> historyData = response as List<dynamic>;
      final List<OrderStatusChange> history = historyData
          .map<OrderStatusChange>((json) => OrderStatusChange.fromJson(json as Map<String, dynamic>))
          .toList();

      dev.log('✅ Found ${history.length} status changes for order $orderId');
      return history;

    } catch (e) {
      dev.log('❌ Error fetching order status history: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to fetch order status history: $e');
    }
  }

  /// Get available shipping carriers
  Future<List<Map<String, dynamic>>> getShippingCarriers() async {
    try {
      dev.log('🚛 Fetching available shipping carriers');

      final response = await client
          .from('shipping_carriers')
          .select()
          .eq('is_active', true)
          .order('name', ascending: true);

      dev.log('✅ Found ${(response as List).length} shipping carriers');
      return List<Map<String, dynamic>>.from(response);

    } catch (e) {
      dev.log('❌ Error fetching shipping carriers: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to fetch shipping carriers: $e');
    }
  }

  /// Get shipping methods for a carrier
  Future<List<Map<String, dynamic>>> getShippingMethods(String carrierCode) async {
    if (carrierCode.trim().isEmpty) {
      throw ArgumentError('Carrier code cannot be empty');
    }

    try {
      dev.log('📦 Fetching shipping methods for carrier $carrierCode');

      final response = await client
          .from('shipping_methods')
          .select('*, shipping_carriers!inner(*)')
          .eq('shipping_carriers.code', carrierCode)
          .eq('is_active', true)
          .order('base_cost', ascending: true);

      dev.log('✅ Found ${(response as List).length} shipping methods for $carrierCode');
      return List<Map<String, dynamic>>.from(response);

    } catch (e) {
      dev.log('❌ Error fetching shipping methods: $e', error: e);
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to fetch shipping methods: $e');
    }
  }

  /// Convert BasicOrder to EnhancedOrder
  Future<EnhancedOrder> convertBasicToEnhancedOrder({
    required BasicOrder basicOrder,
    required String companyId,
    required DeliveryAddress deliveryAddress,
    String? customerEmail,
    String? customerPhone,
  }) async {
    try {
      dev.log('🔄 Converting basic order ${basicOrder.id} to enhanced order');

      return await createEnhancedOrder(
        orderNumber: basicOrder.orderNumber,
        companyId: companyId,
        customerId: basicOrder.userId,
        hikeId: basicOrder.hikeId,
        subtotal: basicOrder.totalAmount - (basicOrder.deliveryType == DeliveryType.shipping ? 5.0 : 0.0),
        shippingCost: basicOrder.deliveryType == DeliveryType.shipping ? 5.0 : 0.0,
        totalAmount: basicOrder.totalAmount,
        baseAmount: basicOrder.totalAmount - (basicOrder.deliveryType == DeliveryType.shipping ? 5.0 : 0.0),
        deliveryAddress: deliveryAddress,
        deliveryType: basicOrder.deliveryType == DeliveryType.shipping 
            ? DeliveryType.standardShipping 
            : DeliveryType.pickup,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        metadata: {
          'converted_from_basic_order': true,
          'original_basic_order_id': basicOrder.id,
          'conversion_date': DateTime.now().toIso8601String(),
        },
      );

    } catch (e) {
      dev.log('❌ Error converting basic to enhanced order: $e', error: e);
      throw Exception('Failed to convert basic to enhanced order: $e');
    }
  }

  /// Generate tracking URL from carrier code and tracking number
  Future<String?> _generateTrackingUrl(String carrierCode, String trackingNumber) async {
    try {
      final response = await client
          .from('shipping_carriers')
          .select('tracking_url_template')
          .eq('code', carrierCode)
          .maybeSingle();

      if (response != null && response['tracking_url_template'] != null) {
        final template = response['tracking_url_template'] as String;
        return template.replaceAll('{tracking_number}', trackingNumber);
      }

      return null;

    } catch (e) {
      dev.log('⚠️ Warning: Could not generate tracking URL for $carrierCode: $e');
      return null;
    }
  }
}
