import 'dart:async';

import 'package:flutter/material.dart';

import '../../injection_container.dart';
import '../theme/app_text_styles.dart';

class TypeWriterEffect extends StatefulWidget {
  final String text;
  final Duration duration;
  final Color? color;
  final double fontSize;

  const TypeWriterEffect({
    super.key,
    required this.text,
    this.duration = const Duration(milliseconds: 70),
    this.color,
    this.fontSize = 16.0,
  });

  @override
  // ignore: library_private_types_in_public_api
  _TypewriterEffectState createState() => _TypewriterEffectState();
}

class _TypewriterEffectState extends State<TypeWriterEffect> {
  String _displayText = "";
  late Timer _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    _timer = Timer.periodic(widget.duration, (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayText += widget.text[_currentIndex];
          _currentIndex++;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayText,
      style: AppTextStyles.bodyLarge(color: widget.color ?? colors.textPrimary),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
