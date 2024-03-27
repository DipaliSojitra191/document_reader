import 'package:document_reader/src/file/bloc/all_file_bloc.dart';
import 'package:document_reader/src/file/bloc/all_file_event.dart';
import 'package:document_reader/src/file/bloc/all_file_state.dart';
import 'package:document_reader/src/file/model/files_data_model.dart';
import 'package:document_reader/utils/AppColors.dart';
import 'package:document_reader/utils/AppImages.dart';
import 'package:document_reader/utils/circular_progrss_indicator.dart';
import 'package:document_reader/utils/common_appbar.dart';
import 'package:document_reader/utils/common_functions.dart';
import 'package:document_reader/utils/common_linear_gradient.dart';
import 'package:document_reader/utils/custom_data/custom_bottomsheet.dart';
import 'package:document_reader/utils/custom_textformfield.dart';
import 'package:document_reader/utils/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class DirectoriesScreen extends StatefulWidget {
  final bool showMenu;
  final String path;
  final String title;

  const DirectoriesScreen({
    super.key,
    required this.showMenu,
    required this.path,
    required this.title,
  });

  @override
  State<DirectoriesScreen> createState() => _DirectoriesScreenState();
}

class _DirectoriesScreenState extends State<DirectoriesScreen> {
  List<FilesDataModel> allFiles = [];
  List<FilesDataModel> allDocument = [];
  List<FilesDataModel> searchList = [];
  final AllFileBloc allFileBloc = AllFileBloc();
  bool search = false;

  @override
  void initState() {
    super.initState();
    checkInternetConnection(context: context);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      allFileBloc.add(DirSelectedEvent(index: 0));
    });
  }

  void getDocuments() {
    allFileBloc.add(
      GetFileEvent(context: context, fileType: "all", selected1: 0, selected2: 0),
    );
  }

  void setData() {
    allFileBloc.add(GetDirEvent(dir: widget.path));
  }

  int selected = 0;
  bool loader = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: allFileBloc,
      listener: (context, AllFileBlocState state) {
        if (state is GetDirState) {
          allFiles = state.allFiles;
        } else if (state is GetFileState) {
          allDocument = state.allFiles;
        } else if (state is GetFileLoadingState) {
          loader = true;
        } else if (state is DirSelectedState) {
          selected = state.index;
          if (selected == 0) {
            if (allFiles.isEmpty) {
              setData();
            }
          } else if (selected == 1) {
            if (allDocument.isEmpty) {
              getDocuments();
            }
          }
        } else if (state is SearchListState) {
          searchList = state.searchList;
        } else if (state is SearchOnTapState) {
          search = state.search;
          searchList = [];
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 1),
            child: CustomAppbar(
              title: widget.title,
              onPress: () {
                if (search == true) {
                  allFileBloc.add(SearchOnTapEvent(search: false));
                } else {
                  navigateBack(context: context);
                }
              },
              action: [
                InkWell(
                  onTap: () {
                    allFileBloc.add(SearchOnTapEvent(search: !search));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: commonGradient(),
                    ),
                    padding: EdgeInsets.all(5.w),
                    child: Icon(
                      !search ? Icons.search : Icons.close,
                      color: ColorUtils.white,
                    ),
                  ),
                ),
                SizedBox(width: 8.w)
              ],
              child: search
                  ? CustomTextFormField(
                      padding: EdgeInsets.zero,
                      hintText: AppLocalizations.of(context)?.search ?? "",
                      onChanged: (v) {
                        if (selected == 0) {
                          allFileBloc.add(
                            SearchListEvent(isDocument: false, allFiles: allFiles, searchText: v ?? ""),
                          );
                        } else {
                          allFileBloc.add(
                            SearchListEvent(isDocument: true, allFiles: allFiles, searchText: v ?? ""),
                          );
                        }
                      },
                    )
                  : null,
            ),
          ),
          body: Column(
            children: [
              if (widget.showMenu)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 15.h),
                  child: Row(
                    children: [
                      menu(title: AppLocalizations.of(context)?.storage ?? "", index: 0),
                      SizedBox(width: 10.w),
                      menu(title: AppLocalizations.of(context)?.allDocuments ?? "", index: 1),
                    ],
                  ),
                ),
              if (state is GetFileLoadingState)
                const Expanded(child: Loader())
              else if (selected == 1 ? allDocument.isEmpty : allFiles.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)?.noDirectoriesFound ?? "",
                    ),
                  ),
                )
              else if (search && searchList.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: searchList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final data = searchList[index];
                      bool isFolder = data.isFolder ?? false;

                      final image = getImageFromExt(
                        data.name.split(".").last,
                        isFolder: data.isFolder,
                      );
                      final date = DateFormat('yyyy-MM-dd').format(DateTime.parse(data.date));
                      final time = DateFormat('H:mm a').format(DateTime.parse(data.date));
                      return ListTile(
                        onTap: () {
                          if (isFolder) {
                            navigatorPush(
                              context: context,
                              navigate: DirectoriesScreen(
                                showMenu: false,
                                path: data.path.path,
                                title: data.name,
                              ),
                            );
                          } else {
                            openFileOnTap(data: data, context: context);
                          }
                        },
                        leading: SizedBox(
                          width: 60.w,
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(
                                  image.split("/").last == "outline_mcs.png" ? 8.w : 0.w,
                                ),
                                child: Image.asset(image),
                              ),
                            ],
                          ),
                        ),
                        title: Text(
                          data.name,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        subtitle: Builder(builder: (context) {
                          return Text(
                            "$date $time ${data.size}",
                            maxLines: 1,
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        }),
                        trailing: (data.isFolder ?? false)
                            ? IconButton(
                                onPressed: () {
                                  if (isFolder) {
                                    navigatorPush(
                                      context: context,
                                      navigate: DirectoriesScreen(showMenu: false, path: data.path.path, title: data.name),
                                    );
                                  } else {
                                    openFileOnTap(data: data, context: context);
                                  }
                                },
                                icon: const Icon(Icons.keyboard_arrow_right),
                              )
                            : null,
                      );
                    },
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: selected == 1 ? allDocument.length : allFiles.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final data = selected == 1 ? allDocument[index] : allFiles[index];
                      bool isFolder = data.isFolder ?? false;

                      final image = getImageFromExt(
                        data.name.split(".").last,
                        isFolder: data.isFolder,
                      );

                      String date = "";
                      String time = "";

                      if (data.date != "") {
                        date = DateFormat('yyyy-MM-dd').format(DateTime.parse(data.date));
                        time = "${DateFormat('H:mm a').format(DateTime.parse(data.date))} ";
                      }

                      return ListTile(
                        onTap: () {
                          if (isFolder) {
                            navigatorPush(
                              context: context,
                              navigate: DirectoriesScreen(
                                showMenu: false,
                                path: data.path.path,
                                title: data.name,
                              ),
                            );
                          } else {
                            openFileOnTap(data: data, context: context);
                          }
                        },
                        leading: SizedBox(
                          width: 60.w,
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(
                                  image.split("/").last == "outline_mcs.png" ? 8.w : 0.w,
                                ),
                                child: Image.asset(image),
                              ),
                            ],
                          ),
                        ),
                        title: Text(
                          data.name,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        subtitle: Text(
                          "$date $time${data.size}",
                          maxLines: 1,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: data.isFolder ?? false
                            ? IconButton(
                                onPressed: () {
                                  if (isFolder) {
                                    navigatorPush(
                                      context: context,
                                      navigate: DirectoriesScreen(showMenu: false, path: data.path.path, title: data.name),
                                    );
                                  } else {
                                    openFileOnTap(data: data, context: context);
                                  }
                                },
                                icon: const Icon(Icons.keyboard_arrow_right),
                              )
                            : null,
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget menu({
    required String title,
    required int index,
  }) {
    return InkWell(
      onTap: () {
        if (selected != index) {
          allFileBloc.add(SearchOnTapEvent(search: false));
        }
        allFileBloc.add(DirSelectedEvent(index: index));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
        decoration: selected == index ? BoxDecoration(gradient: commonGradient()) : BoxDecoration(color: ColorUtils.greyEEE),
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selected == index ? ColorUtils.white : ColorUtils.grey696,
              ),
        ),
      ),
    );
  }
}

///

class CommonListTile extends StatelessWidget {
  final FilesDataModel data;
  final VoidCallback getFilesOnTap;
  final VoidCallback bookmarkOnTap;
  final VoidCallback selectOptionOnTap;
  final VoidCallback onLongPress;
  final bool selectAll;
  final int index;
  final bool showRename;
  final VoidCallback? moveOutOnTap;

  const CommonListTile({
    super.key,
    required this.data,
    required this.index,
    required this.showRename,
    required this.onLongPress,
    required this.getFilesOnTap,
    required this.bookmarkOnTap,
    required this.selectOptionOnTap,
    this.moveOutOnTap,
    required this.selectAll,
  });

  @override
  Widget build(BuildContext context) {
    final image = getImageFromExt(
      data.name.split(".").last,
      isFolder: data.isFolder,
    );
    final date = DateFormat('yyyy-MM-dd').format(DateTime.parse(data.date));
    final time = DateFormat('H:mm a').format(DateTime.parse(data.date));
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 15.w),
      onLongPress: () => onLongPress(),
      key: Key("listTile-$index"),
      onTap: () => selectAll ? selectOptionOnTap() : openFileOnTap(data: data, context: context),
      leading: Padding(
        padding: EdgeInsets.all(
          image.split("/").last == "outline_mcs.png" ? 8.w : 0.w,
        ),
        child: Image.asset(image, key: const Key("image")),
      ),
      title: Text(
        key: const Key("title"),
        data.name,
        maxLines: 1,
        style: Theme.of(context).textTheme.displaySmall,
      ),
      subtitle: Text(
        key: const Key("subtitle"),
        "$date $time ${data.size}",
        maxLines: 1,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: selectAll
          ? InkWell(
              key: const Key("selectOption"),
              onTap: () {
                selectOptionOnTap();
              },
              child: Image.asset(
                key: Key(!data.selected ? "no selected" : "selected"),
                !data.selected ? IconStrings.unselectedOutline : IconStrings.selectedCircle,
                width: 18.w,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  key: Key("bookmark-inkwell-$index"),
                  onTap: () {
                    bookmarkOnTap();
                  },
                  child: Icon(
                    key: Key("bookmark-$index"),
                    Icons.bookmark,
                    color: data.bookmark ? ColorUtils.yellow00 : ColorUtils.greyDE,
                  ),
                ),
                SizedBox(width: 10.w),
                InkWell(
                  key: Key("more-$index"),
                  child: Icon(Icons.more_vert, color: ColorUtils.black),
                  onTap: () {
                    moreBottomSheet(
                      showRename: showRename,
                      moveOutOnTap: moveOutOnTap,
                      showShare: true,
                      context: context,
                      allFiles: data,
                      getFilesOnTap: () => getFilesOnTap(),
                      deleteOnTap: () => navigateBack(context: context),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
