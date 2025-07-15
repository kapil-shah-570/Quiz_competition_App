import 'package:finalexampjt/result.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:async';

class AttendQuizPage extends StatefulWidget {
  @override
  _AttendQuizPageState createState() => _AttendQuizPageState();
}

class _AttendQuizPageState extends State<AttendQuizPage> {
  List<dynamic> questions = [];
  List<int> selectedAnswers = [];
  int currentIndex = 0;
  int score = 0;
  bool isAnswered = false;
  int timeLimit = 30;
  late int remainingTime;
  late Timer _timer;

  Future<void> _fetchQuestions() async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/questions'));

    if (response.statusCode == 200) {
      setState(() {
        questions = json.decode(response.body);
        if (questions.isNotEmpty) {
          timeLimit = questions[currentIndex]['timeLimit'];
          remainingTime = timeLimit;
        }
      });
      _startTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load questions.')));
    }
  }

  void _startTimer() {
    remainingTime = timeLimit;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
        });
      } else {
        timer.cancel();
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (currentIndex + 1 < questions.length) {
      setState(() {
        currentIndex = currentIndex + 1;
        isAnswered = false;
      });
      _startTimer();
    } else {
      _endQuiz();
    }
  }

  void _endQuiz() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Quiz Finished"),
        content: Text("Your Score: $score / ${questions.length}"),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultPage(score: score, totalQuestions: questions.length, questions: questions, selectedAnswers: selectedAnswers),
                ),
              );
            },
            child: Text('Finish'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(appBar: AppBar(title: Text('Attend Quiz')), body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Attend Quiz', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 10,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[300]!, Colors.blue[700]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${currentIndex + 1}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 10),
            Text(
              questions[currentIndex]['question'],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,  // Align timer to the right side
              children: [
                CircularPercentIndicator(
                  radius: 40.0,  // Smaller size for the timer
                  lineWidth: 6.0,
                  percent: remainingTime / timeLimit,
                  center: Text('$remainingTime s', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)), // Timer in red color
                  progressColor: Colors.red, // Timer progress color
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ],
            ),
            SizedBox(height: 20),
            Column(
              children: List.generate(4, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Fixed color for all options
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                    onPressed: () {
                      // Option selection logic without changing color
                      if (!isAnswered) {
                        setState(() {
                          selectedAnswers.add(index);
                          if (index == questions[currentIndex]['correctOptionIndex']) {
                            score++;
                          }
                          isAnswered = true;
                        });
                      }
                    },
                    child: Text(questions[currentIndex]['options'][index], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                );
              }),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  ),
                  child: Text('Next Question', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: _endQuiz,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  ),
                  child: Text('Finish Quiz', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
