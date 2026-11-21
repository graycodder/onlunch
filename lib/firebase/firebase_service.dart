import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseApp? _app;
  FirebaseAuth? _auth;
  FirebaseDatabase? _database;

  FirebaseApp get app => _app ?? Firebase.app();
  FirebaseAuth get auth => _auth ?? FirebaseAuth.instance;
  FirebaseDatabase get database =>
      _database ?? FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: DefaultFirebaseOptions.databaseURL,
      );

  // Root namespace strictly separated from existing Rinus products
  static const String rootNamespace = 'onelunch';

  Future<void> initialize() async {
    try {
      // Get or initialize the Firebase app
      if (Firebase.apps.isEmpty) {
        _app = await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } else {
        _app = Firebase.app();
      }
    } catch (e) {
      // duplicate-app or any init error — always fall back to default app
      debugPrint('Firebase app init note: $e');
      _app = Firebase.app();
    }

    // Always initialize auth and database regardless of above outcome
    try {
      _auth = FirebaseAuth.instanceFor(app: app);
      _database = FirebaseDatabase.instanceFor(
        app: app,
        databaseURL: DefaultFirebaseOptions.databaseURL,
      );

      // Offline persistence for smooth responsive experience
      if (!kIsWeb) {
        try {
          database.setPersistenceEnabled(true);
        } catch (_) {}
      }

      debugPrint('Firebase initialized successfully for OneLunch ($rootNamespace)');
      await _seedInitialDataIfEmpty();
    } catch (e, stack) {
      debugPrint('Firebase service setup error: $e\n$stack');
    }
  }

  // Database references inside onelunch/
  DatabaseReference get usersRef => database.ref('$rootNamespace/users');
  DatabaseReference get productsRef => database.ref('$rootNamespace/products');
  DatabaseReference get mealsRef => database.ref('$rootNamespace/meals');
  DatabaseReference get companiesRef => database.ref('$rootNamespace/companies');
  DatabaseReference get collectionPointsRef => database.ref('$rootNamespace/collectionPoints');
  DatabaseReference get addonCategoriesRef => database.ref('$rootNamespace/addonCategories');
  DatabaseReference get addonItemsRef => database.ref('$rootNamespace/addonItems');
  DatabaseReference get driversRef => database.ref('$rootNamespace/drivers');
  DatabaseReference get categoriesRef => database.ref('$rootNamespace/categories');
  DatabaseReference get bannersRef => database.ref('$rootNamespace/banners');
  DatabaseReference get cartsRef => database.ref('$rootNamespace/carts');
  DatabaseReference get ordersRef => database.ref('$rootNamespace/orders');
  DatabaseReference get settingsRef => database.ref('$rootNamespace/settings');

  DatabaseReference userRef(String uid) => usersRef.child(uid);
  DatabaseReference cartRef(String uid) => cartsRef.child(uid);
  DatabaseReference orderRef(String orderId) => ordersRef.child(orderId);
  DatabaseReference companyRef(String companyId) => companiesRef.child(companyId);
  DatabaseReference collectionPointRef(String cpId) => collectionPointsRef.child(cpId);
  DatabaseReference mealRef(String mealId) => mealsRef.child(mealId);

  /// Seeds initial OneLunch products, corporate hierarchy, and settings if empty
  Future<void> _seedInitialDataIfEmpty() async {
    try {
      final snapshot = await mealsRef.get();
      if (!snapshot.exists || snapshot.value == null) {
        debugPrint('Seeding corporate hierarchy, meals, and add-ons into $rootNamespace...');

        // 1. Initial Companies
        final initialCompanies = {
          'comp_isquare': {
            'id': 'comp_isquare',
            'name': 'iSquare CoWorking Space',
            'address': 'Infopark Road, Kakkanad, Kochi, Kerala',
            'contactPerson': 'Mathew Joseph',
            'contactNumber': '+91 98470 12345',
            'email': 'contact@isquare.in',
            'status': 'Active',
            'createdAt': ServerValue.timestamp,
          },
          'comp_transasia': {
            'id': 'comp_transasia',
            'name': 'Trans Asia Cyber Park',
            'address': 'Phase II, Infopark, Kakkanad, Kochi',
            'contactPerson': 'Anjali Menon',
            'contactNumber': '+91 98471 67890',
            'email': 'info@transasia.com',
            'status': 'Active',
            'createdAt': ServerValue.timestamp,
          },
          'comp_lulu_cyber': {
            'id': 'comp_lulu_cyber',
            'name': 'Lulu Cyber Tower',
            'address': 'Infopark SEZ, Kakkanad, Kochi',
            'contactPerson': 'Rohan Thomas',
            'contactNumber': '+91 98472 54321',
            'email': 'admin@lulucyber.in',
            'status': 'Active',
            'createdAt': ServerValue.timestamp,
          },
        };
        await companiesRef.set(initialCompanies);

        // 2. Initial Collection Points (belonging to companies)
        final initialCollectionPoints = {
          'cp_isquare_thrikkakara': {
            'id': 'cp_isquare_thrikkakara',
            'companyId': 'comp_isquare',
            'companyName': 'iSquare CoWorking Space',
            'name': 'iSquare Thrikkakara',
            'address': 'Ground Floor Cafe Area, iSquare Thrikkakara, Kochi',
            'mapUrl': 'https://maps.google.com/?q=10.033,76.328',
            'contactPerson': 'Haris K.',
            'contactNumber': '+91 99951 11222',
            'deliveryTime': '12:30 PM',
            'deliveryInstructions': 'Leave boxes at security desk reception',
            'assignedDriverId': 'drv_01',
            'assignedDriverName': 'Rajesh Kumar (Driver 01)',
            'maxCapacity': 150,
            'status': 'Active',
            'createdAt': ServerValue.timestamp,
          },
          'cp_isquare_pipeline': {
            'id': 'cp_isquare_pipeline',
            'companyId': 'comp_isquare',
            'companyName': 'iSquare CoWorking Space',
            'name': 'iSquare Pipeline Junction',
            'address': '1st Floor Pantry, Pipeline Road, Palarivattom',
            'mapUrl': 'https://maps.google.com/?q=10.012,76.315',
            'contactPerson': 'Suresh P.',
            'contactNumber': '+91 99952 33444',
            'deliveryTime': '12:45 PM',
            'deliveryInstructions': 'Deliver directly to pantry rack',
            'assignedDriverId': 'drv_01',
            'assignedDriverName': 'Rajesh Kumar (Driver 01)',
            'maxCapacity': 150,
            'status': 'Active',
            'createdAt': ServerValue.timestamp,
          },
          'cp_isquare_kakkanad': {
            'id': 'cp_isquare_kakkanad',
            'companyId': 'comp_isquare',
            'companyName': 'iSquare CoWorking Space',
            'name': 'iSquare Kakkanad',
            'address': 'Tower B, Cafeteria, Infopark Phase 1, Kakkanad',
            'mapUrl': 'https://maps.google.com/?q=10.009,76.357',
            'contactPerson': 'Deepa Nair',
            'contactNumber': '+91 99953 55666',
            'deliveryTime': '01:00 PM',
            'deliveryInstructions': 'Sign delivery log at reception',
            'assignedDriverId': 'drv_02',
            'assignedDriverName': 'Manoj V. (Driver 02)',
            'maxCapacity': 120,
            'status': 'Active',
            'createdAt': ServerValue.timestamp,
          },
          'cp_transasia_tower1': {
            'id': 'cp_transasia_tower1',
            'companyId': 'comp_transasia',
            'companyName': 'Trans Asia Cyber Park',
            'name': 'Trans Asia Tower 1 Hub',
            'address': 'Level 2 Food Court, Trans Asia Tower 1, Infopark Phase 2',
            'mapUrl': '',
            'contactPerson': 'Arun V.',
            'contactNumber': '+91 98473 66778',
            'deliveryTime': '12:40 PM',
            'deliveryInstructions': 'Handover to floor coordinator',
            'assignedDriverId': 'drv_02',
            'assignedDriverName': 'Manoj V. (Driver 02)',
            'maxCapacity': 200,
            'status': 'Active',
            'createdAt': ServerValue.timestamp,
          },
        };
        await collectionPointsRef.set(initialCollectionPoints);

        // 3. Initial Meals (Admin controlled basic meals)
        final initialMeals = {
          'meal_veg': {
            'id': 'meal_veg',
            'name': 'Veg Lunch',
            'description': 'Traditional Kerala sadhya lunch with rice, sambar, rasam, curd, thoran & pickle.',
            'mealType': 'Veg',
            'basePrice': 60,
            'imageUrl': 'assets/images/meals_veg.png',
            'availableDate': 'All',
            'isAvailable': true,
            'displayOrder': 1,
            'associatedCategories': ['cat_rice', 'cat_gravy', 'cat_side', 'cat_fry', 'cat_extra'],
          },
          'meal_nonveg': {
            'id': 'meal_nonveg',
            'name': 'Non-Veg Lunch',
            'description': 'Authentic Kerala lunch with rice, fish curry gravy, thoran, moru & chicken roast.',
            'mealType': 'Non-Veg',
            'basePrice': 80,
            'imageUrl': 'assets/images/meals_nonveg.png',
            'availableDate': 'All',
            'isAvailable': true,
            'displayOrder': 2,
            'associatedCategories': ['cat_rice', 'cat_gravy', 'cat_side', 'cat_fry', 'cat_extra'],
          },
          'meal_special': {
            'id': 'meal_special',
            'name': 'Special Sadya Lunch',
            'description': 'Royal Kerala sadya on banana leaf with payasam & 12 accompaniments.',
            'mealType': 'Veg',
            'basePrice': 120,
            'imageUrl': 'assets/images/rice_lunch.png',
            'availableDate': 'All',
            'isAvailable': true,
            'displayOrder': 3,
            'associatedCategories': ['cat_rice', 'cat_gravy', 'cat_side', 'cat_fry', 'cat_extra'],
          },
        };
        await mealsRef.set(initialMeals);
        await productsRef.set(initialMeals); // Sync legacy products ref

        // 4. Initial Add-on Categories
        final initialAddonCategories = {
          'cat_rice': {
            'id': 'cat_rice',
            'name': 'Rice Portion',
            'description': 'Select your rice preference',
            'selectionMode': 'Single',
            'status': 'Active',
            'displayOrder': 1,
          },
          'cat_gravy': {
            'id': 'cat_gravy',
            'name': 'Gravy Selection',
            'description': 'Choose your primary gravy',
            'selectionMode': 'Single',
            'status': 'Active',
            'displayOrder': 2,
          },
          'cat_side': {
            'id': 'cat_side',
            'name': 'Side Dishes',
            'description': 'Add healthy traditional vegetable preparations',
            'selectionMode': 'Multiple',
            'status': 'Active',
            'displayOrder': 3,
          },
          'cat_fry': {
            'id': 'cat_fry',
            'name': 'Fry & Delicacies',
            'description': 'Hot crispy Kerala style seafood & meat fries',
            'selectionMode': 'Multiple',
            'status': 'Active',
            'displayOrder': 4,
          },
          'cat_extra': {
            'id': 'cat_extra',
            'name': 'Extra Add-ons',
            'description': 'Papad, desserts, extra rice and refreshments',
            'selectionMode': 'Multiple',
            'status': 'Active',
            'displayOrder': 5,
          },
        };
        await addonCategoriesRef.set(initialAddonCategories);

        // 5. Initial Add-on Items
        final initialAddonItems = {
          // Rice
          'item_matta_rice': {
            'id': 'item_matta_rice',
            'categoryId': 'cat_rice',
            'categoryName': 'Rice Portion',
            'name': 'Kerala Matta Rice (Default)',
            'description': 'Nutritious brown boiled Kerala rice',
            'imageUrl': 'assets/images/rice_lunch.png',
            'price': 0,
            'isVeg': true,
            'applicableMealTypes': ['Veg', 'Non-Veg'],
            'maxQty': 1,
            'isAvailable': true,
            'displayOrder': 1,
          },
          'item_white_rice': {
            'id': 'item_white_rice',
            'categoryId': 'cat_rice',
            'categoryName': 'Rice Portion',
            'name': 'White Rice',
            'description': 'Soft polished white ponni rice',
            'imageUrl': 'assets/images/rice_lunch.png',
            'price': 0,
            'isVeg': true,
            'applicableMealTypes': ['Veg', 'Non-Veg'],
            'maxQty': 1,
            'isAvailable': true,
            'displayOrder': 2,
          },
          // Gravy
          'item_sambar': {
            'id': 'item_sambar',
            'categoryId': 'cat_gravy',
            'categoryName': 'Gravy Selection',
            'name': 'Authentic Kerala Sambar',
            'description': 'Rich aromatic lentil & vegetable curry with drumsticks',
            'imageUrl': 'assets/images/meals_veg.png',
            'price': 0,
            'isVeg': true,
            'applicableMealTypes': ['Veg', 'Non-Veg'],
            'maxQty': 1,
            'isAvailable': true,
            'displayOrder': 1,
          },
          'item_fish_gravy': {
            'id': 'item_fish_gravy',
            'categoryId': 'cat_gravy',
            'categoryName': 'Gravy Selection',
            'name': 'Kottayam Fish Curry Gravy',
            'description': 'Traditional kudampuli fish curry spicy gravy',
            'imageUrl': 'assets/images/meals_nonveg.png',
            'price': 0,
            'isVeg': false,
            'applicableMealTypes': ['Non-Veg'],
            'maxQty': 1,
            'isAvailable': true,
            'displayOrder': 2,
          },
          'item_moru_curry': {
            'id': 'item_moru_curry',
            'categoryId': 'cat_gravy',
            'categoryName': 'Gravy Selection',
            'name': 'Seasoned Moru / Pulissery',
            'description': 'Tempered buttermilk curry with cumin & mustard',
            'imageUrl': 'assets/images/meals_veg.png',
            'price': 0,
            'isVeg': true,
            'applicableMealTypes': ['Veg', 'Non-Veg'],
            'maxQty': 1,
            'isAvailable': true,
            'displayOrder': 3,
          },
          // Side Dishes (Multiple selection)
          'item_cabbage_thoran': {
            'id': 'item_cabbage_thoran',
            'categoryId': 'cat_side',
            'categoryName': 'Side Dishes',
            'name': 'Cabbage Thoran',
            'description': 'Fresh shredded cabbage sauteed with grated coconut & curry leaves',
            'imageUrl': 'assets/images/meals_veg.png',
            'price': 15,
            'isVeg': true,
            'applicableMealTypes': ['Veg', 'Non-Veg'],
            'maxQty': 5,
            'isAvailable': true,
            'displayOrder': 1,
          },
          'item_avial': {
            'id': 'item_avial',
            'categoryId': 'cat_side',
            'categoryName': 'Side Dishes',
            'name': 'Traditional Avial',
            'description': 'Mixed farm vegetables cooked in mild coconut-yogurt paste',
            'imageUrl': 'assets/images/meals_veg.png',
            'price': 20,
            'isVeg': true,
            'applicableMealTypes': ['Veg', 'Non-Veg'],
            'maxQty': 5,
            'isAvailable': true,
            'displayOrder': 2,
          },
          'item_mezhukkupuratti': {
            'id': 'item_mezhukkupuratti',
            'categoryId': 'cat_side',
            'categoryName': 'Side Dishes',
            'name': 'Achinga Payar Mezhukkupuratti',
            'description': 'Crisp long beans slow roasted with shallots & crushed garlic',
            'imageUrl': 'assets/images/meals_veg.png',
            'price': 20,
            'isVeg': true,
            'applicableMealTypes': ['Veg', 'Non-Veg'],
            'maxQty': 5,
            'isAvailable': true,
            'displayOrder': 3,
          },
          // Fry & Delicacies (Multiple selection)
          'item_fish_fry': {
            'id': 'item_fish_fry',
            'categoryId': 'cat_fry',
            'categoryName': 'Fry & Delicacies',
            'name': 'Mackerel (Ayala) Fish Fry',
            'description': 'Fresh fish marinated in red chilly, pepper & lemon and pan fried',
            'imageUrl': 'assets/images/meals_nonveg.png',
            'price': 40,
            'isVeg': false,
            'applicableMealTypes': ['Veg', 'Non-Veg'],
            'maxQty': 5,
            'isAvailable': true,
            'displayOrder': 1,
          },
          'item_chicken_fry': {
            'id': 'item_chicken_fry',
            'categoryId': 'cat_fry',
            'categoryName': 'Fry & Delicacies',
            'name': 'Kerala Chicken Roast Fry',
            'description': 'Succulent chicken pieces roasted in dark pepper-curry leaf masala',
            'imageUrl': 'assets/images/meals_nonveg.png',
            'price': 50,
            'isVeg': false,
            'applicableMealTypes': ['Veg', 'Non-Veg'],
            'maxQty': 5,
            'isAvailable': true,
            'displayOrder': 2,
          },
          'item_beef_fry': {
            'id': 'item_beef_fry',
            'categoryId': 'cat_fry',
            'categoryName': 'Fry & Delicacies',
            'name': 'Kerala Beef Fry (Ularthiyathu)',
            'description': 'Classic slow-roasted beef with crunchy fried coconut slivers',
            'imageUrl': 'assets/images/meals_nonveg.png',
            'price': 60,
            'isVeg': false,
            'applicableMealTypes': ['Non-Veg'],
            'maxQty': 5,
            'isAvailable': true,
            'displayOrder': 3,
          },
          'item_prawns_fry': {
            'id': 'item_prawns_fry',
            'categoryId': 'cat_fry',
            'categoryName': 'Fry & Delicacies',
            'name': 'Chemmeen / Prawns Roast',
            'description': 'Tender tiger prawns simmered in thick onion-tomato roast',
            'imageUrl': 'assets/images/meals_nonveg.png',
            'price': 70,
            'isVeg': false,
            'applicableMealTypes': ['Non-Veg'],
            'maxQty': 5,
            'isAvailable': true,
            'displayOrder': 4,
          },
          // Extras
          'item_extra_rice': {
            'id': 'item_extra_rice',
            'categoryId': 'cat_extra',
            'categoryName': 'Extra Add-ons',
            'name': 'Extra Rice Box',
            'description': 'Generous piping hot portion of rice',
            'imageUrl': 'assets/images/rice_lunch.png',
            'price': 15,
            'isVeg': true,
            'applicableMealTypes': ['Veg', 'Non-Veg'],
            'maxQty': 3,
            'isAvailable': true,
            'displayOrder': 1,
          },
          'item_extra_gravy': {
            'id': 'item_extra_gravy',
            'categoryId': 'cat_extra',
            'categoryName': 'Extra Add-ons',
            'name': 'Extra Gravy Container',
            'description': 'Additional serving of your favorite gravy',
            'imageUrl': 'assets/images/meals_veg.png',
            'price': 15,
            'isVeg': true,
            'applicableMealTypes': ['Veg', 'Non-Veg'],
            'maxQty': 3,
            'isAvailable': true,
            'displayOrder': 2,
          },
          'item_papadum': {
            'id': 'item_papadum',
            'categoryId': 'cat_extra',
            'categoryName': 'Extra Add-ons',
            'name': 'Crispy Papadam (Pack of 2)',
            'description': 'Freshly fried Kerala appalams',
            'imageUrl': 'assets/images/rice_lunch.png',
            'price': 10,
            'isVeg': true,
            'applicableMealTypes': ['Veg', 'Non-Veg'],
            'maxQty': 5,
            'isAvailable': true,
            'displayOrder': 3,
          },
          'item_payasam': {
            'id': 'item_payasam',
            'categoryId': 'cat_extra',
            'categoryName': 'Extra Add-ons',
            'name': 'Ada Pradhaman Payasam',
            'description': 'Rich traditional dessert made with jaggery, coconut milk and roasted cashews',
            'imageUrl': 'assets/images/rice_lunch.png',
            'price': 30,
            'isVeg': true,
            'applicableMealTypes': ['Veg', 'Non-Veg'],
            'maxQty': 5,
            'isAvailable': true,
            'displayOrder': 4,
          },
        };
        await addonItemsRef.set(initialAddonItems);

        // 6. Initial Drivers
        final initialDrivers = {
          'drv_01': {
            'id': 'drv_01',
            'name': 'Rajesh Kumar (Driver 01)',
            'phone': '+91 98471 12233',
            'vehicleNo': 'KL-07-CD-1234',
            'status': 'Active',
          },
          'drv_02': {
            'id': 'drv_02',
            'name': 'Manoj V. (Driver 02)',
            'phone': '+91 98472 23344',
            'vehicleNo': 'KL-07-EF-5678',
            'status': 'Active',
          },
        };
        await driversRef.set(initialDrivers);

        // 7. Initial Banner
        final initialBanners = {
          'banner_01': {
            'id': 'banner_01',
            'title': 'Delicious Lunch Just a Click Away!',
            'imageUrl': 'assets/images/video_banner.png',
            'videoUrl': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
            'isActive': true,
          }
        };
        await bannersRef.set(initialBanners);

        // 8. Initial Settings
        final initialSettings = {
          'lunchAvailability': true,
          'orderCutoffTime': '11:30 PM',
          'supportPhone': '+919995226139',
          'minimumOrderAmount': 0,
        };
        await settingsRef.set(initialSettings);
        debugPrint('OneLunch corporate database seeded successfully.');
      }
    } catch (e) {
      debugPrint('Seed check error (rules or network): $e');
    }
  }
}

