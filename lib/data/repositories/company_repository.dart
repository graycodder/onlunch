import 'package:firebase_database/firebase_database.dart';
import '../../firebase/firebase_service.dart';
import '../models/company_model.dart';

class CompanyRepository {
  final FirebaseService _fb = FirebaseService();
  DatabaseReference get _companiesRef => _fb.companiesRef;

  Stream<List<CompanyModel>> getCompaniesStream() {
    return _companiesRef.onValue.map((event) {
      final List<CompanyModel> companies = [];
      final data = event.snapshot.value;
      if (data is Map) {
        data.forEach((key, val) {
          if (val is Map) {
            companies.add(CompanyModel.fromMap(val, key.toString()));
          }
        });
      }
      return companies;
    });
  }

  Future<List<CompanyModel>> getActiveCompanies() async {
    final snapshot = await _companiesRef.get();
    final List<CompanyModel> companies = [];
    if (snapshot.exists && snapshot.value is Map) {
      (snapshot.value as Map).forEach((key, val) {
        if (val is Map) {
          final comp = CompanyModel.fromMap(val, key.toString());
          if (comp.isActive) {
            companies.add(comp);
          }
        }
      });
    }
    return companies;
  }

  Future<void> saveCompany(CompanyModel company) async {
    await _companiesRef.child(company.id).set(company.toMap());
  }

  Future<void> toggleCompanyStatus(String companyId, bool activate) async {
    await _companiesRef.child(companyId).update({
      'status': activate ? 'Active' : 'Inactive',
    });
  }

  Future<void> deleteCompany(String companyId) async {
    await _companiesRef.child(companyId).remove();
  }
}

