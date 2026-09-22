import 'package:flutter/material.dart';
import 'package:piano_practice_app/DataProvider.dart';
import 'package:piano_practice_app/screen/root_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DataProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
            colorScheme: .fromSeed(
              seedColor: const Color(0xFF4A3327),
              brightness: Brightness.light,
              surface: const Color(0xFFFFFDFC),
            ),
          scaffoldBackgroundColor: const Color(0xFFF6F1EB),
          useMaterial3: true,
      ),
      home: const RootScreen(),
    ),
    );
  }
}

