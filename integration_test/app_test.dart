// import 'package:document_reader/app_theme.dart';
// import 'package:document_reader/main.dart' as app;
// import 'package:document_reader/src/bottombar/bottombar.dart';
// import 'package:document_reader/src/home/home.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:integration_test/integration_test.dart';
// import 'package:mockito/mockito.dart';
//
// class MockNavigatorObserver extends Mock implements NavigatorObserver {}
//
// void main() {
//   IntegrationTestWidgetsFlutterBinding.ensureInitialized();
//   app.main();
//
//   /// Onboarding Testing
//   testWidgets("Onboarding Testing", (WidgetTester tester) async {
//     final mockNavigator = MockNavigatorObserver();
//     await tester.pumpWidget(ScreenUtilInit(
//       builder: (_, __) => MaterialApp(
//         theme: AppTheme.lightTheme(),
//         navigatorObservers: [mockNavigator],
//         home: const BottomBarScreen(currentindex: 0),
//         supportedLocales: AppLocalizations.supportedLocales,
//         localizationsDelegates: AppLocalizations.localizationsDelegates,
//       ),
//     ));
//
//     final HomeScreenState homeState = tester.state(find.byType(HomeScreen));
//
//     await tester.tap(find.byKey(Key(AppLocalizations.of(homeState.context)?.recent ?? '')));
//
//     await tester.pumpAndSettle(const Duration(seconds: 2));
//
//     if (homeState.recentList.isEmpty) {
//       print('no recent data');
//       expect(find.byKey(const Key('no data')), findsOneWidget);
//     } else {
//       print('recent data');
//     }
//   });
// }
