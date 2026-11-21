import 'package:firebase_database/firebase_database.dart';
import '../../firebase/firebase_service.dart';
import '../models/collection_point_model.dart';

class CollectionPointRepository {
  final FirebaseService _fb = FirebaseService();
  DatabaseReference get _collectionPointsRef => _fb.collectionPointsRef;

  Stream<List<CollectionPointModel>> getCollectionPointsStream() {
    return _collectionPointsRef.onValue.map((event) {
      final List<CollectionPointModel> points = [];
      final data = event.snapshot.value;
      if (data is Map) {
        data.forEach((key, val) {
          if (val is Map) {
            points.add(CollectionPointModel.fromMap(val, key.toString()));
          }
        });
      }
      return points;
    });
  }

  Future<List<CollectionPointModel>> getActivePointsForCompany(String companyId) async {
    final snapshot = await _collectionPointsRef.get();
    final List<CollectionPointModel> points = [];
    if (snapshot.exists && snapshot.value is Map) {
      (snapshot.value as Map).forEach((key, val) {
        if (val is Map) {
          final cp = CollectionPointModel.fromMap(val, key.toString());
          if (cp.companyId == companyId && cp.isActive) {
            points.add(cp);
          }
        }
      });
    }
    return points;
  }

  Future<void> saveCollectionPoint(CollectionPointModel cp) async {
    await _collectionPointsRef.child(cp.id).set(cp.toMap());
  }

  Future<void> assignDriver(String cpId, String driverId, String driverName) async {
    await _collectionPointsRef.child(cpId).update({
      'assignedDriverId': driverId,
      'assignedDriverName': driverName,
    });
  }

  Future<void> toggleStatus(String cpId, bool activate) async {
    await _collectionPointsRef.child(cpId).update({
      'status': activate ? 'Active' : 'Inactive',
    });
  }

  Future<void> deleteCollectionPoint(String cpId) async {
    await _collectionPointsRef.child(cpId).remove();
  }
}

