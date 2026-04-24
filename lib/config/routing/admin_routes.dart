/// Admin-spezifische Routen für die Web-App
abstract final class AdminRoutes {
  // Dashboard
  static const dashboard = '/admin/dashboard';

  // Wanderrouten-Verwaltung
  static const routes = '/admin/routes';
  static const routeCreate = '/admin/routes/create';
  static const routeEdit = '/admin/routes/edit';
  static const routeDetails = '/admin/routes/details';

  // Bestellverwaltung
  static const orders = '/admin/orders';
  static const orderDetails = '/admin/orders/details';
  static const orderFulfillment = '/admin/orders/fulfillment';

  // Whisky-Katalog
  static const whisky = '/admin/whisky';
  static const whiskyCreate = '/admin/whisky/create';
  static const whiskyEdit = '/admin/whisky/edit';
  static const tastingSets = '/admin/tasting-sets';

  // Analytics & Reporting
  static const analytics = '/admin/analytics';
  static const sales = '/admin/analytics/sales';
  static const customers = '/admin/analytics/customers';
  static const performance = '/admin/analytics/performance';

  // Team-Management
  static const team = '/admin/team';
  static const teamMember = '/admin/team/member';
  static const roles = '/admin/team/roles';

  // Finanzen & Provision
  static const finances = '/admin/finances';
  static const provisions = '/admin/finances/provisions';
  static const billing = '/admin/finances/billing';

  // Einstellungen
  static const settings = '/admin/settings';
  static const company = '/admin/settings/company';
  static const integrations = '/admin/settings/integrations';

  /// Gibt alle Admin-Routen als Liste zurück
  static List<String> get allRoutes => [
    dashboard,
    routes,
    routeCreate,
    routeEdit,
    routeDetails,
    orders,
    orderDetails,
    orderFulfillment,
    whisky,
    whiskyCreate,
    whiskyEdit,
    tastingSets,
    analytics,
    sales,
    customers,
    performance,
    team,
    teamMember,
    roles,
    finances,
    provisions,
    billing,
    settings,
    company,
    integrations,
  ];

  /// Prüft, ob eine Route eine Admin-Route ist
  static bool isAdminRoute(String route) {
    return route.startsWith('/admin');
  }
}
