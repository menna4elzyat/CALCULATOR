
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CalculatorCubit(),
      child: CalculatorView(),
    );
  }
}

class CalculatorView extends StatelessWidget {
  CalculatorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var calBloc = BlocProvider.of<CalculatorCubit>(context);
    return Scaffold(
      appBar: null,
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          // Display for the equation and result
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.bottomRight,
              child: BlocBuilder<CalculatorCubit, CalState>(
                builder: (context, state) {
                  if (state is EquationUpdated) {
                    return Text(
                      state.equation,
                      style: TextStyle(color: Colors.white, fontSize: 48),
                    );
                  }
                  return Text(
                    '0',
                    style: TextStyle(color: Colors.white, fontSize: 48),
                  );
                },
              ),
            ),
          ),
          // Keypad for the calculator
          Expanded(
            flex: 2,
            child: Column(
              children: [

                buttonRow(calBloc, ['C', '←', '%', '/']),
                // Row for 7, 8, 9, and x
                buttonRow(calBloc, ['7', '8', '9', 'x']),
                // Row for 4, 5, 6, and -
                buttonRow(calBloc, ['4', '5', '6', '-']),
                // Row for 1, 2, 3, and +
                buttonRow(calBloc, ['1', '2', '3', '+']),
                // Row for 0, ., and =
                buttonRow(calBloc, ['0', '.', '='], isZero: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buttonRow(CalculatorCubit calBloc, List<String> buttons, {bool isZero = false}) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons.map((button) {
          return CalculatorButton(
            text: button,
            onTap: () => calBloc.calculate(button),
            isZero: button == '0' && isZero,
          );
        }).toList(),
      ),
    );
  }
}

class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isZero;

  const CalculatorButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.isZero = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: isZero ? 2 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }
}
class CalculatorCubit extends Cubit<CalState> {
  CalculatorCubit() : super(InitialCalState());

  void calculate(String buttonText) {
    final currentState = state;
    if (currentState is EquationUpdated) {
      String newEquation = currentState.equation;

    switch (buttonText) {
    case 'C':
    newEquation = '0';
    break;
    case '←':
    newEquation = newEquation.length > 1 ? newEquation.substring(0, newEquation.length - 1) : '0';
    break;
    case '=':
    String finalExpression = newEquation.replaceAll('x', '*').replaceAll('÷', '/');

    Parser p = Parser();
    Expression exp = p.parse(finalExpression);
    ContextModel cm = ContextModel();

    double eval = exp.evaluate(EvaluationType.REAL, cm);

    if (eval == eval.toInt().toDouble()) {
    newEquation = eval.toInt().toString();
    } else {
    newEquation = eval.toStringAsFixed(2); // Limit to 2 decimal places
    }
    break;
    default:
    if (newEquation == '0') {
    newEquation = buttonText;
    } else {
    newEquation += buttonText;
    }
    break;
    }

    emit(EquationUpdated(newEquation));
    } else {
    // If the state is not EquationUpdated, we can assume it's the initial state
    emit(EquationUpdated(buttonText == 'C' ? '0' : buttonText));
    }
  }
}


abstract class CalState {}

class InitialCalState extends CalState {}

class EquationUpdated extends CalState {
  final String equation;

  EquationUpdated(this.equation);
}