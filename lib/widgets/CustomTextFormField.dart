import 'package:flutter/material.dart';
import 'package:daily_training_flutter/utils/Date.dart';
import 'package:daily_training_flutter/utils/AllColors.dart';

class CustomTextFormField extends StatefulWidget {
  final bool filled;
  final String? hint;
  final String? label;
  final bool readOnly;
  final Color? fillColor;
  final Color cursorColor;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final Color selectionColor;
  final TextStyle? labelStyle;
  final OutlineInputBorder? border;
  final EdgeInsetsGeometry? padding;
  final OutlineInputBorder? focusedBorder;
  final OutlineInputBorder? enabledBorder;
  final String? Function(String?)? validator;
  final TextEditingController finalDateController;
  final TextEditingController initialDateController;

  const CustomTextFormField({
    super.key,
    this.hint,
    this.label,
    this.border,
    this.padding,
    this.fillColor,
    this.validator,
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.focusedBorder,
    this.enabledBorder,
    this.filled = true,
    this.readOnly = false,
    required this.finalDateController,
    required this.initialDateController,
    this.cursorColor = AllColors.white,
    this.selectionColor = AllColors.softGold,
  });

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleTap(BuildContext context) async {
    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      saveText: 'Ok',
      confirmText: 'Ok',
      cancelText: 'Cancelar',
      currentDate: Date.now(),
      lastDate: Date.year(2100),
      firstDate: Date.year(2000),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AllColors.orange,
              primaryFixed: AllColors.background,
              surface: AllColors.background,
              onPrimary: AllColors.background,
              onSurface: AllColors.background,
            ),
            dialogBackgroundColor: AllColors.softBlack,
          ),
          child: child!,
        );
      },
    );
    if (pickedRange != null) {
      widget.finalDateController.text = Date(date: pickedRange.end).format();
      widget.initialDateController.text =
          Date(date: pickedRange.start).format();
      _controller.text =
          '${Date(date: pickedRange.start).format()} - ${Date(date: pickedRange.end).format()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 500, maxWidth: 600),
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: widget.cursorColor,
            selectionColor: widget.selectionColor,
          ),
        ),
        child: TextFormField(
          controller: _controller,
          readOnly: widget.readOnly,
          onTap: () => _handleTap(context),
          style: const TextStyle(color: AllColors.white),
          decoration: InputDecoration(
            filled: true,
            hintText: widget.hint,
            labelText: widget.label,
            fillColor: AllColors.background,
            labelStyle: const TextStyle(color: AllColors.white),
            hintStyle: const TextStyle(color: AllColors.softWhite),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AllColors.gold),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AllColors.softWhite),
            ),
          ),
          validator: widget.validator,
        ),
      ),
    );
  }
}
