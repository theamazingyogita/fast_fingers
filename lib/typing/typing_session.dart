import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'typing_constants.dart';

class TypingSession extends ChangeNotifier {
  TypingSession({
    required String passage,
    this.duration = const Duration(seconds: 60),
  }) : _passage = passage;

  static const _tickInterval = Duration(milliseconds: 100);

  final Duration duration;

  String _passage;
  String _typed = '';
  Duration _elapsed = Duration.zero;
  TypingStatus _status = TypingStatus.ready;
  Timer? _ticker;
  Timer? _autoTyper;

  String get passage => _passage;

  String get typed => _typed;

  int get elapsedSeconds => _elapsed.inSeconds;

  TypingStatus get status => _status;

  bool get isAutoTyping => _autoTyper?.isActive ?? false;

  int get remainingSeconds => duration.inSeconds - elapsedSeconds;

  bool get isPerfect => _typed == _passage;

  String? get nextCharacter =>
      _typed.length < _passage.length ? _passage[_typed.length] : null;

  int get correctCharacters {
    var count = 0;
    for (var i = 0; i < _typed.length; i++) {
      if (_typed[i] == _passage[i]) count++;
    }
    return count;
  }

  int get mistakes => _typed.length - correctCharacters;

  int get wordsTyped =>
      _typed.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;

  int get wordsPerMinute {
    if (_typed.isEmpty) return 0;
    final minutes = max(_elapsed.inMilliseconds, 1000) / 60000;
    return (correctCharacters / 5 / minutes).round();
  }

  int get accuracy {
    if (_typed.isEmpty) return 100;
    return (correctCharacters / _typed.length * 100).round();
  }

  void type(String character) {
    if (_status == TypingStatus.finished) return;
    if (_status == TypingStatus.ready) _start();

    _typed += character;
    if (_typed.length >= _passage.length) {
      _finish();
    } else {
      notifyListeners();
    }
  }

  void backspace() {
    if (_status != TypingStatus.running || _typed.isEmpty) return;
    _typed = _typed.substring(0, _typed.length - 1);
    notifyListeners();
  }

  void autoType({Duration interval = const Duration(milliseconds: 40)}) {
    restart(_passage);
    _autoTyper = Timer.periodic(interval, (_) {
      final next = nextCharacter;
      if (next != null) type(next);
    });
  }

  void restart(String passage) {
    _ticker?.cancel();
    _autoTyper?.cancel();
    _passage = passage;
    _typed = '';
    _elapsed = Duration.zero;
    _status = TypingStatus.ready;
    notifyListeners();
  }

  void _start() {
    _status = TypingStatus.running;
    _ticker = Timer.periodic(_tickInterval, (_) => _tick());
  }

  void _tick() {
    final before = elapsedSeconds;
    _elapsed += _tickInterval;
    if (_elapsed >= duration) {
      _finish();
    } else if (elapsedSeconds != before) {
      notifyListeners();
    }
  }

  void _finish() {
    _ticker?.cancel();
    _autoTyper?.cancel();
    _status = TypingStatus.finished;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _autoTyper?.cancel();
    super.dispose();
  }
}
