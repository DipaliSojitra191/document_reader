import 'package:document_reader/shared_Preference/preferences_helper.dart';
import 'package:document_reader/src/file/model/files_data_model.dart';
import 'package:document_reader/utils/AppColors.dart';
import 'package:document_reader/utils/AppImages.dart';
import 'package:document_reader/utils/common_functions.dart';
import 'package:document_reader/utils/custom_btn.dart';
import 'package:document_reader/utils/custom_data/custom_dialog.dart';
import 'package:document_reader/utils/custom_data/custom_widget.dart';
import 'package:document_reader/utils/logs.dart';
import 'package:document_reader/utils/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

modalBottomSheet({required Widget child}) {
  showModalBottomSheet(
    context: currentContext,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(15.w)),
    ),
    builder: (BuildContext context) {
      return child;
    },
  );
}

/// Bottom sheet
void moreBottomSheet({
  required BuildContext context,
  required bool showShare,
  required bool showRename,
  required VoidCallback getFilesOnTap,
  required VoidCallback deleteOnTap,
  VoidCallback? moveOutOnTap,
  required FilesDataModel allFiles,
}) {
  modalBottomSheet(
    child: StatefulBuilder(builder: (context, setStat) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(10.w)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
              child: Row(
                children: [
                  Image.asset(
                    getImageFromExt(allFiles.name.split(".").last),
                    scale: 3.8.w,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          allFiles.name,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.displaySmall!.copyWith(fontSize: 15.sp),
                        ),
                        Text(
                          allFiles.path.path,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.sp),
                        )
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                ],
              ),
            ),
            Divider(color: ColorUtils.greyC0),
            SizedBox(width: 20.h),
            Container(
              height: 80.h,
              margin: EdgeInsets.symmetric(vertical: 10.h),
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 0.h, 20.w, 0.h),
                scrollDirection: Axis.horizontal,
                children: [
                  if (showShare)
                    menus(
                      image: IconStrings.outlineShare,
                      context: context,
                      onTap: () {
                        navigateBack();

                        shareFile(path: [allFiles.path]);
                      },
                      allFiles: allFiles,
                      name: AppLocalizations.of(context)!.share,
                    ),
                  if (showRename) SizedBox(width: 15.w),
                  if (showRename)
                    menus(
                      context: context,
                      name: AppLocalizations.of(context)!.rename,
                      image: IconStrings.outlineRename,
                      allFiles: allFiles,
                      onTap: () async {
                        navigateBack();
                        logs(message: 'rename');

                        String oldName = allFiles.name.split(".").first;
                        final rename = await renameDialog(context: context, name: oldName);

                        if (rename != oldName) {
                          final status = await renameFile(allFiles.path.path, rename);

                          logs(message: "OLD: ${status["old"]}, NEW: ${status["new"]}, path: ${allFiles.path.path}");
                          if (status["old"] != "" && status["new"] != "") {
                            List<FilesDataModel> recentData = await PrefsRepo().getRecentJson();
                            List<FilesDataModel> bookmarkData = await PrefsRepo().getBookmarkJson();

                            if (recentData.isNotEmpty) {
                              for (var element in recentData) {
                                if (element.path.path == status["old"]) {
                                  PrefsRepo().updateRecentPathJson(path: status["old"], newPath: status["new"]);
                                }
                              }
                            }

                            if (bookmarkData.isNotEmpty) {
                              for (var element in bookmarkData) {
                                if (element.path.path == status["old"]) {
                                  PrefsRepo().updateBookmarkPathJson(path: status["old"], newPath: status["new"]);
                                }
                              }
                            }
                            getFilesOnTap();
                          }
                        }
                      },
                    ),
                  if (moveOutOnTap != null) SizedBox(width: 15.w),
                  if (moveOutOnTap != null)
                    menus(
                      context: context,
                      image: IconStrings.outlineMoveout,
                      name: AppLocalizations.of(context)!.moveOut,
                      allFiles: allFiles,
                      onTap: () {
                        navigateBack();
                        moveOutDialog(
                          context: context,
                          moveOut: () => moveOutOnTap(),
                        );
                      },
                    ),
                  SizedBox(width: 15.w),
                  menus(
                    context: context,
                    allFiles: allFiles,
                    image: IconStrings.outlineDelete,
                    name: AppLocalizations.of(context)!.delete,
                    onTap: () {
                      navigateBack();

                      deleteDialog(
                        context: context,
                        callback: () async {
                          final bool status = await deleteFile(allFiles.path.path);
                          if (status) {
                            List<FilesDataModel> recentData = await PrefsRepo().getRecentJson();
                            List<FilesDataModel> bookmarkData = await PrefsRepo().getBookmarkJson();

                            for (var element in recentData) {
                              if (element.path.path == allFiles.path.path) {
                                PrefsRepo().deleteRecentJson(path: allFiles.path.path);
                              }
                            }

                            for (var element in bookmarkData) {
                              if (element.path.path == allFiles.path.path) {
                                PrefsRepo().deleteBookmarkJson(path: allFiles.path.path);
                              }
                            }
                            await Future.delayed(const Duration(milliseconds: 1000));
                            getFilesOnTap();
                          }
                        },
                      );
                    },
                  ),
                  SizedBox(width: 10.w),
                ],
              ),
            ),
            SizedBox(width: 20.h),
          ],
        ),
      );
    }),
  );
}

void fileNotSupportBottomSheet() {
  modalBottomSheet(
    child: StatefulBuilder(builder: (context, setStat) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(15.w)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(IconStrings.fileNotSupport, scale: 5.w),
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Text(
                  AppLocalizations.of(context)!.fileTypeNotSupported,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 14.sp),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                AppLocalizations.of(context)!.fileTypeNotSupportedMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.normal,
                    ),
              ),
              // SizedBox(height: 10.h),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.all(5.w),
                child: Center(
                  child: CustomBtn(
                    onTap: () => navigateBack(),
                    title: AppLocalizations.of(context)!.ok,
                    radius: 10.w,
                    height: 35.h,
                    width: 100.w,
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }),
  );
}
