import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:daily_training_flutter/utils/AllColors.dart';

class CustomTextField extends StatefulWidget {
  final String hint;
  final String label;
  final bool enabled;
  final String? suffix;
  final bool isNumeric;
  final bool obscureText;
  final Color cursorColor;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color selectionColor;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const CustomTextField({
    Key? key,
    this.suffix,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    required this.hint,
    this.enabled = true,
    required this.label,
    this.isNumeric = false,
    required this.controller,
    this.obscureText = false,
    this.cursorColor = AllColors.white,
    this.keyboardType = TextInputType.text,
    this.selectionColor = AllColors.softGold,
    this.textInputAction = TextInputAction.done,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: widget.cursorColor,
          selectionColor: widget.selectionColor,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText && _obscureText,
              validator: widget.validator,
              keyboardType:
                  widget.isNumeric ? TextInputType.number : widget.keyboardType,
              textInputAction: widget.textInputAction,
              style: const TextStyle(color: AllColors.white),
              enabled: widget.enabled,
              inputFormatters: widget.isNumeric
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : null,
              cursorColor: widget.cursorColor,
              selectionControls: MaterialTextSelectionControls(),
              decoration: InputDecoration(
                filled: true,
                hintText: widget.hint,
                labelText: widget.label,
                fillColor: AllColors.background,
                labelStyle: const TextStyle(color: AllColors.white),
                hintStyle: const TextStyle(color: AllColors.softWhite),
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.obscureText
                    ? IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xFFCCA253),
                        ),
                        onPressed: _togglePasswordVisibility,
                      )
                    : widget.suffixIcon,
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 222, 159, 42)),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: Color.fromARGB(255, 222, 159, 42)),
                ),
              ),
            ),
          ),
          if (widget.suffix != null && widget.isNumeric)
            Positioned(
              top: 20,
              right: 10,
              child: Text(
                widget.suffix!,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
        ],
      ),
    );
  }
}
