import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:piano_practice_app/DataProvider.dart';
import 'package:piano_practice_app/data/piece.dart';
import 'package:piano_practice_app/data/section.dart';
import 'package:piano_practice_app/piece_database.dart';
import 'package:provider/provider.dart';

class SectionsScreen extends StatefulWidget {
  final Piece piece;

  const SectionsScreen({
    super.key,
    required this.piece,
  });

  @override
  State<SectionsScreen> createState() => _SectionsScreenState();
}

class _SectionsScreenState extends State<SectionsScreen>
    with TickerProviderStateMixin {
  late TextEditingController _tfController;
  late RecorderController _recorderController;
  bool _isRecording = false;
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    _tfController = TextEditingController();
    _recorderController = RecorderController();
  }

  @override
  void dispose() {
    _tfController.dispose();
    _recorderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();


    List<Section> sections = provider.getSections(widget.piece.id)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];

        final int currentCount = section.currentCount;
        final int targetCount = section.targetCount;

        final double progress =
        (currentCount / targetCount).clamp(0.0, 1.0);

        final int percentage = (progress * 100).round();

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                _onSectionTap(context, section);
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 8, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$currentCount / $targetCount회',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                              Text(
                                '$percentage%',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 7),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 4),

                    PopupMenuButton<String>(
                      tooltip: '메뉴',
                      onSelected: (String value) {
                        setState(() {
                          if (value == 'edit') {
                            onEditPressed(section);
                          } else if (value == 'delete') {
                            onDeletePressed(section);
                          }
                        });
                      },
                      icon: Icon(
                        Icons.more_vert,
                        color:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
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
                                Icon(Icons.delete_outline),
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

  Future<void> _onSectionTap(
      BuildContext context,
      Section section,
      ) {
    final provider = Provider.of<DataProvider>(context, listen: false);
    bool isEditingMemo = false;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

          title: Column(
            children: [
              Icon(
                Icons.music_note_rounded,
                size: 34,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 10),
              Text(
                '${section.title} 연습 중',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
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
              final provider = context.read<DataProvider>();
              final int currentCount = section.currentCount;
              final int targetCount = section.targetCount;

              final double progress =
              (currentCount / targetCount).clamp(0.0, 1.0);

              return SingleChildScrollView(
                child:Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Center(
                      child: IconButton(
                        icon: _isRecording ? Icon(Icons.stop) : Icon(Icons.mic),
                        onPressed: () {
                          setDialogState(() {
                            _isRecording = !_isRecording;
                          });
                          if (_isRecording)  {
                            stopRecording();
                          } else {
                            startRecording();
                          }
                        },
                      ),
                    ),
                    _isRecording ? AudioWaveforms(
                      size: Size(
                        MediaQuery.of(context).size.width,
                        100,
                      ),
                      recorderController: _recorderController,
                      waveStyle: WaveStyle(
                        waveColor: Theme.of(context).colorScheme.primary,
                        extendWaveform: true,
                        showMiddleLine: false,
                      ),
                    ) : Center(),

                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _CountButton(
                          icon: Icons.remove_rounded,
                          onPressed: () async {
                            setDialogState(() {
                              if (currentCount > 0) {
                                section.currentCount--;

                              }
                            });
                            await PieceDatabase.instance.updateSectionCurrentCount(section.id, section.currentCount);
                          },
                        ),

                        SizedBox(
                          width: 90,
                          child: Text(
                            section.currentCount.toString(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        _CountButton(
                          icon: Icons.add_rounded,
                          onPressed: () async {
                            setDialogState(() {
                              section.currentCount++;
                            });
                            await PieceDatabase.instance.updateSectionCurrentCount(section.id, section.currentCount);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '연습 진행도',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${section.currentCount} / ${section.targetCount}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerLow,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.sticky_note_2_outlined,
                                  size: 19,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: Text(
                                  '메모',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),

                              IconButton(
                                tooltip: '메모 수정',
                                visualDensity: VisualDensity.compact,
                                icon: Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                ),
                                onPressed: () {
                                  setDialogState(() {
                                    isEditingMemo = true;

                                    if (section.memo == null) {
                                      _tfController.text = '';
                                    } else {
                                      _tfController.text = section.memo!;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          if (isEditingMemo)
                            TextField(
                              controller: _tfController,
                              minLines: 3,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText: '오늘 연습에서 개선할 점을 적어보세요.',
                                hintStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withValues(alpha: 0.65),
                                ),
                                filled: true,
                                fillColor: Theme.of(context)
                                    .colorScheme
                                    .surface,
                                contentPadding: const EdgeInsets.all(14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              onSubmitted: (value) {
                                provider.editSectionMemo(
                                  section.id,
                                  _tfController.text,
                                );

                                setDialogState(() {
                                  isEditingMemo = false;
                                });
                              },
                            )
                          else
                            Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(
                                minHeight: 60,
                              ),
                              alignment: Alignment.topLeft,
                              child: Text(
                                section.memo == null ||
                                    section.memo!.trim().isEmpty
                                    ? '아직 작성된 메모가 없습니다.'
                                    : section.memo!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                  height: 1.5,
                                  color: section.memo == null ||
                                      section.memo!.trim().isEmpty
                                      ? Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      : Theme.of(context)
                                      .colorScheme
                                      .onSurface,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),

          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  setState(() {});
                  Navigator.of(context).pop();
                  provider.editSectionMemo(section.id, _tfController.text);
                  _tfController.clear();
                },
                child: const Text('완료'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> onEditPressed(Section section) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        _tfController.text = section.title;
        int goalCount = section.targetCount;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('구간 수정'),

          content: StatefulBuilder(
            builder: (
                BuildContext context,
                StateSetter setDialogState,
                ) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _tfController,
                    decoration: InputDecoration(
                      labelText: '구간 이름',
                      hintText: '예: 1~8마디',
                      prefixIcon:
                      const Icon(Icons.edit_note_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
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

                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_rounded),
                          onPressed: () {
                            setDialogState(() {
                              if (goalCount > 1) {
                                goalCount--;
                              }
                            });
                          },
                        ),

                        Text(
                          '$goalCount회',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.add_rounded),
                          onPressed: () {
                            setDialogState(() {
                              goalCount++;
                            });
                          },
                        ),
                      ],
                    ),
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
            FilledButton(
              onPressed: () {
                if (_tfController.text.isEmpty) {
                  return;
                }

                context.read<DataProvider>().editSectionTitle(
                  section.id,
                  _tfController.text,
                );

                context.read<DataProvider>().editSectionGoalCount(
                  section.id,
                  goalCount,
                );

                _tfController.clear();

                setState(() {});

                Navigator.of(context).pop();
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  Future<void> onDeletePressed(Section section) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),

          icon: Icon(
            Icons.delete_outline_rounded,
            size: 36,
            color: Theme.of(context).colorScheme.error,
          ),

          title: const Text(
            '구간을 삭제할까요?',
            textAlign: TextAlign.center,
          ),

          content: Text(
            '"${section.title}" 구간이 삭제됩니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
              Theme.of(context).colorScheme.onSurfaceVariant,
            ),
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
                    .removeSection(section.id);

                setState(() {});

                Navigator.of(context).pop();
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  Future<void> startRecording() async {
    final directory =
    await getApplicationCacheDirectory();

    final path =
        '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorderController.record(
      path: path,
    );

    setState(() {
      _recordingPath = path;
    });
  }

  Future<void> stopRecording() async {
    final path =
    await _recorderController.stop();

    setState(() {
      _recordingPath = path;
    });
  }
}

class _CountButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CountButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 68,
          height: 68,
          child: Icon(
            icon,
            size: 36,
            color:
            Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

