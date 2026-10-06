import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/form_service.dart';
import 'package:dnd_app/services/json_service.dart';
import 'package:dnd_app/services/string_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/checklist.dart';
import 'package:dnd_app/widgets/description_column_widget.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:dnd_app/widgets/list_widget.dart';
import 'package:dnd_app/widgets/multiple_choice_field.dart';
import 'package:dnd_app/widgets/multiple_field.dart';
import 'package:dnd_app/widgets/radio_field.dart';
import 'package:dnd_app/widgets/selector_field.dart';
import 'package:dnd_app/widgets/table_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FormTextField extends ConsumerStatefulWidget {
  const FormTextField({
    super.key,
    required this.title,
    required this.formId,
    required this.path,
    this.initialValue = "",
    this.color = 2,
  });
  final String title;
  final String formId;
  final String path;
  final String initialValue;
  final int color;

  @override
  ConsumerState<FormTextField> createState() => _FormTextFieldState();
}

class _FormTextFieldState extends ConsumerState<FormTextField> {
  late final FormController formController;
  late final List<String> path;
  late final String startText;

  @override
  void initState() {
    super.initState();
    formController = ref.read(formControllerProvider(widget.formId).notifier);
    path = widget.path.split(".");
    final saved = formController.getValue(path);
    startText = saved is String ? saved : widget.initialValue;
    Future.microtask(() {
      if (!mounted) return;
      formController.initPath(path, widget.initialValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(colorControllerProvider);
    ref.watch(textStyleControllerProvider);
    final colorController = ref.read(colorControllerProvider.notifier);
    final textStyleController = ref.read(textStyleControllerProvider.notifier);
    return TextFormField(
      scrollPadding: EdgeInsets.zero,
      style: textStyleController.getTextStyle(6, 4),
      initialValue: startText,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        label: Text(
          widget.title,
          style: textStyleController.getTextStyle(6, 5),
        ),
        filled: true,
        fillColor: colorController.getColor(widget.color),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(
            Radius.circular(MediaQuery.sizeOf(context).height / 72),
          ),
        ),
      ),
      cursorColor: colorController.getColor(1),
      onChanged: (value) => formController.setValue(path, value),
    );
  }
}
