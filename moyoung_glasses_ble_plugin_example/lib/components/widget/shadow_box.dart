import 'package:flutter/material.dart';

class ShadowBox extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final double? borderRadius;
  final Color? shadowColor;
  final Offset? offset;
  final double? blurRadius;
  final double? spreadRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const ShadowBox({
    Key? key,
    this.child,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderRadius,
    this.shadowColor,
    this.offset,
    this.blurRadius,
    this.spreadRadius,
    this.padding,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(borderRadius ?? 4.0),
          boxShadow: [
            BoxShadow(
                color: shadowColor ?? const Color(0xffB7C5E3),
                offset: offset ?? const Offset(0.0, 6.0),
                blurRadius: blurRadius ?? 10.0,
                spreadRadius: spreadRadius ?? 0.0)
          ]),
      padding: padding ?? EdgeInsets.zero,
      margin: margin ?? EdgeInsets.zero,
      child: child,
    );
  }
}
