import 'package:flutter/material.dart';
import 'button_values.dart';
import 'button_widget.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => CalculatorScreenState();
}

class CalculatorScreenState extends State<CalculatorScreen> {
  List<String> expression = []; // Lista przechowująca wyrażenie do obliczenia

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Wyświetlacz wyników
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: Container(
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(15),
                  child: FittedBox(
                    alignment: Alignment.centerRight,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      expression.join("").isEmpty ? "0" : expression.join(""),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Przyciski kalkulatora
            Expanded(
              flex: 5,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final buttonHeight = constraints.maxHeight / 5;
                  return Column(
                    children: [
                      _buildButtonRow(0, 4, buttonHeight),
                      _buildButtonRow(4, 4, buttonHeight),
                      _buildButtonRow(8, 4, buttonHeight),
                      _buildButtonRow(12, 4, buttonHeight),
                      _buildLastRow(buttonHeight),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Metoda do budowania wiersza przycisków
  Widget _buildButtonRow(int startIdx, int count, double height) {
    return SizedBox(
      height: height,
      child: Row(
        children:
            Btn.buttonValues
                .sublist(startIdx, startIdx + count)
                .map(
                  (value) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      child: ButtonWidget(
                        value: value,
                        onBtnTap: onBtnTap,
                        getBtnColor: getBtnColor,
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  // Metoda do budowania ostatniego wiersza przycisków (z zerem i kropką)
  Widget _buildLastRow(double height) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(4),
              child: ButtonWidget(
                value: Btn.n0,
                onBtnTap: onBtnTap,
                getBtnColor: getBtnColor,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(4),
              child: ButtonWidget(
                value: Btn.dot,
                onBtnTap: onBtnTap,
                getBtnColor: getBtnColor,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(4),
              child: ButtonWidget(
                value: Btn.calculate,
                onBtnTap: onBtnTap,
                getBtnColor: getBtnColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Metoda zwracająca kolor przycisku
  Color getBtnColor(String value) {
    return [Btn.del, Btn.clr].contains(value)
        ? Colors.blueGrey
        : [
          Btn.per,
          Btn.multiply,
          Btn.add,
          Btn.divide,
          Btn.calculate,
          Btn.subtract,
        ].contains(value)
        ? Colors.orange
        : Colors.black38;
  }

  // Metoda obsługująca kliknięcie przycisku
  void onBtnTap(String value) {
    if (value == Btn.del) {
      deleteLastCharacter();
      return;
    }
    if (value == Btn.clr) {
      clearAll();
      return;
    }
    if (value == Btn.per) {
      convertToPercentage();
      return;
    }
    if (value == Btn.calculate) {
      calculate();
      return;
    }

    appendValue(value);
  }

  // Metoda do usuwania ostatniego znaku (cyfry lub operatora)
  void deleteLastCharacter() {
    if (expression.isNotEmpty) {
      final lastElement = expression.last;
      if (lastElement.length > 1) {
        // Jeśli ostatni element ma więcej niż jeden znak, usuń ostatni znak
        expression[expression.length - 1] = lastElement.substring(
          0,
          lastElement.length - 1,
        );
      } else {
        // Jeśli ostatni element ma jeden znak, usuń cały element
        expression.removeLast();
      }
      setState(() {});
    }
  }

  // Metoda do czyszczenia całego wyrażenia
  void clearAll() {
    setState(() {
      expression.clear();
    });
  }

  // Metoda do konwersji ostatniej liczby na procent
  void convertToPercentage() {
    if (expression.isNotEmpty && _isNumber(expression.last)) {
      final lastNumber = expression.last;
      final number = double.parse(lastNumber);
      expression[expression.length - 1] = _formatNumber(number / 100);
      setState(() {});
    }
  }

  // Metoda do dodawania wartości (cyfry lub operatora) do wyrażenia
  void appendValue(String value) {
    if (value != Btn.dot && int.tryParse(value) == null) {
      // Jeśli wartość jest operatorem
      if (expression.isNotEmpty && _isNumber(expression.last)) {
        expression.add(value);
      }
    } else {
      // Jeśli wartość jest liczbą lub kropką
      if (expression.isEmpty || !_isNumber(expression.last)) {
        if (value == Btn.dot) {
          expression.add("0.");
        } else {
          expression.add(value);
        }
      } else {
        if (value == Btn.dot && expression.last.contains(Btn.dot)) {
          return; // Zapobiega wielokrotnym kropkom w jednej liczbie
        }
        expression[expression.length - 1] += value;
      }
    }
    setState(() {});
  }

  // Metoda do obliczania wyniku
  void calculate() {
    if (expression.isEmpty) {
      _showError("Błąd: Brak wyrażenia do obliczenia.");
      return;
    }

    if (!_isNumber(expression.last)) {
      _showError("Błąd: Wyrażenie nie może kończyć się operatorem.");
      return;
    }

    try {
      // Najpierw wykonaj mnożenie i dzielenie
      for (int i = 0; i < expression.length; i++) {
        if (expression[i] == Btn.multiply || expression[i] == Btn.divide) {
          if (i == 0 || i == expression.length - 1) {
            _showError("Błąd: Nieprawidłowe użycie operatora.");
            return;
          }
          final num1 = double.parse(expression[i - 1]);
          final num2 = double.parse(expression[i + 1]);
          if (expression[i] == Btn.divide && num2 == 0) {
            _showError("Błąd: Nie można dzielić przez zero.");
            return;
          }
          final result =
              expression[i] == Btn.multiply ? num1 * num2 : num1 / num2;
          expression.replaceRange(i - 1, i + 2, [_formatNumber(result)]);
          i--; // Dostosuj indeks po modyfikacji
        }
      }

      // Następnie wykonaj dodawanie i odejmowanie
      double result = double.parse(expression[0]);
      for (int i = 1; i < expression.length; i += 2) {
        final num = double.parse(expression[i + 1]);
        if (expression[i] == Btn.add) {
          result += num;
        } else if (expression[i] == Btn.subtract) {
          result -= num;
        }
      }

      setState(() {
        expression = [_formatNumber(result)];
      });
    } catch (e) {
      _showError("Błąd: Nieprawidłowe wyrażenie.");
    }
  }

  // Metoda do formatowania liczby (usuwanie niepotrzebnych zer po przecinku)
  String _formatNumber(double number) {
    // Zaokrąglij do 10 miejsc po przecinku, aby uniknąć błędów zmiennoprzecinkowych
    final roundedNumber = double.parse(number.toStringAsFixed(10));

    // Usuń niepotrzebne zera po przecinku
    String formatted = roundedNumber.toString();
    if (formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'\.?0*$'), '');
    }
    return formatted;
  }

  // Metoda sprawdzająca, czy wartość jest liczbą
  bool _isNumber(String value) {
    return double.tryParse(value) != null;
  }

  // Metoda do wyświetlania błędów
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
