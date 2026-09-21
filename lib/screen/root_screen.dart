import 'package:flutter/material.dart';
import 'package:piano_practice_app/DataProvider.dart';
import 'package:piano_practice_app/data/piece.dart';
import 'package:piano_practice_app/screen/pieces_screen.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

// bottomNavBar로 화면이동
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});
  
  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> with TickerProviderStateMixin{
  late TabController _tabController;
  late TextEditingController _tfController;
  int _selectedIndex = 0;
  
  @override
  void initState(){
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {

      });
    });
    _tfController = TextEditingController();
  }

  @override
  void dispose(){
    _tabController.dispose();
    _tfController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedIndex: _selectedIndex,
        destinations: <Widget>[
          NavigationDestination(icon: Icon(Icons.book), label: '곡 목록'),
          NavigationDestination(icon: Icon(Icons.library_books), label: '연습 기록'),
        ],
      ),
      body: <Widget>[
          PiecesScreen(),
          Center(),
        ][_selectedIndex],
      floatingActionButton: _selectedIndex == 0 ? FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            _onAddPiecePressed(context);
          },
      ) : null,
    );
  }

  Future<void> _onAddPiecePressed(BuildContext context) {

      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('곡 추가'),
            content: TextField(
              controller: _tfController,
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.cancel),
                onPressed: () {
                  _tfController.clear();
                  Navigator.of(context).pop();
                },
              ),
              IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  context.read<DataProvider>().addPiece(
                      Piece(
                          id: const Uuid().v4(),
                          title: _tfController.text,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                      ));
                  _tfController.clear();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
      );
  }
}