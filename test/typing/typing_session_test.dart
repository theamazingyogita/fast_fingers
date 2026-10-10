import 'package:fast_fingers/typing/typing_session.dart';
import 'package:fast_fingers/typing/typing_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('first keystroke starts the clock', (tester) async {
    final session = TypingSession(passage: 'hello world');

    expect(session.status, TypingStatus.ready);
    await tester.pump(const Duration(seconds: 3));
    expect(session.elapsedSeconds, 0);

    session.type('h');
    await tester.pump(const Duration(seconds: 3));
    expect(session.status, TypingStatus.running);
    expect(session.elapsedSeconds, 3);
    expect(session.remainingSeconds, 57);
    session.dispose();
  });

  testWidgets('counts correct characters and mistakes', (tester) async {
    final session = TypingSession(passage: 'hello world');

    for (final c in 'hexlo'.split('')) {
      session.type(c);
    }

    expect(session.correctCharacters, 4);
    expect(session.mistakes, 1);
    expect(session.accuracy, 80);
    expect(session.nextCharacter, ' ');
    session.dispose();
  });

  testWidgets('backspace removes a mistake', (tester) async {
    final session = TypingSession(passage: 'hello');

    session
      ..type('h')
      ..type('x')
      ..backspace()
      ..type('e');

    expect(session.typed, 'he');
    expect(session.mistakes, 0);
    session.dispose();
  });

  testWidgets('backspace does nothing before the test starts', (tester) async {
    final session = TypingSession(passage: 'hello');

    session.backspace();
    expect(session.typed, isEmpty);
    expect(session.status, TypingStatus.ready);
    session.dispose();
  });

  testWidgets('wpm uses five correct characters per word', (tester) async {
    final session = TypingSession(passage: 'a' * 100);

    for (var i = 0; i < 50; i++) {
      session.type('a');
    }
    await tester.pump(const Duration(seconds: 30));

    expect(session.wordsPerMinute, 20);
    session.dispose();
  });

  testWidgets('finishes when the passage is complete', (tester) async {
    final session = TypingSession(passage: 'hi');

    session
      ..type('h')
      ..type('i');

    expect(session.status, TypingStatus.finished);
    expect(session.isPerfect, isTrue);
    expect(session.wordsPerMinute, 24);
    session.type('x');
    expect(session.typed, 'hi');
    session.dispose();
  });

  testWidgets('finishes when time runs out', (tester) async {
    final session = TypingSession(
      passage: 'hello world',
      duration: const Duration(seconds: 5),
    );

    session.type('h');
    await tester.pump(const Duration(seconds: 5));

    expect(session.status, TypingStatus.finished);
    expect(session.remainingSeconds, 0);
    await tester.pump(const Duration(seconds: 5));
    expect(session.elapsedSeconds, 5);
    session.dispose();
  });

  testWidgets('restart resets everything', (tester) async {
    final session = TypingSession(passage: 'hi');

    session
      ..type('h')
      ..type('i')
      ..restart('new text');

    expect(session.passage, 'new text');
    expect(session.typed, isEmpty);
    expect(session.elapsedSeconds, 0);
    expect(session.status, TypingStatus.ready);
    session.dispose();
  });

  testWidgets('autoType finishes the passage with no mistakes', (tester) async {
    final session = TypingSession(passage: 'hello');

    session
      ..type('x')
      ..autoType(interval: const Duration(milliseconds: 100));
    expect(session.typed, isEmpty);
    expect(session.isAutoTyping, isTrue);

    await tester.pump(const Duration(milliseconds: 500));

    expect(session.status, TypingStatus.finished);
    expect(session.typed, 'hello');
    expect(session.accuracy, 100);
    expect(session.isAutoTyping, isFalse);
    session.dispose();
  });

  testWidgets('restart stops autoType', (tester) async {
    final session = TypingSession(passage: 'hello');

    session.autoType(interval: const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 200));
    session.restart('other');
    await tester.pump(const Duration(seconds: 1));

    expect(session.typed, isEmpty);
    expect(session.isAutoTyping, isFalse);
    session.dispose();
  });

  testWidgets('wpm counts partial seconds', (tester) async {
    final session = TypingSession(passage: 'a' * 100);

    session.type('a');
    await tester.pump(const Duration(milliseconds: 2500));
    for (var i = 0; i < 24; i++) {
      session.type('a');
    }

    expect(session.wordsPerMinute, 120);
    session.dispose();
  });

  testWidgets('a run without mistakes is only perfect when complete', (
    tester,
  ) async {
    final session = TypingSession(passage: 'hello');

    session
      ..type('h')
      ..type('e');
    expect(session.mistakes, 0);
    expect(session.isPerfect, isFalse);

    session
      ..type('l')
      ..type('l')
      ..type('x');
    expect(session.status, TypingStatus.finished);
    expect(session.isPerfect, isFalse);
    session.dispose();
  });
}
