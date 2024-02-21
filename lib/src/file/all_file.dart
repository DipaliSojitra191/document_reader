import 'dart:io';

import 'package:document_reader/shared_Preference/preferences_helper.dart';
import 'package:document_reader/src/file/all_directories.dart';
import 'package:document_reader/src/file/bloc/all_file_bloc.dart';
import 'package:document_reader/src/file/bloc/all_file_event.dart';
import 'package:document_reader/src/file/bloc/all_file_state.dart';
import 'package:document_reader/src/file/model/files_data_model.dart';
import 'package:document_reader/utils/AppColors.dart';
import 'package:document_reader/utils/AppImages.dart';
import 'package:document_reader/utils/Lists.dart';
import 'package:document_reader/utils/circular_progrss_indicator.dart';
import 'package:document_reader/utils/common_appbar.dart';
import 'package:document_reader/utils/common_functions.dart';
import 'package:document_reader/utils/custom_btn.dart';
import 'package:document_reader/utils/custom_data/custom_bottomsheet.dart';
import 'package:document_reader/utils/custom_data/custom_dialog.dart';
import 'package:document_reader/utils/gradient_text.dart';
import 'package:document_reader/utils/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AllFile extends StatefulWidget {
  final String fileType;
  final String title;

  const AllFile({super.key, required this.fileType, required this.title});

  @override
  State<AllFile> createState() => _AllFileState();
}

class _AllFileState extends State<AllFile> {
  List<FilesDataModel> allFiles = [];

  final AllFileBloc allFileBloc = AllFileBloc();
  final PrefsRepo prefsRepo = PrefsRepo();

  bool recentSelected = false;
  bool permissionGranted = false;

  int filter1 = 0;
  int filter2 = 0;

  Future<void> getFiles() async {
    allFiles.clear();

    allFileBloc.add(
      GetFileEvent(
        fileType: widget.fileType,
        selected1: filter1,
        selected2: filter2,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    checkInternetConnection();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      filter1 = prefsRepo.getInt(key: PrefsRepo.filter1);
      filter2 = prefsRepo.getInt(key: PrefsRepo.filter2);

      getFiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: allFileBloc,
      listener: (context, AllFileState state) {
        if (state is GetFileState) {
          allFiles = state.allFiles;
          recentSelected = state.selected ?? false;
        }
        if (state is CheckStoragePermissionStatus) {
          permissionGranted = state.isGranted;
        }
        if (state is FilterState) {
          allFiles = state.allFiles;
          recentSelected = state.selected ?? false;
          navigateBack();
        } else if (state is FileSelectState) {
          if (state.isBookmark == true) {
            allFiles[state.index].bookmark = state.selected;

            addToBookmark(
              data: allFiles[state.index],
              bookmark: state.selected,
            );
          } else {
            allFiles[state.index].selected = state.selected;
          }
        } else if (state is SelectedBackTapState) {
          recentSelected = state.selected;
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 1),
            child: CustomAppbar(
              onPress: () {
                if (recentSelected == true) {
                  allFileBloc.add(SelectedBackTapEvent(selected: false));
                } else {
                  navigateBack();
                }
              },
              title: !recentSelected ? widget.title : AppLocalizations.of(context)!.selected,
              action: [
                Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: InkWell(
                    onTap: () {
                      allFileBloc.add(
                        FileSelectedUnSelectedEvent(
                          allFiles: allFiles,
                          selected: !recentSelected,
                        ),
                      );
                    },
                    child: Image.asset(
                      recentSelected ? IconStrings.unselect : IconStrings.select,
                      height: 24.w,
                      width: 24.w,
                    ),
                  ),
                ),
                if (!recentSelected)
                  Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: InkWell(
                      onTap: () {
                        filterBottomSheet(context);
                      },
                      child: Image.asset(
                        IconStrings.filter,
                        height: 30.w,
                        width: 30.w,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          body: Column(
            children: [
              if (permissionGranted)
                const SizedBox.shrink()
              else if (state is GetFileLoadingState)
                const Expanded(child: Loader())
              else if (allFiles.isEmpty)
                noDataFound()
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: allFiles.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return CommonListTile(
                        onLongPress: () {
                          if (!recentSelected) {
                            allFileBloc.add(
                              FileSelectedUnSelectedEvent(allFiles: allFiles, selected: true),
                            );
                          }
                        },
                        showRename: true,
                        data: allFiles[index],
                        selectAll: recentSelected,
                        getFilesOnTap: getFiles,
                        bookmarkOnTap: () {
                          allFileBloc.add(
                            FileSelectEvent(
                              isBookmark: true,
                              index: index,
                              selected: !allFiles[index].bookmark,
                            ),
                          );
                        },
                        selectOptionOnTap: () {
                          allFileBloc.add(
                            FileSelectEvent(
                              isBookmark: false,
                              index: index,
                              selected: !allFiles[index].selected,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              if (recentSelected)
                Builder(builder: (context) {
                  bool isEmpty = allFiles.where((element) => element.selected).isEmpty;
                  Color color = isEmpty ? ColorUtils.greyAA : ColorUtils.primary;
                  return SizedBox(
                    height: 70.h,
                    child: Column(
                      children: [
                        SizedBox(height: 2.h),
                        Divider(color: ColorUtils.black, height: 2),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              InkWell(
                                onTap: isEmpty
                                    ? null
                                    : () {
                                        List<File> filePath = [];
                                        for (var element in allFiles) {
                                          if (element.selected) {
                                            filePath.add(element.path);
                                          }
                                        }
                                        shareFile(path: filePath);
                                      },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      child: Image.asset(
                                        IconStrings.share1,
                                        fit: BoxFit.cover,
                                        height: 25.h,
                                        color: color,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      AppLocalizations.of(context)!.share,
                                      style: Theme.of(context).textTheme.displaySmall!.copyWith(color: color),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: isEmpty
                                    ? null
                                    : () {
                                        deleteDialog(
                                            context: context,
                                            callback: () {
                                              for (var element in allFiles) {
                                                if (element.selected) {
                                                  deleteFile(element.path.path);
                                                }
                                              }
                                              recentSelected = false;

                                              getFiles();
                                            });
                                      },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      IconStrings.delete1,
                                      fit: BoxFit.cover,
                                      height: 25.h,
                                      color: color,
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      AppLocalizations.of(context)!.delete,
                                      style: Theme.of(context).textTheme.displaySmall!.copyWith(color: color),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: ColorUtils.black, height: 2),
                        SizedBox(height: 2.h),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget noDataFound() {
    return Expanded(
      child: Center(child: Text(AppLocalizations.of(context)!.noFilesFound)),
    );
  }

  void assignSelected({required bool isSelected1, required int index, required StateSetter setStat}) {
    if (isSelected1 == true) {
      filter1 = index;
      prefsRepo.setInt(key: PrefsRepo.filter1, value: index);
    } else if (isSelected1 == false) {
      filter2 = index;
      prefsRepo.setInt(key: PrefsRepo.filter2, value: index);
    }
    setStat(() {});
  }

  void filterBottomSheet(BuildContext context) {
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
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.filter_by,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: SizedBox(
                          height: 30.h,
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: list1.length,
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.horizontal,
                            separatorBuilder: (context, index) {
                              return SizedBox(width: 8.w);
                            },
                            itemBuilder: (context, index) {
                              return filter1 == index
                                  ? GradientBorderWidget(
                                      child: Container(
                                        height: 40.h,
                                        padding: EdgeInsets.only(right: 15.w, top: 6.h, bottom: 6.h),
                                        decoration: BoxDecoration(
                                          color: ColorUtils.white,
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Row(
                                          children: [
                                            GradientText(
                                              child: Radio(
                                                value: index,
                                                groupValue: filter1,
                                                onChanged: (v) {},
                                              ),
                                            ),
                                            Text(
                                              list1[index],
                                              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                                                    color: ColorUtils.primary,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () {
                                        assignSelected(index: index, isSelected1: true, setStat: setStat);
                                      },
                                      child: Container(
                                        height: 40.h,
                                        padding: EdgeInsets.only(right: 15.w, top: 6.h, bottom: 6.h),
                                        decoration: BoxDecoration(
                                          color: ColorUtils.black.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10.w),
                                        ),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: index,
                                              groupValue: filter1,
                                              onChanged: (v) {
                                                assignSelected(index: index, setStat: setStat, isSelected1: true);
                                              },
                                            ),
                                            Text(list1[index]),
                                          ],
                                        ),
                                      ),
                                    );
                            },
                          ),
                        ),
                      ),
                      const Divider(),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: SizedBox(
                          height: 30.h,
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: list2.length,
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.horizontal,
                            separatorBuilder: (context, index) {
                              return SizedBox(width: 10.w);
                            },
                            itemBuilder: (context, index) {
                              return filter2 == index
                                  ? GradientBorderWidget(
                                      child: Container(
                                        height: 40.h,
                                        padding: EdgeInsets.only(
                                          right: 15.w,
                                          top: 6.h,
                                          bottom: 6.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: ColorUtils.white,
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Row(
                                          children: [
                                            GradientText(
                                              child: Radio(
                                                value: index,
                                                groupValue: filter2,
                                                onChanged: (v) {},
                                              ),
                                            ),
                                            Text(
                                              list2[index],
                                              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                                                    color: ColorUtils.primary,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () {
                                        assignSelected(index: index, setStat: setStat, isSelected1: false);
                                      },
                                      child: Container(
                                        height: 40.h,
                                        padding: EdgeInsets.only(right: 15.w, top: 6.h, bottom: 6.h),
                                        decoration: BoxDecoration(
                                          color: ColorUtils.black.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10.w),
                                        ),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: index,
                                              groupValue: filter2,
                                              onChanged: (v) {
                                                assignSelected(index: index, setStat: setStat, isSelected1: true);
                                              },
                                            ),
                                            Text(list2[index]),
                                          ],
                                        ),
                                      ),
                                    );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(5.w),
                        child: Center(
                          child: CustomBtn(
                            onTap: () {
                              allFileBloc.add(FilterEvent(selected1: filter1, selected2: filter2));
                            },
                            title: AppLocalizations.of(currentContext)!.ok,
                            radius: 10.w,
                            height: 35.h,
                            width: 100.w,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
