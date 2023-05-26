// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print, avoid_types_as_parameter_names
// ignore_for_file: prefer_const_constructors, dead_code, avoid_unnecessary_containers

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_quize_app/quiz.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Quiz quiz;
  late List<Results> results;
  Future<void> fetchQuestions() async {
    var res =
        await http.get(Uri.parse("https://opentdb.com/api.php?amount=20"));
    var decRes = jsonDecode(res.body);
    print(decRes);

    quiz = Quiz.fromJson(decRes);
    results = quiz.results!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Quiz App",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0.0,
      ),
      body: RefreshIndicator(
        onRefresh: fetchQuestions,
        child: FutureBuilder(
          future: fetchQuestions(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text("press button to start.");
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.done:
                if (snapshot.hasError) return errorData(snapshot);
                return questionList();
            }
          },
        ),
      ),
    );
  }

  Padding errorData(AsyncSnapshot snapshot) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Error:${snapshot.error}"),
          SizedBox(
            height: 20.0,
          ),
          ElevatedButton(
            onPressed: () {
              fetchQuestions();
              setState(() {});
            },
            child: Text("Try Again"),
          )
        ],
      ),
    );
  }

  ListView questionList() {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) => Card(
        color: Colors.white,
        elevation: 0.0,
        child: ExpansionTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  results[index].question.toString(),
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FilterChip(
                        backgroundColor: Colors.grey[100],
                        label: Text(
                          results[index].category.toString(),
                        ),
                        onSelected: (bool) {},
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      FilterChip(
                        backgroundColor: Colors.grey[100],
                        label: Text(
                          results[index].difficulty.toString(),
                        ),
                        onSelected: (bool) {},
                      ),
                    ],
                  ),
                )
              ],
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.grey[100],
              child: Text(results[index].type!.startsWith("m") ? "M" : "B"),
            ),
            children: results[index].allAnswers!.map((m) {
              return AnswerWidget(results: results, index: index, m: m);
            }).toList()),
      ),
    );
  }
}

class AnswerWidget extends StatefulWidget {
  final List<Results> results;
  final int index;
  final String m;
  const AnswerWidget({
    Key? key,
    required this.results,
    required this.index,
    required this.m,
  }) : super(key: key);

  @override
  State<AnswerWidget> createState() => _AnswerWidgetState();
}

class _AnswerWidgetState extends State<AnswerWidget> {
  Color c = Colors.black;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        setState(() {
          if (widget.m == widget.results[widget.index].correctAnswer) {
            c = Colors.green;
          } else {
            c = Colors.red;
          }
        });
      },
      title: Text(
        widget.m,
        textAlign: TextAlign.center,
        style: TextStyle(color: c, fontWeight: FontWeight.bold),
      ),
    );
  }
}
