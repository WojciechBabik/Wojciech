import 'package:bibik_kalkulator/button_values.dart';
import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => CalculatorScreenState();
}

class CalculatorScreenState extends State<CalculatorScreen> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            //output
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: Container(
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    "0",
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ),
            //input
            Wrap(
              children:
                  Btn.buttonValues
                      .map(
                        (value) => SizedBox(
                          width: screenSize.width / 4,
                          height: screenSize.width / 5,
                          child: buildButton(value),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(value) {
    return Material(
      shape: OutlineInputBorder(
        borderRadius: BorderRadius.circular(120),
        borderSide: BorderSide(color: Colors.white30),
      ),
      child: InkWell(onTap: () {}, child: Center(child: Text(value))),
    );
  }
}
