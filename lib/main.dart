import 'package:flutter/material.dart';
import 'package:notes_app/screens/note_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note Keeper',
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/" : (context) => NoteList(),
      },
    );
  }
}