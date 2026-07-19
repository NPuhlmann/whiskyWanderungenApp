abstract final class Routes {
  static const home = '/';
  static const login = '/login';
  static const signUp = '/signUp';
  static const profile = '/profile';
  static const myHikes = '/myHikes';
  // Child routes only: GoRouter declares them relative to their parent, so
  // they carry no leading slash.
  static const hikeDetails = 'hikeDetails';
  static const hikeMap = 'hikeMap';

  // Auth routes
  static const ageGate = '/age-gate';
  static const magicLink = '/magic-link';

  // Payment routes
  static const checkout = '/checkout';
  static const paymentSuccess = '/payment-success';
  static const paymentFailed = '/payment-failed';
  static const orderHistory = '/order-history';
  static const orderTracking = '/order-tracking';
}
