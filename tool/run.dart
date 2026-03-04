import 'dart:io';

void main() async {
  // 1. Read your key from a local file (don't check this into git!)
  final envFile = File('.env');
  if (!await envFile.exists()) {
    print('Error: .env file missing');
    return;
  }

  final key = await envFile.readAsString();

  // 2. Read the index.html
  final htmlFile = File('web/index.html');
  String contents = await htmlFile.readAsString();

  // 3. Perform the replacement
  // Assumes you have MAPS_API_KEY_PLACEHOLDER in your index.html
  final updatedContents = contents.replaceAll('MAPS_API_KEY', key.trim());
  await htmlFile.writeAsString(updatedContents);

  print('✅ API Key injected into index.html');

  // 4. Start the flutter app
  final process = await Process.start(
    'flutter',
    ['run', '-d', 'chrome'],
    runInShell: true, // This is the magic flag
  );

  // Pipe the output to your terminal
  stdout.addStream(process.stdout);
  stderr.addStream(process.stderr);
}