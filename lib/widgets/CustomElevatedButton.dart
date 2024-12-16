import 'package:daily_training_flutter/utils/AllColors.dart';
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final Widget? child;
  final bool isLoading;
  final double? fontSize;
  final Color? iconColor;
  final Color? textColor;
  final double? elevation;
  final String? labelText;
  final Size? maximumSize;
  final Size? minimumSize;
  final IconData? iconData;
  final double? borderRadius;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;

  const CustomElevatedButton({
    super.key,
    this.child,
    this.fontSize,
    this.iconData,
    this.iconColor,
    this.labelText,
    this.onPressed,
    this.textColor,
    this.elevation,
    this.textStyle,
    this.maximumSize,
    this.minimumSize,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.isLoading = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: padding,
        textStyle: textStyle,
        maximumSize: maximumSize,
        minimumSize: minimumSize,
        elevation: elevation ?? 2.0,
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AllColors.gold,
              ),
            )
          : child ??
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (iconData != null)
                    Icon(iconData,
                        color: iconColor ?? textColor, size: fontSize ?? 20),
                  if (labelText != null && iconData != null)
                    const SizedBox(width: 8), // Espaço entre ícone e texto
                  if (labelText != null)
                    Text(
                      labelText!,
                      style: TextStyle(
                        color: textColor ?? Colors.white,
                        fontSize: fontSize ?? 16,
                      ),
                    ),
                ],
              ),
    );
  }
}
