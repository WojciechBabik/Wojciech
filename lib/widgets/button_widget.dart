import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String value;
  final Function(String) onBtnTap;
  final Function(String) getBtnColor;

  const ButtonWidget({
    required this.value,
    required this.onBtnTap,
    required this.getBtnColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: getBtnColor(value),
      clipBehavior: Clip.hardEdge,
      shape: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: const BorderSide(color: Colors.white30),
      ),
      child: InkWell(
        onTap: () => onBtnTap(value),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }
}
