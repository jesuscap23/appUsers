import 'package:flutter/material.dart';

class WorkoutSummaryView extends StatelessWidget {
  final String exerciseType;
  final String exercise;
  final int weight;

  const WorkoutSummaryView({
    Key? key,
    required this.exerciseType,
    required this.exercise,
    required this.weight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resumen del Entrenamiento')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Tipo de Ejercicio: $exerciseType'),
            Text('Ejercicio: $exercise'),
            Text('Peso: $weight'),
          ],
        ),
      ),
    );
  }
}
