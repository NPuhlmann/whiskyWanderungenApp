abstract final class Routes {
  static const home = '/';
  static const login = '/login';
  static const signUp = '/signUp';
  static const profile = '/profile';
  static const myHikes = '/myHikes';
  static const hikeDetails = '/hikeDetails';
  static const hikeMap = '/hikeMap';

  // Age gate routes
  static const ageGate = '/age-gate';
  static const ageBlocked = '/age-blocked';

  // Magic link auth routes
  static const magicLink = '/magic-link';
  static const magicLinkVerify = '/magic-link-verify';

  // Cart + payment routes
  static const cart = '/cart';
  static const stubCheckout = '/stub-checkout';
  static const checkout = '/checkout';
  static const paymentSuccess = '/payment-success';
  static const paymentFailed = '/payment-failed';
  static const orderHistory = '/order-history';
  static const orderTracking = '/order-tracking';
}
