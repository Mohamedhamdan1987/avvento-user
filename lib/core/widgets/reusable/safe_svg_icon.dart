import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A safe SVG icon widget that falls back to Material Icon if SVG asset is not found
class SafeSvgIcon extends StatefulWidget {
  final String iconName;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;
  final EdgeInsetsGeometry? padding;
  final IconData fallbackIcon;

  const SafeSvgIcon({
    super.key,
    required this.iconName,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
    this.padding,
    this.fallbackIcon = Icons.image,
  });

  @override
  State<SafeSvgIcon> createState() => _SafeSvgIconState();
}

class _SafeSvgIconState extends State<SafeSvgIcon> {
  bool _assetExists = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAssetExists();
  }

  Future<void> _checkAssetExists() async {
    try {
      await rootBundle.load(widget.iconName);
      if (mounted) {
        setState(() {
          _assetExists = true;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _assetExists = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: widget.padding,
        width: widget.width,
        height: widget.height,
        child: Icon(
          widget.fallbackIcon,
          size: widget.width ?? widget.height ?? 24,
          color: widget.color,
        ),
      );
    }

    if (!_assetExists) {
      // Fallback to Material Icon if SVG doesn't exist
      return Container(
        padding: widget.padding,
        width: widget.width,
        height: widget.height,
        child: Icon(
          widget.fallbackIcon,
          size: widget.width ?? widget.height ?? 24,
          color: widget.color,
        ),
      );
    }

    return Container(
      padding: widget.padding,
      child: SvgPicture.asset(
        widget.iconName,
        width: widget.width,
        height: widget.height,
        colorFilter: widget.color != null
            ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
            : null,
        fit: widget.fit,
      ),
    );
  }
}