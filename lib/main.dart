import 'package:flutter/material.dart';
import 'package:piano_practice_app/DataProvider.dart';
import 'package:piano_practice_app/piece_database.dart';
import 'package:piano_practice_app/screen/root_screen.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await PieceDatabase.instance.initDatabase();

  final provider = DataProvider();
  await provider.loadData();
  runApp(
    ChangeNotifierProvider.value(
        value: provider,
        child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: const Color(0xFF4A3327),
          brightness: Brightness.light,
          surface: const Color(0xFFFFFDFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F1EB),
        useMaterial3: true,
      ),
      home: const RootScreen(),
    );
  }
}

