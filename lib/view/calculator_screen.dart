import 'package:flutter/material.dart';

class CalculatorView extends StatefulWidget {
  const CalculatorView({super.key});

  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView> {
  final _textController = TextEditingController();

  // List of symbols displayed in the calculator
  List<String> lstSymbols = [
    "C", "*", "/", "<-",
    "1", "2", "3", "+",
    "4", "5", "6", "-",
    "7", "8", "9", "*",
    "%", "0", ".", "=",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Display the current input and result
            TextFormField(
              controller: _textController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              readOnly: true, // Make the text field read-only
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 4 buttons per row
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: lstSymbols.length,
                itemBuilder: (context, index) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _onButtonPressed(lstSymbols[index]),
                    child: Text(
                      lstSymbols[index],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onButtonPressed(String symbol) {
    setState(() {
      if (symbol == "C") {
        // Clear the text field
        _textController.clear();
      } else if (symbol == "<-") {
        // Remove the last character
        if (_textController.text.isNotEmpty) {
          _textController.text =
              _textController.text.substring(0, _textController.text.length - 1);
        }
      } else if (symbol == "=") {
        // Evaluate the expression
        _evaluateExpression();
      } else {
        // Append the symbol to the text field
        _textController.text += symbol;
      }
    });
  }

  void _evaluateExpression() {
    try {
      String expression = _textController.text;

      // Remove whitespace
      expression = expression.replaceAll(" ", "");

      // Evaluate the expression manually
      double result = _evaluateExpressionManually(expression);

      // Update the text field with the result
      setState(() {
        _textController.text = result.toString();
      });
    } catch (e) {
      // Display "Error" in case of invalid input
      setState(() {
        _textController.text = "Error";
      });
    }
  }

  double _evaluateExpressionManually(String expression) {
    List<String> tokens = _tokenizeExpression(expression);

    // First pass: Handle multiplication, division, and modulus
    List<String> processedTokens = [];
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i] == "*" || tokens[i] == "/" || tokens[i] == "%") {
        double left = double.parse(processedTokens.removeLast());
        double right = double.parse(tokens[++i]);
        if (tokens[i - 1] == "*") {
          processedTokens.add((left * right).toString());
        } else if (tokens[i - 1] == "/") {
          processedTokens.add((left / right).toString());
        } else if (tokens[i - 1] == "%") {
          processedTokens.add((left % right).toString());
        }
      } else {
        processedTokens.add(tokens[i]);
      }
    }

    // Second pass: Handle addition and subtraction
    double result = double.parse(processedTokens[0]);
    for (int i = 1; i < processedTokens.length; i++) {
      if (processedTokens[i] == "+" || processedTokens[i] == "-") {
        double nextValue = double.parse(processedTokens[++i]);
        if (processedTokens[i - 1] == "+") {
          result += nextValue;
        } else if (processedTokens[i - 1] == "-") {
          result -= nextValue;
        }
      }
    }

    return result;
  }

  List<String> _tokenizeExpression(String expression) {
    // Convert expression into a list of numbers and operators
    List<String> tokens = [];
    StringBuffer currentToken = StringBuffer();

    for (int i = 0; i < expression.length; i++) {
      String char = expression[i];
      if ("0123456789.".contains(char)) {
        currentToken.write(char);
      } else {
        if (currentToken.isNotEmpty) {
          tokens.add(currentToken.toString());
          currentToken.clear();
        }
        tokens.add(char);
      }
    }
    if (currentToken.isNotEmpty) {
      tokens.add(currentToken.toString());
    }
    return tokens;
  }
}
