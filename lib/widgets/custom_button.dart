import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutlined;
  final double height;
  final double? width;
  final EdgeInsets? padding;
  final double borderRadius;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isOutlined = false,
    this.height = 50,
    this.width,
    this.padding,
    this.borderRadius = 8,
    this.icon,
<<<<<<< HEAD
  }) 
=======
  });
>>>>>>> 24a5cd288fa8b05ddf6d021bb45a2ff48ae048f1

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: backgroundColor ?? theme.colorScheme.primary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                padding: padding,
              ),
              child: _buildButtonContent(context),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor ?? theme.colorScheme.primary,
                foregroundColor: textColor ?? Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                padding: padding,
              ),
              child: _buildButtonContent(context),
            ),
    );
  }

  Widget _buildButtonContent(BuildContext context) {
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isOutlined
                  ? (textColor ?? Theme.of(context).colorScheme.primary)
                  : textColor ?? Colors.white,
            ),
          ),
        ],
      );
    } else {
      return Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isOutlined
              ? (textColor ?? Theme.of(context).colorScheme.primary)
              : textColor ?? Colors.white,
        ),
      );
    }
  }
}
