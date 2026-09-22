import 'package:flutter/material.dart';
import 'package:piano_practice_app/data/piece.dart';
import 'package:provider/provider.dart';
import 'package:piano_practice_app/DataProvider.dart';

class PiecesScreen extends StatefulWidget {
  final void Function(Piece piece) onPieceTap;

  const PiecesScreen({
    super.key,
    required this.onPieceTap,
  });

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
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: provider.pieces.length,
      itemBuilder: (context, index) {
        final Piece piece = provider.pieces[index];
        final String id = piece.id;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                widget.onPieceTap(piece);
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  12,
                  6,
                  12,
                ),
                child: Row(
                  children: [
                    // 곡 아이콘
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.music_note_rounded,
                        size: 28,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),

                    const SizedBox(width: 14),

                    // 곡 제목
                    Expanded(
                      child: Text(
                        piece.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),

                    // 메뉴
                    PopupMenuButton<String>(
                      tooltip: '메뉴',
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onSelected: (String value) {
                        if (value == 'edit') {
                          onEditPressed(id);
                        } else if (value == 'delete') {
                          onDeletePressed(id);
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined),
                                SizedBox(width: 12),
                                Text('수정'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline_rounded),
                                SizedBox(width: 12),
                                Text('삭제'),
                              ],
                            ),
                          ),
                        ];
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> onEditPressed(String id) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        _tfController?.text =
            context.read<DataProvider>().getPiece(id)!.title;

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
            8,
            16,
            16,
          ),

          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color:
                  Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.edit_note_rounded,
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer,
                ),
              ),

              const SizedBox(width: 12),

              const Text(
                '곡 수정',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          content: TextField(
            controller: _tfController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: '곡 제목',
              prefixIcon: const Icon(
                Icons.music_note_rounded,
              ),
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

          actions: [
            TextButton(
              onPressed: () {
                _tfController?.clear();
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),

            FilledButton.icon(
              icon: const Icon(
                Icons.check_rounded,
                size: 18,
              ),
              label: const Text('저장'),
              onPressed: () {
                if (_tfController!.text.isEmpty) {
                  return;
                }

                context
                    .read<DataProvider>()
                    .editPieceTitle(
                  id,
                  _tfController!.text,
                );

                _tfController?.clear();

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> onDeletePressed(String id) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final piece =
        context.read<DataProvider>().getPiece(id);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),

          icon: Icon(
            Icons.delete_outline_rounded,
            size: 38,
            color: Theme.of(context).colorScheme.error,
          ),

          title: const Text(
            '곡을 삭제할까요?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),

          content: Text(
            piece != null
                ? '"${piece.title}" 곡이 삭제됩니다.'
                : '선택한 곡이 삭제됩니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
          ),

          actionsPadding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            16,
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),

            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor:
                Theme.of(context).colorScheme.error,
                foregroundColor:
                Theme.of(context).colorScheme.onError,
              ),
              onPressed: () {
                context
                    .read<DataProvider>()
                    .removePiece(id);

                Navigator.of(context).pop();
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }
}