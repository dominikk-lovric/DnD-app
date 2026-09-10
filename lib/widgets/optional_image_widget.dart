import 'package:flutter/material.dart';

import 'package:dnd_app/services/icon_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OptionalImageWidget extends ConsumerStatefulWidget {
  final String path;
  final double height;

  const OptionalImageWidget(this.height, this.path, {super.key});

  @override
  ConsumerState<OptionalImageWidget> createState() =>
      _OptionalImageWidgetState();
}

class _OptionalImageWidgetState extends ConsumerState<OptionalImageWidget> {
  Image? image;

  @override
  void initState() {
    super.initState();
    image = IconService.getIcon(ref, widget.path);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.height,
      child: ClipOval(child: image),
    );
  }
}
