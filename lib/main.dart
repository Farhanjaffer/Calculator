import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(Calculator());
}

class Calculator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = '';
  String _currentNumber = '';
  String _expression = '';
  String _result = '';

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'C') {
        _clear();
      } else if (buttonText == '=') {
        _calculateResult();
      } else {
        _appendButton(buttonText);
      }
    });
  }

  void _clear() {
    _currentNumber = '';
    _expression = '';
    _output = '';
    _result = '';
  }

  void _appendButton(String buttonText) {
    _expression += buttonText;
    _output = _expression;
  }

  void _calculateResult() {
    try {
      Parser parser = Parser();
      _result = parser.evaluateExpression(_expression);
      _output = _result;
    } catch (e) {
      _output = 'Error';
    }
  }

  Widget _buildButton(String buttonText) {
    Color textColor = Colors.black;
    Color buttonColor = Colors.white;

    if (buttonText == 'C' || buttonText == '=') {
      textColor = Colors.white;
    }

    if (buttonText == 'C' || buttonText == '=') {
      buttonColor = Colors.red;
    }

    return Expanded(
      child: CupertinoButton(
        onPressed: () {
          _onButtonPressed(buttonText);
        },
        padding: EdgeInsets.all(16.0),
        color: buttonColor,
        child: Text(
          buttonText,
          style: TextStyle(fontSize: 20.0, color: textColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.grey[200],
              child: Text(
                _output,
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      _buildButton('7'),
                      _buildButton('8'),
                      _buildButton('9'),
                      _buildButton('/'),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      _buildButton('4'),
                      _buildButton('5'),
                      _buildButton('6'),
                      _buildButton('*'),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      _buildButton('1'),
                      _buildButton('2'),
                      _buildButton('3'),
                      _buildButton('-'),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      _buildButton('C'),
                      _buildButton('0'),
                      _buildButton('='),
                      _buildButton('+'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Parser {
  String evaluateExpression(String expression) {
    List<String> tokens = _tokenize(expression);
    Queue<String> outputQueue = _shuntingYard(tokens);
    return _evaluateRPN(outputQueue);
  }

  List<String> _tokenize(String expression) {
    List<String> tokens = [];
    String currentToken = '';

    for (int i = 0; i < expression.length; i++) {
      String char = expression[i];
      if (char == '+' || char == '-' || char == '*' || char == '/') {
        if (currentToken.isNotEmpty) {
          tokens.add(currentToken);
          currentToken = '';
        }
        tokens.add(char);
      } else {
        currentToken += char;
      }
    }

    if (currentToken.isNotEmpty) {
      tokens.add(currentToken);
    }

    return tokens;
  }

  Queue<String> _shuntingYard(List<String> tokens) {
    Queue<String> outputQueue = Queue();
    List<String> operatorStack = [];

    Map<String, int> precedence = {
      '+': 1,
      '-': 1,
      '*': 2,
      '/': 2,
    };

    for (String token in tokens) {
      if (token == '+' || token == '-' || token == '*' || token == '/') {
        while (operatorStack.isNotEmpty &&
            precedence[operatorStack.last]! >= precedence[token]!) {
          outputQueue.add(operatorStack.removeLast());
        }
        operatorStack.add(token);
      } else {
        outputQueue.add(token);
      }
    }

    while (operatorStack.isNotEmpty) {
      outputQueue.add(operatorStack.removeLast());
    }

    return outputQueue;
  }

  String _evaluateRPN(Queue<String> outputQueue) {
    List<String> stack = [];
    while (outputQueue.isNotEmpty) {
      String token = outputQueue.removeFirst();
      double result=0.0;
      if (token == '+' || token == '-' || token == '*' || token == '/') {
        double operand2 = double.parse(stack.removeLast());
        double operand1 = double.parse(stack.removeLast());
        switch (token) {
          case '+':
            result = operand1 + operand2;
            break;
          case '-':
            result = operand1 - operand2;
            break;
          case '*':
            result = operand1 * operand2;
            break;
          case '/':
            result = operand1 / operand2;
            break;
        }
        stack.add(result.toString());
      } else {
        stack.add(token);
      }
    }
    return stack.first;
  }
}
