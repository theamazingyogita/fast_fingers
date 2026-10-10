import 'dart:async';

import 'package:flutter/foundation.dart';

import 'typing_constants.dart';

class TypingSession extends ChangeNotifier {
  TypingSession({
    required String passage,
    this.duration = const Duration(seconds: 60),
  }) : _passage = passage;

  final Duration duration;

  String _passage;
  String _typed = '';
  int _elapsedSeconds = 0;
  TypingStatus _status = TypingStatus.ready;
  Timer? _ticker;
  Timer? _autoTyper;

  String get passage => _passage;

  String get typed => _typed;

  int get elapsedSeconds => _elapsedSeconds;

  TypingStatus get status => _status;

  bool get isAutoTyping => _autoTyper?.isActive ?? false;

  int get remainingSeconds => duration.inSeconds - _elapsedSeconds;

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
    if (_elapsedSeconds == 0) return 0;
    return (correctCharacters / 5 / (_elapsedSeconds / 60)).round();
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
    _elapsedSeconds = 0;
    _status = TypingStatus.ready;
    notifyListeners();
  }

  void _start() {
    _status = TypingStatus.running;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    _elapsedSeconds++;
    if (remainingSeconds <= 0) {
      _finish();
    } else {
      notifyListeners();
    }
  }

  void _finish() {
    _ticker?.cancel();
    _autoTyper?.cancel();
    if (_elapsedSeconds == 0) _elapsedSeconds = 1;
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
