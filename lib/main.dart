import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_dapp/features/note/presentation/provider/note_provider.dart';

import 'features/note/data/model/note_model.dart';

void main() {
  runApp(ChangeNotifierProvider(create: (context)=>NoteService(),child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter with Web3 Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

