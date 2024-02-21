import 'package:document_reader/utils/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String?)? validator;
  final Function(String?)? onChanged;
  final int? maxLines;
  final bool? readOnly;
  final bool? enabled;
  final Color? cursorColor;
  final TextAlign? textAlign;

  final int? maxLength;
  final TextStyle? style;

  final bool? showCursor;
  final bool? obscuredText;

  final double? cursorRadius;
  final FocusNode? focusNode;

  final String? obscuringCharacter;
  final TextInputType? textInputType;

  final OutlineInputBorder? border;
  final OutlineInputBorder? focusBorder;
  final OutlineInputBorder? enabledBorder;

  final VoidCallback? onTap;

  final EdgeInsetsGeometry? padding;
  final bool? filled;
  final Color? filledColor;
  final String? hintText;
  final String? labelText;
  final TextStyle? hintStyle;
  final IconButton? suffixIcon;
  final Widget? prefixIcon;
  final TextStyle? labelStyle;
  final bool? isDense;

  final Iterable<String>? autoFillHints;
  final TextInputAction? textInputAction;
  final TextCapitalization? textCapitalization;
  final String? initialValue;

  const CustomTextFormField({
    super.key,
    this.controller,
    this.validator,
    this.maxLines,
    this.readOnly,
    this.enabled,
    this.cursorColor,
    this.textAlign,
    this.maxLength,
    this.style,
    this.showCursor,
    this.focusNode,
    this.obscuredText,
    this.textInputType,
    this.obscuringCharacter,
    this.cursorRadius,
    this.border,
    this.enabledBorder,
    this.focusBorder,
    this.padding,
    this.filled,
    this.filledColor,
    this.hintText,
    this.labelText,
    this.hintStyle,
    this.prefixIcon,
    this.suffixIcon,
    this.isDense,
    this.labelStyle,
    this.autoFillHints,
    this.textInputAction,
    this.onTap,
    this.onChanged,
    this.textCapitalization,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onTap: onTap,
      maxLines: maxLines ?? 1,
      cursorHeight: 20.h,
      cursorColor: cursorColor ?? ColorUtils.primary,
      enabled: enabled ?? true,
      readOnly: readOnly ?? false,
      textCapitalization: TextCapitalization.words,
      autofillHints: autoFillHints ?? [],
      validator: (v) => validator!(v),
      textInputAction: textInputAction ?? TextInputAction.next,
      textAlign: textAlign ?? TextAlign.start,
      maxLength: maxLength ?? 1000,
      initialValue: initialValue,
      style: style ?? Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600),
      focusNode: focusNode,
      showCursor: showCursor ?? true,
      obscureText: obscuredText ?? false,
      obscuringCharacter: obscuringCharacter ?? '*',
      keyboardType: textInputType ?? TextInputType.name,
      cursorRadius: Radius.circular(cursorRadius ?? 0.0),
      onChanged: (v) => onChanged != null ? onChanged!(v) : (v) {},
      decoration: InputDecoration(
        border: border,
        enabledBorder: enabledBorder,
        focusedBorder: focusBorder,
        contentPadding: padding,
        counterText: '',
        filled: filled ?? false,
        fillColor: filledColor,
        isDense: isDense,
        labelText: labelText,
        hintText: hintText,
        hintStyle: hintStyle ?? Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600),
        prefix: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
