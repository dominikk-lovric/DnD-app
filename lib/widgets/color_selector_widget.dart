import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ColorSelectorWidget extends ConsumerStatefulWidget {
  int setting;
  final VoidCallback? onSaved;

  ColorSelectorWidget(this.setting, {super.key, this.onSaved});

  @override
  ConsumerState<ColorSelectorWidget> createState() => _ColorSelectorWidget();
}

class _ColorSelectorWidget extends ConsumerState<ColorSelectorWidget> {
  late final SettingsController settingsController;
  late final ColorController colorController;
  _ColorSelectorWidget();

  late final TextEditingController rController;
  late final TextEditingController gController;
  late final TextEditingController bController;

  late int INT32;
  late List<int> ARGB;

  @override
  void initState() {
    super.initState();
    settingsController = ref.read(settingsControllerProvider.notifier);
    colorController = ref.read(colorControllerProvider.notifier);
    INT32 = colorController.getColor(widget.setting).toARGB32();
    ARGB = colorController.fromARGB32(INT32);

    rController = TextEditingController(text: ARGB[1].toString());
    gController = TextEditingController(text: ARGB[2].toString());
    bController = TextEditingController(text: ARGB[3].toString());
  }

  @override
  void dispose() {
    rController.dispose();
    gController.dispose();
    bController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height =
        (settingsController.getSetting("listItemHeight") ?? 50.0) * 2;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 350 * MediaQuery.sizeOf(context).width / 72,
      ),
      child: Container(
        child: InputDecorator(
          decoration: InputDecoration(
            filled: true,
            fillColor: colorController.getColor(3),
            labelText: colorController.getColorNames()[widget.setting],
            labelStyle: TextStyle(color: colorController.getColor(4)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: colorController.getColor(6),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Wrap(
              spacing: MediaQuery.sizeOf(context).width / 144,
              runSpacing: MediaQuery.sizeOf(context).width / 72,
              alignment: WrapAlignment.center,
              children: [
                Container(
                  height: MediaQuery.sizeOf(context).width / 12,
                  width: MediaQuery.sizeOf(context).width / 12,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(ARGB[0], ARGB[1], ARGB[2], ARGB[3]),
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Wrap(
                  spacing: MediaQuery.sizeOf(context).width / 72,
                  runSpacing: MediaQuery.sizeOf(context).width / 72,
                  children: [
                    colorInput(rController, "R", 1),
                    colorInput(gController, "G", 2),
                    colorInput(bController, "B", 3),
                  ],
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 350) {
                      return Wrap(
                        spacing: MediaQuery.sizeOf(context).width / 144,
                        runSpacing: MediaQuery.sizeOf(context).width / 72,
                        children: [ResetButtonWIdget(), SaveButtonWidget()],
                      );
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: MediaQuery.sizeOf(context).width / 72,
                      children: [ResetButtonWIdget(), SaveButtonWidget()],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget colorInput(TextEditingController controller, String label, int index) {
    return SizedBox(
      width: 60,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: TextStyle(color: colorController.getColor(4)),
        decoration: InputDecoration(
          filled: true,
          fillColor: colorController.getColor(2),
          labelText: label,
          labelStyle: TextStyle(color: colorController.getColor(4)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorController.getColor(6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: colorController.getColor(4),
              width: 2,
            ),
          ),
        ),
        onChanged: (value) {
          final n = int.tryParse(value);
          if (n == null) {
            controller.text = "0";
            setState(() {
              ARGB[index] = 0;
            });
            return;
          }
          setState(() {
            ARGB[index] = n;
          });
        },
      ),
    );
  }

  Widget ResetButtonWIdget() {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.hovered)) {
            return colorController.getColor(1);
          }
          return colorController.getColor(0);
        }),
        foregroundColor: WidgetStateProperty.all(colorController.getColor(4)),
      ),
      onPressed: () async {
        final color = colorController.getBasicColor(widget.setting);
        colorController.setColor(widget.setting, color);
        setState(() {
          ARGB = colorController.fromARGB32(color.toARGB32());

          rController.text = ARGB[1].toString();
          gController.text = ARGB[2].toString();
          bController.text = ARGB[3].toString();
        });
      },
      child: Text("reset"),
    );
  }

  Widget SaveButtonWidget() {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.hovered)) {
            return colorController.getColor(1);
          }
          return colorController.getColor(0);
        }),
        foregroundColor: WidgetStateProperty.all(colorController.getColor(4)),
      ),
      onPressed: () async {
        final color = Color.fromARGB(ARGB[0], ARGB[1], ARGB[2], ARGB[3]);

        colorController.setColor(widget.setting, color);
      },
      child: const Text("Save"),
    );
  }
}
