import 'package:flutter/material.dart';

class ReviewPage extends StatelessWidget {
  final List<dynamic> questions;
  final List<int> selectedAnswers;

  ReviewPage({required this.questions, required this.selectedAnswers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Questions'),
        elevation: 10,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[300]!, Colors.blue[700]!], // Gradient color same as home page
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          // If no answer is selected, use -1 as the default value
          int selectedAnswer = index < selectedAnswers.length ? selectedAnswers[index] : -1;
          bool isCorrect = selectedAnswer == questions[index]['correctOptionIndex'];

          return Card(
            child: ListTile(
              title: Text(
                questions[index]['question'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...List.generate(4, (optionIndex) {
                    // Determine the icon for each option
                    IconData icon = Icons.check_circle;  // Green tick by default

                    if (optionIndex == selectedAnswer && !isCorrect) {
                      // Show red cross for selected wrong answer
                      icon = Icons.cancel;
                    } else if (optionIndex != questions[index]['correctOptionIndex']) {
                      // Show red cross for incorrect options that were not selected
                      icon = Icons.cancel;
                    }

                    return Row(
                      children: [
                        Icon(
                          icon,
                          color: icon == Icons.check_circle ? Colors.green : Colors.red,
                        ),
                        SizedBox(width: 10),
                        Text(questions[index]['options'][optionIndex]),
                      ],
                    );
                  }),
                  SizedBox(height: 10),
                  Text(
                    'Correct Answer: ${questions[index]['options'][questions[index]['correctOptionIndex']]}',
                    style: TextStyle(color: Colors.green),
                  ),
                  Text(
                    'Your Answer: ${selectedAnswer != -1 ? questions[index]['options'][selectedAnswer] : 'Not answered'}',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
