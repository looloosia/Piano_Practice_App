import 'package:flutter/material.dart';
import 'package:piano_practice_app/data/piece.dart';
import 'package:piano_practice_app/screen/sections_screen.dart';
import 'package:provider/provider.dart';
import 'package:piano_practice_app/DataProvider.dart';

class PiecesScreen extends StatefulWidget {
  const PiecesScreen({super.key});

  @override
  State<PiecesScreen> createState() => _PiecesScreenState();
}

class _PiecesScreenState extends State<PiecesScreen> {
  TextEditingController? _tfController;

  @override
  void initState() {
    super.initState();
    _tfController = TextEditingController();
  }

  @override
  void dispose() {
    _tfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    String selectedValue = '';

    return ListView.builder(
      itemCount: provider.pieces.length,
      itemBuilder: (context, index) {
        Piece piece = context.read<DataProvider>().pieces[index];
        String id = piece.id;
        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SectionsScreen(piece: piece)
              ),
            );
          },
          title: Text(
              '${provider.pieces[index].title}'
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                if (value == 'edit') {
                  onEditPressed(id);
                } else if (value == 'delete') {
                  onDeletePressed(id);
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('수정')
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('삭제')
                )
              ];
            },
          ),
        );
      }
    );
  }

  Future<void> onEditPressed(String id) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        _tfController?.text = context.read<DataProvider>().getPiece(id)!.title;
        return AlertDialog(
          title: const Text('곡 수정'),
          content: TextField(
            controller: _tfController
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () {
                _tfController?.clear();
                Navigator.of(context).pop();
              },
            ),
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                if (_tfController!.text.isEmpty) {
                  return;
                }
                context.read<DataProvider>().editPieceTitle(id, _tfController!.text); // 곡 수정
                _tfController?.clear();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    );
  }

  Future<void> onDeletePressed(String id) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('곡을 삭제하시겠습니까?'),
            actions: [
              IconButton(
                icon: Icon(Icons.cancel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  context.read<DataProvider>().removePiece(id);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
    );
  }
}
