import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../data/models.dart';

enum CompareResult { added, removed, full }

class PropertyFilter {
  static const double priceCap = 30000000;

  String query = '';
  ListingKind? kind;
  Set<PropertyType> types = {};
  String? city;
  double minPrice = 0;
  double maxPrice = priceCap;
  int minBeds = 0;
  FinishType? finish;
  bool? ready;
  SortBy sort = SortBy.newest;

  PropertyFilter clone() => PropertyFilter()
    ..query = query
    ..kind = kind
    ..types = {...types}
    ..city = city
    ..minPrice = minPrice
    ..maxPrice = maxPrice
    ..minBeds = minBeds
    ..finish = finish
    ..ready = ready
    ..sort = sort;

  int get activeCount {
    var c = 0;
    if (types.isNotEmpty) c++;
    if (city != null) c++;
    if (minPrice > 0 || maxPrice < priceCap) c++;
    if (minBeds > 0) c++;
    if (finish != null) c++;
    if (ready != null) c++;
    return c;
  }

  bool matches(Property p) {
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      final hay = '${p.title.ar} ${p.title.en} ${p.location.ar} ${p.location.en} ${p.city.ar} ${p.city.en}'.toLowerCase();
      if (!hay.contains(q)) return false;
    }
    if (kind != null && p.kind != kind) return false;
    if (types.isNotEmpty && !types.contains(p.type)) return false;
    if (city != null && p.city.en != city) return false;
    if (p.price < minPrice) return false;
    if (maxPrice < priceCap && p.price > maxPrice) return false;
    if (p.beds < minBeds) return false;
    if (finish != null && p.finish != finish) return false;
    if (ready != null && p.isReady != ready) return false;
    return true;
  }

  List<Property> apply(List<Property> source) {
    final list = source.where(matches).toList();
    switch (sort) {
      case SortBy.newest:
        list.sort((a, b) => b.listedAt.compareTo(a.listedAt));
      case SortBy.priceLow:
        list.sort((a, b) => a.price.compareTo(b.price));
      case SortBy.priceHigh:
        list.sort((a, b) => b.price.compareTo(a.price));
      case SortBy.areaHigh:
        list.sort((a, b) => b.area.compareTo(a.area));
      case SortBy.pricePerMeter:
        list.sort((a, b) => a.pricePerMeter.compareTo(b.pricePerMeter));
    }
    return list;
  }
}

class AppNotification {
  final Tx title;
  final Tx body;
  final IconData icon;
  final DateTime at;
  const AppNotification(this.title, this.body, this.icon, this.at);
}

class AppState extends ChangeNotifier {
  AppState() {
    _seed();
  }

  Locale _locale = const Locale('ar');
  Locale get locale => _locale;
  bool get isAr => _locale.languageCode == 'ar';
  void setLocale(String code) {
    if (_locale.languageCode == code) return;
    _locale = Locale(code);
    notifyListeners();
  }

  void toggleLocale() => setLocale(isAr ? 'en' : 'ar');

  bool onboarded = false;
  void completeOnboarding() {
    onboarded = true;
    notifyListeners();
  }

  UserProfile? user;
  bool get loggedIn => user != null;
  void login(String name, String phone) {
    user = UserProfile(name: name, phone: phone);
    notifyListeners();
  }

  void logout() {
    user = null;
    notifyListeners();
  }

  bool notificationsOn = true;
  void setNotifications(bool v) {
    notificationsOn = v;
    notifyListeners();
  }

  int tab = 0;
  void setTab(int i) {
    if (tab == i) return;
    tab = i;
    notifyListeners();
  }

  final List<Property> myListings = [];
  List<Property> get marketProperties => MockData.properties;
  List<Property> get allProperties => [...myListings, ...MockData.properties];

  Property? propertyById(String? id) {
    for (final p in allProperties) {
      if (p.id == id) return p;
    }
    return null;
  }

  void addListing(Property p) {
    myListings.insert(0, p);
    notifyListeners();
  }

  final Set<String> _fav = {};
  bool isFav(String id) => _fav.contains(id);
  int get favCount => _fav.length;
  void toggleFav(String id) {
    _fav.contains(id) ? _fav.remove(id) : _fav.add(id);
    notifyListeners();
  }

  List<Property> get favorites => allProperties.where((p) => _fav.contains(p.id)).toList();

  static const maxCompare = 3;
  final List<String> _compare = [];
  List<String> get compareIds => List.unmodifiable(_compare);
  bool inCompare(String id) => _compare.contains(id);
  CompareResult toggleCompare(String id) {
    if (_compare.remove(id)) {
      notifyListeners();
      return CompareResult.removed;
    }
    if (_compare.length >= maxCompare) return CompareResult.full;
    _compare.add(id);
    notifyListeners();
    return CompareResult.added;
  }

  void clearCompare() {
    _compare.clear();
    notifyListeners();
  }

  final List<Inquiry> inquiries = [];
  void addInquiry(Inquiry i) {
    inquiries.insert(0, i);
    notifyListeners();
  }

  PropertyFilter filter = PropertyFilter();
  void setFilter(PropertyFilter f) {
    filter = f;
    notifyListeners();
  }

  void resetFilter() => setFilter(PropertyFilter());

  void exploreWith(void Function(PropertyFilter f) preset) {
    final f = PropertyFilter();
    preset(f);
    filter = f;
    tab = 1;
    notifyListeners();
  }

  List<Property> get filtered => filter.apply(marketProperties);

  late final List<AppNotification> notifications;

  void _seed() {
    final now = DateTime.now();
    notifications = [
      AppNotification(const Tx('إطلاق جديد', 'New launch'), const Tx('أبراج مرسى العلمين متاحة الآن بمقدم 10%', 'Alamein Marina Towers now open with 10% down'), Icons.rocket_launch_rounded, now.subtract(const Duration(hours: 2))),
      AppNotification(const Tx('انخفاض سعر', 'Price drop'), const Tx('شقة إعادة بيع بالتجمع انخفض سعرها 4%', 'A New Cairo resale apartment dropped 4%'), Icons.trending_down_rounded, now.subtract(const Duration(hours: 9))),
      AppNotification(const Tx('تأكيد معاينة', 'Viewing confirmed'), const Tx('تم تأكيد موعد معاينتك في زايد هايتس', 'Your Zayed Heights viewing is confirmed'), Icons.event_available_rounded, now.subtract(const Duration(days: 1))),
    ];
    inquiries.addAll([
      Inquiry(
        id: 'i-seed-1',
        type: InquiryType.viewing,
        propertyId: 'p3',
        name: 'Guest',
        phone: '01000000000',
        message: '',
        viewingDate: now.add(const Duration(days: 2)),
        slot: '12:00',
        createdAt: now.subtract(const Duration(days: 1)),
        status: InquiryStatus.confirmed,
      ),
      Inquiry(
        id: 'i-seed-2',
        type: InquiryType.info,
        projectId: 'pr4',
        name: 'Guest',
        phone: '01000000000',
        message: 'Payment plan for 2-bedroom chalets?',
        createdAt: now.subtract(const Duration(days: 4)),
        status: InquiryStatus.completed,
      ),
    ]);
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
