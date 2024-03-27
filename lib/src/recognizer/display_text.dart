import 'dart:developer';

import 'package:clipboard/clipboard.dart';
import 'package:document_reader/src/recognizer/bloc/display_text_bloc.dart';
import 'package:document_reader/src/recognizer/bloc/display_text_event.dart';
import 'package:document_reader/src/recognizer/bloc/display_text_state.dart';
import 'package:document_reader/utils/AppColors.dart';
import 'package:document_reader/utils/AppImages.dart';
import 'package:document_reader/utils/common_appbar.dart';
import 'package:document_reader/utils/common_functions.dart';
import 'package:document_reader/utils/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

class DisplayText extends StatefulWidget {
  final String text;

  const DisplayText({super.key, required this.text});

  @override
  State<DisplayText> createState() => DisplayTextState();
}

class DisplayTextState extends State<DisplayText> {
  @override
  void initState() {
    super.initState();
    checkInternetConnection(context: context);
  }

  final DisplayTextBloc displayTextBloc = DisplayTextBloc();

  bool isEdit = false;
  final controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  int count = 5;

  getLength(String text) {
    List<String> words = text.split(' ');

    List<String> lines = [];
    String currentLine = '';

    for (String word in words) {
      if ((currentLine.length + word.length) <= 28) {
        currentLine += (currentLine.isEmpty ? '' : ' ') + word;
      } else {
        lines.add(currentLine);
        currentLine = word;
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }
    return lines.length < 6 ? 5 : lines.length;
  }

  @override
  Widget build(BuildContext context) {
    if (controller.text.isEmpty) {
      controller.text = widget.text;
      count = getLength(controller.text);
    }

    return BlocConsumer(
      bloc: displayTextBloc,
      listener: (context, DisplayTextBlocState state) {
        if (state is DisplayTextEditState) {
          isEdit = state.isEdit ?? false;
          if (isEdit) {
            _focus.requestFocus();
          } else {
            FocusScope.of(context).unfocus();
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 1),
            child: CustomAppbar(
              title: AppLocalizations.of(context)?.recognizeText ?? "",
              action: !isEdit
                  ? []
                  : [
                      IconButton(
                        key: const Key("close-btn"),
                        onPressed: () {
                          displayTextBloc.add(DisplayTextEdit(isEdit: false));
                        },
                        icon: const Icon(Icons.close),
                      )
                    ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.w),
                  child: Padding(
                    padding: EdgeInsets.all(30.w),
                    child: TextFormField(
                      maxLines: count,
                      readOnly: !isEdit,
                      controller: controller,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: ColorUtils.greyEEE,
                        contentPadding: EdgeInsets.all(20.w),
                        border: const OutlineInputBorder(borderSide: BorderSide.none),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 70.h,
                color: ColorUtils.greyE4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      key: const Key("edit"),
                      onTap: () => displayTextBloc.add(DisplayTextEdit(isEdit: true)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(IconStrings.edit, width: 20.w, key: const Key("edit-image")),
                          SizedBox(height: 10.h),
                          Text(AppLocalizations.of(context)?.edit ?? "", key: const Key("edit-text")),
                        ],
                      ),
                    ),
                    InkWell(
                      key: const Key("copy"),
                      onTap: () {
                        FlutterClipboard.copy(widget.text).then((_) {
                          showSnackBar(context: context, message: AppLocalizations.of(context)?.copiedSuccessfully ?? "");
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(IconStrings.copy, width: 20.w, key: const Key("copy-image")),
                          SizedBox(height: 10.h),
                          Text(AppLocalizations.of(context)?.copy ?? "", key: const Key("copy-text")),
                        ],
                      ),
                    ),
                    InkWell(
                      key: const Key("share"),
                      onTap: () {
                        log("share btn tap");
                        Share.share(widget.text);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(IconStrings.share1, width: 20.w, key: const Key("share-image")),
                          SizedBox(height: 10.h),
                          Text(AppLocalizations.of(context)?.share ?? "", key: const Key("share-text")),
                        ],
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
}
