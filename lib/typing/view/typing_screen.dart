import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../typing_session.dart';
import '../typing_constants.dart';
import 'widgets/on_screen_keyboard.dart';
import 'widgets/passage_view.dart';
import 'widgets/result_panel.dart';
import 'widgets/stats_bar.dart';

class TypingScreen extends StatefulWidget {
  const TypingScreen({super.key, this.passages = defaultPassages});

  final List<String> passages;

  @override
  State<TypingScreen> createState() => _TypingScreenState();
}

class _TypingScreenState extends State<TypingScreen> {
  final _random = Random();
  final _focusNode = FocusNode();
  late final TypingSession _session;
  String? _pressedKey;

  @override
  void initState() {
    super.initState();
    _session = TypingSession(passage: _pickPassage());
  }

  @override
  void dispose() {
    _session.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _pickPassage([String? current]) {
    final options = widget.passages.where((p) => p != current).toList();
    final pool = options.isEmpty ? widget.passages : options;
    return pool[_random.nextInt(pool.length)];
  }

  void _restart() {
    _session.restart(_pickPassage(_session.passage));
    _focusNode.requestFocus();
  }

  void _reset() {
    _session.restart(_session.passage);
    _focusNode.requestFocus();
  }

  void _testRun() {
    _session.autoType();
    _focusNode.requestFocus();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape &&
        _session.status == TypingStatus.running) {
      _reset();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.tab) {
      return KeyEventResult.handled;
    }

    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isControlPressed ||
        keyboard.isMetaPressed ||
        _session.isAutoTyping) {
      return KeyEventResult.ignored;
    }

    if (event is KeyUpEvent) {
      setState(() => _pressedKey = null);
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      _session.backspace();
      setState(() => _pressedKey = backspaceKey);
      return KeyEventResult.handled;
    }

    final character = event.character;
    if (character == null || character.length != 1 || character == '\t') {
      return KeyEventResult.ignored;
    }
    _session.type(character);
    setState(() => _pressedKey = keyFor(character));
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _onKeyEvent,
        child: GestureDetector(
          onTap: _focusNode.requestFocus,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListenableBuilder(
                  listenable: _session,
                  builder: (context, _) => Column(
                    spacing: 32,
                    children: [
                      Text(
                        'FAST FINGERS',
                        style: textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      StatsBar(
                        remainingSeconds: _session.remainingSeconds,
                        wordsPerMinute: _session.wordsPerMinute,
                        wordsTyped: _session.wordsTyped,
                        accuracy: _session.accuracy,
                      ),
                      PassageView(
                        passage: _session.passage,
                        typed: _session.typed,
                      ),
                      if (_session.status == TypingStatus.finished)
                        ResultPanel(
                          wordsPerMinute: _session.wordsPerMinute,
                          accuracy: _session.accuracy,
                          mistakes: _session.mistakes,
                          isPerfect: _session.isPerfect,
                          onRestart: _restart,
                        )
                      else ...[
                        Text(
                          _session.status == TypingStatus.ready
                              ? 'Start typing to see how fast you are'
                              : 'Keep going!',
                          style: textTheme.titleMedium,
                        ),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            FilledButton.tonalIcon(
                              onPressed: _session.status == TypingStatus.running
                                  ? _reset
                                  : null,
                              icon: const Icon(Icons.restart_alt),
                              label: const Text('Restart (Esc)'),
                            ),
                            if (kDebugMode)
                              OutlinedButton.icon(
                                onPressed: _session.isAutoTyping
                                    ? null
                                    : _testRun,
                                icon: const Icon(Icons.science_outlined),
                                label: const Text('Test perfect run'),
                              ),
                          ],
                        ),
                        OnScreenKeyboard(
                          pressedKey: _pressedKey,
                          nextKey: switch (_session.nextCharacter) {
                            final next? => keyFor(next),
                            null => null,
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
