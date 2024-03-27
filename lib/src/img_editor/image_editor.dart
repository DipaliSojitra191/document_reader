// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:croppy/croppy.dart';
import 'package:document_reader/src/bottombar/bottombar.dart';
import 'package:document_reader/src/img_editor/bloc/image_editor/image_editor_bloc.dart';
import 'package:document_reader/src/img_editor/bloc/image_editor/image_editor_event.dart';
import 'package:document_reader/src/img_editor/bloc/image_editor/image_editor_state.dart';
import 'package:document_reader/utils/AppColors.dart';
import 'package:document_reader/utils/AppImages.dart';
import 'package:document_reader/utils/circular_progrss_indicator.dart';
import 'package:document_reader/utils/common_appbar.dart';
import 'package:document_reader/utils/common_functions.dart';
import 'package:document_reader/utils/common_linear_gradient.dart';
import 'package:document_reader/utils/custom_data/custom_dialog.dart';
import 'package:document_reader/utils/navigation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:photofilters/photofilters.dart';

class ImgPath {
  final Uint8List path;

  ImgPath({required this.path});
}

enum ImageStatus { none, filter, crop }

class ImageEditorScreen extends StatefulWidget {
  final List<Uint8List> uIntImageList;
  final List<String> selectedAssets;

  const ImageEditorScreen({
    super.key,
    required this.uIntImageList,
    required this.selectedAssets,
  });

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  ImageStatus imageType = ImageStatus.none;

  bool showLoader = false;
  int currentIndex = 0;

  img.Image? imageFile;
  String fileName = "";
  List<Filter> filters = presetFiltersList;
  String pdfName = '';
  ImageEditorBloc imageEditorBloc = ImageEditorBloc();

  @override
  void initState() {
    super.initState();
    checkInternetConnection(context: context);
  }

  @override
  Widget build(BuildContext context) {
    pdfName = "${AppLocalizations.of(context)!.allDocumentReader.toString().replaceAll(" ", "_")}_${DateTime.now().toLocal().microsecondsSinceEpoch}";
    return BlocConsumer(
      bloc: imageEditorBloc,
      listener: (context, ImageEditorState state) {
        if (state is SetPdfNameState) {
          pdfName = state.name;
        } else if (state is SetCurrentIndexState) {
          currentIndex = state.index;
        } else if (state is FilterApplyState) {
          widget.uIntImageList[currentIndex] = state.path;

          filterIndex = 0;
          _filter = filters[0];
          imageType = ImageStatus.none;
        } else if (state is SetFilterOptionsState) {
          _filter = filters[state.index];
          filterIndex = state.index;
        } else if (state is SaveImageLoadingState) {
          showLoader = true;
        } else if (state is SaveImageState) {
          if (state.status == true) {
            removeRoute(const BottomBarScreen(currentindex: 0), context: context);
          }
          showLoader = false;
        } else if (state is ImageStatusState) {
          imageType = state.imageType;
          _filter = filters[0];
          filterIndex = 0;
        } else if (state is RemoveAtIndexState) {
          widget.uIntImageList.removeAt(state.index);
          widget.selectedAssets.removeAt(state.index);
          if (widget.uIntImageList.isEmpty) {
            navigateBack(context: context);
          }
        } else if (state is FilterState) {
          filterIndex = 0;
          cachedFilters = {};
          _filter = null;

          fileName = state.fileName;
          imageFile = state.imageFile;
          imageType = state.imageStatus;
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 1),
            child: CustomAppbar(
              title: pdfName,
              onPress: () {
                if (imageType != ImageStatus.none) {
                  imageEditorBloc.add(ImageStatusEvent(imageType: ImageStatus.none));
                } else {
                  navigateBack(context: context);
                }
              },
              action: [
                if (imageType == ImageStatus.filter)
                  IconButton(
                    onPressed: () async {
                      File file = await saveFilteredImage();
                      imageEditorBloc.add(FilterApplyEvent(path: file.path));
                    },
                    icon: const Icon(Icons.check),
                  )
                else if (imageType == ImageStatus.none)
                  IconButton(
                    onPressed: () async {
                      final name = await renameDialog(context: context, name: pdfName.split(".").first);

                      if (name != "") {
                        imageEditorBloc.add(SetPdfNameEvent(name: name));
                      }
                    },
                    icon: Image.asset(IconStrings.edit, scale: 5.w),
                  )
              ],
            ),
          ),
          body: Column(
            children: [
              if (imageType == ImageStatus.filter)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(10.w),
                    child: _buildFilteredImage(_filter, imageFile, fileName),
                  ),
                )
              else if (imageType == ImageStatus.none)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Image.memory(
                      widget.uIntImageList[currentIndex] as dynamic,
                      fit: BoxFit.fitWidth,
                      frameBuilder: ((context, child, frame, wasSynchronouslyLoaded) {
                        if (wasSynchronouslyLoaded) return child;
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: frame != null ? child : const Loader(),
                        );
                      }),
                    ),
                  ),
                ),
              SizedBox(
                height: 70.h,
                child: imageType == ImageStatus.none
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (currentIndex != 0) {
                                    imageEditorBloc.add(
                                      SetCurrentIndexEvent(index: currentIndex - 1),
                                    );
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: currentIndex == 0 ? ColorUtils.greyEEE : ColorUtils.grey3D3,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(3.w),
                                    child: Icon(
                                      Icons.keyboard_arrow_left,
                                      color: currentIndex == 0 ? ColorUtils.grey696 : ColorUtils.greyF4F,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                child: Text(
                                  "${currentIndex + 1}/${widget.uIntImageList.length}",
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  if ((currentIndex + 1) < widget.uIntImageList.length) {
                                    imageEditorBloc.add(
                                      SetCurrentIndexEvent(index: currentIndex + 1),
                                    );
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (currentIndex + 1) == widget.uIntImageList.length ? ColorUtils.greyEEE : ColorUtils.grey3D3,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(3.w),
                                    child: Icon(
                                      Icons.keyboard_arrow_right,
                                      color: (currentIndex + 1) == widget.uIntImageList.length ? ColorUtils.grey696 : ColorUtils.greyF4F,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                    : const SizedBox(),
              ),
              showBottomMenu(),
            ],
          ),
        );
      },
    );
  }

  Widget showBottomMenu() {
    return Container(
      height: 70.h,
      color: ColorUtils.greyE4,
      child: optionFilter(),
    );
  }

  Widget optionFilter() {
    if (imageType == ImageStatus.filter) {
      return Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Container(
              width: 37.w,
              height: 32.h,
              decoration: BoxDecoration(
                gradient: commonGradient(),
                borderRadius: BorderRadius.circular(10.w),
              ),
              child: IconButton(
                onPressed: () {
                  imageEditorBloc.add(
                    ImageStatusEvent(imageType: ImageStatus.none),
                  );
                },
                padding: EdgeInsets.zero,
                icon: Icon(Icons.arrow_back_outlined, color: ColorUtils.white),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () => imageEditorBloc.add(SetFilterOptions(index: index)),
                  child: Container(
                    padding: const EdgeInsets.all(5.0),
                    child: _buildFilterThumbnail(
                      filter: filters[index],
                      image: imageFile,
                      filename: fileName,
                      index: index,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              SizedBox(width: 10.w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: InkWell(
                  onTap: () => navigateBack(context: context),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(IconStrings.add, width: 18.w),
                      SizedBox(height: 10.h),
                      Text(AppLocalizations.of(context)!.add),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: InkWell(
                  onTap: () {
                    imageEditorBloc.add(FilterEvent(imagePath: widget.uIntImageList[currentIndex]));
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(IconStrings.filter1, width: 18.w),
                      SizedBox(height: 10.h),
                      Text(AppLocalizations.of(context)!.filter),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: InkWell(
                  onTap: () async {
                    await cropOnTap(image: widget.uIntImageList[currentIndex]);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(IconStrings.crop, width: 18.w),
                      SizedBox(height: 10.h),
                      Text(AppLocalizations.of(context)!.crop),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: InkWell(
                  onTap: () {
                    deleteDialog(
                      context: context,
                      callback: () {
                        imageEditorBloc.add(RemoveAtIndexEvent(index: currentIndex));
                      },
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(IconStrings.delete2, width: 18.w),
                      SizedBox(height: 10.h),
                      Text(AppLocalizations.of(context)!.delete),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10.w),
            ],
          ),
        ),
        VerticalDivider(
          color: ColorUtils.greyD7,
          width: 0,
        ),
        SizedBox(width: 10.w),
        InkWell(
          onTap: () {
            if (!showLoader) {
              imageEditorBloc.add(SaveImageEvent(imageList: widget.uIntImageList, context: context));
            }
          },
          child: Container(
            height: 30.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              gradient: commonGradient(),
              borderRadius: BorderRadius.circular(10.w),
            ),
            child: Center(
              child: showLoader
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: const Loader(color: Colors.white, strokeWidth: 3),
                    )
                  : Text(
                      AppLocalizations.of(context)!.save,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: ColorUtils.white),
                    ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
      ],
    );
  }

  /// FILTER IMAGE
  int filterIndex = 0;
  Filter? _filter;
  Map<String, List<int>?> cachedFilters = {};

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/filtered_${_filter?.name ?? "_"}_$fileName');
  }

  Future<File> saveFilteredImage() async {
    try {
      var imageFile = await _localFile;
      await imageFile.writeAsBytes(cachedFilters[_filter?.name ?? "_"]!);

      return imageFile;
    } catch (e) {
      return File("");
    }
  }

  Widget _buildFilteredImage(Filter? filter, img.Image? image, String? filename) {
    if (cachedFilters[filter?.name ?? "_"] == null) {
      return FutureBuilder<List<int>>(
        future: compute(
          applyFilter,
          {"filter": filter, "image": image, "filename": filename},
        ),
        builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return loader;
            case ConnectionState.active:
            case ConnectionState.waiting:
              return loader;
            case ConnectionState.done:
              if (snapshot.hasError) {
                return const Center(child: Text("Error"));
              }
              cachedFilters[filter?.name ?? "_"] = snapshot.data;
              return Image.memory(snapshot.data as dynamic);
          }
          // unreachable
        },
      );
    } else {
      return Image.memory(cachedFilters[filter?.name ?? "_"] as dynamic);
    }
  }

  _buildFilterThumbnail({
    required Filter filter,
    img.Image? image,
    String? filename,
    required int index,
  }) {
    if (cachedFilters[filter.name] == null) {
      return FutureBuilder<List<int>>(
        future: compute(applyFilter, <String, dynamic>{"filter": filter, "image": image, "filename": filename}),
        builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return loader;
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              cachedFilters[filter.name] = snapshot.data;
              return filterDD(index: index, filter: filter);
          }
        },
      );
    } else {
      return filterDD(index: index, filter: filter);
    }
  }

  Widget filterDD({required int index, required Filter filter}) {
    return Stack(
      children: [
        SizedBox(
          width: 55.w,
          height: 65.h,
          child: Image.memory(
            cachedFilters[filter.name] as dynamic,
            fit: BoxFit.fill,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            width: 70.w,
            height: 15.h,
            color: index == filterIndex ? ColorUtils.primary : ColorUtils.grey70,
            child: Center(
              child: Text(
                filter.name,
                maxLines: 1,
                style: TextStyle(color: ColorUtils.white, fontSize: 8.sp),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget loader = const SizedBox(
    height: 60.0,
    width: 60.0,
    child: Loader(),
  );

  CroppableImageData? _data;
  ui.Image? _croppedImage;
  CropSettings cropSettings = CropSettings.initial();

  Future<dynamic> cropOnTap({required Uint8List image}) async {
    ImageProvider<Object> imageProviders = MemoryImage(image);

    _data = null;
    _croppedImage = null;
    cropSettings = CropSettings.initial();

    if (Platform.isIOS) {
      final data = await showCupertinoImageCropper(
        context,
        locale: cropSettings.locale,
        imageProvider: imageProviders,
        initialData: _data,
        cropPathFn: cropSettings.cropShapeFn,
        enabledTransformations: cropSettings.enabledTransformations,
        allowedAspectRatios: cropSettings.forcedAspectRatio != null ? [cropSettings.forcedAspectRatio!] : null,
        postProcessFn: (result) async {
          _croppedImage?.dispose();

          _croppedImage = result.uiImage;
          _data = result.transformationsData;

          RawImage rawImage = RawImage(image: _croppedImage);
          ui.Image? imageProvider = rawImage.image;

          final Uint8List? uint8List = await encodeImageToUint8List(imageProvider!);
          widget.uIntImageList[currentIndex] = uint8List!;
          setState(() {});

          return result;
        },
      );
      return data;
    } else {
      final data = await showMaterialImageCropper(
        context,
        locale: cropSettings.locale,
        imageProvider: imageProviders,
        initialData: _data,
        cropPathFn: cropSettings.cropShapeFn,
        enabledTransformations: cropSettings.enabledTransformations,
        allowedAspectRatios: cropSettings.forcedAspectRatio != null ? [cropSettings.forcedAspectRatio!] : null,
        postProcessFn: (result) async {
          _croppedImage?.dispose();

          _croppedImage = result.uiImage;
          _data = result.transformationsData;

          RawImage rawImage = RawImage(image: _croppedImage);
          ui.Image? imageProvider = rawImage.image;

          final Uint8List? uint8List = await encodeImageToUint8List(imageProvider!);
          widget.uIntImageList[currentIndex] = uint8List!;
          setState(() {});

          return result;
        },
      );
      return data;
    }
  }

  Future<Uint8List?> encodeImageToUint8List(ui.Image image) async {
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}

class CropSettings {
  CropSettings({
    required this.cropShapeFn,
    required this.enabledTransformations,
    required this.forcedAspectRatio,
    this.locale = const Locale('en'),
  });

  CropSettings.initial()
      : this(
          cropShapeFn: aabbCropShapeFn,
          enabledTransformations: Transformation.values,
          forcedAspectRatio: null,
        );

  final CropShapeFn cropShapeFn;
  final List<Transformation> enabledTransformations;
  final CropAspectRatio? forcedAspectRatio;
  final Locale locale;

  CropSettings copyWith({
    CropShapeFn? cropShapeFn,
    List<Transformation>? enabledTransformations,
    CropAspectRatio? forcedAspectRatio,
    Locale? locale,
  }) {
    return CropSettings(
      cropShapeFn: cropShapeFn ?? this.cropShapeFn,
      enabledTransformations: enabledTransformations ?? this.enabledTransformations,
      forcedAspectRatio: forcedAspectRatio ?? this.forcedAspectRatio,
      locale: locale ?? this.locale,
    );
  }

  CropSettings copyWithNoForcedAspectRatio() {
    return CropSettings(
      cropShapeFn: cropShapeFn,
      enabledTransformations: enabledTransformations,
      forcedAspectRatio: null,
      locale: locale,
    );
  }
}
