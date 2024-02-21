// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:document_reader/src/img_editor/bloc/image_editor/image_editor_event.dart';
import 'package:document_reader/src/img_editor/bloc/image_editor/image_editor_state.dart';
import 'package:document_reader/src/img_editor/image_editor.dart';
import 'package:document_reader/utils/common_functions.dart';
import 'package:document_reader/utils/custom_snackbar.dart';
import 'package:document_reader/utils/logs.dart';
import 'package:document_reader/utils/navigation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image/image.dart' as imagelib;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class ImageEditorBloc extends Bloc<ImageEditorEvent, ImageEditorState> {
  ImageEditorBloc() : super(ImageEditorInitial()) {
    on<SetPdfNameEvent>((event, emit) {
      emit(SetPdfNameState(name: event.name));
    });

    on<SetCurrentIndexEvent>((event, emit) {
      emit(SetCurrentIndexState(index: event.index));
    });

    on<FilterApplyEvent>((event, emit) async {
      Uint8List data = await pathToUIntList(path: event.path);
      emit(FilterApplyState(path: data));
    });

    on<ConvertPathToIIntListEvent>((event, emit) async {
      final Uint8List path = await pathToUIntList(path: event.path);
      emit(ConvertPathToIIntListState(path: path));
    });

    on<ImageStatusEvent>((event, emit) async {
      emit(ImageStatusState(imageType: event.imageType));
    });

    on<SaveImageEvent>((event, emit) async {
      if (Platform.isIOS) {
        try {
          emit(SaveImageLoadingState());
          final Directory? docDir1 = await getDownloadsDirectory();
          final Directory docDir = Directory('${docDir1?.path}/document_reader');

          if (!(await docDir.exists())) {
            await docDir.create(recursive: true);
          }

          String name = 'document_reader_${DateTime.now().toLocal().microsecondsSinceEpoch}.pdf';
          String filePath = '${docDir.path}/$name';
          Uint8List imageBytes = await convertImageToPdf(event.imageList);
          await File(filePath).writeAsBytes(imageBytes);
          emit(SaveImageState(status: true));

          showSnackBar(
            message: AppLocalizations.of(currentContext)!.downloadSuccess,
          );
        } catch (e) {
          logs(message: "Save Image IOS E:-----> $e");
          emit(SaveImageState(status: false));
          showSnackBar(
            message: AppLocalizations.of(currentContext)!.somethingWentWrong,
            errorSnackBar: true,
          );
        }
        return;
      }
      try {
        emit(SaveImageLoadingState());
        final Directory directory = Directory("/storage/emulated/0/document_reader");
        if (!(await directory.exists())) {
          await directory.create(recursive: true);
        }

        String name = 'document_reader_${DateTime.now().toLocal().microsecondsSinceEpoch}.pdf';
        String filePath = '${directory.path}/$name';
        Uint8List imageBytes = await convertImageToPdf(event.imageList);
        await File(filePath).writeAsBytes(imageBytes);
        emit(SaveImageState(status: true));

        showSnackBar(
          message: AppLocalizations.of(currentContext)!.downloadSuccess,
        );
      } catch (e) {
        logs(message: "Save Image E:-----> $e");
        emit(SaveImageState(status: false));
        showSnackBar(
          message: AppLocalizations.of(currentContext)!.somethingWentWrong,
          errorSnackBar: true,
        );
      }
    });

    on<RemoveAtIndexEvent>((event, emit) {
      emit(RemoveAtIndexState(index: event.index));
    });

    on<FilterEvent>((event, emit) async {
      final path = await uIntListToPath(imageBytes: event.imagePath);

      File imageFile1 = File(path.toString());
      String fileName = imageFile1.path.split("/").last;

      var image = imagelib.decodeImage(await imageFile1.readAsBytes());
      var imageFile = imagelib.copyResize(image!, width: 600);
      await Future.delayed(const Duration(milliseconds: 100));
      emit(
        FilterState(
          imageFile: imageFile,
          imageStatus: ImageStatus.filter,
          fileName: fileName,
        ),
      );
    });

    on<SetFilterOptions>((event, emit) {
      emit(SetFilterOptionsState(index: event.index));
    });
  }

  final pdf = pw.Document();
  Future<Uint8List> convertImageToPdf(imageList) async {
    try {
      for (Uint8List imageData in imageList) {
        final imageProvider = pw.MemoryImage(imageData as dynamic);

        pdf.addPage(pw.Page(
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(imageProvider));
          },
        ));
      }
    } catch (e) {
      logs(message: "convertImageToPdf E:-----> $e");
      // showSnackBar(
      //   message: AppLocalizations.of(currentContext)!.somethingWentWrong,
      //   errorSnackBar: true,
      // );
    }

    return await pdf.save();
  }
}
