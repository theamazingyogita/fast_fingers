# Typing test

## What it does
Shows a passage and measures how fast and accurately the user types it. The
clock starts on the first keystroke and runs for 60 seconds, or until the
passage is finished. An on screen keyboard lights up the key being pressed and
outlines the key the passage expects next. Correct characters turn green.
A passage typed in full with no mistakes ends with a celebration: a check badge, confetti and a
count up of the WPM.

## Flow
1. TypingScreen picks a random passage and focuses itself so keys arrive straight away
2. A key down event is passed to TypingSession.type, or backspace for Backspace
3. The first keystroke moves the session from ready to running and starts a one second ticker
4. Each change notifies listeners, which redraws the passage colours, stats and keyboard
5. Passage complete or time up moves the session to finished and the ResultPanel replaces the keyboard
6. Restart, or Esc, stops the clock and clears the current passage while a test is running
7. Try again restarts the session with a different passage
8. In debug builds, Test perfect run calls TypingSession.autoType, which restarts and types the passage with no mistakes

## Files
- lib/typing/typing_session.dart
- lib/typing/typing_constants.dart
- lib/typing/view/typing_screen.dart
- lib/typing/view/widgets/passage_view.dart
- lib/typing/view/widgets/stats_bar.dart
- lib/typing/view/widgets/on_screen_keyboard.dart
- lib/typing/view/widgets/key_cap.dart
- lib/typing/view/widgets/result_panel.dart
- lib/typing/view/widgets/success_badge.dart
- lib/typing/view/widgets/confetti_burst.dart
- lib/app_colors.dart

## States
TypingStatus.ready, TypingStatus.running, TypingStatus.finished

## Edge cases
- WPM counts only correct characters, five per word
- Accuracy is measured on what is currently typed, so fixing a mistake with backspace restores it
- Backspace before starting or after finishing does nothing
- Keys held with Ctrl or Cmd are ignored so browser shortcuts keep working
- WPM uses time measured to a tenth of a second, with a one second floor so the first keystrokes do not show a huge number
- The celebration only plays when the whole passage is typed with no mistakes, running out of time never counts as perfect
- Keys are ignored while the test run is typing, so it always ends with no mistakes
- The test button is hidden in release builds
- Tab is swallowed so focus cannot move to a button, which would leave keystrokes going nowhere while the clock runs
- Restart is disabled until the first keystroke
