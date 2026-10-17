import 'package:cultech_hackaton/app.dart';
import 'package:cultech_hackaton/core/config/app_config.dart';
import 'package:cultech_hackaton/core/di/injection_container.dart';
import 'package:cultech_hackaton/core/router/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  setUp(() => configureDependencies(config: const AppConfig(apiBaseUrl: '')));

  Future<void> pumpApp(
    WidgetTester tester, {
    required Size size,
    String location = AppRoutes.splash,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(App(initialLocation: location));
    await tester.pump(const Duration(seconds: 1));
  }

  /// Unmounts the app and lets the demo backend's pending timers drain.
  Future<void> disposeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 6));
  }

  testWidgets('desktop layout uses the sidebar and shows KPIs', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      size: const Size(1440, 1000),
      location: AppRoutes.dashboard,
    );

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('İdarə Paneli'), findsOneWidget);
    expect(find.text('Toplam Mədəni AI DNT İndeksi'), findsOneWidget);
    expect(find.text('Aktiv Pozuntular'), findsOneWidget);
    expect(find.text('B2B Lisenziya Gəliri'), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('mobile layout uses bottom navigation and switches tabs', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      size: const Size(390, 844),
      location: AppRoutes.dashboard,
    );

    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.tap(find.text('Skaner'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Mədəni nümunəni yükləyin'), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('scanner runs a demo sample end-to-end', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      size: const Size(1440, 1100),
      location: AppRoutes.scanner,
    );

    await tester.tap(find.text('midjourney_buta_pattern_v6.png'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('AI DNT Skanını Başlat'));
    // The demo pipeline paces ~12 steps; give it ample time plus the
    // delayed auto-open of the verdict dialog.
    for (int i = 0; i < 80; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('Müəllif Hüququ İddiası Qaldır'), findsOneWidget);
    expect(find.text('B2B Lisenziyası Al'), findsOneWidget);
    expect(find.textContaining('Şirvan Xalçaçılıq Məktəbi'), findsWidgets);

    await disposeApp(tester);
  });

  testWidgets('splash flows into onboarding', (WidgetTester tester) async {
    await pumpApp(tester, size: const Size(1280, 900));
    expect(find.textContaining('Rəqəmsal Mühafizəçisi'), findsOneWidget);

    // Pump at a realistic frame cadence through intro + hold + transition.
    for (int i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Keç'), findsOneWidget);
    expect(find.textContaining('Mədəni irsin rəqəmsal'), findsOneWidget);

    await disposeApp(tester);
  });
}
