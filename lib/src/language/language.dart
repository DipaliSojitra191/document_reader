import 'package:document_reader/src/bottombar/bottombar.dart';
import 'package:document_reader/src/language/bloc/language_bloc.dart';
import 'package:document_reader/src/language/bloc/language_event.dart';
import 'package:document_reader/src/language/bloc/language_state.dart';
import 'package:document_reader/utils/AppColors.dart';
import 'package:document_reader/utils/AppImages.dart';
import 'package:document_reader/utils/Lists.dart';
import 'package:document_reader/utils/common_appbar.dart';
import 'package:document_reader/utils/common_functions.dart';
import 'package:document_reader/utils/common_linear_gradient.dart';
import 'package:document_reader/utils/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Language extends StatefulWidget {
  const Language({super.key});

  @override
  State<Language> createState() => LanguageState();
}

class LanguageState extends State<Language> {
  final LanguageBloc languageBloc = LanguageBloc();
  String selected = languageList[0].title;

  @override
  void initState() {
    super.initState();

    checkInternetConnection(context: context);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      languageBloc.add(SetLanguageEvent());
    });
  }

  languageOnTap(String title) {
    languageBloc.add(SetLanguageEvent(title: title));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: languageBloc,
      listener: (context, LanguageBlocState state) {
        if (state is SetLanguageState) {
          selected = state.language;
        }
      },
      builder: (context, state) {
        return Scaffold(
          key: const Key("language"),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 1),
            child: CustomAppbar(
              key: const Key("languageAppBar"),
              title: AppLocalizations.of(context)?.language ?? '',
              onPress: () => removeRoute(const BottomBarScreen(currentindex: 2), context: context),
            ),
          ),
          body: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: languageList.length,
            itemBuilder: (context, index) {
              String title = languageList[index].title;
              String image = languageList[index].img;
              return Padding(
                padding: EdgeInsets.all(8.h),
                child: InkWell(
                  key: Key(title),
                  onTap: () => languageOnTap(title),
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: commonGradient(),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          IconStrings.languageImages(image),
                          height: 40.sp,
                          width: 40.sp,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: ColorUtils.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: const BoxDecoration(shape: BoxShape.circle),
                          padding: EdgeInsets.all(2.r),
                          child: Image.asset(
                            selected == title ? IconStrings.selected : IconStrings.unselected,
                            width: 20.w,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
