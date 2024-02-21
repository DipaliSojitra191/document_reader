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
import 'package:document_reader/utils/custom_data/custom_bottomsheet.dart';
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

class BottomBar extends StatefulWidget {
  final int currentindex;

  const BottomBar({
    super.key,
    required this.currentindex,
  });

  static void changeBottom(BuildContext context, bool showBottom) {
    _BottomBarState? state = context.findAncestorStateOfType<_BottomBarState>();

    state?.setState(() {
      show = showBottom;
    });
  }

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  final BottomBarBloc bottomBarBloc = BottomBarBloc();

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    setPageIndex(index: widget.currentindex);
    checkInternetConnection();
  }

  setPageIndex({int? index}) {
    bottomBarBloc.add(GetPageIndexEvent(index: index ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: bottomBarBloc,
      listener: (context, state) {
        if (state is GetPageIndexState) {
          currentIndex = state.index ?? 0;
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: currentIndex == 0 ? Home(onBackPress: () => setPageIndex(), showMenu: !show) : Setting(onBackPress: () => setPageIndex()),
          bottomNavigationBar: show
              ? BottomAppBar(
                  elevation: 0,
                  height: 55.h,
                  notchMargin: 10.w,
                  color: ColorUtils.white,
                  padding: EdgeInsets.zero,
                  shadowColor: ColorUtils.white,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: const CircularNotchedRectangle(),
                  child: Container(
                    height: 55.h,
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(color: ColorUtils.white),
                    child: BottomNavigationBar(
                      iconSize: 6.w,
                      elevation: 0.0,
                      currentIndex: currentIndex,
                      backgroundColor: ColorUtils.greyF4,
                      type: BottomNavigationBarType.fixed,
                      onTap: (index) => setPageIndex(index: index),
                      selectedLabelStyle: TextStyle(fontSize: 12.sp, height: 1.3.h),
                      unselectedLabelStyle: TextStyle(fontSize: 12.sp, height: 1.3.h),
                      items: [
                        BottomNavigationBarItem(
                          label: AppLocalizations.of(currentContext)!.home,
                          icon: Image.asset(IconStrings.home, width: 20.w),
                          activeIcon: Image.asset(IconStrings.homeActive, width: 20.w),
                        ),
                        const BottomNavigationBarItem(icon: Icon(null), label: ''),
                        BottomNavigationBarItem(
                          label: AppLocalizations.of(currentContext)!.setting,
                          icon: Image.asset(IconStrings.setting, width: 20.w),
                          activeIcon: Image.asset(IconStrings.settingActive, width: 20.w),
                        )
                      ],
                    ),
                  ),
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
          floatingActionButton: show
              ? Container(
                  decoration: BoxDecoration(
                    gradient: commonGradient(),
                    shape: BoxShape.circle,
                  ),
                  child: FloatingActionButton(
                    elevation: 0,
                    highlightElevation: 0,
                    onPressed: scanBottomSheet,
                    shape: const CircleBorder(),
                    splashColor: ColorUtils.transparent,
                    backgroundColor: ColorUtils.transparent,
                    child: Image.asset(IconStrings.scanner, scale: 5.w),
                  ),
                )
              : null,
        );
      },
    );
  }

  scanBottomSheet() {
    modalBottomSheet(
      child: StatefulBuilder(builder: (context, setStat) {
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
                  AppLocalizations.of(currentContext)!.camera,
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
                            name: AppLocalizations.of(currentContext)!.scan,
                            image: IconStrings.scan,
                          ),
                          SizedBox(width: 20.w),
                          scanWidget(
                            name: AppLocalizations.of(currentContext)!.ocr,
                            image: IconStrings.ocr,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  AppLocalizations.of(currentContext)!.convert,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 17.sp),
                ),
                SizedBox(height: 10.h),
                scanWidget(
                  name: AppLocalizations.of(context)!.imageToPdf,
                  isPdf: true,
                  image: IconStrings.imageToPdf,
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget scanWidget({
    required String name,
    required String image,
    bool? isPdf,
  }) {
    return InkWell(
      onTap: (isPdf ?? false)
          ? () async {
              try {
                final s = await checkInternetConnection();
                if (s == false) {
                  return;
                }

                await navigatorPush(const SelectImages());
                navigateBack();
              } catch (e) {
                logs(message: "Select Image navigate E:-----> $e");
              }
            }
          : () async {
              try {
                final s = await checkInternetConnection();
                if (s == false) {
                  showSnackBar(message: 'no internet connection', errorSnackBar: true);
                  return;
                }

                final source = name == AppLocalizations.of(currentContext)!.scan ? ImageSource.camera : ImageSource.gallery;
                final path = await ImagePicker().pickImage(source: source);

                if (path != null) {
                  final textRecognizer = TextRecognizer();
                  final RecognizedText recognizedText = await textRecognizer.processImage(InputImage.fromFilePath(path.path));
                  textRecognizer.close();

                  navigateBack();

                  if (recognizedText.text.isNotEmpty) {
                    navigatorPush(DisplayText(text: recognizedText.text));
                  } else {
                    showSnackBar(message: AppLocalizations.of(context)!.somethingWentWrong);
                  }
                } else {
                  navigateBack();
                }
              } catch (e) {
                showSnackBar(
                  message: AppLocalizations.of(context)!.failedToScan,
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
                style: Theme.of(currentContext).textTheme.displaySmall?.copyWith(fontSize: 16.sp),
              ),
              SizedBox(width: 10.w)
            ],
          ),
        ),
      ),
    );
  }
}
