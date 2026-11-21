import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/corporate_lunch_settings.dart';
import '../models/corporate_models.dart';
import '../models/meal_option.dart';
import '../models/corporate_lunch_order.dart';
import '../services/lunch_ordering_service.dart';

class LunchOrderProvider extends ChangeNotifier {
  final LunchOrderingService _service = LunchOrderingService();

  // Master Data
  CorporateLunchSettings _settings = CorporateLunchSettings();
  List<LunchMealOption> _allMealOptions = [];
  List<Corporate> _corporates = [];
  List<CollectionPoint> _collectionPoints = [];
  List<CorporateLunchOrder> _customerOrders = [];

  // Active Selection State
  Corporate? _selectedCorporate;
  CollectionPoint? _selectedCollectionPoint;
  String _selectedLunchDate = '';
  String _mealType = 'VEG'; // "VEG" | "NON_VEG"
  String _riceQuantity = 'REGULAR'; // "REGULAR" | "LESS"
  String? _selectedGravyId;
  String? _selectedFryId;
  String? _selectedCurryId;
  final Set<String> _selectedAddonIds = {};
  int _paidQuantity = 1;

  bool _isLoading = false;
  String? _errorMessage;

  // Stream Subscriptions
  StreamSubscription? _settingsSub;
  StreamSubscription? _optionsSub;
  StreamSubscription? _corpsSub;
  StreamSubscription? _cpsSub;
  StreamSubscription? _ordersSub;

  // Getters
  CorporateLunchSettings get settings => _settings;
  List<LunchMealOption> get allMealOptions => _allMealOptions;
  List<Corporate> get corporates => _corporates;
  List<CollectionPoint> get collectionPoints => _collectionPoints;
  List<CorporateLunchOrder> get customerOrders => _customerOrders;

  Corporate? get selectedCorporate => _selectedCorporate;
  CollectionPoint? get selectedCollectionPoint => _selectedCollectionPoint;
  String get selectedLunchDate => _selectedLunchDate;
  String get mealType => _mealType;
  String get riceQuantity => _riceQuantity;
  String? get selectedGravyId => _selectedGravyId;
  String? get selectedFryId => _selectedFryId;
  String? get selectedCurryId => _selectedCurryId;
  Set<String> get selectedAddonIds => _selectedAddonIds;
  int get paidQuantity => _paidQuantity;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Filtered meal option sub-lists
  List<LunchMealOption> get gravyOptions =>
      _allMealOptions.where((o) => o.category == MealCategory.GRAVY && o.active).toList();
  List<LunchMealOption> get fryOptions =>
      _allMealOptions.where((o) => o.category == MealCategory.FRY && o.active).toList();
  List<LunchMealOption> get curryOptions =>
      _allMealOptions.where((o) => o.category == MealCategory.CURRY && o.active).toList();
  List<LunchMealOption> get addonOptions =>
      _allMealOptions.where((o) => o.category == MealCategory.ADDON && o.active).toList();

  List<LunchMealOption> get selectedAddons =>
      addonOptions.where((o) => _selectedAddonIds.contains(o.optionId)).toList();

  // Pricing Calculation
  PricingCalculationResult get currentPricing {
    return _service.calculatePricing(
      settings: _settings,
      mealType: _mealType,
      selectedAddons: selectedAddons,
      paidQuantity: _paidQuantity,
    );
  }

  LunchOrderProvider() {
    _initStreams();
  }

  void _initStreams() {
    _settingsSub = _service.streamSettings().listen((s) {
      _settings = s;
      if (_selectedLunchDate.isEmpty) {
        _selectedLunchDate = TimezoneHelper.getDefaultLunchDate(s.lunchOrderCutoffTime);
      }
      notifyListeners();
    });

    _optionsSub = _service.streamMealOptions().listen((opts) {
      _allMealOptions = opts;
      notifyListeners();
    });

    _corpsSub = _service.streamCorporates().listen((corps) {
      _corporates = corps;
      if (_selectedCorporate == null && corps.isNotEmpty) {
        _selectedCorporate = corps.first;
        _listenCollectionPoints(corps.first.corporateId);
      }
      notifyListeners();
    });
  }

  void _listenCollectionPoints(String corporateId) {
    _cpsSub?.cancel();
    _cpsSub = _service.streamCollectionPoints(corporateId: corporateId).listen((cps) {
      _collectionPoints = cps;
      if (cps.isNotEmpty && (_selectedCollectionPoint == null || _selectedCollectionPoint!.corporateId != corporateId)) {
        _selectedCollectionPoint = cps.first;
      }
      notifyListeners();
    });
  }

  void listenCustomerOrders(String mobile) {
    _ordersSub?.cancel();
    _ordersSub = _service.streamCustomerOrders(mobile).listen((orders) {
      _customerOrders = orders;
      notifyListeners();
    });
  }

  // Setters & Actions
  void setCorporate(Corporate corp) {
    _selectedCorporate = corp;
    _listenCollectionPoints(corp.corporateId);
    notifyListeners();
  }

  void setCollectionPoint(CollectionPoint cp) {
    _selectedCollectionPoint = cp;
    notifyListeners();
  }

  void setLunchDate(String date) {
    _selectedLunchDate = date;
    notifyListeners();
  }

  void setMealType(String type) {
    _mealType = type;
    notifyListeners();
  }

  void setRiceQuantity(String portion) {
    _riceQuantity = portion;
    notifyListeners();
  }

  void setGravy(String? id) {
    _selectedGravyId = id;
    notifyListeners();
  }

  void setFry(String? id) {
    _selectedFryId = id;
    notifyListeners();
  }

  void setCurry(String? id) {
    _selectedCurryId = id;
    notifyListeners();
  }

  void toggleAddon(String id) {
    if (_selectedAddonIds.contains(id)) {
      _selectedAddonIds.remove(id);
    } else {
      _selectedAddonIds.add(id);
    }
    notifyListeners();
  }

  void setPaidQuantity(int qty) {
    if (qty >= 1 && qty <= 200) {
      _paidQuantity = qty;
      notifyListeners();
    }
  }

  MealSelectionSnapshot buildSnapshot() {
    final gravy = gravyOptions.firstWhere((e) => e.optionId == _selectedGravyId, orElse: () => LunchMealOption(optionId: '', category: MealCategory.GRAVY, name: 'Default Gravy', active: true, sortOrder: 0, price: 0));
    final fry = fryOptions.firstWhere((e) => e.optionId == _selectedFryId, orElse: () => LunchMealOption(optionId: '', category: MealCategory.FRY, name: 'Default Fry', active: true, sortOrder: 0, price: 0));
    final curry = curryOptions.firstWhere((e) => e.optionId == _selectedCurryId, orElse: () => LunchMealOption(optionId: '', category: MealCategory.CURRY, name: 'Default Curry', active: true, sortOrder: 0, price: 0));

    return MealSelectionSnapshot(
      mealType: _mealType,
      mealTypeName: _mealType == 'VEG' ? 'Standard Veg Meal' : 'Authentic Non-Veg Meal',
      riceQuantity: _riceQuantity,
      riceQuantityName: _riceQuantity == 'REGULAR' ? 'Regular Rice' : 'Less Rice',
      gravyId: _selectedGravyId,
      gravyName: _selectedGravyId != null ? gravy.name : null,
      fryId: _selectedFryId,
      fryName: _selectedFryId != null ? fry.name : null,
      curryId: _selectedCurryId,
      curryName: _selectedCurryId != null ? curry.name : null,
      customAddons: selectedAddons.map((a) => a.toMap()).toList(),
    );
  }

  Future<CorporateLunchOrder?> placeOrder({
    required String customerId,
    required String customerName,
    required String customerMobile,
    required String customerEmail,
    required String paymentMethod, // "CASHFREE" | "COD"
  }) async {
    if (_selectedCorporate == null || _selectedCollectionPoint == null) {
      _errorMessage = 'Please select a company and collection point.';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = buildSnapshot();
      final pricing = currentPricing;

      final isCod = paymentMethod == 'COD';
      final order = await _service.createDailyOrder(
        customerId: customerId,
        customerName: customerName,
        customerMobile: customerMobile,
        customerEmail: customerEmail,
        corporate: _selectedCorporate!,
        collectionPoint: _selectedCollectionPoint!,
        lunchDate: _selectedLunchDate,
        meal: snapshot,
        pricing: pricing,
        paymentMethod: paymentMethod,
        paymentStatus: isCod ? 'PENDING' : 'PENDING',
        orderStatus: isCod ? 'CONFIRMED' : 'PENDING_PAYMENT',
      );

      _isLoading = false;
      notifyListeners();
      return order;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> switchOrderToCod(String orderId) async {
    if (_selectedCollectionPoint == null) return;
    await _service.switchOrderToCod(orderId, _selectedCollectionPoint!);
  }

  @override
  void dispose() {
    _settingsSub?.cancel();
    _optionsSub?.cancel();
    _corpsSub?.cancel();
    _cpsSub?.cancel();
    _ordersSub?.cancel();
    super.dispose();
  }
}

