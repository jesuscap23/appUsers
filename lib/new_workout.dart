import 'package:flutter/material.dart';
import 'workout_summary.dart';

class NewWorkoutView extends StatefulWidget {
  const NewWorkoutView({Key? key}) : super(key: key);

  @override
  State<NewWorkoutView> createState() => _NewWorkoutViewState();
}

class _NewWorkoutViewState extends State<NewWorkoutView> {
  String selectedExerciseType = 'pecho';
  String selectedExercise = 'press banca';
  int weight = 0;

  final exerciseTypes = ['pecho', 'espalda', 'gluteos y piernas', 'hombros'];
  final exerciseMap = {
    'pecho': ['press banca', 'flexiones'],
    'espalda': ['dominadas', 'remo con barra'],
    'gluteos y piernas': ['Hip Thrust', 'sentadilla'],
    'hombros': ['press militar', 'press normal'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Entrenamiento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedExerciseType,
              onChanged: (value) {
                setState(() {
                  selectedExerciseType = value!;
                  selectedExercise = exerciseMap[selectedExerciseType]![0];
                });
              },
              items: exerciseTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
            ),
            DropdownButtonFormField<String>(
              value: selectedExercise,
              onChanged: (value) {
                setState(() {
                  selectedExercise = value!;
                });
              },
              items: exerciseMap[selectedExerciseType]!.map((exercise) {
                return DropdownMenuItem(value: exercise, child: Text(exercise));
              }).toList(),
            ),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Peso (0-999)'),
              controller: TextEditingController(text: weight.toString()),
              onChanged: (value) {
                setState(() {
                  weight = int.tryParse(value) ?? 0;
                  weight = weight.clamp(0, 999);
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutSummaryView(
                      exerciseType: selectedExerciseType,
                      exercise: selectedExercise,
                      weight: weight,
                    ),
                  ),
                );
              },
              child: const Text('Iniciar'),
            ),
          ],
        ),
      ),
    );
  }
}
