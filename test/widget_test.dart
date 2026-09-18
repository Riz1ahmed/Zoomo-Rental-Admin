import 'package:flutter_test/flutter_test.dart';

import 'package:ebike_admin/main.dart';

void main() {
  testWidgets('Admin app entrypoint is available', (WidgetTester tester) async {
    expect(const AdminApp(), isA<AdminApp>());
  });
}
