import 'package:document_reader/shared_Preference/preferences_helper.dart';
import 'package:document_reader/src/language/language.dart';
import 'package:document_reader/src/settings/model/setting_model.dart';
import 'package:document_reader/utils/AppColors.dart';
import 'package:document_reader/utils/AppImages.dart';
import 'package:document_reader/utils/common_functions.dart';
import 'package:document_reader/utils/custom_btn.dart';
import 'package:document_reader/utils/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

import '../../utils/common_appbar.dart';

class Setting extends StatefulWidget {
  final VoidCallback onBackPress;

  const Setting({
    super.key,
    required this.onBackPress,
  });

  @override
  State<Setting> createState() => SettingState();
}

class SettingState extends State<Setting> {
  @override
  void initState() {
    super.initState();
    checkInternetConnection(context: context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  final PrefsRepo prefsRepo = PrefsRepo();
  List<SettingModel> settingList = [];

  optionsTap(int index) {
    if (index == 0) {
      Share.shareUri(Uri.parse('https://play.google.com/store/apps/details?id=com.example.document_reader'));
    } else if (index == 1) {
      dialogData(context);
    } else if (index == 2) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Language()));
    }
  }

  @override
  Widget build(BuildContext context) {
    settingList = [
      SettingModel(
        title: AppLocalizations.of(context)?.share ?? '',
        img: IconStrings.share,
      ),
      SettingModel(
        title: AppLocalizations.of(context)?.rateUs ?? '',
        img: IconStrings.rate,
      ),
      SettingModel(
        title: AppLocalizations.of(context)?.language ?? '',
        img: IconStrings.language,
      ),
      SettingModel(
        title: AppLocalizations.of(context)?.privacyPolicy ?? '',
        img: IconStrings.policy,
      ),
    ];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => widget.onBackPress(),
      child: Scaffold(
        key: const Key('setting'),
        backgroundColor: ColorUtils.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 1),
          child: CustomAppbar(
            title: AppLocalizations.of(context)?.setting ?? '',
            onPress: () => widget.onBackPress(),
          ),
        ),
        body: ListView.builder(
          padding: EdgeInsets.only(top: 10.h),
          shrinkWrap: true,
          itemCount: settingList.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                ListTile(
                  key: Key('setting-$index'),
                  onTap: () => optionsTap(index),
                  leading: SizedBox(
                    width: 40.w,
                    height: 40.w,
                    child: Image.asset(settingList[index].img),
                  ),
                  title: Text(
                    key: Key(settingList[index].title),
                    settingList[index].title,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),
                Divider(color: const Color(0xFFDADADA), endIndent: 10.w, indent: 10.w),
              ],
            );
          },
        ),
      ),
    );
  }

  dialogData(BuildContext context) {
    int img = 1;
    String title1 = AppLocalizations.of(context)?.thankYou ?? '';
    String desc1 = AppLocalizations.of(context)?.rateUsDesc ?? '';
    String title2 = AppLocalizations.of(context)?.appreciation ?? '';
    String desc2 = AppLocalizations.of(context)?.motivation ?? '';

    double rat = prefsRepo.getInt(key: PrefsRepo.rate).toDouble();

    const double padding = 16.0;
    const double avatarRadius = 40.0;

    String title = '';
    String subtitle = '';

    bool isTitle2 = rat > 3 && rat < 6;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStat) {
          if (isTitle2) {
            title = title2;
            subtitle = desc2;
            img = 2;
          } else {
            title = title1;
            subtitle = desc1;
            img = 1;
          }

          return Dialog(
            key: const Key("ratting-dialog"),
            insetPadding: EdgeInsets.all(20.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(padding),
            ),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            child: Stack(
              key: Key(isTitle2 ? "Title 2" : "Title 1"),
              children: <Widget>[
                Text(AppLocalizations.of(context)?.thankYou ?? "null 6", key: const Key("test")),
                Container(
                  width: 380.w,
                  padding: const EdgeInsets.only(
                    top: avatarRadius + padding,
                    bottom: padding,
                    left: padding,
                    right: padding,
                  ),
                  margin: const EdgeInsets.only(top: avatarRadius),
                  decoration: BoxDecoration(
                    color: ColorUtils.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(30.w),
                    border: Border.all(color: ColorUtils.blueCFF, width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        key: const Key("title"),
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 17.sp),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8.h, bottom: 15.h),
                        child: Text(
                          key: const Key("subtitle"),
                          subtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.normal),
                        ),
                      ),
                      Container(
                        key: const Key("ratting"),
                        child: RatingBar(
                          glow: false,
                          itemCount: 5,
                          initialRating: rat,
                          allowHalfRating: false,
                          direction: Axis.horizontal,
                          ratingWidget: RatingWidget(
                            full: Image.asset(IconStrings.starFilled),
                            empty: Image.asset(IconStrings.star),
                            half: Image.asset(""),
                          ),
                          itemSize: 28.w,
                          itemPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                          onRatingUpdate: (rating) {
                            if (rat > 3 && rat < 6) {
                              title = title2;
                              subtitle = desc2;
                              img = 2;
                            } else {
                              title = title1;
                              subtitle = desc1;
                              img = 1;
                            }
                            rat = rating;
                            setStat(() {});
                          },
                        ),
                      ),
                      SizedBox(height: 15.h),
                      CustomBtn(
                        onTap: rat == 0.0
                            ? () {}
                            : () {
                                prefsRepo.setInt(key: PrefsRepo.rate, value: rat.toInt());
                                navigateBack(context: context);
                              },
                        title: AppLocalizations.of(context)?.rate ?? '',
                        height: 38.h,
                        width: 160.w,
                        radius: 30.w,
                        c1: ColorUtils.blue4FF,
                        border: Border.all(
                          color: const Color.fromRGBO(255, 255, 255, 0.30),
                          width: 1.5,
                        ),
                        shadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(70, 99, 255, 0.25),
                            offset: Offset(0, 3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: padding,
                  right: padding,
                  child: CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: ColorUtils.transparent,
                    child: Image.asset(IconStrings.support(img)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
