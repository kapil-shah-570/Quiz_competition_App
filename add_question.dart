import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddQuestionPage extends StatefulWidget {
  @override
  _AddQuestionPageState createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  final _formKey = GlobalKey<FormState>();
  String question = '';
  List<String> options = ['', '', '', ''];
  int? correctOptionIndex;
  int timeLimit = 30;
  bool _isSubmitting = false; // Track submission state

  // Function to submit the question
  Future<void> _submitQuestion() async {
    if (_formKey.currentState!.validate() && correctOptionIndex != null) {
      _formKey.currentState!.save(); // Save the form data

      setState(() {
        _isSubmitting = true; // Show the loading indicator
      });

      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/api/questions'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'question': question,
            'options': options,
            'correctOptionIndex': correctOptionIndex,
            'timeLimit': timeLimit,
          }),
        );

        setState(() {
          _isSubmitting = false; // Hide the loading indicator
        });

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Question added successfully!')),
          );
          _formKey.currentState!.reset();
          setState(() {
            options = ['', '', '', ''];
            correctOptionIndex = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add question. Please try again.')),
          );
        }
      } catch (e) {
        setState(() {
          _isSubmitting = false; // Hide the loading indicator in case of an error
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error occurred: $e')),
        );
      }
    } else {
      setState(() {
        _isSubmitting = false; // Hide the loading indicator if validation fails
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields before submitting.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Question'),
        elevation: 10,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[300]!, Colors.blue[700]!], // Gradient matching the home page
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.blue[200]!], // Light gradient for the body
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // The Expanded widget ensures the form takes up all available space
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Question Field
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Question',
                            labelStyle: TextStyle(color: Colors.blue[700]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0), // Circular border
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue[700]!, width: 2.0),
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Enter question' : null,
                          onSaved: (value) => question = value!,
                        ),
                        SizedBox(height: 15),

                        // Option Fields
                        ...List.generate(4, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Option ${index + 1}',
                                labelStyle: TextStyle(color: Colors.blue[700]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0), // Circular border
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue[700]!, width: 2.0),
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              validator: (value) => value == null || value.isEmpty ? 'Enter option' : null,
                              onSaved: (value) => options[index] = value!,
                            ),
                          );
                        }),

                        // Correct Option Selector
                        SizedBox(height: 20),
                        Text(
                          'Select the correct option:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(4, (index) {
                            return ChoiceChip(
                              label: Text(
                                'Option ${index + 1}',
                                style: TextStyle(color: Colors.blue[700]),
                              ),
                              selected: correctOptionIndex == index,
                              onSelected: (selected) {
                                setState(() {
                                  correctOptionIndex = selected ? index : null;
                                });
                              },
                              selectedColor: Colors.blue[700]!,
                              backgroundColor: Colors.blue[100]!, // Matching color
                              labelStyle: TextStyle(color: Colors.white),
                            );
                          }),
                        ),

                        // Time Limit Field
                        SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Time Limit (in seconds)',
                            labelStyle: TextStyle(color: Colors.blue[700]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0), // Circular border
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue[700]!, width: 2.0),
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          initialValue: timeLimit.toString(),
                          keyboardType: TextInputType.number,
                          onSaved: (value) => timeLimit = int.parse(value!),
                        ),

                        // Submit Button with Gradient
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitQuestion,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0), // Circular border
                            ),
                            elevation: 5,
                            // primary: Colors.transparent, // Make the button transparent
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue[300]!, Colors.blue[700]!], // Gradient matching the app bar
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(50.0), // Circular border for button
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: _isSubmitting
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                'Submit',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
