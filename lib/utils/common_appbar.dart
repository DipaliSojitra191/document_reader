import 'package:document_reader/shared_Preference/preferences_helper.dart';
import 'package:document_reader/utils/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'AppStrings.dart';
import 'navigation.dart';

class CustomAppbar extends StatelessWidget {
  final String? title;
  final VoidCallback? onPress;
  final Color? textColor;
  final Color? iconColor;
  final Widget? leadingImage;
  final List<Widget>? action;

  final bool? hideLeading;

  final Widget? child;

  const CustomAppbar({
    super.key,
    this.title,
    this.action,
    this.onPress,
    this.textColor,
    this.iconColor,
    this.leadingImage,
    this.hideLeading,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final language = PrefsRepo().getString(key: PrefsRepo.language);
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Column(
        children: [
          AppBar(
            systemOverlayStyle: const SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
            primary: true,
            backgroundColor: ColorUtils.white,
            leading: IconButton(
              key: const Key("back-btn"),
              onPressed: () {
                if (onPress != null) {
                  onPress!();
                } else {
                  navigateBack(context: context);
                }
              },
              icon: hideLeading ?? false
                  ? const SizedBox()
                  : Transform.rotate(
                      angle: language == StringUtils.arabic ? 0 : 0,
                      child: const Icon(Icons.arrow_back_ios_new),
                    ),
            ),
            title: child ?? Text(title ?? "", maxLines: 1, key: const Key('text')),
            actions: action ?? [],
          ),
          Divider(color: ColorUtils.black, height: 1),
        ],
      ),
    );
  }
}
