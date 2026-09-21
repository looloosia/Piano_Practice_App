import 'package:flutter/material.dart';
import 'package:piano_practice_app/data/piece.dart';

class SectionsScreen extends StatefulWidget {
  final Piece piece;

  const SectionsScreen({super.key, required this.piece});

  @override
  State<SectionsScreen> createState() => _SectionsScreenState();
}

class _SectionsScreenState extends State<SectionsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
