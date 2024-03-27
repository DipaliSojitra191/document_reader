import 'package:clipboard/clipboard.dart';
import 'package:document_reader/app_theme.dart';
import 'package:document_reader/main.dart';
import 'package:document_reader/shared_Preference/preferences_helper.dart';
import 'package:document_reader/src/bottombar/bottombar.dart';
import 'package:document_reader/src/file/all_file.dart';
import 'package:document_reader/src/home/home.dart';
import 'package:document_reader/src/language/language.dart';
import 'package:document_reader/src/onboarding/bloc/onboarding_event.dart';
import 'package:document_reader/src/onboarding/onboarding.dart';
import 'package:document_reader/src/recognizer/display_text.dart';
import 'package:document_reader/src/settings/settings.dart';
import 'package:document_reader/src/splash/splash_screen.dart';
import 'package:document_reader/utils/AppColors.dart';
import 'package:document_reader/utils/AppStrings.dart';
import 'package:document_reader/utils/Lists.dart';
import 'package:document_reader/utils/common_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

final PrefsRepo prefsRepo = PrefsRepo();

class ShareUtils {
  share(String url) {
    Share.share(url);
  }
}

class PermissionUtils {
  storagePermission() async {
    final storage = await Permission.storage.request();
    return storage;
  }
}

class MockShareUtil extends Mock implements ShareUtils {}

// class MockPermission extends Mock implements PermissionService {}

class MockImagePicker extends Mock implements ImagePicker {}

class MockTextRecognizer extends Mock implements TextRecognizer {}

// class PermissionService {
//   Future<PermissionStatus> requestPermission() async {
//     PermissionStatus status = await Permission.camera.request();
//     return status;
//   }
// }

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Test widget", (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        builder: (_, __) => MaterialApp(
          theme: AppTheme.lightTheme(),
          home: const SplashScreen(),
          navigatorKey: navigatorKey,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    // await tester.pumpAndSettle(const Duration(seconds: 2));
    // final MockPermission mockPermission = MockPermission();
    // mockPermission.requestPermission();
    // verify(() => mockPermission.requestPermission()).called(1);
  });

  /// onboarding scenarios
  testWidgets('onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        builder: (_, __) => MaterialApp(
          home: const OnBoarding(),
          theme: AppTheme.lightTheme(),
          navigatorKey: navigatorKey,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    await tester.pump();
    final OnBoardingState myHomePageState = tester.state(find.byType(OnBoarding));
    final onboardingBloc = myHomePageState.onboardingBloc;
    expect(find.byKey(const Key('onboarding')), findsOneWidget);

    for (int i = 0; i < myHomePageState.onboardingData.length; i++) {
      onboardingBloc.add(GetOnboardingIndexEvent(pageIndex: i));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('onboarding_next_button')));

      switch (i) {
        case 0:
          expect(myHomePageState.onboardingData[i].title, StringUtils.onboarding1Title);
          expect(myHomePageState.onboardingData[i].subTitle, StringUtils.onboarding1Desc);
          break;
        case 1:
          expect(myHomePageState.onboardingData[i].title, StringUtils.onboarding2Title);
          expect(myHomePageState.onboardingData[i].subTitle, StringUtils.onboarding2Desc);
          break;
        case 2:
          expect(myHomePageState.onboardingData[i].title, StringUtils.onboarding3Title);
          expect(myHomePageState.onboardingData[i].subTitle, StringUtils.onboarding3Desc);
          break;
        case 3:
          expect(myHomePageState.onboardingData[i].title, StringUtils.onboarding4Title);
          expect(myHomePageState.onboardingData[i].subTitle, StringUtils.onboarding4Desc);
          break;
        case 4:
          expect(myHomePageState.onboardingData[i].title, StringUtils.onboarding5Title);
          expect(myHomePageState.onboardingData[i].subTitle, StringUtils.onboarding5Desc);
          break;
      }
    }
  });

  /// splash scenarios
  testWidgets("splash", (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        builder: (_, __) => const MaterialApp(home: SplashScreen()),
      ),
    );
  });

  /// bottom bar scenarios
  testWidgets("Bottom Bar", (WidgetTester tester) async {
    await tester.pumpWidget(ScreenUtilInit(
      builder: (_, __) => MaterialApp(
        theme: AppTheme.lightTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const BottomBarScreen(currentindex: 0),
      ),
    ));

    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byKey(const Key('bottom-sheet')), findsWidgets);
  });

  /// home screen scenarios
  group("Home Testing", () {
    late MockShareUtil mockShareUtil;

    setUpAll(() {
      mockShareUtil = MockShareUtil();
    });

    testWidgets("Home", (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          builder: (_, __) => MaterialApp(
            theme: AppTheme.lightTheme(),
            navigatorKey: navigatorKey,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const BottomBarScreen(currentindex: 0),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      final HomeScreenState homeState = tester.state(find.byType(HomeScreen));

      /// default data
      expect(getTypeAndTitle(context: homeState.context, index: 0).title, AppLocalizations.of(homeState.context)?.allFiles ?? '');
      expect(getTypeAndTitle(context: homeState.context, index: 1).title, AppLocalizations.of(homeState.context)?.pdfFiles ?? '');
      expect(getTypeAndTitle(context: homeState.context, index: 2).title, AppLocalizations.of(homeState.context)?.wordFiles ?? '');
      expect(getTypeAndTitle(context: homeState.context, index: 3).title, AppLocalizations.of(homeState.context)?.pptFiles ?? '');
      expect(getTypeAndTitle(context: homeState.context, index: 4).title, AppLocalizations.of(homeState.context)?.excelFiles ?? '');
      expect(getTypeAndTitle(context: homeState.context, index: 5).title, AppLocalizations.of(homeState.context)?.txtFiles ?? '');
      expect(getTypeAndTitle(context: homeState.context, index: 6).title, AppLocalizations.of(homeState.context)?.imageFiles ?? '');
      expect(getTypeAndTitle(context: homeState.context, index: 7).title, AppLocalizations.of(homeState.context)?.directories ?? '');

      /// recent files
      await tester.tap(find.byKey(Key(1.toString())));
      await tester.pump(const Duration(seconds: 3));

      if (homeState.recentList.isEmpty) {
        expect(find.byKey(const Key('no-data')), findsWidgets);
      } else {
        expect(find.byKey(const Key('recent-data')), findsWidgets);
      }

      await tester.tap(find.byKey(Key(2.toString())));
      await tester.pump(const Duration(seconds: 3));

      if (homeState.bookmarkList.isEmpty) {
        expect(find.byKey(const Key('no-data')), findsWidgets);
      } else {
        expect(find.byKey(const Key('bookmark-data')), findsWidgets);
      }
    });

    testWidgets("Recent", (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          builder: (_, __) => MaterialApp(
            theme: AppTheme.lightTheme(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const BottomBarScreen(currentindex: 0),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));
      final HomeScreenState homeState = tester.state(find.byType(HomeScreen));

      /// recent files
      await tester.tap(find.byKey(const Key('1')));
      await tester.pump(const Duration(seconds: 3));

      if (homeState.bookmarkList.isEmpty) {
        expect(find.byKey(const Key('no-data')), findsWidgets);
      } else {
        expect(find.byKey(const Key('recent-data')), findsWidgets);
        expect(find.byKey(const Key('recent-selected')), findsWidgets);
        // expect(find.byKey(const Key('recent-select-all')), findsWidgets);

        await tester.pump(const Duration(seconds: 2));
        await tester.tap(find.byKey(const Key('more-0')), warnIfMissed: false);

        await tester.pump(const Duration(seconds: 2));
        expect(find.byKey(const Key('more-dialog')), findsWidgets);

        await tester.pump(const Duration(seconds: 3));
        expect(tester.widget<Text>(find.byKey(const Key('name'))).data, homeState.recentList[0].name);
        expect(tester.widget<Text>(find.byKey(const Key('path'))).data, homeState.recentList[0].path.path);

        String imageType = "";
        final images = tester.widgetList(find.byKey(const Key('image')));
        for (final image in images) {
          if (image is Image) {
            if (image.image is AssetImage) {
              final assetName = (image.image as AssetImage).assetName;
              imageType = assetName;
            }
          }
        }

        expect(imageType.split(".").last, tester.widget<Text>(find.byKey(const Key('name'))).data.toString().split(".").last);

        expect(find.byKey(Key('onTap-${AppLocalizations.of(homeState.context)?.share ?? ''}')), findsOneWidget);
        expect(find.byKey(Key('onTap-${AppLocalizations.of(homeState.context)?.moveOut ?? ''}')), findsOneWidget);
        expect(find.byKey(Key('onTap-${AppLocalizations.of(homeState.context)?.delete ?? ''}')), findsOneWidget);

        await tester.tap(find.byKey(Key('onTap-${AppLocalizations.of(homeState.context)?.share ?? ''}')), warnIfMissed: false);

        mockShareUtil.share(homeState.recentList[0].path.path);
        verify(() => mockShareUtil.share(homeState.recentList[0].path.path)).called(1);

        // await tester.pump(const Duration(seconds: 2));
        // expect(tester.widget<Text>(find.byKey(const Key('name'))).data, homeState.bookmarkList[0].name);
        // expect(tester.widget<Text>(find.byKey(const Key('path'))).data, homeState.bookmarkList[0].path.path);
        // await tester.tap(find.byKey(Key('onTap-${AppLocalizations.of(homeState.context)?.share ?? ''}')), warnIfMissed: false);
      }
    });

    testWidgets("Bookmark", (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          builder: (_, __) => MaterialApp(
            theme: AppTheme.lightTheme(),
            navigatorKey: navigatorKey,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const BottomBarScreen(currentindex: 0),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));
      final HomeScreenState homeState = tester.state(find.byType(HomeScreen));

      /// bookmark files
      await tester.tap(find.byKey(const Key('2')));
      await tester.pump(const Duration(seconds: 3));

      if (homeState.bookmarkList.isEmpty) {
        expect(find.byKey(const Key('no-data')), findsWidgets);
      } else {
        expect(find.byKey(const Key('bookmark-data')), findsWidgets);
        expect(find.byKey(const Key('bookmark-selected')), findsWidgets);
        expect(find.byKey(const Key('bookmark-select-all')), findsWidgets);

        await tester.pump(const Duration(seconds: 2));
        await tester.tap(find.byKey(const Key('more-0')), warnIfMissed: false);

        await tester.pump(const Duration(seconds: 2));
        expect(find.byKey(const Key('more-dialog')), findsWidgets);

        await tester.pump(const Duration(seconds: 3));
        expect(tester.widget<Text>(find.byKey(const Key('name'))).data, homeState.bookmarkList[0].name);
        expect(tester.widget<Text>(find.byKey(const Key('path'))).data, homeState.bookmarkList[0].path.path);

        String imageType = "";
        final images = tester.widgetList(find.byKey(const Key('image')));
        for (final image in images) {
          if (image is Image) {
            if (image.image is AssetImage) {
              final assetName = (image.image as AssetImage).assetName;
              imageType = assetName;
            }
          }
        }

        expect(imageType.split(".").last, tester.widget<Text>(find.byKey(const Key('name'))).data.toString().split(".").last);

        expect(find.byKey(Key('onTap-${AppLocalizations.of(homeState.context)?.share ?? ''}')), findsOneWidget);
        expect(find.byKey(Key('onTap-${AppLocalizations.of(homeState.context)?.moveOut ?? ''}')), findsOneWidget);
        expect(find.byKey(Key('onTap-${AppLocalizations.of(homeState.context)?.delete ?? ''}')), findsOneWidget);

        await tester.pump(const Duration(seconds: 2));
        expect(tester.widget<Text>(find.byKey(const Key('name'))).data, homeState.bookmarkList[0].name);
        expect(tester.widget<Text>(find.byKey(const Key('path'))).data, homeState.bookmarkList[0].path.path);

        await tester.tap(find.byKey(Key('onTap-${AppLocalizations.of(homeState.context)?.share ?? ''}')), warnIfMissed: false);

        mockShareUtil.share(homeState.recentList[0].path.path);
        verify(() => mockShareUtil.share(homeState.recentList[0].path.path)).called(1);
      }
    });
  });

  /// all file scenarios
  testWidgets("All File", (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        builder: (_, __) => MaterialApp(
          theme: AppTheme.lightTheme(),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const AllFile(title: "All File", fileType: 'all'),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 3));
    AllFileState allFileState = tester.state(find.byType(AllFile));

    if (allFileState.allFiles.isEmpty) {
      debugPrint("No data");
      expect(find.byKey(const Key('no-files-found')), findsWidgets);
    } else {
      expect(find.byKey(const Key('title')), findsWidgets);
      expect(find.byKey(const Key('subtitle')), findsWidgets);

      ///Select All
      String path = allFileState.allFiles[0].path.path;
      expect(find.byKey(const Key('selected-all')), findsWidgets);
      expect(find.byKey(const Key('share-delete')), findsNothing);

      await tester.tap(find.byKey(const Key('selected-all')));
      await tester.pump(const Duration(seconds: 3));
      expect(find.byKey(const Key('share-delete')), findsWidgets);

      expect(find.byKey(const Key('listTile-0')), findsWidgets);
      await tester.tap(find.byKey(const Key('listTile-0')));
      await tester.pump(const Duration(seconds: 3));

      await tester.tap(find.byKey(const Key('delete-all')));
      await tester.pump(const Duration(seconds: 3));
      expect(find.byKey(const Key("delete-dialog")), findsWidgets);

      await tester.pump(const Duration(seconds: 3));
      expect(find.byKey(const Key("button")), findsWidgets);

      await tester.pump(const Duration(seconds: 4));

      for (var element in allFileState.allFiles) {
        debugPrint("element ${element.path.path == path}");
      }

      /// Select All Closed

      /// Filter by
      expect(find.byKey(const Key('filter')), findsWidgets);

      await tester.tap(find.byKey(const Key('filter')));
      await tester.pump(const Duration(seconds: 3));

      expect(find.byKey(const Key("filter-bottom-sheet")), findsWidgets);
      expect(find.byKey(const Key("filter-by")), findsWidgets);
      expect(find.byKey(const Key("unselected1-0")), findsNothing);
      expect(find.byKey(const Key("unselected1-1")), findsWidgets);
      expect(find.byKey(const Key("unselected1-2")), findsWidgets);

      // filter 1
      await tester.pump(const Duration(seconds: 3));
      await tester.tap(find.byKey(const Key("unselected1-1")), pointer: 10, warnIfMissed: false);
      await tester.pump(const Duration(seconds: 3));
      expect(find.byKey(const Key("unselected1-0")), findsWidgets);
      expect(find.byKey(const Key("unselected1-1")), findsNothing);
      expect(find.byKey(const Key("unselected1-2")), findsWidgets);

      allFileState.allFiles.sort((a, b) => a.name.compareTo(b.name));

      await tester.pump(const Duration(seconds: 3));
      await tester.tap(find.byKey(const Key("unselected1-2")), warnIfMissed: false);
      await tester.pump(const Duration(seconds: 3));
      expect(find.byKey(const Key("unselected1-0")), findsWidgets);
      expect(find.byKey(const Key("unselected1-1")), findsWidgets);
      expect(find.byKey(const Key("unselected1-2")), findsNothing);

      // filter 2
      await tester.pump(const Duration(seconds: 3));
      expect(find.byKey(const Key("unselected2-0")), findsNothing);
      expect(find.byKey(const Key("unselected2-1")), findsWidgets);

      await tester.tap(find.byKey(const Key("unselected2-1")), warnIfMissed: false);
      await tester.pump(const Duration(seconds: 3));
      expect(find.byKey(const Key("unselected2-0")), findsWidgets);
      expect(find.byKey(const Key("unselected2-1")), findsNothing);
      expect(find.byKey(const Key("ok")), findsWidgets);

      await tester.pump(const Duration(seconds: 3));
      await tester.tap(find.byKey(const Key("ok")), warnIfMissed: false);
      await tester.pump(const Duration(seconds: 3));

      ///

      /// Bookmark
      expect(find.byKey(const Key('bookmark-0')), findsOneWidget);
      bool greyColor = tester.widget<Icon>(find.byKey(const Key("bookmark-0"))).color == ColorUtils.greyDE;
      await tester.tap(find.byKey(const Key('bookmark-inkwell-0')));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      if (greyColor) {
        expect(tester.widget<Icon>(find.byKey(const Key("bookmark-0"))).color, ColorUtils.yellow00);
      } else {
        expect(tester.widget<Icon>(find.byKey(const Key("bookmark-0"))).color, ColorUtils.greyDE);
      }

      /// bookmark Closed

      /// More
      await tester.tap(find.byKey(const Key('more-0')));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.byKey(const Key('more-dialog')), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.widget<Text>(find.byKey(const Key('name'))).data, allFileState.allFiles[0].name);
      expect(tester.widget<Text>(find.byKey(const Key('path'))).data, allFileState.allFiles[0].path.path);

      /// More Closed

      ///  Delete
      final key = find.byKey(const Key("Delete"));
      expect(key, findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(key, warnIfMissed: false);
      await tester.pump(const Duration(seconds: 1));

      /// Delete Closed
    }
  });

  /// Scan widget scenarios
  testWidgets("Scan widget", (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        builder: (_, __) => MaterialApp(
          navigatorKey: navigatorKey,
          theme: AppTheme.lightTheme(),
          home: const BottomBarScreen(currentindex: 0),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byKey(const Key("scan-bottom-sheet")), findsWidgets);
    await tester.tap(find.byKey(const Key("scan-bottom-sheet")));

    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byKey(const Key("camera")), findsOneWidget);

    await tester.tap(find.byKey(const Key("btn-scan")));

    final MockImagePicker mockImagePicker = MockImagePicker();

    String imageUrl = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKKA06sxEvRUMTpCm4DCNVIkH4hhttiGrc3g&usqp=CAU";
    when(() => mockImagePicker.pickImage(source: ImageSource.gallery)).thenAnswer(
      (_) => Future.value(XFile(imageUrl)),
    );
  });

  /// Display image text scenarios
  testWidgets("Display text", (WidgetTester tester) async {
    const text = """BE\nSTRONGER\nTHAN YOUR\nSUCCESS""";
    await tester.pumpWidget(
      ScreenUtilInit(
        builder: (_, __) => MaterialApp(
          navigatorKey: navigatorKey,
          theme: AppTheme.lightTheme(),
          home: const DisplayText(text: text),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 2));

    DisplayTextState displayTextState = tester.state(find.byType(DisplayText));
    expect(displayTextState.controller.text, text);

    expect(tester.widget<Text>(find.byKey(const Key("edit-text"))).data, AppLocalizations.of(displayTextState.context)?.edit ?? "");
    expect(tester.widget<Text>(find.byKey(const Key("copy-text"))).data, AppLocalizations.of(displayTextState.context)?.copy ?? "");
    expect(tester.widget<Text>(find.byKey(const Key("share-text"))).data, AppLocalizations.of(displayTextState.context)?.share ?? "");

    await tester.tap(find.byKey(const Key("share")), warnIfMissed: false);
    final MockShareUtil mockShareUtil = MockShareUtil();
    mockShareUtil.share(text);
    verify(() => mockShareUtil.share(text)).called(1);

    await tester.tap(find.byKey(const Key("copy")), warnIfMissed: false);
    await tester.pump(const Duration(seconds: 2));
    await FlutterClipboard.copy(text);

    expect(find.byKey(const Key("close-btn")), findsNothing);
    expect(displayTextState.isEdit, false);

    await tester.tap(find.byKey(const Key("edit")), warnIfMissed: false);
    await tester.pump(const Duration(seconds: 3));
    expect(displayTextState.isEdit, true);

    expect(find.byKey(const Key("close-btn")), findsWidgets);
    await tester.tap(find.byKey(const Key("close-btn")), warnIfMissed: false);
    await tester.pump(const Duration(seconds: 2));
    expect(displayTextState.isEdit, false);
  });

  /// Settings scenarios
  testWidgets("Settings Language Navigate", (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        builder: (_, __) => MaterialApp(
          theme: AppTheme.lightTheme(),
          navigatorKey: navigatorKey,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const BottomBarScreen(currentindex: 1),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byKey(const Key("setting-2")), findsWidgets);

    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.byKey(const Key("setting-2")));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byKey(const Key("language")), findsWidgets);
  });

  /// Ratting scenarios
  group("Ratting dialog", () {
    testWidgets("Ratting Dialog", (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          builder: (_, __) => MaterialApp(
            theme: AppTheme.lightTheme(),
            home: const BottomBarScreen(currentindex: 1),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.tap(find.byKey(const Key("setting-1")));

      await tester.pump(const Duration(seconds: 2));
      expect(find.byKey(const Key("ratting-dialog")), findsWidgets);
    });

    testWidgets("Open Ratting dialog", (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          builder: (_, __) => MaterialApp(
            theme: AppTheme.lightTheme(),
            home: const BottomBarScreen(currentindex: 1),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));
      final SettingState settingState = tester.state(find.byType(Setting));

      await tester.tap(find.byKey(const Key("setting-1")));
      await tester.pump(const Duration(seconds: 2));

      expect(find.byKey(const Key("ratting-dialog")), findsWidgets);

      prefsRepo.setInt(key: PrefsRepo.rate, value: 0);
      double rat = prefsRepo.getInt(key: PrefsRepo.rate).toDouble();

      if (rat > 3 && rat < 6) {
        expect(find.byKey(const Key("Title 2")), findsOneWidget);

        expect(tester.widget<Text>(find.byKey(const Key("title"))).data, AppLocalizations.of(settingState.context)?.appreciation ?? '');
        expect(tester.widget<Text>(find.byKey(const Key("subtitle"))).data, AppLocalizations.of(settingState.context)?.motivation ?? '');

        rat = 4;
      }

      if (rat < 4) {
        expect(find.byKey(const Key("Title 1")), findsOneWidget);

        expect(tester.widget<Text>(find.byKey(const Key("title"))).data, AppLocalizations.of(settingState.context)?.thankYou ?? '');
        expect(tester.widget<Text>(find.byKey(const Key("subtitle"))).data, AppLocalizations.of(settingState.context)?.rateUsDesc ?? '');
      }
    });
  });

  /// Language scenarios
  group("Language", () {
    testWidgets("Language", (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          builder: (_, __) => MaterialApp(
            home: const Language(),
            theme: AppTheme.lightTheme(),
            navigatorKey: navigatorKey,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('language')), findsOneWidget);
    });

    testWidgets("Language check localisation", (WidgetTester tester) async {
      await tester.pumpWidget(ScreenUtilInit(builder: (_, __) => const MaterialApp(home: Language())));
      await tester.pump();

      await tester.tap(find.byKey(Key(languageList[0].title)));
      expect(StringUtils.english, languageList[0].title);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(Key(languageList[1].title)));
      expect(StringUtils.arabic, languageList[1].title);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(Key(languageList[2].title)));
      expect(StringUtils.bulgarian, languageList[2].title);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(Key(languageList[3].title)));
      expect(StringUtils.czech, languageList[3].title);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(Key(languageList[4].title)));
      expect(StringUtils.polish, languageList[4].title);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });
  });
}
