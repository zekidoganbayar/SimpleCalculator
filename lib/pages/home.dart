import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _display = '0';
  bool _shouldResetDisplay = false;
  bool _lastButtonWasOperation = false;

  final List<String> buttons = [
    'C', 'DEL', '%', '÷',
    '7', '8', '9', 'x',
    '4', '5', '6', '-',
    '1', '2', '3', '+',
    '+/-', '0', '.', '=',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Simple Calculator',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 0.0,
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFE0E0E0),
              border: Border.all(color: Colors.black, width: 2.0),
              borderRadius: BorderRadius.circular(3.0),
            ),
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 80.0),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(0.5),
              child: Container(
                width: double.infinity,
                alignment: Alignment.centerRight,
                child: Text(
                  _display,
                  style: TextStyle(
                    fontSize: 72.0,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              itemCount: buttons.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                return _buildButton(buttons[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleButtonPress(String buttonText) {
    setState(() {
      switch (buttonText) {
        case 'C':
          _clear();
          break;
        case 'DEL':
          _delete();
          break;
        case '+/-':
          _toggleSign();
          break;
        case '=':
          _calculate();
          break;
        case '+':
        case '-':
        case 'x':
        case '÷':
        case '%':
          _handleOperation(buttonText);
          break;
        case '.':
          _addDecimal();
          break;
        default:
          _addDigit(buttonText);
      }
    });
  }

  void _clear() {
    _display = '0';
    _shouldResetDisplay = false;
    _lastButtonWasOperation = false;
  }

  void _delete() {
    if (_display.length > 1) {
      _display = _display.substring(0, _display.length - 1);
    } else {
      _display = '0';
    }
    _lastButtonWasOperation = false;
  }

  void _toggleSign() {
    // Check if the display contains any operation
    RegExp operationRegex = RegExp(r'[+\-x÷%]');
    if (operationRegex.hasMatch(_display) && !_lastButtonWasOperation) {
      // Find the last operation in the display
      int lastOpIndex = _display.lastIndexOf(operationRegex);

      // Get the part after the last operation (current number)
      String firstPart = _display.substring(0, lastOpIndex + 1);
      String currentNumber = _display.substring(lastOpIndex + 1);

      // Toggle the sign of the current number
      if (currentNumber.isNotEmpty) {
        if (currentNumber.startsWith('-')) {
          currentNumber = currentNumber.substring(1);
        } else {
          currentNumber = '-$currentNumber';
        }
        _display = firstPart + currentNumber;
      }
    } else {
      // No operation found or last button was an operation, toggle the sign of the entire display
      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else if (_display != '0') {
        _display = '-$_display';
      }
    }
    _lastButtonWasOperation = false;
  }

  void _addDecimal() {
    if (_shouldResetDisplay || _lastButtonWasOperation) {
      _display = '0.';
      _shouldResetDisplay = false;
      _lastButtonWasOperation = false;
    } else {
      bool hasOperation = ['+', '-', 'x', '÷', '%'].any((op) => _display.contains(op));

      if (!_display.contains('.') && !hasOperation) {
        _display = '$_display.';
      } else if (hasOperation && !_display.substring(_display.lastIndexOf(RegExp(r'[+\-x÷%]'))).contains('.')) {
        _display = '$_display.';
      }
    }
  }

  void _addDigit(String digit) {
    if (_display == '0' || _shouldResetDisplay || _lastButtonWasOperation) {
      _display = _lastButtonWasOperation ? _display + digit : digit;
      _shouldResetDisplay = false;
      _lastButtonWasOperation = false;
    } else {
      _display = _display + digit;
    }
  }

  void _handleOperation(String operation) {
    // If we have a previous calculation result and add an operation,
    // we should continue with that result
    if (_shouldResetDisplay) {
      _shouldResetDisplay = false;
    }

    // If there's already an operation in the display, calculate first
    if (['+', '-', 'x', '÷', '%'].any((op) => _display.contains(op)) && !_lastButtonWasOperation) {
      _calculate();
    }

    _display = '$_display$operation';
    _lastButtonWasOperation = true;
  }

  void _calculate() {
    String expression = _display.replaceAll('x', '*').replaceAll('÷', '/');

    try {
      // Fix the parsing to handle negative numbers correctly
      RegExp operatorPattern = RegExp(r'([+\-*/%)])');
      List<String> tokens = [];
      String currentNumber = '';
      bool expectingNumber = true;

      for (int i = 0; i < expression.length; i++) {
        String char = expression[i];

        if (operatorPattern.hasMatch(char)) {
          // If we're expecting a number and see a minus, it's a negative sign
          if (char == '-' && expectingNumber) {
            currentNumber += char;
          } else {
            // Otherwise it's an operator
            if (currentNumber.isNotEmpty) {
              tokens.add(currentNumber);
              currentNumber = '';
            }
            tokens.add(char);
            expectingNumber = true;
          }
        } else {
          // This is a digit or decimal point
          currentNumber += char;
          expectingNumber = false;
        }
      }

      // Add the last number if there is one
      if (currentNumber.isNotEmpty) {
        tokens.add(currentNumber);
      }

      // Now calculate
      if (tokens.length >= 3) {
        double result = double.parse(tokens[0]);
        for (int i = 1; i < tokens.length - 1; i += 2) {
          String op = tokens[i];
          double num2 = double.parse(tokens[i+1]);
          switch (op) {
            case '+': result += num2; break;
            case '-': result -= num2; break;
            case '*': result *= num2; break;
            case '/': result /= num2; break;
            case '%':
            // Changed to modulus operation instead of percentage
              result = result % num2;
              break;
          }
        }
        _display = result == result.toInt() ? result.toInt().toString() : result.toString();
      }
    } catch (e) {
      _display = 'Error';
    }
    _shouldResetDisplay = true;
    _lastButtonWasOperation = false;
  }

  Widget _buildButton(String buttonText) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: ElevatedButton(
        onPressed: () => _handleButtonPress(buttonText),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
            side: BorderSide(
              color: Colors.black,
              width: 1.0,
            ),
          ),
          backgroundColor: Colors.blue,
          padding: EdgeInsets.all(0.0),
        ),
        child: Text(
          buttonText,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}