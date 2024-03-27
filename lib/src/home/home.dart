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

class HomeScreen extends StatefulWidget {
  final VoidCallback onBackPress;
  final bool showMenu;

  const HomeScreen({super.key, required this.onBackPress, required this.showMenu});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int tabIndex = 0;

  HomeBloc homeBloc = HomeBloc();
  final PrefsRepo prefsRepo = PrefsRepo();

  List<FilesModel> filesList = [];

  List<FilesDataModel> allFiles = [];
  final AllFileBloc allFileBloc = AllFileBloc();

  getFiles() {
    allFiles.clear();
    allFileBloc.add(
      GetFileEvent(context: context, fileType: "all", selected1: 0, selected2: 0),
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
    checkInternetConnection(context: context);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getRecentData();
    });
  }

  @override
  Widget build(BuildContext context) {
    filesList = [
      FilesModel(
        title: AppLocalizations.of(context)?.allFiles ?? '',
        color: ColorUtils.blueCFF,
        ext: '',
      ),
      FilesModel(
        title: AppLocalizations.of(context)?.pdf ?? '',
        color: ColorUtils.red4C,
        ext: '.pdf',
      ),
      FilesModel(
        title: AppLocalizations.of(context)?.word ?? '',
        color: ColorUtils.blueC9,
        ext: '.word',
      ),
      FilesModel(
        title: AppLocalizations.of(context)?.ppt ?? '',
        color: ColorUtils.orange4C,
        ext: '.ppt',
      ),
      FilesModel(
        title: AppLocalizations.of(context)?.excel ?? '',
        color: ColorUtils.green66,
        ext: '.exls',
      ),
      FilesModel(
        title: AppLocalizations.of(context)?.text ?? '',
        color: ColorUtils.pink9E,
        ext: '.txt',
      ),
      FilesModel(
        title: AppLocalizations.of(context)?.imageDocument ?? '',
        color: ColorUtils.blueF0,
        ext: '.img',
      ),
      FilesModel(
        title: AppLocalizations.of(context)?.directories ?? '',
        color: ColorUtils.yellowF0,
        ext: '',
      ),
    ];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (tabIndex != 0) {
          BottomBarScreen.showBottomBar(showBottom: true, context: context);
          homeBloc.add(RecentTabEvent(index: 0));
        } else {
          final bool status = await showExitConfirmationDialog(context);
          if (status) {
            SystemNavigator.pop();
          }
        }
      },
      child: BlocConsumer<HomeBloc, HomeBlocState>(
        bloc: homeBloc,
        listener: (context, HomeBlocState homeBlocState) {
          if (homeBlocState is GetRecent) {
            recentList = homeBlocState.recentList;
            bookmarkList = homeBlocState.bookmarkList;
          }
          if (homeBlocState is RecentTabState) {
            tabIndex = homeBlocState.index;
            selected = false;

            for (var element in recentList) {
              element.selected = false;
            }
            for (var element in bookmarkList) {
              element.selected = false;
            }
            if (!mounted) {
              BottomBarScreen.showBottomBar(showBottom: true, context: context);
            }
          }
          if (homeBlocState is RecentBookmarkSelectedState) {
            if (homeBlocState.isBookmark == true) {
              if (bookmarkList.length >= homeBlocState.index) {
                bookmarkList[homeBlocState.index].selected = homeBlocState.selected;
              }
            } else {
              if (recentList.length >= homeBlocState.index) {
                recentList[homeBlocState.index].selected = homeBlocState.selected;
              }
            }
          }
          if (homeBlocState is ShowBottomMenuState) {
            selected = homeBlocState.selected;
            BottomBarScreen.showBottomBar(context: context, showBottom: !selected);
            for (var element in recentList) {
              element.selected = false;
            }
            for (var element in bookmarkList) {
              element.selected = false;
            }
          }
        },
        builder: (context, HomeBlocState homeBlocState) {
          return BlocConsumer<AllFileBloc, AllFileBlocState>(
            bloc: allFileBloc,
            listener: (context, AllFileBlocState fileState) {
              if (fileState is GetFileState) {
                allFiles = fileState.allFiles;
                getRecentData();
              }

              if (fileState is FileSelectState) {
                if (fileState.isBookmark == true) {
                  bookmarkList[fileState.index].bookmark = fileState.selected;
                  addToBookmark(
                    data: bookmarkList[fileState.index],
                    bookmark: fileState.selected,
                  );
                } else {
                  recentList[fileState.index].bookmark = fileState.selected;

                  addToBookmark(
                    data: recentList[fileState.index],
                    bookmark: fileState.selected,
                  );
                }
              }
            },
            builder: (context, AllFileBlocState state) {
              return SafeArea(
                child: Scaffold(
                  key: GlobalKey(),
                  body: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              tabBar(),
                              SizedBox(height: 10.h),
                              if (tabIndex == 1) recentData(),
                              if (tabIndex == 2) bookmarkData(),
                              if (tabIndex == 0) defaultData(),
                              SizedBox(height: 10.h),
                            ],
                          ),
                        ),
                      ),
                      if (widget.showMenu)
                        Builder(builder: (context) {
                          List<FilesDataModel> data = [];
                          if (tabIndex == 1) {
                            data = recentList;
                          } else if (tabIndex == 2) {
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
                                          List<String> path = [];
                                          for (var element in data) {
                                            if (element.selected) {
                                              path.add(element.path.path);
                                            }
                                          }

                                          shareFile(path: path);
                                          selected = false;
                                          BottomBarScreen.showBottomBar(context: context, showBottom: false);
                                        },
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Image.asset(IconStrings.share1, width: 20.w, color: color),
                                            Text(
                                              AppLocalizations.of(context)?.share ?? '',
                                              style: Theme.of(context).textTheme.bodySmall!.copyWith(color: color),
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          for (var element in data) {
                                            if (element.selected) {
                                              if (tabIndex == 1) {
                                                prefsRepo.deleteRecentJson(path: element.path.path);
                                              } else if (tabIndex == 2) {
                                                prefsRepo.deleteBookmarkJson(path: element.path.path);
                                              }
                                            }
                                          }
                                          selected = false;
                                          BottomBarScreen.showBottomBar(context: context, showBottom: false);
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
                                              AppLocalizations.of(context)?.moveOut ?? '',
                                              style: Theme.of(context).textTheme.bodySmall!.copyWith(color: color),
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          for (var element in data) {
                                            if (element.selected) {
                                              if (tabIndex == 1) {
                                                prefsRepo.deleteRecentJson(path: element.path.path);
                                              } else if (tabIndex == 2) {
                                                prefsRepo.deleteBookmarkJson(path: element.path.path);
                                              }
                                            }
                                          }

                                          for (var element in data) {
                                            if (element.selected) {
                                              deleteFile(element.path.path);
                                            }
                                          }
                                          getRecentData();
                                          selected = false;
                                          BottomBarScreen.showBottomBar(context: context, showBottom: true);
                                        },
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Image.asset(IconStrings.delete1, width: 20.w, color: color),
                                            Text(
                                              AppLocalizations.of(context)?.delete ?? '',
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
            },
          );
        },
      ),
    );
  }

  Widget tabBar() {
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
                        AppLocalizations.of(context)?.allDocumentReader ?? '',
                        maxLines: 1,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(color: ColorUtils.white),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: ColorUtils.white,
                      boxShadow: commonShadow(),
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    child: Row(
                      children: [
                        tab(title: AppLocalizations.of(context)?.recent ?? '', count: 1),
                        tab(title: AppLocalizations.of(context)?.bookmark ?? '', count: 2),
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
      children: filesList.isEmpty
          ? []
          : [
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
                    final GetTypeNameTitle data = getTypeAndTitle(context: context, index: index);

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
                getTypeAndTitle: getTypeAndTitle(context: context, index: 6),
              ),
              SizedBox(height: 20.h),
              verticalTab(
                data: filesList[7],
                getTypeAndTitle: getTypeAndTitle(context: context, index: 7),
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
          Text(key: const Key("no-data"), AppLocalizations.of(context)?.noDataFound ?? ''),
        ],
      ),
    );
  }

  Widget recentData() {
    if (recentList.isEmpty) {
      return noDataFound();
    }
    return Column(
      key: const Key('recent-data'),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Row(
            children: [
              Text(
                key: const Key("recent-selected"),
                AppLocalizations.of(context)?.selected ?? '',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  homeBloc.add(ShowBottomMenuEvent(selected: !selected));
                },
                key: const Key("recent-selected-all"),
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
              index: index,
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
      key: const Key('bookmark-data'),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Row(
            children: [
              Text(
                key: const Key("bookmark-selected"),
                AppLocalizations.of(context)?.selected ?? '',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
              const Spacer(),
              InkWell(
                key: const Key("bookmark-select-all"),
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
              index: index,
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

  Widget verticalTab({required FilesModel data, required GetTypeNameTitle getTypeAndTitle}) {
    return InkWell(
      onTap: () async {
        if (getTypeAndTitle.fileType == "Directories") {
          await navigatorPush(
            context: context,
            navigate: DirectoriesScreen(path: '/storage/emulated/0/', showMenu: true, title: getTypeAndTitle.title),
          );
        } else {
          await navigatorPush(
            context: context,
            navigate: AllFile(fileType: getTypeAndTitle.fileType, title: getTypeAndTitle.title),
          );
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Image.asset(getTypeAndTitle.image, width: 55.w, fit: BoxFit.cover),
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: Text(
                  key: Key(getTypeAndTitle.title.toString()),
                  data.title,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
              // const Spacer(),
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
      key: Key(title.toString()),
      onTap: () {
        navigatorPush(
          context: context,
          navigate: AllFile(fileType: fileType, title: title),
        );
      },
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
              style: Theme.of(context).textTheme.displaySmall,
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

  Widget tab({required String title, required int count}) {
    return InkWell(
      key: Key(count.toString()),
      onTap: () {
        if (tabIndex == count) {
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
            boxShadow: tabIndex == count ? commonShadow() : [],
            gradient: tabIndex == count ? commonGradient() : null,
            borderRadius: BorderRadius.circular(10.w),
          ),
          padding: EdgeInsets.symmetric(vertical: 8.w),
          child: Center(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tabIndex == count ? ColorUtils.white : null,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
