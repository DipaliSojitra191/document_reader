import 'package:document_reader/shared_Preference/preferences_helper.dart';
import 'package:document_reader/src/onboarding/bloc/onboarding_bloc.dart';
import 'package:document_reader/src/onboarding/bloc/onboarding_event.dart';
import 'package:document_reader/src/onboarding/bloc/onboarding_state.dart';
import 'package:document_reader/src/onboarding/model/onboarding_model.dart';
import 'package:document_reader/src/splash/splash_Screen.dart';
import 'package:document_reader/utils/AppColors.dart';
import 'package:document_reader/utils/AppStrings.dart';
import 'package:document_reader/utils/common_functions.dart';
import 'package:document_reader/utils/common_linear_gradient.dart';
import 'package:document_reader/utils/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  final PrefsRepo prefsRepo = PrefsRepo();
  final PageController _pageController = PageController();
  @override
  void initState() {
    super.initState();
    checkInternetConnection();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<OnboardingModel> onboardingData = [
    OnboardingModel(
      title: StringUtils.onboarding1Title,
      subTitle: StringUtils.onboarding1Desc,
    ),
    OnboardingModel(
      title: StringUtils.onboarding2Title,
      subTitle: StringUtils.onboarding2Desc,
    ),
    OnboardingModel(
      title: StringUtils.onboarding3Title,
      subTitle: StringUtils.onboarding3Desc,
    ),
    OnboardingModel(
      title: StringUtils.onboarding4Title,
      subTitle: StringUtils.onboarding4Desc,
    ),
    OnboardingModel(
      title: StringUtils.onboarding5Title,
      subTitle: StringUtils.onboarding5Desc,
    ),
  ];
  int currentPageIndex = 0;
  final OnboardingBloc onboardingBloc = OnboardingBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc(),
      child: BlocConsumer(
        bloc: onboardingBloc,
        listener: (context, OnboardingState state) {
          if (state is GetOnboardingIndexState) {
            currentPageIndex = state.pageIndex ?? 0;
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: onboardingData.length,
                      onPageChanged: (int index) {
                        onboardingBloc.add(GetOnboardingIndexEvent(pageIndex: index));
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.h),
                          child: Column(
                            children: [
                              Text(
                                onboardingData[index].title,
                                style: Theme.of(context).textTheme.displayMedium?.copyWith(color: ColorUtils.blueCFF),
                              ),
                              const Spacer(),
                              SizedBox(
                                height: 280.h,
                                width: 280.h,
                                child: Image.asset("assets/onboarding/${index + 1}.png"),
                              ),
                              const Spacer(),
                              SizedBox(
                                height: 70.h,
                                child: Text(
                                  onboardingData[index].subTitle,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 18.sp),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 25.w),
                    height: 130.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        currentPageIndex == 0
                            ? SizedBox(height: 40.h, width: 40.h)
                            : InkWell(
                                onTap: () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeIn,
                                  );
                                },
                                child: Container(
                                  height: 40.h,
                                  width: 40.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ColorUtils.greyE4,
                                  ),
                                  child: RotatedBox(
                                    quarterTurns: 2,
                                    child: Icon(
                                      Icons.play_arrow_rounded,
                                      color: ColorUtils.grey98,
                                    ),
                                  ),
                                ),
                              ),
                        const Spacer(),
                        Column(
                          children: [
                            showCurrentDots(),
                          ],
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                            if ((onboardingData.length - 1) == currentPageIndex) {
                              prefsRepo.setBool(
                                key: PrefsRepo.onboarding,
                                value: true,
                              );
                              navigatorPush(const SplashScreen());
                            }
                          },
                          child: Container(
                            height: 40.h,
                            width: 40.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: commonGradient(),
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: ColorUtils.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // color: Colors.red,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget showCurrentDots() {
    return Expanded(
      child: ListView.builder(
        itemCount: 5,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (c, i) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Container(
              height: 12.w,
              width: 12.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: currentPageIndex == i ? commonGradient() : null,
                color: currentPageIndex == i ? null : ColorUtils.greyE4,
              ),
            ),
          );
        },
      ),
    );
  }
}
