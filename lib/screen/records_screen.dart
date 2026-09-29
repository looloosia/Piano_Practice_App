import 'package:flutter/material.dart';
import 'package:piano_practice_app/data/piece.dart';
import 'package:provider/provider.dart';
import 'package:piano_practice_app/DataProvider.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Center(
        child: Text('연습 기록')
      )
    );
  }
}
