import 'package:fast_fingers/app_colors.dart';
import 'package:fast_fingers/typing/view/typing_screen.dart';
import 'package:fast_fingers/typing/view/widgets/confetti_burst.dart';
import 'package:fast_fingers/typing/view/widgets/key_cap.dart';
import 'package:fast_fingers/typing/view/widgets/success_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpScreen(WidgetTester tester, List<String> passages) async {
  tester.view.physicalSize = const Size(1400, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: TypingScreen(passages: passages)));
}

KeyCap _key(WidgetTester tester, String label) => tester.widget(
  find.ancestor(of: find.text(label), matching: find.byType(KeyCap)),
);

void main() {
  testWidgets('shows the prompt and full timer before typing', (tester) async {
    await _pumpScreen(tester, ['abc']);

    expect(find.text('Start typing to see how fast you are'), findsOneWidget);
    expect(find.text('1:00'), findsOneWidget);
    expect(_key(tester, 'a').isNext, isTrue);
  });

  testWidgets('typing runs the timer and animates the key', (tester) async {
    await _pumpScreen(tester, ['abc']);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyA, character: 'a');
    await tester.pump();
    expect(_key(tester, 'a').isPressed, isTrue);
    expect(_key(tester, 'b').isNext, isTrue);
    expect(find.text('Keep going!'), findsOneWidget);

    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyA);
    await tester.pump(const Duration(seconds: 2));
    expect(_key(tester, 'a').isPressed, isFalse);
    expect(find.text('0:58'), findsOneWidget);
  });

  testWidgets('a wrong key lowers accuracy', (tester) async {
    await _pumpScreen(tester, ['abc']);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyX, character: 'x');
    await tester.pumpAndSettle();

    expect(find.text('0%'), findsOneWidget);
    await tester.pump(const Duration(minutes: 1));
  });

  testWidgets('finishing shows results and try again restarts', (tester) async {
    await _pumpScreen(tester, ['ab']);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyA, character: 'a');
    await tester.sendKeyEvent(LogicalKeyboardKey.keyB, character: 'b');
    await tester.pumpAndSettle();

    expect(find.text('24 WPM'), findsOneWidget);
    expect(find.text('100% accuracy, 0 mistakes'), findsOneWidget);
    expect(find.byType(KeyCap), findsNothing);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Start typing to see how fast you are'), findsOneWidget);
  });

  testWidgets('time running out ends the test', (tester) async {
    await _pumpScreen(tester, ['abcdef']);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyA, character: 'a');
    await tester.pump(const Duration(minutes: 1));
    await tester.pumpAndSettle();

    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('0:00'), findsOneWidget);
  });

  testWidgets('correct characters are green', (tester) async {
    await _pumpScreen(tester, ['ab']);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyA, character: 'a');
    await tester.pump();

    final text = tester.widget<RichText>(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText() == 'ab',
      ),
    );
    final first = (text.text as TextSpan).children!.first as TextSpan;
    expect(first.style?.color, AppColors.dark.success);
    await tester.pump(const Duration(minutes: 1));
  });

  testWidgets('test button plays the perfect run celebration', (tester) async {
    await _pumpScreen(tester, ['abc']);

    await tester.tap(find.text('Test perfect run'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('Perfect!'), findsOneWidget);
    expect(find.byType(SuccessBadge), findsOneWidget);
    expect(find.byType(ConfettiBurst), findsOneWidget);
    expect(find.text('100% accuracy, 0 mistakes'), findsOneWidget);
  });

  testWidgets('keys are ignored during the test run', (tester) async {
    await _pumpScreen(tester, ['abcdef']);

    await tester.tap(find.text('Test perfect run'));
    await tester.sendKeyEvent(LogicalKeyboardKey.keyX, character: 'x');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Perfect!'), findsOneWidget);
  });

  testWidgets('a run with mistakes has no celebration', (tester) async {
    await _pumpScreen(tester, ['ab']);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyX, character: 'x');
    await tester.sendKeyEvent(LogicalKeyboardKey.keyB, character: 'b');
    await tester.pumpAndSettle();

    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Perfect!'), findsNothing);
    expect(find.byType(ConfettiBurst), findsNothing);
  });

  testWidgets('restart stops the clock and clears the text', (tester) async {
    await _pumpScreen(tester, ['abcdef']);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyA, character: 'a');
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('0:57'), findsOneWidget);

    await tester.tap(find.text('Restart (Esc)'));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('1:00'), findsOneWidget);
    expect(find.text('Start typing to see how fast you are'), findsOneWidget);
  });

  testWidgets('restart is disabled before typing starts', (tester) async {
    await _pumpScreen(tester, ['abc']);

    final button = tester.widget<ButtonStyleButton>(
      find.ancestor(
        of: find.text('Restart (Esc)'),
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
      ),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('escape restarts a running test', (tester) async {
    await _pumpScreen(tester, ['abcdef']);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyA, character: 'a');
    await tester.pump(const Duration(seconds: 2));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('1:00'), findsOneWidget);
  });

  testWidgets('escape stops the test run', (tester) async {
    await _pumpScreen(tester, ['abcdefghij']);

    await tester.tap(find.text('Test perfect run'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Start typing to see how fast you are'), findsOneWidget);
  });

  testWidgets('typing still works after clicking a button', (tester) async {
    await _pumpScreen(tester, ['abcdef']);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyA, character: 'a');
    await tester.tap(find.text('Restart (Esc)'));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA, character: 'a');
    await tester.pump();

    expect(find.text('Keep going!'), findsOneWidget);
    await tester.pump(const Duration(minutes: 1));
    await tester.pumpAndSettle();
  });
}
