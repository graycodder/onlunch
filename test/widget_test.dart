import 'package:flutter_test/flutter_test.dart';
import 'package:onelunch/core/constants/strings.dart';

void main() {
  test('OneLunch app brand string validation', () {
    expect(AppStrings.appName, 'OneLunch');
    expect(AppStrings.companyName, 'Rinus Food Products');
  });
}
