import 'package:flutter/material.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:piano_practice_app/data/piece.dart';
import 'package:piano_practice_app/data/practice_record.dart';
import 'package:piano_practice_app/data/section.dart';

class DataProvider with ChangeNotifier {
  List<Piece> pieces = [];
  List<Section> sections = [];
  List<PracticeRecord> practiceRecords = [];

  void addPiece(Piece piece) {
    pieces.add(piece);
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

  void addSections(List<Section> sections) {
    this.sections.addAll(sections);
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

  void editPieceTitle(String pieceId, String title) {
    pieces.where((p) => p.id == pieceId).first.title = title;
    notifyListeners();
  }

  void editSectionTitle(String sectionId, String title) {
    sections.where((p) => p.id == sectionId).first.title = title;
    notifyListeners();
  }

  void editSectionGoalCount(String sectionId, int goalCount) {
    sections.where((p) => p.id == sectionId).first.targetCount = goalCount;
    notifyListeners();
  }

  void removePiece(String id) {
    pieces.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void removeSection(String sectionId) {
    sections.removeWhere((p) => p.id == sectionId);
    notifyListeners();
  }
}