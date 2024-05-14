import 'package:dart_console/dart_console.dart';

main() {
  final console = Console();

  console.clearScreen();
  console.resetCursorPosition();

  console.writeLine(
    'Console size is ${console.windowWidth} cols and ${console.windowHeight} rows.',
    TextAlignment.center,
  );

  console.writeLine();

  return 0;
}
