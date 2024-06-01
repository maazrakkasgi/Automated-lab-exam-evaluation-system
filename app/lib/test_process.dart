import 'dart:io';
import 'dart:convert';

Future<void> main() async {
  // Path to the Python script
  const pythonScriptPath = 'lib\\cat.py';

  // Start the Python script process
  final process = await Process.start('python', [pythonScriptPath]);

  // Listen for outputs from the Python script
  process.stdout.transform(utf8.decoder).listen((data) {
    print('Python script says: $data');
  });

  // Listen for errors from the Python script
  process.stderr.transform(utf8.decoder).listen((data) {
    print('Python script error: $data');
  });

  // Listen for user input and send it to the Python script
  print('Please enter input for the Python script:');
  stdin.listen((input) {
    print(input.runtimeType);
    print(input);
    process.stdin.add(input);
    process.stdin.flush();
  });

  // Wait for the Python script to finish
  final exitCode = await process.exitCode;
  print('Python script exited with code: $exitCode');
  exit(0);
}
