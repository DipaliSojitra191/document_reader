import 'package:document_reader/utils/AppColors.dart';
import 'package:document_reader/utils/custom_btn.dart';
import 'package:document_reader/utils/logs.dart';
import 'package:document_reader/utils/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Dialog
void deleteDialog({
  required BuildContext context,
  required VoidCallback deleteOnTap,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      logs(message: "open delete dialog");
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.w),
        ),
        contentPadding: EdgeInsets.fromLTRB(20.w, 10.h, 10.h, 10.h),
        content: Column(
          key: const Key('delete-dialog'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Spacer(),
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: Text(
                    AppLocalizations.of(context)?.delete ?? "",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => navigateBack(context: context),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorUtils.greyD7,
                    ),
                    padding: EdgeInsets.all(2.w),
                    child: Icon(Icons.close, size: 18.w),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              AppLocalizations.of(context)?.confirmDelete ?? '',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.all(5.w),
              child: Center(
                child: CustomBtn(
                  onTap: () async {
                    deleteOnTap();
                    navigateBack(context: context);
                  },
                  title: AppLocalizations.of(context)?.delete ?? "",
                  radius: 10.w,
                  height: 35.h,
                  width: 100.w,
                ),
              ),
            )
          ],
        ),
      );
    },
  ).then((value) => logs(message: "close delete dialog"));
}

Future<String> renameDialog({
  required BuildContext context,
  required String name,
}) async {
  final renameController = TextEditingController(text: name);
  final renameKey = GlobalKey<FormState>();
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      print("rename dialog open");
      return StatefulBuilder(builder: (context, setStat) {
        return AlertDialog(
          key: const Key("rename-dialog"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.w),
          ),
          contentPadding: EdgeInsets.fromLTRB(20.w, 10.h, 10.h, 10.h),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: Text(
                      AppLocalizations.of(context)?.rename ?? "",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 17.sp),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => navigateBack(context: context),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorUtils.greyD7,
                      ),
                      padding: EdgeInsets.all(2.w),
                      child: Icon(Icons.close, size: 18.w),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 14.h),
                child: Form(
                  key: renameKey,
                  child: TextFormField(
                    controller: renameController,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: ColorUtils.blueE8),
                    decoration: InputDecoration(
                      suffixIcon: Padding(
                        padding: EdgeInsets.all(10.w),
                        child: InkWell(
                          onTap: () {
                            renameController.clear();
                            setStat(() {});
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ColorUtils.white,
                            ),
                            padding: EdgeInsets.all(2.w),
                            child: Icon(
                              Icons.close,
                              size: 18.w,
                              color: ColorUtils.blueDA,
                            ),
                          ),
                        ),
                      ),
                      filled: true,
                      hintText: AppLocalizations.of(context)?.fileRename ?? "",
                      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: ColorUtils.blueE8),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(10.w),
                      fillColor: ColorUtils.grey7FF,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: ColorUtils.transparent),
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: ColorUtils.transparent),
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: ColorUtils.transparent),
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                    ),
                    onChanged: (value) {},
                    validator: (value) {
                      if (value!.isEmpty) {
                        return AppLocalizations.of(context)?.fieldIsRequired;
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5.w),
                child: Center(
                  child: CustomBtn(
                    onTap: () async {
                      if (renameKey.currentState!.validate()) {
                        navigateBack(context: context);
                      }
                    },
                    title: AppLocalizations.of(context)?.ok ?? "",
                    radius: 10.w,
                    height: 38.h,
                    width: 100.w,
                  ),
                ),
              )
            ],
          ),
        );
      });
    },
  ).then((value) => logs(message: "close rename dialog"));

  return renameController.text;
}

moveOutDialog({
  required BuildContext context,
  required VoidCallback moveOut,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.w),
        ),
        contentPadding: EdgeInsets.fromLTRB(20.w, 10.h, 10.h, 10.h),
        content: Column(
          key: const Key('move-out-dialog'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Spacer(),
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: Text(
                    AppLocalizations.of(context)?.moveOutOfRecent ?? "",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 17.sp),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => navigateBack(context: context),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorUtils.greyD7,
                    ),
                    padding: EdgeInsets.all(2.w),
                    child: Icon(Icons.close, size: 18.w),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              AppLocalizations.of(context)?.confirmMove ?? "",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.all(5.w),
              child: Center(
                child: CustomBtn(
                  onTap: () {
                    navigateBack(context: context);
                    moveOut();
                  },
                  title: 'Yes',
                  radius: 10.w,
                  height: 35.h,
                  width: 100.w,
                ),
              ),
            )
          ],
        ),
      );
    },
  );
}

Future<bool> showExitConfirmationDialog(BuildContext context) async {
  bool data = false;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        contentPadding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
        title: Text(
          AppLocalizations.of(context)?.exitApp ?? "",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 15.sp),
        ),
        content: Text(
          AppLocalizations.of(context)?.exitConfirmation ?? "",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  navigateBack(context: context);
                  data = false;
                },
                child: Text(AppLocalizations.of(context)?.no ?? ""),
              ),
              Padding(
                padding: EdgeInsets.all(5.w),
                child: Center(
                  child: CustomBtn(
                    onTap: () {
                      navigateBack(context: context);
                      data = true;
                    },
                    title: AppLocalizations.of(context)?.yes ?? "",
                    radius: 10.w,
                    height: 30.h,
                    width: 60.w,
                  ),
                ),
              )
            ],
          )
        ],
      );
    },
  ).then((value) {});
  return data;
}

Future<bool> permissionDialog({required VoidCallback allow, required BuildContext internetContext}) async {
  bool data = false;
  await showDialog(
    barrierDismissible: false,
    context: internetContext,
    builder: (BuildContext context) {
      return AlertDialog(
        key: const Key("permission-dialog"),
        contentPadding: EdgeInsets.fromLTRB(15.w, 10.h, 15.w, 10.h),
        title: Text(
          key: const Key("permission-dialog-title"),
          AppLocalizations.of(internetContext)?.permissionRequired ?? '',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 15.sp),
        ),
        content: Text(
          AppLocalizations.of(internetContext)?.externalStoragePermissionRequired ?? '',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              data = false;
              Navigator.pop(internetContext);
              Navigator.pop(internetContext);
            },
            child: Text(AppLocalizations.of(context)?.cancel ?? ""),
          ),
          TextButton(
            onPressed: () {
              allow();
            },
            child: Text(AppLocalizations.of(context)?.allow ?? ''),
          ),
        ],
      );
    },
  ).then((value) {});
  return data;
}
