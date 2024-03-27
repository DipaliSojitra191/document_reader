// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:document_reader/src/img_editor/bloc/select_image/select_image_bloc.dart';
import 'package:document_reader/src/img_editor/bloc/select_image/select_image_event.dart';
import 'package:document_reader/src/img_editor/bloc/select_image/select_image_state.dart';
import 'package:document_reader/src/img_editor/image_editor.dart';
import 'package:document_reader/utils/AppColors.dart';
import 'package:document_reader/utils/circular_progrss_indicator.dart';
import 'package:document_reader/utils/common_appbar.dart';
import 'package:document_reader/utils/common_functions.dart';
import 'package:document_reader/utils/common_linear_gradient.dart';
import 'package:document_reader/utils/custom_btn.dart';
import 'package:document_reader/utils/custom_snackbar.dart';
import 'package:document_reader/utils/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelectImages extends StatefulWidget {
  const SelectImages({super.key});

  @override
  State<SelectImages> createState() => SelectImagesState();
}

class SelectImagesState extends State<SelectImages> {
  final SelectImageBloc selectImageBloc = SelectImageBloc();

  List<String> selectedAssets = [];
  List<SelectImageModel> assets = [];

  @override
  void initState() {
    super.initState();
    selectImageBloc.add(FetchAssetsEvent(context: context));

    checkInternetConnection(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: selectImageBloc,
      listener: (context, state) {
        if (state is FetchAssetsState) {
          assets = state.assets ?? [];
        } else if (state is AddAssetsState) {
          selectedAssets = state.selectedAssets;
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 1),
            child: CustomAppbar(
              title: AppLocalizations.of(context)?.convert_image_to_pdf,
            ),
          ),
          body: Column(
            children: [
              if (state is FetchAssetsLoadingState)
                const Expanded(child: Loader())
              else if (assets.isEmpty)
                Expanded(child: Center(child: Text(AppLocalizations.of(context)?.imageNotFound ?? "")))
              else
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: GridView.builder(
                          physics: const ClampingScrollPhysics(),
                          padding: EdgeInsets.all(10.w),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: assets.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () {
                                selectImageBloc.add(
                                  AddAssetsEvent(
                                    path: assets[index].path,
                                    selectedAssets: selectedAssets,
                                  ),
                                );
                              },
                              child: Stack(
                                children: <Widget>[
                                  Image.file(
                                    File(assets[index].path),
                                    fit: BoxFit.fill,
                                    frameBuilder: ((context, child, frame, wasSynchronouslyLoaded) {
                                      if (wasSynchronouslyLoaded) return child;
                                      return AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 200),
                                        child: frame != null ? child : const Loader(),
                                      );
                                    }),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: FileImage(File(assets[index].path)),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  if (selectedAssets.indexWhere((element) => element == assets[index].path) != -1)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: commonGradient(),
                                        ),
                                        child: Text(
                                          "${(selectedAssets.indexWhere((element) => element == assets[index].path)) + 1}",
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: ColorUtils.white),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      // SizedBox(height: 5.h),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: CustomBtn(
                          onTap: () async {
                            List<Uint8List> uInt8ListData = [];

                            for (var element in selectedAssets) {
                              final Uint8List? tempData = await loadImage(element);
                              if (tempData != null) {
                                uInt8ListData.add(tempData);
                              }
                            }

                            if (uInt8ListData.isNotEmpty) {
                              navigatorPush(
                                context: context,
                                navigate: ImageEditorScreen(
                                  uIntImageList: uInt8ListData,
                                  selectedAssets: selectedAssets,
                                ),
                              );
                            } else {
                              showSnackBar(
                                context: context,
                                message: "Image not selected",
                                errorSnackBar: true,
                              );
                            }
                          },
                          title: "${AppLocalizations.of(context)!.import} ${selectedAssets.isEmpty ? "" : "(${selectedAssets.length})"}",
                          radius: 8.w,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<Uint8List?> loadImage(String path) async {
    File imageFile = File(path);

    if (await imageFile.exists()) {
      List<int> imageBytes = await imageFile.readAsBytes();

      return Uint8List.fromList(imageBytes);
    } else {
      return null;
    }
  }
}

class SelectImageModel {
  String path;
  int count;

  SelectImageModel({
    required this.path,
    required this.count,
  });
}
