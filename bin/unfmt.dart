import 'dart:io';

import 'package:args/args.dart';
import 'package:unfmt/unfmt.dart';

void main(List<String> args) async {
  var parser = ArgParser();

  void printUsageAndExit() {
    stderr.writeln('Usage: unfmt [-y] [-c <hash>] [path]\n');
    stderr.writeln(parser.usage);
    exit(1);
  }

  parser.addFlag(
    'yes', abbr: 'y',
    negatable: false,
    help: 'Automatically accept changes',
  );

  parser.addOption(
    'commit', abbr: 'c',
    valueHelp: 'hash',
    help: 'Which unformatted commit to diff against',
  );

  ArgResults res;

  try {
    res = parser.parse(args);
  } on FormatException catch (e) {
    stderr.writeln('Error: ${e.message}\n');
    printUsageAndExit();
  }

  var options = UnfmtOptions();

  options.workingDirectory = Directory.current.path;
  options.baseCommit = res['commit'];
  assert(options.baseCommit != null);

  printUsageAndExit();
}
