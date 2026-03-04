import 'dart:io';
import 'package:properties/properties.dart';

void main() async {
  final htmlFile = File('web/index.html');
  try {
    ProcessSignal.sigint.watch().listen((signal) {
      print("Caught signal $signal, cleaning up...");
      // Perform cleanup here
      htmlFile.delete();
      exit(0); // Exit gracefully
    });

    // Listen for SIGTERM (Termination request)
    // ProcessSignal.sigterm.watch().listen((signal) {
    //   print("Caught signal $signal, shutting down...");
    //   // Perform cleanup here
    //   htmlFile.delete();
    //   exit(0);
    // });

    final properties = await Properties.fromFile(File('.env').path);
    final key = properties.get('MAPS_API_KEY');

    // 2. Read the index.html
    final htmlFileTemplate = File('web/index.html.template');
    String contents = await htmlFileTemplate.readAsString();

    // 3. Perform the replacement
    // Assumes you have MAPS_API_KEY in your index.html
    final updatedContents = contents.replaceAll('MAPS_API_KEY', key!);
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
  } catch (_) {
    htmlFile.delete();
  }
}