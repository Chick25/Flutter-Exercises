// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:project1/main.dart';

void main() {
  testWidgets('displays the personal calendar', (WidgetTester tester) async {
    await initializeDateFormatting('vi_VN', null);
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const LichCaNhanApp());

    expect(find.text('Lịch Cá Nhân'), findsOneWidget);
    expect(find.text('Hôm nay'), findsOneWidget);
  });
}
