// ignore_for_file: use_build_context_synchronously

import 'package:document_reader/src/bottombar/bloc/bottombar_bloc.dart';
import 'package:document_reader/src/bottombar/bloc/bottombar_state.dart';
import 'package:document_reader/src/home/home.dart';
import 'package:document_reader/src/img_editor/select_img.dart';
import 'package:document_reader/src/recognizer/display_text.dart';
import 'package:document_reader/src/settings/settings.dart';
import 'package:document_reader/utils/AppColors.dart';
import 'package:document_reader/utils/AppImages.dart';
import 'package:document_reader/utils/common_functions.dart';
import 'package:document_reader/utils/common_linear_gradient.dart';
import 'package:document_reader/utils/custom_snackbar.dart';
import 'package:document_reader/utils/logs.dart';
import 'package:document_reader/utils/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

import 'bloc/bottombar_event.dart';

bool show = true;

class BottomBarScreen extends StatefulWidget {
  final int? currentindex;

  const BottomBarScreen({
    super.key,
    this.currentindex,
  });

  static void showBottomBar({required bool showBottom, required BuildContext context}) {
    final _BottomBarScreenState? state = context.findAncestorStateOfType<_BottomBarScreenState>();

    state?.setState(() {
      show = showBottom;
    });
  }

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  final BottomBarBloc bottomBarBloc = BottomBarBloc();

  int currentIndex = 0;

  @override
  void initState() {
    setPageIndex(index: widget.currentindex);
    checkInternetConnection(context: context);
    super.initState();
  }

  setPageIndex({int? index}) {
    bottomBarBloc.add(GetPageIndexEvent(index: index ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      key: const Key('bottom-bar'),
      bloc: bottomBarBloc,
      listener: (BuildContext context, BottomBarState state) {
        if (state is GetPageIndexState) {
          currentIndex = state.index ?? 0;
        }
      },
      builder: (BuildContext context, BottomBarState state) {
        return Scaffold(
          key: UniqueKey(),
          body: currentIndex == 0 ? HomeScreen(onBackPress: () => setPageIndex(), showMenu: !show) : Setting(onBackPress: () => setPageIndex()),
          bottomNavigationBar: show
              ? BottomAppBar(
                  elevation: 0,
                  // height: 55.h,
                  notchMargin: 10.w,
                  color: ColorUtils.white,
                  padding: EdgeInsets.zero,
                  shadowColor: ColorUtils.white,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: const CircularNotchedRectangle(),
                  child: Container(
                    // height: 55.h,
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(color: ColorUtils.white),
                    child: BottomNavigationBar(
                      key: const Key("bottom-sheet"),
                      iconSize: 6.w,
                      elevation: 0.0,
                      currentIndex: currentIndex,
                      backgroundColor: ColorUtils.greyF4,
                      type: BottomNavigationBarType.fixed,
                      onTap: (index) => setPageIndex(index: index),
                      selectedLabelStyle: TextStyle(height: 1.3.h),
                      unselectedLabelStyle: TextStyle(height: 1.3.h),
                      items: [
                        BottomNavigationBarItem(
                          label: AppLocalizations.of(context)?.home ?? '',
                          icon: Image.asset(IconStrings.home, width: 20.w),
                          activeIcon: Image.asset(IconStrings.homeActive, width: 20.w),
                        ),
                        const BottomNavigationBarItem(icon: Icon(null), label: ''),
                        BottomNavigationBarItem(
                          label: AppLocalizations.of(context)?.setting ?? '',
                          icon: Image.asset(IconStrings.setting, width: 20.w),
                          activeIcon: Image.asset(IconStrings.settingActive, width: 20.w),
                        )
                      ],
                    ),
                  ),
                )
              : const SizedBox(),
          floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
          floatingActionButton: show
              ? Container(
                  decoration: BoxDecoration(
                    gradient: commonGradient(),
                    shape: BoxShape.circle,
                  ),
                  child: FloatingActionButton(
                    key: const Key('scan-bottom-sheet'),
                    elevation: 0,
                    highlightElevation: 0,
                    onPressed: () => scanBottomSheet(context: context),
                    shape: const CircleBorder(),
                    splashColor: ColorUtils.transparent,
                    backgroundColor: ColorUtils.transparent,
                    child: Image.asset(IconStrings.scanner, scale: 5.w),
                  ),
                )
              : const SizedBox(),
        );
      },
    );
  }

  scanBottomSheet({required BuildContext context}) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.w)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setStat) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18.w)),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Padding(
              padding: EdgeInsets.all(25.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    key: const Key("camera"),
                    AppLocalizations.of(context)?.camera ?? "",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 17.sp),
                  ),
                  SizedBox(height: 10.h),
                  SizedBox(
                    height: 35.h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        Row(
                          children: [
                            scanWidget(
                              name: AppLocalizations.of(context)?.scan ?? "",
                              image: IconStrings.scan,
                              key: 'scan',
                            ),
                            SizedBox(width: 20.w),
                            scanWidget(
                              name: AppLocalizations.of(context)?.ocr ?? "",
                              image: IconStrings.ocr,
                              key: 'ocr',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    AppLocalizations.of(context)?.convert ?? "",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 17.sp),
                  ),
                  SizedBox(height: 10.h),
                  scanWidget(
                    name: AppLocalizations.of(context)?.imageToPdf ?? "",
                    isPdf: true,
                    image: IconStrings.imageToPdf,
                    key: 'pdf',
                  )
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget scanWidget({
    required String key,
    required String name,
    required String image,
    bool? isPdf,
  }) {
    return InkWell(
      key: Key('btn-$key'),
      onTap: (isPdf ?? false)
          ? () async {
              try {
                await navigatorPush(context: context, navigate: const SelectImages());
                navigateBack(context: context);
              } catch (e) {
                logs(message: "Select Image navigate E:-----> $e");
              }
            }
          : () async {
              try {
                final s = await checkInternetConnection(context: context);
                if (s == false) {
                  showSnackBar(message: 'no internet connection', errorSnackBar: true, context: context);
                  return;
                }

                final source = name == (AppLocalizations.of(context)?.scan ?? "") ? ImageSource.camera : ImageSource.gallery;
                final path = await ImagePicker().pickImage(source: source);

                if (path != null) {
                  final textRecognizer = TextRecognizer();
                  final RecognizedText recognizedText = await textRecognizer.processImage(InputImage.fromFilePath(path.path));
                  textRecognizer.close();

                  navigateBack(context: context);

                  if (recognizedText.text.isNotEmpty) {
                    navigatorPush(context: context, navigate: DisplayText(text: recognizedText.text));
                  } else {
                    showSnackBar(message: AppLocalizations.of(context)?.somethingWentWrong ?? "", context: context);
                  }
                } else {
                  navigateBack(context: context);
                }
              } catch (e) {
                showSnackBar(
                  context: context,
                  message: AppLocalizations.of(context)?.failedToScan ?? "",
                  errorSnackBar: true,
                );
              }
            },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.w),
        child: Container(
          height: 40.h,
          width: (isPdf ?? false) == true ? double.infinity : null,
          color: ColorUtils.greyF4,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Image.asset(image, scale: 5.w),
              ),
              Text(
                name,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 16.sp),
              ),
              SizedBox(width: 10.w)
            ],
          ),
        ),
      ),
    );
  }
}
