import 'dart:io';

import 'package:document_reader/shared_Preference/preferences_helper.dart';
import 'package:document_reader/src/bottombar/bottombar.dart';
import 'package:document_reader/src/file/all_directories.dart';
import 'package:document_reader/src/file/all_file.dart';
import 'package:document_reader/src/file/bloc/all_file_bloc.dart';
import 'package:document_reader/src/file/bloc/all_file_event.dart';
import 'package:document_reader/src/file/bloc/all_file_state.dart';
import 'package:document_reader/src/file/model/files_data_model.dart';
import 'package:document_reader/src/home/bloc/home_bloc.dart';
import 'package:document_reader/src/home/model/files_model.dart';
import 'package:document_reader/utils/AppColors.dart';
import 'package:document_reader/utils/AppImages.dart';
import 'package:document_reader/utils/common_functions.dart';
import 'package:document_reader/utils/common_linear_gradient.dart';
import 'package:document_reader/utils/common_shadow.dart';
import 'package:document_reader/utils/custom_data/custom_dialog.dart';
import 'package:document_reader/utils/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Home extends StatefulWidget {
  final VoidCallback onBackPress;
  final bool showMenu;

  const Home({super.key, required this.onBackPress, required this.showMenu});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int recentIndex = 0;

  HomeBloc homeBloc = HomeBloc();
  final PrefsRepo prefsRepo = PrefsRepo();

  List<FilesModel> filesList = [
    FilesModel(
      title: AppLocalizations.of(currentContext)!.allFiles,
      color: ColorUtils.blueCFF,
      ext: '',
    ),
    FilesModel(
      title: AppLocalizations.of(currentContext)!.pdf,
      color: ColorUtils.red4C,
      ext: '.pdf',
    ),
    FilesModel(
      title: AppLocalizations.of(currentContext)!.word,
      color: ColorUtils.blueC9,
      ext: '.word',
    ),
    FilesModel(
      title: AppLocalizations.of(currentContext)!.ppt,
      color: ColorUtils.orange4C,
      ext: '.ppt',
    ),
    FilesModel(
      title: AppLocalizations.of(currentContext)!.excel,
      color: ColorUtils.green66,
      ext: '.exls',
    ),
    FilesModel(
      title: AppLocalizations.of(currentContext)!.text,
      color: ColorUtils.pink9E,
      ext: '.txt',
    ),
    FilesModel(
      title: AppLocalizations.of(currentContext)!.imageDocument,
      color: ColorUtils.blueF0,
      ext: '.img',
    ),
    FilesModel(
      title: AppLocalizations.of(currentContext)!.directories,
      color: ColorUtils.yellowF0,
      ext: '',
    ),
  ];

  List<FilesDataModel> allFiles = [];
  final AllFileBloc allFileBloc = AllFileBloc();

  getFiles() {
    allFiles.clear();
    allFileBloc.add(
      GetFileEvent(fileType: "all", selected1: 0, selected2: 0),
    );
  }

  List<FilesDataModel> recentList = [];
  List<FilesDataModel> bookmarkList = [];

  getRecentData() {
    homeBloc.add(GetRecentData(allFiles: allFiles));
  }

  bool selected = false;

  @override
  void initState() {
    super.initState();
    checkInternetConnection();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getRecentData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (recentIndex != 0) {
          BottomBar.changeBottom(context, true);
          homeBloc.add(RecentTabEvent(index: 0));
        } else {
          final bool status = await showExitConfirmationDialog(context);
          if (status) {
            SystemNavigator.pop();
          }
        }
      },
      child: BlocConsumer(
        bloc: homeBloc,
        listener: (context, state) {
          if (state is GetRecent) {
            recentList = state.recentList;
            bookmarkList = state.bookmarkList;
          }
          if (state is RecentTabState) {
            recentIndex = state.index;
          }
          if (state is RecentBookmarkSelectedState) {
            if (state.isBookmark == true) {
              if (bookmarkList.length >= state.index) {
                bookmarkList[state.index].selected = state.selected;
              }
            } else {
              if (recentList.length >= state.index) {
                recentList[state.index].selected = state.selected;
              }
            }
          }
          if (state is ShowBottomMenuState) {
            selected = state.selected;
            BottomBar.changeBottom(context, !selected);
            for (var element in recentList) {
              element.selected = false;
            }
            for (var element in bookmarkList) {
              element.selected = false;
            }
          }
        },
        builder: (context, state) {
          return BlocConsumer(
              bloc: allFileBloc,
              listener: (context, state) {
                if (state is GetFileState) {
                  allFiles = state.allFiles;
                  getRecentData();
                }

                if (state is FileSelectState) {
                  if (state.isBookmark == true) {
                    bookmarkList[state.index].bookmark = state.selected;
                    addToBookmark(
                      data: bookmarkList[state.index],
                      bookmark: state.selected,
                    );
                  } else {
                    recentList[state.index].bookmark = state.selected;

                    addToBookmark(
                      data: recentList[state.index],
                      bookmark: state.selected,
                    );
                  }
                }
              },
              builder: (context, state) {
                return SafeArea(
                  child: Scaffold(
                    body: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                recentTabBar(),
                                SizedBox(height: 10.h),
                                if (recentIndex == 1) recentData(),
                                if (recentIndex == 2) bookmarkData(),
                                if (recentIndex == 0) defaultData(),
                                SizedBox(height: 10.h),
                              ],
                            ),
                          ),
                        ),
                        if (widget.showMenu)
                          Builder(builder: (context) {
                            List<FilesDataModel> data = [];
                            if (recentIndex == 1) {
                              data = recentList;
                            } else if (recentIndex == 2) {
                              data = bookmarkList;
                            }

                            bool isEmpty = data.where((element) => element.selected).isEmpty;
                            Color color = isEmpty ? ColorUtils.greyAA : ColorUtils.primary;
                            return SizedBox(
                              height: 70.h,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Divider(color: ColorUtils.black),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            List<File> path = [];
                                            for (var element in data) {
                                              if (element.selected) {
                                                path.add(element.path);
                                              }
                                            }

                                            shareFile(path: path);
                                            selected = false;
                                            BottomBar.changeBottom(context, false);
                                          },
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Image.asset(IconStrings.share1, width: 20.w, color: color),
                                              Text(
                                                AppLocalizations.of(context)!.share,
                                                style: Theme.of(context).textTheme.bodySmall!.copyWith(color: color),
                                              ),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            for (var element in data) {
                                              if (element.selected) {
                                                if (recentIndex == 1) {
                                                  prefsRepo.deleteRecentJson(path: element.path.path);
                                                } else if (recentIndex == 2) {
                                                  prefsRepo.deleteBookmarkJson(path: element.path.path);
                                                }
                                              }
                                            }
                                            selected = false;
                                            BottomBar.changeBottom(context, false);
                                            getRecentData();
                                          },
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Image.asset(
                                                isEmpty ? IconStrings.greyMoveOut : IconStrings.moveOut,
                                                width: 20.w,
                                              ),
                                              Text(
                                                AppLocalizations.of(context)!.moveOut,
                                                style: Theme.of(context).textTheme.bodySmall!.copyWith(color: color),
                                              ),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            for (var element in data) {
                                              if (element.selected) {
                                                deleteFile(element.path.path);
                                              }
                                            }
                                            selected = false;
                                            BottomBar.changeBottom(context, false);
                                            getRecentData();
                                          },
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Image.asset(IconStrings.delete1, width: 20.w, color: color),
                                              Text(
                                                AppLocalizations.of(context)!.delete,
                                                style: Theme.of(context).textTheme.bodySmall!.copyWith(color: color),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(color: ColorUtils.black),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                );
              });
        },
      ),
    );
  }

  Widget recentTabBar() {
    return Stack(
      children: [
        SizedBox(
          height: 170.h,
          width: double.infinity,
          child: Image.asset(ImageString.bgShape, fit: BoxFit.fill),
        ),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.allDocumentReader,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.displayMedium!.copyWith(color: ColorUtils.white),
                      ),
                    ),
                    // Image.asset(
                    //   IconStrings.search,
                    //   scale: 4.5.w,
                    // ),
                  ],
                ),
              ),
              SizedBox(height: 15.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: commonShadow(),
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    child: Row(
                      children: [
                        recentTab(
                          title: AppLocalizations.of(context)!.recent,
                          count: 1,
                        ),
                        recentTab(
                          title: AppLocalizations.of(context)!.bookmark,
                          count: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget defaultData() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 15.h),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 20.h,
              mainAxisSpacing: 20.h,
              childAspectRatio: 0.8,
            ),
            itemCount: 6,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemBuilder: (BuildContext context, int index) {
              final GetTypeNameTitle data = getTypeAndTitle(index);

              return filesMeni(
                image: data.image,
                title: data.title,
                data: filesList[index],
                fileType: data.fileType,
              );
            },
          ),
        ),
        SizedBox(height: 20.h),
        verticalTab(
          data: filesList[6],
          img: getTypeAndTitle(6).image,
          title: getTypeAndTitle(6).title,
          fileType: getTypeAndTitle(6).fileType,
        ),
        SizedBox(height: 20.h),
        verticalTab(
          data: filesList[7],
          img: getTypeAndTitle(7).image,
          title: getTypeAndTitle(7).title,
          fileType: getTypeAndTitle(7).fileType,
        ),
        SizedBox(height: 5.h),
      ],
    );
  }

  Widget noDataFound() {
    return SizedBox(
      height: 400.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(AppLocalizations.of(context)!.noDataFound),
        ],
      ),
    );
  }

  Widget recentData() {
    if (recentList.isEmpty) {
      return noDataFound();
    }
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context)!.selected,
                style: Theme.of(currentContext).appBarTheme.titleTextStyle,
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  homeBloc.add(ShowBottomMenuEvent(selected: !selected));
                },
                child: Image.asset(
                  selected ? IconStrings.unselect : IconStrings.select,
                  height: 25.w,
                  width: 25.w,
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          itemCount: recentList.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 0),
          itemBuilder: (context, index) {
            final data = recentList[index];

            return CommonListTile(
              showRename: false,
              data: data,
              selectAll: selected,
              onLongPress: () {
                if (!selected) {
                  homeBloc.add(ShowBottomMenuEvent(selected: true));
                }
              },
              getFilesOnTap: () {},
              bookmarkOnTap: () {
                allFileBloc.add(
                  FileSelectEvent(
                    index: index,
                    selected: !recentList[index].bookmark,
                    isBookmark: false,
                  ),
                );
              },
              selectOptionOnTap: () {
                final selected = !recentList[index].selected;

                homeBloc.add(
                  RecentBookmarkSelectedEvent(
                    selected: selected,
                    isBookmark: false,
                    index: index,
                  ),
                );
              },
              moveOutOnTap: () async {
                prefsRepo.deleteRecentJson(
                  path: recentList[index].path.path,
                );
                await getRecentData();
              },
            );
          },
        ),
      ],
    );
  }

  Widget bookmarkData() {
    if (bookmarkList.isEmpty) {
      return noDataFound();
    }
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context)!.selected,
                style: Theme.of(currentContext).appBarTheme.titleTextStyle,
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  homeBloc.add(ShowBottomMenuEvent(selected: !selected));
                },
                child: Image.asset(
                  selected ? IconStrings.unselect : IconStrings.select,
                  height: 25.w,
                  width: 25.w,
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          itemCount: bookmarkList.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 0),
          itemBuilder: (context, index) {
            return CommonListTile(
              onLongPress: () {
                if (!selected) {
                  homeBloc.add(ShowBottomMenuEvent(selected: true));
                }
              },
              showRename: false,
              data: bookmarkList[index],
              getFilesOnTap: () async {
                prefsRepo.deleteBookmarkJson(
                  path: bookmarkList[index].path.path,
                );
                getRecentData();
              },
              moveOutOnTap: () {
                prefsRepo.deleteBookmarkJson(
                  path: bookmarkList[index].path.path,
                );
                getRecentData();
              },
              bookmarkOnTap: () {
                allFileBloc.add(
                  FileSelectEvent(
                    index: index,
                    selected: !bookmarkList[index].bookmark,
                    isBookmark: true,
                  ),
                );
              },
              selectOptionOnTap: () {
                final selected = !bookmarkList[index].selected;

                homeBloc.add(
                  RecentBookmarkSelectedEvent(
                    selected: selected,
                    isBookmark: true,
                    index: index,
                  ),
                );
              },
              selectAll: selected,
            );
          },
        ),
      ],
    );
  }

  Widget verticalTab({
    required FilesModel data,
    required String img,
    required String fileType,
    required String title,
  }) {
    return InkWell(
      onTap: () async {
        if (fileType == "Directories") {
          await navigatorPush(
            DirectoriesScreen(path: '/storage/emulated/0/', showMenu: true, title: title),
          );
        } else {
          await navigatorPush(AllFile(fileType: fileType, title: title));
        }
        getRecentData();
      },
      child: Padding(
        padding: EdgeInsets.only(left: 20.w, right: 20.w),
        child: Container(
          height: 80.h,
          decoration: BoxDecoration(
            color: ColorUtils.greyF4,
            boxShadow: commonShadow(),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Image.asset(img, width: 55.w, fit: BoxFit.cover),
              ),
              SizedBox(height: 2.h),
              Text(
                data.title,
                style: Theme.of(currentContext).textTheme.displaySmall,
              ),
              const Spacer(),
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 3.w, 3.w),
                decoration: BoxDecoration(
                  border: Border.all(color: data.color),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.keyboard_arrow_right,
                  color: data.color,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 10.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget filesMeni({
    required FilesModel data,
    required String image,
    required String fileType,
    required String title,
  }) {
    return InkWell(
      onTap: () => navigatorPush(AllFile(fileType: fileType, title: title)),
      child: Container(
        decoration: BoxDecoration(
          color: ColorUtils.greyF4,
          boxShadow: commonShadow(),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height: 5.h),
            Image.asset(image, width: 55.w, fit: BoxFit.cover),
            SizedBox(height: 2.h),
            Text(
              data.title,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: Theme.of(currentContext).textTheme.displaySmall,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 0, 3.w, 3.w),
                decoration: BoxDecoration(
                  border: Border.all(color: data.color),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.keyboard_arrow_right,
                  color: data.color,
                  size: 13.w,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget recentTab({required String title, required int count}) {
    return InkWell(
      onTap: () {
        homeBloc.add(ShowBottomMenuEvent(selected: false));
        BottomBar.changeBottom(context, true);

        if (recentIndex == count) {
          homeBloc.add(RecentTabEvent(index: 0));
        } else {
          homeBloc.add(RecentTabEvent(index: count));
          getRecentData();
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
        child: Container(
          width: 95.w,
          decoration: BoxDecoration(
            boxShadow: recentIndex == count ? commonShadow() : [],
            gradient: recentIndex == count ? commonGradient() : null,
            borderRadius: BorderRadius.circular(10.w),
          ),
          padding: EdgeInsets.symmetric(vertical: 8.w),
          child: Center(
            child: Text(
              title,
              style: Theme.of(currentContext).textTheme.bodyMedium?.copyWith(
                    color: recentIndex == count ? ColorUtils.white : null,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
