import 'package:flutter/material.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:piano_practice_app/data/piece.dart';
import 'package:piano_practice_app/data/practice_record.dart';
import 'package:piano_practice_app/data/section.dart';
import 'package:piano_practice_app/piece_database.dart';

class DataProvider with ChangeNotifier {
  List<Piece> pieces = [];
  List<Section> sections = [];
  List<PracticeRecord> practiceRecords = [];

  void addPiece(Piece piece) async {
    pieces.add(piece);
    await PieceDatabase.instance.insertPiece(piece);
    notifyListeners();
  }

  Piece? getPiece(String id) {
    for (var piece in pieces) {
      if (piece.id == id) {
        return piece;
      }
    }
    return null;
  }

  void addSections(List<Section> sections) async {
    this.sections.addAll(sections);
    await PieceDatabase.instance.insertSections(sections);
    notifyListeners();
  }

  List<Section> getSections(String pieceId) {
    List<Section> newSections = [];
    for (var section in sections) {
      if (section.pieceId == pieceId) {
        newSections.add(section);
      }
    }
    return newSections;
  }

  void editPieceTitle(String pieceId, String title) async {
    pieces.where((p) => p.id == pieceId).first.title = title;
    await PieceDatabase.instance.updatePieceTitle(pieceId, title);
    notifyListeners();
  }

  void editSectionTitle(String sectionId, String title) async {
    sections.where((p) => p.id == sectionId).first.title = title;
    await PieceDatabase.instance.updateSectionTitle(sectionId, title);
    notifyListeners();
  }

  void editSectionGoalCount(String sectionId, int goalCount) async {
    sections.where((p) => p.id == sectionId).first.targetCount = goalCount;
    await PieceDatabase.instance.updateSectionTargetCount(sectionId, goalCount);
    notifyListeners();
  }

  void removePiece(String id) async {
    pieces.removeWhere((p) => p.id == id);
    await PieceDatabase.instance.deletePiece(id);
    notifyListeners();
  }

  void removeSection(String sectionId) async {
    sections.removeWhere((p) => p.id == sectionId);
    await PieceDatabase.instance.deleteSection(sectionId);
    notifyListeners();
  }
}