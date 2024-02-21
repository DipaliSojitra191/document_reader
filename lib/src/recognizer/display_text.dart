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
  State<DisplayText> createState() => _DisplayTextState();
}

class _DisplayTextState extends State<DisplayText> {
  @override
  void initState() {
    super.initState();
    checkInternetConnection();
  }

  final DisplayTextBloc displayTextBloc = DisplayTextBloc();

  bool isEdit = false;
  final controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  int count = 5;
  @override
  Widget build(BuildContext context) {
    if (controller.text.isEmpty) {
      controller.text = widget.text;
      String text = controller.text;
      int numberOfLines = (text.length / 27).ceil();
      count = numberOfLines;
    }

    return BlocConsumer(
      bloc: displayTextBloc,
      listener: (context, DisplayTextState state) {
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
              title: AppLocalizations.of(context)!.recognizeText,
              action: !isEdit
                  ? []
                  : [
                      IconButton(
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
                      onTap: () => displayTextBloc.add(DisplayTextEdit(isEdit: true)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(IconStrings.edit, width: 20.w),
                          SizedBox(height: 10.h),
                          Text(AppLocalizations.of(context)!.edit),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        FlutterClipboard.copy(widget.text).then((value) {
                          showSnackBar(message: AppLocalizations.of(context)!.copiedSuccessfully);
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(IconStrings.copy, width: 20.w),
                          SizedBox(height: 10.h),
                          Text(AppLocalizations.of(context)!.copy),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => Share.share(widget.text),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(IconStrings.share1, width: 20.w),
                          SizedBox(height: 10.h),
                          Text(AppLocalizations.of(context)!.share),
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
