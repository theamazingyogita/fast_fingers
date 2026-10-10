import 'dart:math';

import 'package:flutter/material.dart';

import 'key_cap.dart';

const backspaceKey = 'backspace';

const _rows = [
  ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', backspaceKey],
  ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']'],
  ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'"],
  ['z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/'],
  [' '],
];

const _shiftedToBase = {
  '!': '1',
  '@': '2',
  '#': '3',
  r'$': '4',
  '%': '5',
  '^': '6',
  '&': '7',
  '*': '8',
  '(': '9',
  ')': '0',
  '_': '-',
  '+': '=',
  '{': '[',
  '}': ']',
  ':': ';',
  '"': "'",
  '<': ',',
  '>': '.',
  '?': '/',
};

String keyFor(String character) =>
    _shiftedToBase[character] ?? character.toLowerCase();

class OnScreenKeyboard extends StatelessWidget {
  const OnScreenKeyboard({super.key, this.pressedKey, this.nextKey});

  final String? pressedKey;
  final String? nextKey;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 6.0;
        final keyWidth = min(56.0, (constraints.maxWidth - gap * 14) / 14.5);
        final keyHeight = keyWidth * 0.9;

        return Column(
          spacing: gap,
          children: [
            for (final row in _rows)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: gap,
                children: [
                  for (final key in row)
                    KeyCap(
                      label: switch (key) {
                        backspaceKey => '⌫',
                        ' ' => 'space',
                        _ => key,
                      },
                      width: switch (key) {
                        backspaceKey => keyWidth * 1.5,
                        ' ' => keyWidth * 6,
                        _ => keyWidth,
                      },
                      height: keyHeight,
                      isPressed: key == pressedKey,
                      isNext: key == nextKey,
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}
