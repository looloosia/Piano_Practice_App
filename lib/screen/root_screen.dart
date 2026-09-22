import 'package:flutter/material.dart';
import 'package:piano_practice_app/DataProvider.dart';
import 'package:piano_practice_app/data/piece.dart';
import 'package:piano_practice_app/data/section.dart';
import 'package:piano_practice_app/screen/pieces_screen.dart';
import 'package:piano_practice_app/screen/sections_screen.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

// bottomNavBar로 화면이동
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _tfController;

  int _selectedIndex = 0;
  int _sectionsCount = 1;

  Piece? _selectedPiece;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
    );

    _tabController.addListener(() {
      setState(() {});
    });

    _tfController = TextEditingController();
  }

  @override
  void dispose() {
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        scrolledUnderElevation: 0,

        leading: (_selectedPiece != null)
            ? IconButton(
          tooltip: '뒤로',
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
          onPressed: () {
            setState(() {
              _selectedPiece = null;
            });
          },
        )
            : null,

        title: Text(
          _selectedIndex == 0
              ? (_selectedPiece == null
              ? '나의 연습곡'
              : _selectedPiece!.title)
              : '연습 기록',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        indicatorColor: colorScheme.primaryContainer,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.library_music_outlined),
            selectedIcon: Icon(Icons.library_music_rounded),
            label: '곡 목록',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            selectedIcon: Icon(Icons.history_toggle_off_rounded),
            label: '연습 기록',
          ),
        ],
      ),

      body: <Widget>[
        (_selectedPiece == null)
            ? PiecesScreen(
          onPieceTap: (piece) {
            setState(() {
              _selectedPiece = piece;
            });
          },
        )
            : SectionsScreen(
          piece: _selectedPiece!,
        ),

        const Center(
          child: Text('연습 기록'),
        ),
      ][_selectedIndex],

      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: Text(
          _selectedPiece == null ? '곡 추가' : '구간 추가',
        ),
        onPressed: () {
          _selectedPiece == null
              ? _onAddPiecePressed(context)
              : _onAddSectionPressed(
            context,
            _selectedPiece!,
          );
        },
      )
          : null,
    );
  }

  Future<void> _onAddPiecePressed(
      BuildContext context,
      ) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),

          titlePadding: const EdgeInsets.fromLTRB(
            24,
            24,
            24,
            12,
          ),

          contentPadding: const EdgeInsets.fromLTRB(
            24,
            8,
            24,
            8,
          ),

          actionsPadding: const EdgeInsets.fromLTRB(
            16,
            4,
            16,
            16,
          ),

          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.library_music_rounded,
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer,
                ),
              ),

              const SizedBox(width: 12),

              const Text(
                '곡 추가',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          content: StatefulBuilder(
            builder: (
                BuildContext context,
                StateSetter setDialogState,
                ) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  TextField(
                    controller: _tfController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: '곡 제목',
                      hintText: '예: Chopin Etude Op.10 No.4',
                      prefixIcon:
                      const Icon(Icons.music_note_rounded),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color:
                          Theme.of(context).colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    '부분연습 구간 수',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 8),

                  _NumberSelector(
                    value: _sectionsCount,
                    onRemove: () {
                      setDialogState(() {
                        if (_sectionsCount > 1) {
                          _sectionsCount--;
                        }
                      });
                    },
                    onAdd: () {
                      setDialogState(() {
                        _sectionsCount++;
                      });
                    },
                  ),
                ],
              );
            },
          ),

          actions: [
            TextButton(
              onPressed: () {
                _tfController.clear();
                _sectionsCount = 1;
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),

            FilledButton.icon(
              icon: const Icon(
                Icons.check_rounded,
                size: 18,
              ),
              label: const Text('추가'),
              onPressed: () {
                final provider =
                context.read<DataProvider>();

                String newPieceId =
                const Uuid().v4();

                provider.addPiece(
                  Piece(
                    id: newPieceId,
                    title: _tfController.text,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                );

                _tfController.clear();

                List<Section> sections = [];

                for (int i = 0; i < _sectionsCount; i++) {
                  sections.add(
                    Section(
                      id: const Uuid().v4(),
                      title: '구간 ${(i + 1).toString()}',
                      pieceId: newPieceId,
                      sortOrder: i,
                      createdAt: DateTime.now(),
                      currentCount: 0,
                      targetCount: 10,
                    ),
                  );
                }

                provider.addSections(sections);

                _sectionsCount = 1;

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _onAddSectionPressed(
      BuildContext context,
      Piece piece,
      ) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final provider =
        context.read<DataProvider>();

        _tfController.text =
        '구간 ${provider.getSections(piece.id).length + 1}';

        int goalCount = 10;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),

          titlePadding: const EdgeInsets.fromLTRB(
            24,
            24,
            24,
            12,
          ),

          contentPadding: const EdgeInsets.fromLTRB(
            24,
            8,
            24,
            8,
          ),

          actionsPadding: const EdgeInsets.fromLTRB(
            16,
            4,
            16,
            16,
          ),

          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.add_chart_rounded,
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer,
                ),
              ),

              const SizedBox(width: 12),

              const Text(
                '구간 추가',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          content: StatefulBuilder(
            builder: (
                BuildContext context,
                StateSetter setDialogState,
                ) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  TextField(
                    controller: _tfController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: '구간 이름',
                      hintText: '예: 1~8마디',
                      prefixIcon:
                      const Icon(Icons.edit_note_rounded),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color:
                          Theme.of(context).colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    '목표 연습 횟수',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 8),

                  _NumberSelector(
                    value: goalCount,
                    suffix: '회',
                    onRemove: () {
                      setDialogState(() {
                        if (goalCount > 1) {
                          goalCount--;
                        }
                      });
                    },
                    onAdd: () {
                      setDialogState(() {
                        goalCount++;
                      });
                    },
                  ),
                ],
              );
            },
          ),

          actions: [
            TextButton(
              onPressed: () {
                _tfController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),

            FilledButton.icon(
              icon: const Icon(
                Icons.check_rounded,
                size: 18,
              ),
              label: const Text('추가'),
              onPressed: () {
                provider.sections.add(
                  Section(
                    id: const Uuid().v4(),
                    pieceId: piece.id,
                    title: _tfController.text,
                    sortOrder:
                    provider.getSections(piece.id).length,
                    createdAt: DateTime.now(),
                    currentCount: 0,
                    targetCount: goalCount,
                  ),
                );

                _tfController.clear();

                setState(() {});

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class _NumberSelector extends StatelessWidget {
  final int value;
  final String suffix;
  final VoidCallback onRemove;
  final VoidCallback onAdd;

  const _NumberSelector({
    required this.value,
    required this.onRemove,
    required this.onAdd,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _SmallRoundButton(
            icon: Icons.remove_rounded,
            onPressed: onRemove,
          ),

          Expanded(
            child: Text(
              '$value$suffix',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ),

          _SmallRoundButton(
            icon: Icons.add_rounded,
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}

class _SmallRoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _SmallRoundButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.primaryContainer,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            size: 23,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}